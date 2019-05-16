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
		if (DelayedReinforcementOrders[idx].TurnsUntilSpawn > Threshold)
		{
			DelayedReinforcementOrders[idx].TurnsUntilSpawn--;
		}
	}
}

function bool GetNextOrder(out DelayedReinforcementOrder NextDRO)
{
	local DelayedReinforcementOrder CurrentDRO;

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
			return true;
		}
	}

	return false;
}

static function int GetNextReinforcements()
{
	local XComGameState NewGameState;
	local XComGameState_CIReinforcementsManager ManagerState;
	local DelayedReinforcementOrder NextDRO, NewDRO;
	local bool bOrderCompleted;

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
		bOrderCompleted = ManagerState.GetNextOrder(NextDRO);
		ManagerState.bNeedsUpdate = false;

		`TACTICALRULES.SubmitGameState(NewGameState);

		if (bOrderCompleted)
		{// we need a fresh gamestate to do this
			class'XComGameState_AIReinforcementSpawner'.static.InitiateReinforcements(NextDRO.EncounterID, default.Threshold, , , 6, , , , , , , , true);

			if (NextDRO.Repeating)
			{	
				NewDRO.EncounterID = NextDRO.EncounterID;
				NewDRO.TurnsUntilSpawn = NextDRO.RepeatTime + 1;
				NewDRO.Repeating = true;
				NewDRO.RepeatTime = NextDRO.RepeatTime;
				
				ManagerState.DelayedReinforcementOrders.AddItem(NewDRO);
			}
		}
	}
	else
	{
		ManagerState.GetNextOrder(NextDRO);
	}

	return NextDRO.TurnsUntilSpawn;
}

defaultproperties 
{
	bTacticalTransient=true
	Threshold=1
}