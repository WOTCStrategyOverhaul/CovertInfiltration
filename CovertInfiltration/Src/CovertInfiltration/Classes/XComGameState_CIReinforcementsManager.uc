//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to control the delay of any reinforcements issued
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CIReinforcementsManager extends XComGameState_BaseObject;

var array<DelayedReinforcementSpawner> DelayedReinforcementSpawners;

var int NextReinforcementsArrival;
var int LastTurnModified;

var localized string m_strReinforcementsBodyWarning;
var localized string m_strReinforcementsBodyImminent;

static function CreateReinforcementsManager()
{
	local XComGameState NewGameState;

	if(GetReinforcementsManager(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating reinforcements manager singleton");

		NewGameState.CreateNewStateObject(class'XComGameState_CIReinforcementsManager');

		`TACTICALRULES.SubmitGameState(NewGameState);
	}
}

static function XComGameState_CIReinforcementsManager GetReinforcementsManager(optional bool AllowNull = false)
{
	return XComGameState_CIReinforcementsManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CIReinforcementsManager', AllowNull));
}

function AddDelayedReinforcementSpawner(DelayedReinforcementSpawner DelayedSpawner, optional XComGameState_CIReinforcementsManager ManagerState, optional bool bResetUpdate=false)
{
	local XComGameState NewGameState;

	if (ManagerState == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Deleting DelayedReinforcementSpawner from manager");

		ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ObjectID));
		ManagerState.DelayedReinforcementSpawners.AddItem(DelayedSpawner);

		`TACTICALRULES.SubmitGameState(NewGameState);
	}
	else
	{
		ManagerState.DelayedReinforcementSpawners.AddItem(DelayedSpawner);
	}

	if (bResetUpdate)
	{
		ManagerState.LastTurnModified = -1;
	}
}

function RemoveDelayedReinforcementSpawner(int idx, optional XComGameState_CIReinforcementsManager ManagerState)
{
	local XComGameState NewGameState;
	
	if (ManagerState == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Deleting DelayedReinforcementSpawner from manager");

		ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ObjectID));
		ManagerState.DelayedReinforcementSpawners.Remove(idx, 1);

		`TACTICALRULES.SubmitGameState(NewGameState);
	}
	else
	{
		ManagerState.DelayedReinforcementSpawners.Remove(idx, 1);
	}
}

function Update(optional int Threshold=1)
{
	local XComGameState NewGameState;
	local XComGameState_CIReinforcementsManager ManagerState;
	local DelayedReinforcementSpawner CurrentDRS;
	local int idx, CurrentTurn;
	local bool bRemovedSpawner;

	CurrentTurn = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData')).TacticalTurnCount;

	if (LastTurnModified == CurrentTurn)
	{// if we've been here already this turn, gtfo
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Reinforcements Manager");
	ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ObjectID));

	ManagerState.NextReinforcementsArrival = 0;
	for (idx = 0; idx < ManagerState.DelayedReinforcementSpawners.Length; idx++)
	{
		CurrentDRS = ManagerState.DelayedReinforcementSpawners[idx];
		CurrentDRS.TurnsUntilSpawn = CurrentDRS.TurnCreated + CurrentDRS.SpawnerDelay - CurrentTurn;

		if (CurrentDRS.TurnsUntilSpawn > Threshold && (CurrentDRS.TurnsUntilSpawn < NextReinforcementsArrival || NextReinforcementsArrival == 0))
		{
			ManagerState.NextReinforcementsArrival = CurrentDRS.TurnsUntilSpawn;
		}
		else if (CurrentDRS.TurnsUntilSpawn >= Threshold)
		{// removing via index works better for an array of structs
			RemoveDelayedReinforcementSpawner(idx, ManagerState);
			bRemovedSpawner = true;
		}
	}

	ManagerState.LastTurnModified = CurrentTurn;
	`TACTICALRULES.SubmitGameState(NewGameState);

	if (bRemovedSpawner)
	{
		class'XComGameState_AIReinforcementSpawner'.static.InitiateReinforcements(CurrentDRS.EncounterID, Threshold, , , 6, , , , , , , , true);
	}
}
