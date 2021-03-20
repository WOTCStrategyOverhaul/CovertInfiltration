//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Singleton manager that keeps track of covert actions expirations.
//           Mostly used for infiltration only
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CovertActionExpirationManager extends XComGameState_BaseObject;

var array<ActionExpirationInfo> ActionExpirationInfoList;

`include(CovertInfiltration\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

static function CreateExpirationManager(optional XComGameState StartState)
{
	local XComGameState NewGameState;

	if (StartState != none)
	{
		StartState.CreateNewStateObject(class'XComGameState_CovertActionExpirationManager');
	}
	else if (GetExpirationManager(true) == none)
	{// if we didn't send a gamestate and we don't have one yet make one from a newgamestate
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating expiration manager singleton");

		NewGameState.CreateNewStateObject(class'XComGameState_CovertActionExpirationManager');

		`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	}
}

static function Update()
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local array<ActionExpirationInfo> LocalActionExpirationInfoList;
	local array<XComGameState_CovertAction> ExpiringActions;
	local XComGameState_CovertAction CovertAction;
	local XComGameState NewGameState;

	local ActionExpirationInfo ExpirationInfo;
	local TDateTime CurrentTime, AdjustedTime;
	local bool WarnBeforeExpiration, bDirty;
	local int HoursBeforeWarning;

	ActionExpirationManager = GetExpirationManager(true); 
	if (ActionExpirationManager == none)
	{
		`RedScreenOnce("CI: Failed to fetch XComGameState_CovertActionExpirationManager for ticking");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Covert Action Expirations");
	ActionExpirationManager = XComGameState_CovertActionExpirationManager(NewGameState.ModifyStateObject(class'XComGameState_CovertActionExpirationManager', ActionExpirationManager.ObjectID));

	// Duplicate array to a local variable so that we can remove from ActionExpirationInfoList as we are iterating
	LocalActionExpirationInfoList = ActionExpirationManager.ActionExpirationInfoList;
	foreach LocalActionExpirationInfoList(ExpirationInfo)
	{
		CovertAction = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(ExpirationInfo.ActionRef.ObjectID));
		WarnBeforeExpiration = `GETMCMVAR(WARN_BEFORE_EXPIRATION);
		CurrentTime = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();

		if (CovertAction == none)
		{
			bDirty = true;
			ActionExpirationManager.RemoveActionExpirationInfo(ExpirationInfo);
			`log("Expiration manager removed action that no longer exists",, 'CI');
		}
		// if action started remove from expiration manager
		else if (CovertAction.bStarted)
		{
			bDirty = true;
			ActionExpirationManager.RemoveActionExpirationInfo(ExpirationInfo);
		}
		// if expiration has passed remove from expiration manager and delete the covert action
		else if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(ExpirationInfo.Expiration, CurrentTime))
		{
			bDirty = true;
			CovertAction = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', CovertAction.ObjectID));
			CovertAction.RemoveEntity(NewGameState);

			ActionExpirationManager.RemoveActionExpirationInfo(ExpirationInfo);
			`XEVENTMGR.TriggerEvent('CovertActionExpired', CovertAction, CovertAction, NewGameState); // Use CovertAction as source so that we can use native filtering
		}
		if (WarnBeforeExpiration && !ExpirationInfo.bAlreadyWarnedOfExpiration)
		{
			HoursBeforeWarning = `GETMCMVAR(HOURS_BEFORE_WARNING);
			AdjustedTime = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
			class'X2StrategyGameRulesetDataStructures'.static.AddHours(AdjustedTime, HoursBeforeWarning);

			if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(ExpirationInfo.Expiration, AdjustedTime))
			{
				bDirty = true;
				ActionExpirationManager.MarkAlreadyWarnedOfExpiration(ExpirationInfo.ActionRef);
				ExpiringActions.AddItem(CovertAction);
			}
		}
	}
	
	if (bDirty)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
	}

	foreach ExpiringActions(CovertAction)
	{
		if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(CovertAction))
		{
			class'UIUtilities_Infiltration'.static.InfiltrationExpiring(XComGameState_MissionSiteInfiltration(class'X2Helper_Infiltration'.static.GetMissionSiteFromAction(CovertAction)));
		}
		else
		{
			class'UIUtilities_Infiltration'.static.CovertActionExpiring(CovertAction);
		}
	}
}

static function XComGameState_CovertActionExpirationManager GetExpirationManager(optional bool AllowNull = false)
{
	return XComGameState_CovertActionExpirationManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CovertActionExpirationManager', AllowNull));
}

function static bool GetActionExpirationInfo(StateObjectReference ActionRef, optional out ActionExpirationInfo RequestedAction)
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local ActionExpirationInfo ExpirationInfo;

	ActionExpirationManager = GetExpirationManager();

	foreach ActionExpirationManager.ActionExpirationInfoList(ExpirationInfo)
	{
		if (ExpirationInfo.ActionRef == ActionRef)
		{
			RequestedAction = ExpirationInfo;
			return true;
		}
	}

	return false;
}

function AddActionExpirationInfo(StateObjectReference ActionRef, TDateTime Expiration, optional bool bBlockMonthlyCleanup = true)
{
	local ActionExpirationInfo ExpirationInfo;

	ExpirationInfo.ActionRef = ActionRef;
	ExpirationInfo.Expiration = Expiration;
	ExpirationInfo.OriginTime = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
	ExpirationInfo.bBlockMonthlyCleanup = bBlockMonthlyCleanup;

	ActionExpirationInfoList.AddItem(ExpirationInfo);
}

function RemoveActionExpirationInfo(ActionExpirationInfo ExpirationInfo)
{
	ActionExpirationInfoList.RemoveItem(ExpirationInfo);
}

function MarkAlreadyWarnedOfExpiration(StateObjectReference WarningRef)
{
	local int idx;
	
	for (idx = 0; idx < ActionExpirationInfoList.Length; idx++)
	{
		if (ActionExpirationInfoList[idx].ActionRef == WarningRef)
		{
			ActionExpirationInfoList[idx].bAlreadyWarnedOfExpiration = true;
		}
	}
}