//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to control the delay of any reinforcements issued
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CIReinforcementsManager extends XComGameState_BaseObject;

var array<DelayedReinforcementSpawner> DelayedReinforcementSpawners;

var protectedwrite bool bNeedsUpdate;
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

function DelayedReinforcementSpawner GetNextDelayedReinforcementSpawner(optional bool bUpdate=true)
{
	local XComGameState_AIReinforcementSpawner ReinforcementSpawner;
	local DelayedReinforcementSpawner CurrentDRS, IncomingDRS;
	local int idx;

	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AIReinforcementSpawner', ReinforcementSpawner)
	{
		if (ReinforcementSpawner.Countdown > 0)
		{
			if (IncomingDRS.TurnsUntilSpawn > ReinforcementSpawner.Countdown || IncomingDRS.TurnsUntilSpawn == 0)
			{
				IncomingDRS.TurnsUntilSpawn = ReinforcementSpawner.Countdown;
			}
		}
	}

	if (bUpdate)
	{
		for (idx = 0; idx < DelayedReinforcementSpawners.Length; idx++)
		{
			if (DelayedReinforcementSpawners[idx].TurnsUntilSpawn > 1)
			{
				DelayedReinforcementSpawners[idx].TurnsUntilSpawn--;
			}
		}
	}

	if (IncomingDRS.TurnsUntilSpawn == 0)
	{// if we found another spawner skip all this (essentially.. pause)
		foreach DelayedReinforcementSpawners(CurrentDRS)
		{
			if (CurrentDRS.TurnsUntilSpawn > Threshold && (CurrentDRS.TurnsUntilSpawn < IncomingDRS.TurnsUntilSpawn || IncomingDRS.TurnsUntilSpawn == 0))
			{
				IncomingDRS = CurrentDRS;
			}
			else if (CurrentDRS.TurnsUntilSpawn <= Threshold)
			{
				IncomingDRS = CurrentDRS;
				DelayedReinforcementSpawners.RemoveItem(CurrentDRS);
				break;
			}
		}
	}

	return IncomingDRS;
}

static function bool SetCountdownDisplay(XComLWTuple Tuple)
{
	local XComGameState NewGameState;
	local XComGameState_CIReinforcementsManager ManagerState;
	local DelayedReinforcementSpawner NextDRS;
	local XGParamTag kTag;

	ManagerState = GetReinforcementsManager(true);

	if (ManagerState == none)
	{
		return false;
	}

	if (ManagerState.bNeedsUpdate)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Reinforcements Manager");
		ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));

		NextDRS = ManagerState.GetNextDelayedReinforcementSpawner();
		ManagerState.bNeedsUpdate = false;

		`TACTICALRULES.SubmitGameState(NewGameState);

		if (NextDRS.TurnsUntilSpawn == default.Threshold && NextDRS.EncounterID != '')
		{// we need a fresh gamestate to do this
			class'XComGameState_AIReinforcementSpawner'.static.InitiateReinforcements(NextDRS.EncounterID, default.Threshold, , , 6, , , , , , , , true);
		}
	}
	else
	{
		NextDRS = ManagerState.GetNextDelayedReinforcementSpawner(false);
	}

	if (NextDRS.TurnsUntilSpawn > 2)
	{
		kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		kTag.StrValue0 = string(NextDRS.TurnsUntilSpawn);

		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Good);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(`XEXPAND.ExpandString(default.m_strReinforcementsBodyWarning), eUIState_Good);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Good);
	}
	else if (NextDRS.TurnsUntilSpawn > 1)
	{
		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Warning);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(default.m_strReinforcementsBodyImminent, eUIState_Warning);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Warning);
	}
	else if (NextDRS.TurnsUntilSpawn > 0)
	{
		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Bad);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsBody, eUIState_Bad);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Bad);
	}
	else
	{
		return false;
	}

	return true;
}

defaultproperties 
{
	Threshold=1
}
