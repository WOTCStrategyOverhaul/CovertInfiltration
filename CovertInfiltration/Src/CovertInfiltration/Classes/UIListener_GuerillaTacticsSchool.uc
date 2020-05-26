//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class is used to call the tutorial popup when the player enters
//           the Gorilla Tactics School
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_GuerillaTacticsSchool extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIFacility_Academy FacilityGTS;
	
	FacilityGTS = UIFacility_Academy(Screen);
	if (FacilityGTS == none) return;

	class'UIUtilities_InfiltrationTutorial'.static.GuerillaTactics();
}