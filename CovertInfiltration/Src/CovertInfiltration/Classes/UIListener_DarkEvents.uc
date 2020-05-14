//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class is used to call the tutorial popup when the player is shown the
//           next month's pending dark events
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_DarkEvents extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIAdventOperations AdventOperations;
	
	AdventOperations = UIAdventOperations(Screen);
	if (AdventOperations == none) return;

	AdventOperations.bHideOnLoseFocus = false;
	class'UIUtilities_InfiltrationTutorial'.static.DarkEventPreview();
	AdventOperations.bHideOnLoseFocus = true;
}