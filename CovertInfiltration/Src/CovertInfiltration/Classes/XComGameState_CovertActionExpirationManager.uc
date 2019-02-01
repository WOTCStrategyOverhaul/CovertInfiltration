//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to keep track of covert infiltration expirations
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CovertActionExpirationManager extends XComGameState_BaseObject;

var array<ActionExpirationInfo> ActionExpirationInfoList;

static function CreateExpirationManager(optional XComGameState StartState)
{
	local XComGameState NewGameState;

	// create a manager on new campaign
	if (StartState != none)
	{
		StartState.CreateNewStateObject(class'XComGameState_CovertActionExpirationManager');
	}
	// seems this never runs cuz reasons
	if (GetExpirationManager(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating expiration manager singleton");

		NewGameState.CreateNewStateObject(class'XComGameState_CovertActionExpirationManager');

		`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	}
}

static function Update()
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local XComGameState_CovertAction CovertAction;
	local XComGameState NewGameState;

	local ActionExpirationInfo ExpirationInfo;
	local bool bDirty;

	ActionExpirationManager = GetExpirationManager(true); 
	if (ActionExpirationManager == none)
	{
		`RedScreenOnce("CI: Failed to fetch XComGameState_CovertActionExpirationManager for ticking");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Covert Action Expirations");
	ActionExpirationManager = XComGameState_CovertActionExpirationManager(NewGameState.ModifyStateObject(class'XComGameState_CovertActionExpirationManager', ActionExpirationManager.ObjectID));

	foreach ActionExpirationManager.ActionExpirationInfoList(ExpirationInfo)
	{
		CovertAction = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(ExpirationInfo.ActionRef.ObjectID));

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
		else if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(ExpirationInfo.Expiration, class'XComGameState_GeoscapeEntity'.static.GetCurrentTime()))
		{
			bDirty = true;
			CovertAction = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', CovertAction.ObjectID));
			CovertAction.RemoveEntity(NewGameState);

			ActionExpirationManager.RemoveActionExpirationInfo(ExpirationInfo);
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

function AddActionExpirationInfo(StateObjectReference ActionRef, TDateTime Expiration)
{
	local ActionExpirationInfo ExpirationInfo;

	ExpirationInfo.ActionRef = ActionRef;
	ExpirationInfo.Expiration = Expiration;
	ExpirationInfo.OriginTime = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();

	ActionExpirationInfoList.AddItem(ExpirationInfo);
}

function RemoveActionExpirationInfo(ActionExpirationInfo ExpirationInfo)
{
	ActionExpirationInfoList.RemoveItem(ExpirationInfo);
}