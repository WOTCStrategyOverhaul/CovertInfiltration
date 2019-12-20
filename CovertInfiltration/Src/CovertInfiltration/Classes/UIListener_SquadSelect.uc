//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class is used to call the tutorial popup when the player enters loadout
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_SquadSelect extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UISquadSelect SquadSelect;

	SquadSelect = UISquadSelect(Screen);
	if (SquadSelect == none) return;

	// Check that we are not inside SSAAT (check that this is not a CI or CA)
	if (class'SSAAT_Helpers'.static.GetCurrentConfiguration() != none) return;

	class'UIUtilities_InfiltrationTutorial'.static.AssaultLoadout();
}