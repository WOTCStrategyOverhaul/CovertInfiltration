//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class adds a button to the Avenger to allow players to access
//           the Covert Actions menu without the Resistance Ring built
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIAvengerHUD_CAButton extends UIScreenListener dependson(UICovertActions);

var localized string CovertActionButtonLabel;

event OnInit(UIScreen Screen)
{

	local UILargeButton CovertActionButton;

	CovertActionButton = Screen.Spawn(class 'UILargeButton', Screen);

	CovertActionButton.SetResizeToText(false);
	CovertActionButton.InitButton('CovertActionButton', CovertActionButtonLabel, OnCovertActionButton);
	CovertActionButton.AnchorTopRight();
	CovertActionButton.SetFontSize(35);
	CovertActionButton.SetPosition(-250, 70);
	
}

public function OnCovertActionButton(UIButton CovertActionButton)
{

	local UIScreenStack ScreenStack;
	local UIAvengerHUD AvengerHUDScreen;
	local UIScreen CovertActionScreen;

	ScreenStack = `SCREENSTACK;
	CovertActionScreen = ScreenStack.GetScreen(class'UICovertActions');
	AvengerHUDScreen = UIAvengerHUD(ScreenStack.GetScreen(class'UIAvengerHUD'));

	if(CovertActionScreen == none)
		AvengerHUDScreen.Movie.Stack.Push(AvengerHUDScreen.Movie.Pres.Spawn(class'UICovertActions', AvengerHUDScreen.Movie.Pres));
	else
		CovertActionScreen.CloseScreen();
}

defaultproperties
{
	ScreenClass = class'UIAvengerHUD';
}