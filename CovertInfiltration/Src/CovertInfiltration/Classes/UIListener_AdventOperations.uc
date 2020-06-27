//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Prevents UIAdventOperations from showing orders screen on month end if
//           ring isn't built yet and shows a tutorial popup
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_AdventOperations extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	local UIAdventOperations AdventOperations;

	AdventOperations = UIAdventOperations(Screen);
	if (AdventOperations == none) return;

	if (AdventOperations.bResistanceReport && `XCOMHQ.GetFacilityByName('ResistanceRing') == none)
	{
		AdventOperations.AddOnRemovedDelegate(DisableResistanceReportMode);
	}
	
	AdventOperations.bHideOnLoseFocus = false;
	class'UIUtilities_InfiltrationTutorial'.static.DarkEventPreview();
	AdventOperations.bHideOnLoseFocus = true;
}

static protected function DisableResistanceReportMode (UIPanel Panel)
{
	local UIAdventOperations AdventOperations;

	AdventOperations = UIAdventOperations(Panel);
	AdventOperations.bResistanceReport = false;
}

event OnReceiveFocus (UIScreen Screen)
{
	local UIAdventOperations AdventOperations;

	AdventOperations = UIAdventOperations(Screen);
	if (AdventOperations == none) return;

	// Fix missing "continue" button after the DEs tutorial
	AdventOperations.RefreshNav();
}
