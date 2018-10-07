//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class hides the button created in UIAvengerHUD_CAButton.uc
//           on every screen except the Avenger and the Geoscape
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIHidden_CAButton extends UIScreenListener;

var UIButton CovertActionButton;

event OnInit(UIScreen Screen)
{
	local UIScreenStack ScreenStack;
	local UIAvengerHUD UIAvengerHUDScreen;

	//Hide the button if one of these screens is initialized
	if(
	UISquadSelect(Screen) != none ||
	UIAfterAction(Screen) != none ||
	UIAlert(Screen) != none ||
	UIInventory_LootRecovered(Screen) != none ||
	UICredits(Screen) != none ||
	UIEndGameStats(Screen) != none ||
	UICovertActions(Screen) != none)
	{
		ScreenStack = `SCREENSTACK;
		UIAvengerHUDScreen = UIAvengerHUD(ScreenStack.GetScreen(class'UIAvengerHUD'));

		CovertActionButton = UIButton(UIAvengerHUDScreen.GetChild('CovertActionButton'));
	
		CovertActionButton.Hide();
	}

}

event OnRemoved(UIScreen Screen)
{
	//Display the button again after the screen is exited.
	if(
	UISquadSelect(Screen) != none ||
	UIAfterAction(Screen) != none ||
	UIAlert(Screen) != none ||
	UIInventory_LootRecovered(Screen) != none ||
	UICredits(Screen) != none ||
	UIEndGameStats(Screen) != none ||
	UICovertActions(Screen) != none)
	{
		CovertActionButton.Show();

		//Clean up memory for global variable
		CovertActionButton = none; 
	}
}