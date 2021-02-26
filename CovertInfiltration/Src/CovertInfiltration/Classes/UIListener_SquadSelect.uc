//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf, Xymanek
//  PURPOSE: This class is used to call the tutorial popups in the Squad Select screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_SquadSelect extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UISquadSelect SquadSelect;

	SquadSelect = UISquadSelect(Screen);
	if (SquadSelect == none) return;

	// Likely will never trigger as tired units are kicked out by default, but just in case
	TryMindshieldNerfTutorial();

	// Check that we are not inside SSAAT (check that this is not a CI or CA)
	if (class'SSAAT_Helpers'.static.GetCurrentConfiguration() != none) return;

	class'UIUtilities_InfiltrationTutorial'.static.AssaultLoadout();
}

event OnReceiveFocus(UIScreen Screen)
{
	local UISquadSelect SquadSelect;

	SquadSelect = UISquadSelect(Screen);
	if (SquadSelect == none) return;

	// After selecting a unit for an empty slot or coming back from unit loadout
	TryMindshieldNerfTutorial();
}

static protected function TryMindshieldNerfTutorial ()
{
	local StateObjectReference UnitRef;
	local XComGameState_Unit UnitState;

	if (!class'X2EventListener_Infiltration'.default.MindShieldOnTiredNerf_Enabled[`StrategyDifficultySetting])
	{
		return;
	}

	foreach `XCOMHQ.Squad(UnitRef)
	{
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
		if (UnitState == none) continue;
		if (!UnitState.BelowReadyWillState()) continue;

		if (class'X2EventListener_Infiltration'.static.UnitHasMindshieldNerfItem(UnitRef))
		{
			class'UIUtilities_InfiltrationTutorial'.static.MindShieldOnTiredNerf();
			return;
		}
	}
}