//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to control the delay of any reinforcements issued
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CIReinforcementsManager extends XComGameState_BaseObject;

var array<DelayedReinforcementSpawner> DelayedReinforcementSpawners;

var protectedwrite int NextReinforcements;
var const int Threshold;

var localized string m_strReinforcementsBodyWarning;
var localized string m_strReinforcementsBodyImminent;

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
	`XEVENTMGR.RegisterForEvent(ThisObj, 'PlayerTurnBegun', OnPlayerTurnBegun, ELD_Immediate, , PlayerState);
}

function EventListenerReturn OnPlayerTurnBegun(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_CIReinforcementsManager ManagerState;
	local name EncounterID;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Reinforcements Manager");
	ManagerState = GetReinforcementsManager();
	ManagerState = XComGameState_CIReinforcementsManager(GameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));

	ManagerState.UpdateNextReinforcements(EncounterID);

	`TACTICALRULES.SubmitGameState(NewGameState);

	if (EncounterID != '')
	{// we need a fresh gamestate to do this
		class'XComGameState_AIReinforcementSpawner'.static.InitiateReinforcements(EncounterID, Threshold, , , 6, , , , , , , , true);
	}

	return ELR_NoInterrupt;
}

static function XComGameState_CIReinforcementsManager GetReinforcementsManager(optional bool AllowNull = false)
{
	return XComGameState_CIReinforcementsManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CIReinforcementsManager', AllowNull));
}

function UpdateNextReinforcements(out name EncounterID)
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

	if (IncomingReinforcements == 0)
	{// if we found another spawner skip all this (essentially.. pause)
		for (idx = 0; idx < DelayedReinforcementSpawners.Length; idx++)
		{
			DelayedReinforcementSpawners[idx].TurnsUntilSpawn--;
			CurrentDRS = DelayedReinforcementSpawners[idx];
			
			if (CurrentDRS.TurnsUntilSpawn > Threshold && (CurrentDRS.TurnsUntilSpawn < IncomingReinforcements || IncomingReinforcements == 0))
			{
				IncomingReinforcements = CurrentDRS.TurnsUntilSpawn;
			}
			else if (CurrentDRS.TurnsUntilSpawn >= Threshold)
			{
				DelayedReinforcementSpawners.Remove(idx, 1);
				IncomingReinforcements = Threshold;
				EncounterID = CurrentDRS.EncounterID;
			}
		}
	}

	NextReinforcements = IncomingReinforcements;
}

function bool GetCountdownDisplay(out XComLWTuple Tuple)
{
	local XGParamTag kTag;

	if (NextReinforcements == 0)
	{
		return false;
	}
	else if (NextReinforcements > 2)
	{
		kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		kTag.StrValue0 = string(NextReinforcements);

		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Good);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(`XEXPAND.ExpandString(default.m_strReinforcementsBodyWarning), eUIState_Good);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Good);
	}
	else if (NextReinforcements > 1)
	{
		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Warning);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(default.m_strReinforcementsBodyImminent, eUIState_Warning);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Warning);
	}
	else
	{
		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Bad);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsBody, eUIState_Bad);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Bad);
	}

	return true;
}

defaultproperties 
{
	Threshold=1
}
