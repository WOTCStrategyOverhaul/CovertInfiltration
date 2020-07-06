//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class is used to call the tutorial popup when the player visits
//           the engineering bay after researching tier 2 gear
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_BuildItems extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIInventory_BuildItems BuildItems;
	
	BuildItems = UIInventory_BuildItems(Screen);
	if (BuildItems == none) return;

	if (`XCOMHQ.IsTechResearched('MagnetizedWeapons') || `XCOMHQ.IsTechResearched('PlatedArmor'))
	{
		//BuildItems.bHideOnLoseFocus = false;
		class'UIUtilities_InfiltrationTutorial'.static.IndividualBuiltItems();
		//BuildItems.bHideOnLoseFocus = true;

		// UIInventory hides the 3d display when losing focus, so restore it manually
		if (!BuildItems.bIsVisible)
		{
			BuildItems.Show();
			UIMovie_3D(BuildItems.Movie).ShowDisplay(BuildItems.DisplayTag);
		}
	}
}