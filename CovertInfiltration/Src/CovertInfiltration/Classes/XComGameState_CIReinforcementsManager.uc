//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to control the delay of any reinforcements issued
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CIReinforcementsManager extends XComGameState_BaseObject;

var array<DelayedReinforcementOrder> DelayedReinforcementOrders;

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
	local DelayedReinforcementOrder DRO, NewDRO;
	local array<DelayedReinforcementOrder> PendingDROs;
	local int idx;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Reinforcements Manager");
	ManagerState = GetReinforcementsManager();
	ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));

	// Decrement the countdown and start those which are at the threshold
	for (idx = 0; idx < ManagerState.DelayedReinforcementOrders.Length; idx++)
	{
		ManagerState.DelayedReinforcementOrders[idx].TurnsUntilSpawn--;

		if (ManagerState.DelayedReinforcementOrders[idx].TurnsUntilSpawn <= Threshold)
		{
			PendingDROs.AddItem(ManagerState.DelayedReinforcementOrders[idx]);

			ManagerState.DelayedReinforcementOrders.Remove(idx, 1); // TODO: Check
			idx--;
		}
	}

	// Queue the ones which are repeating and were started
	foreach PendingDROs(DRO)
	{
		if (DRO.Repeating)
		{	
			NewDRO.EncounterID = DRO.EncounterID;
			NewDRO.TurnsUntilSpawn = DRO.RepeatTime + 1;
			NewDRO.Repeating = true;
			NewDRO.RepeatTime = DRO.RepeatTime;
				
			ManagerState.DelayedReinforcementOrders.AddItem(NewDRO);
		}
	}

	`TACTICALRULES.SubmitGameState(NewGameState);

	// We need a fresh gamestate to do this
	foreach PendingDROs(DRO)
	{
		class'XComGameState_AIReinforcementSpawner'.static.InitiateReinforcements(DRO.EncounterID, default.Threshold, , , 6, , , , , , , , true);
	}

	return ELR_NoInterrupt;
}

static function XComGameState_CIReinforcementsManager GetReinforcementsManager(optional bool AllowNull = false)
{
	return XComGameState_CIReinforcementsManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CIReinforcementsManager', AllowNull));
}

function bool GetNextOrder(out DelayedReinforcementOrder NextDRO)
{
	local DelayedReinforcementOrder CurrentDRO;

	// Reset just in case
	NextDRO = CurrentDRO;

	foreach DelayedReinforcementOrders(CurrentDRO)
	{
		if (CurrentDRO.TurnsUntilSpawn < NextDRO.TurnsUntilSpawn || NextDRO.TurnsUntilSpawn == 0)
		{
			NextDRO = CurrentDRO;
		}
	}

	return false;
}

static function int GetNextReinforcements (optional XComGameState AssociatedGameState)
{
	local XComGameState_CIReinforcementsManager ManagerState;
	local DelayedReinforcementOrder NextDRO;

	ManagerState = GetReinforcementsManager(true);

	if (ManagerState == none)
	{
		return 0;
	}

	if (AssociatedGameState != none)
	{
		ManagerState = XComGameState_CIReinforcementsManager(`XCOMHISTORY.GetGameStateForObjectID(ManagerState.ObjectID,, AssociatedGameState.HistoryIndex));
	}

	ManagerState.GetNextOrder(NextDRO);

	return NextDRO.TurnsUntilSpawn;
}

defaultproperties 
{
	bTacticalTransient=true
	Threshold=1
}