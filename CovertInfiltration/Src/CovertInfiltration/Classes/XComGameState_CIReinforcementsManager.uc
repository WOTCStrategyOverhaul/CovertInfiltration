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

static function CreateReinforcementsManager(optional XComGameState GameState)
{
	local XComGameState NewGameState;

	if (GameState != none)
	{
		GameState.CreateNewStateObject(class'XComGameState_CIReinforcementsManager');
	}

	if (GetReinforcementsManager(true) == none)
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

function AddDelayedReinforcementSpawner(DelayedReinforcementSpawner DelayedSpawner)
{
	DelayedReinforcementSpawners.AddItem(DelayedSpawner);
}

function RemoveDelayedReinforcementSpawner(DelayedReinforcementSpawner DelayedSpawner)
{
	DelayedReinforcementSpawners.RemoveItem(DelayedSpawner);
}

function Update(optional int Threshold=1)
{
	local XComGameState NewGameState;
	local XComGameState_AIReinforcementSpawner ReinforcementSpawner;
	local DelayedReinforcementSpawner CurrentDRS;
	local int idx, CurrentTurn;

	CurrentTurn = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData')).TacticalTurnCount;

	if (LastTurnModified == CurrentTurn)
	{// if we've been here already this turn, gtfo
		return;
	}

	NextReinforcementsArrival = 0;
	for (idx = 0; idx < DelayedReinforcementSpawners.Length; idx++)
	{
		CurrentDRS = DelayedReinforcementSpawners[idx];
		CurrentDRS.TurnsUntilSpawn = CurrentDRS.TurnCreated + CurrentDRS.SpawnerDelay - CurrentTurn;

		if (CurrentDRS.TurnsUntilSpawn > Threshold && (CurrentDRS.TurnsUntilSpawn < NextReinforcementsArrival || NextReinforcementsArrival == 0))
		{
			NextReinforcementsArrival = CurrentDRS.TurnsUntilSpawn;
		}
		else if (CurrentDRS.TurnsUntilSpawn <= Threshold)
		{
			class'XComGameState_AIReinforcementSpawner'.static.InitiateReinforcements(CurrentDRS.EncounterID, Threshold, , , 6, , , , , , , , true);

			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Deleting DelayedReinforcementSpawner from manager");
			
			RemoveDelayedReinforcementSpawner(CurrentDRS);

			`TACTICALRULES.SubmitGameState(NewGameState);
		}
	}

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AIReinforcementSpawner', ReinforcementSpawner)
	{// quick pass on any non-managed RNF spawners to ensure we have the very next rnf deployment
		if (ReinforcementSpawner.Countdown < NextReinforcementsArrival)
		{
			NextReinforcementsArrival = ReinforcementSpawner.Countdown;
		}
	}

	LastTurnModified = CurrentTurn;
}