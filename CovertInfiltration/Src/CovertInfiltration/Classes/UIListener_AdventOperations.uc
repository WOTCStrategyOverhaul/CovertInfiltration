//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Prevents UIAdventOperations from showing orders screen on month end if
//           ring isn't built yet
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
		AdventOperations.AddOnRemovedDelegate(DisableResiatnceReportMode);
	}
}

static protected function DisableResiatnceReportMode (UIPanel Panel)
{
	local UIAdventOperations AdventOperations;

	AdventOperations = UIAdventOperations(Panel);
	AdventOperations.bResistanceReport = false;
}