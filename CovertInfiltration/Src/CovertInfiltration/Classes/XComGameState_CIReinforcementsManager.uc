//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to control the delay of any reinforcements issued
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CIReinforcementsManager extends XComGameState_BaseObject;

var array<DelayedReinforcementOrder> DelayedReinforcementOrders;

var protectedwrite bool bNeedsUpdate;
var const int Threshold;

static function CreateReinforcementsManager()
{
	local XComGameState NewGameState;
	local XComGameState_Player PlayerState;
	local Object ThisObj;

	if (GetReinforcementsManager(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating reinforcements manager singleton");

		NewGameState.CreateNewStateObject(class'XComGameState_CIReinforcementsManager');

		`TACTICALRULES.SubmitGameState(NewGameState);
	}

	PlayerState = class'XComGameState_Player'.static.GetPlayerState(eTeam_XCom);
	ThisObj = GetReinforcementsManager();
	`XEVENTMGR.RegisterForEvent(ThisObj, 'PlayerTurnBegun', OnPlayerTurnBegun, ELD_OnStateSubmitted, , PlayerState);
}

function EventListenerReturn OnPlayerTurnBegun(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_CIReinforcementsManager ManagerState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Reinforcements Manager");
	ManagerState = GetReinforcementsManager();
	ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));

	ManagerState.bNeedsUpdate = true;

	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

static function XComGameState_CIReinforcementsManager GetReinforcementsManager(optional bool AllowNull = false)
{
	return XComGameState_CIReinforcementsManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CIReinforcementsManager', AllowNull));
}

function Update()
{
	local int idx;

	for (idx = 0; idx < DelayedReinforcementOrders.Length; idx++)
	{
		if (DelayedReinforcementOrders[idx].TurnsUntilSpawn > 1)
		{
			DelayedReinforcementOrders[idx].TurnsUntilSpawn--;
		}
	}
}

function DelayedReinforcementOrder GetNextOrder()
{
	local DelayedReinforcementOrder CurrentDRO, NextDRO;

	foreach DelayedReinforcementOrders(CurrentDRO)
	{
		if (CurrentDRO.TurnsUntilSpawn > Threshold && (CurrentDRO.TurnsUntilSpawn < NextDRO.TurnsUntilSpawn || NextDRO.TurnsUntilSpawn == 0))
		{
			NextDRO = CurrentDRO;
		}
		else if (CurrentDRO.TurnsUntilSpawn <= Threshold)
		{
			NextDRO = CurrentDRO;
			DelayedReinforcementOrders.RemoveItem(CurrentDRO);
			break;
		}
	}

	return NextDRO;
}

static function int GetNextReinforcements()
{
	local XComGameState NewGameState;
	local XComGameState_CIReinforcementsManager ManagerState;
	local DelayedReinforcementOrder NextDRO;

	ManagerState = GetReinforcementsManager(true);

	if (ManagerState == none)
	{
		return 0;
	}

	if (ManagerState.bNeedsUpdate)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Reinforcements Manager");
		ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));

		ManagerState.Update();
		NextDRO = ManagerState.GetNextOrder();
		ManagerState.bNeedsUpdate = false;

		`TACTICALRULES.SubmitGameState(NewGameState);

		if (NextDRO.TurnsUntilSpawn <= default.Threshold && NextDRO.EncounterID != '')
		{// we need a fresh gamestate to do this
			class'XComGameState_AIReinforcementSpawner'.static.InitiateReinforcements(NextDRO.EncounterID, default.Threshold, , , 6, , , , , , , , true);
		}
	}
	else
	{
		NextDRO = ManagerState.GetNextOrder();
	}

	return NextDRO.TurnsUntilSpawn;
}

defaultproperties 
{
	bTacticalTransient=true
	Threshold=1
}
