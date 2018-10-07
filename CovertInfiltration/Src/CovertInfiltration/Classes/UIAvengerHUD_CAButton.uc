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
	local UIStrategyMap StrategyMap;

	StrategyMap = UIStrategyMap(Screen);
	if (StrategyMap == none) return;

	CovertActionButton = Screen.Spawn(class 'UILargeButton', StrategyMap.StrategyMapHUD);

	CovertActionButton.InitButton('CovertActionButton', CovertActionButtonLabel, OnCovertActionButton);
	CovertActionButton.AnchorBottomCenter();
	CovertActionButton.SetFontSize(40);
	CovertActionButton.SetPosition(-135, -200);
	
}

public function OnCovertActionButton(UIButton CovertActionButton)
{

	local UIScreenStack ScreenStack;
	local UIScreen AvengerHUDScreen;
	local UIScreen CovertActionScreen;

	ScreenStack = `SCREENSTACK;
	CovertActionScreen = ScreenStack.GetScreen(class'UICovertActions');
	AvengerHUDScreen = ScreenStack.GetScreen(class'UIStrategyMap');

	if(CovertActionScreen == none)
		AvengerHUDScreen.Movie.Stack.Push(AvengerHUDScreen.Movie.Pres.Spawn(class'UICovertActions', AvengerHUDScreen.Movie.Pres));
}

defaultproperties
{
	ScreenClass = none //class'UIStrategyMap';
}