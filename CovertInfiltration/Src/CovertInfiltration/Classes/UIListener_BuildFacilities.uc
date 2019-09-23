//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Triggers the tutorial message
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_BuildFacilities extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	local UIBuildFacilities BuildFacilitiesScreen;

	BuildFacilitiesScreen = UIBuildFacilities(Screen);
	if (BuildFacilitiesScreen == none) return;

	class'UIUtilities_InfiltrationTutorial'.static.FacilityChanges();
}