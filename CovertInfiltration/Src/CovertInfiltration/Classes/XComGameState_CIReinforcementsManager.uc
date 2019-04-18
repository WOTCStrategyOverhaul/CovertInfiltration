//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to control the delay of any reinforcements issued
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CIReinforcementsManager extends XComGameState_BaseObject;

var array<DelayedReinforcementSpawner> DelayedReinforcementSpawners;

var int NextReinforcements;
var int Threshold;

var string CountdownDisplayTitle;
var string CountdownDisplayBody;
var string CountdownDisplayColor;

var localized string m_strReinforcementsBodyWarningPrefix;
var localized string m_strReinforcementsBodyWarningSuffix;
var localized string m_strReinforcementsBodyImminent;

static function CreateReinforcementsManager()
{
	local XComGameState NewGameState;
	local Object ThisObj;

	if (GetReinforcementsManager(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating reinforcements manager singleton");

		NewGameState.CreateNewStateObject(class'XComGameState_CIReinforcementsManager');

		`TACTICALRULES.SubmitGameState(NewGameState);
	}

	ThisObj = GetReinforcementsManager();
	`XEVENTMGR.RegisterForEvent(ThisObj, 'PlayerTurnBegun', OnPlayerTurnBegun, ELD_OnStateSubmitted);
}

function EventListenerReturn OnPlayerTurnBegun(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_CIReinforcementsManager ManagerState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Reinforcements Manager");
	ManagerState = GetReinforcementsManager();
	ManagerState = XComGameState_CIReinforcementsManager(GameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));

	ManagerState.UpdateNextReinforcements();
	ManagerState.UpdateCountdownDisplay();

	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

static function XComGameState_CIReinforcementsManager GetReinforcementsManager(optional bool AllowNull = false)
{
	return XComGameState_CIReinforcementsManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CIReinforcementsManager', AllowNull));
}

function UpdateNextReinforcements(optional bool bSkipReduction=false)
{
	local XComGameState_AIReinforcementSpawner ReinforcementSpawner;
	local DelayedReinforcementSpawner CurrentDRS;
	local int idx, IncomingReinforcements;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AIReinforcementSpawner', ReinforcementSpawner)
	{
		if (ReinforcementSpawner.Countdown > 0)
		{
			if (IncomingReinforcements > ReinforcementSpawner.Countdown || IncomingReinforcements == 0)
			{
				IncomingReinforcements = ReinforcementSpawner.Countdown;
			}
		}
	}
	`CI_Log(DelayedReinforcementSpawners.Length);
	if (IncomingReinforcements == 0)
	{// if we found another spawner skip all this (essentially.. pause)
		for (idx = 0; idx < DelayedReinforcementSpawners.Length; idx++)
		{
			CurrentDRS = DelayedReinforcementSpawners[idx];
			
			if (!bSkipReduction)
			{// this is purely to update the UI mid-turn
				CurrentDRS.TurnsUntilSpawn--;
			}
			
			if (CurrentDRS.TurnsUntilSpawn > Threshold && (CurrentDRS.TurnsUntilSpawn < IncomingReinforcements || IncomingReinforcements == 0))
			{
				IncomingReinforcements = CurrentDRS.TurnsUntilSpawn;
			}
			else if (CurrentDRS.TurnsUntilSpawn == Threshold)
			{
				DelayedReinforcementSpawners.Remove(idx, 1);
				IncomingReinforcements = Threshold;
				class'XComGameState_AIReinforcementSpawner'.static.InitiateReinforcements(CurrentDRS.EncounterID, Threshold, , , 6, , , , , , , , true);
			}
		}
	}

	NextReinforcements = IncomingReinforcements;
}

function UpdateCountdownDisplay()
{
	if (NextReinforcements > 2)
	{
		CountdownDisplayTitle = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Good);
		CountdownDisplayBody = class'UIUtilities_Text'.static.GetColoredText(m_strReinforcementsBodyWarningPrefix @ NextReinforcements @ m_strReinforcementsBodyWarningSuffix, eUIState_Good);
		CountdownDisplayColor = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Good);
	}
	else if (NextReinforcements > 1)
	{
		CountdownDisplayTitle = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Warning);
		CountdownDisplayBody = class'UIUtilities_Text'.static.GetColoredText(m_strReinforcementsBodyImminent, eUIState_Warning);
		CountdownDisplayColor = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Warning);
	}
	else
	{
		CountdownDisplayTitle = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Bad);
		CountdownDisplayBody = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsBody, eUIState_Bad);
		CountdownDisplayColor = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Bad);
	}
}

static function bool CheckForReinforcements(out XComLWTuple Tuple, XComGameState_CIReinforcementsManager ManagerState)
{
	if (ManagerState.NextReinforcements == 0)
	{
		return false;
	}

	Tuple.Data[1].s = ManagerState.CountdownDisplayTitle;
	Tuple.Data[2].s = ManagerState.CountdownDisplayBody;
	Tuple.Data[3].s = ManagerState.CountdownDisplayColor;

	return true;
}

defaultproperties 
{
	Threshold=1
}
