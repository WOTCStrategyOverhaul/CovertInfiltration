//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to keep track of covert infiltration expirations
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CovertActionExpirationManager extends XComGameState_BaseObject;

struct ExpiringAction
{
	var() StateObjectReference	ActionRef;
	var() TDateTime				Expiration;
	var() TDateTime				OriginTime;
};
var() array<ExpiringAction>		ExpiringActions;

static function CreateExpirationManager(optional XComGameState StartState)
{
	local XComGameState NewGameState;

	// create a manager on new campaign
	if (StartState != none)
	{
		XComGameState_CovertActionExpirationManager(StartState.CreateNewStateObject(class'XComGameState_CovertActionExpirationManager'));
	}
	// seems this never runs cuz reasons
	if (GetExpirationManager(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating expiration manager singleton");

		XComGameState_CovertActionExpirationManager(NewGameState.CreateNewStateObject(class'XComGameState_CovertActionExpirationManager'));

		`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	}
}

static function Update()
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local XComGameState_CovertAction CovertAction;
	local XComGameState NewGameState;

	local ExpiringAction CurrentAction;

	ActionExpirationManager = GetExpirationManager();

	foreach ActionExpirationManager.ExpiringActions(CurrentAction)
	{
		CovertAction = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(CurrentAction.ActionRef.ObjectID));

		// if expiration has passed remove the covert infiltration
		if (CovertAction.bStarted || class'X2StrategyGameRulesetDataStructures'.static.LessThan(CurrentAction.Expiration, class'XComGameState_GeoscapeEntity'.static.GetCurrentTime()))
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Covert Action Expirations");
			
			if (!CovertAction.bStarted)
			{
				CovertAction.RemoveEntity(NewGameState);
			}

			ActionExpirationManager.RemoveActionExpiration(CurrentAction);
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		}
	}
}

static function XComGameState_CovertActionExpirationManager GetExpirationManager(optional bool AllowNull = false)
{
	return XComGameState_CovertActionExpirationManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CovertActionExpirationManager', AllowNull));
}

function ExpiringAction GetActionExpiration(StateObjectReference ActionRef)
{
	local ExpiringAction CurrentAction;

	foreach ExpiringActions(CurrentAction)
	{
		if (CurrentAction.ActionRef == ActionRef)
		{
			return CurrentAction;
		}
	}
}

function AddActionExpiration(StateObjectReference ActionRef, TDateTime Expiration)
{
	local ExpiringAction CurrentAction;

	CurrentAction.ActionRef = ActionRef;
	CurrentAction.Expiration = Expiration;
	CurrentAction.OriginTime = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();

	ExpiringActions.AddItem(CurrentAction);
}

function RemoveActionExpiration(ExpiringAction CurrentAction)
{
	ExpiringActions.RemoveItem(CurrentAction);
}