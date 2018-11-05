//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf and Xymanek
//  PURPOSE: This class adds a button to the Avenger to allow players to access
//           the Covert Actions menu without the Resistance Ring built
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIStrategyMap_CAButton extends UIScreenListener dependson(UICovertActions);

var localized string CovertActionButtonLabel;

/////////////////////
/// Adding button ///
/////////////////////

event OnInit(UIScreen Screen)
{
	local UILargeButton CovertActionButton;
	local UILargeButton CovertActionButtonNew;
	local UIStrategyMap StrategyMap;

	StrategyMap = UIStrategyMap(Screen);
	if (StrategyMap == none) return;

	CovertActionButton = Screen.Spawn(class 'UILargeButton', StrategyMap.StrategyMapHUD);
	CovertActionButton.InitButton('CovertActionButton', CovertActionButtonLabel, OnCovertActionButton);
	CovertActionButton.AnchorBottomCenter();
	CovertActionButton.SetFontSize(40);
	CovertActionButton.SetPosition(-135, -200);

	CovertActionButtonNew = Screen.Spawn(class 'UILargeButton', StrategyMap.StrategyMapHUD);
	CovertActionButtonNew.InitButton('CovertActionButtonNew', CovertActionButtonLabel $ "2", OnCovertActionNewButton);
	CovertActionButtonNew.AnchorBottomCenter();
	CovertActionButtonNew.SetFontSize(40);
	CovertActionButtonNew.SetPosition(-135, -300);	

	CovertActionButton.DisableNavigation();
	CovertActionButtonNew.DisableNavigation();

	if (`ISCONTROLLERACTIVE)
	{
		CovertActionButtonNew.SetText(
			class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_X_SQUARE, 26, 26, -10)
			$ CovertActionButtonNew.Text
		);
	}
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

public function OnCovertActionNewButton(UIButton CovertActionNewButton)
{
	class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape();
}

///////////////////////////////////////////
/// Handling input (controller support) ///
///////////////////////////////////////////

event OnReceiveFocus(UIScreen screen)
{
	if (UIStrategyMap(Screen) == none) return;

	HandleInput(true);
}

event OnLoseFocus(UIScreen screen)
{
	if (UIStrategyMap(Screen) == none) return;
	
	HandleInput(false);
}

function HandleInput(bool isSubscribing)
{
	local delegate<UIScreenStack.CHOnInputDelegate> inputDelegate;
	inputDelegate = OnUnrealCommand;

	if(isSubscribing)
	{
		`SCREENSTACK.SubscribeToOnInput(inputDelegate);
	}
	else
	{
		`SCREENSTACK.UnsubscribeFromOnInput(inputDelegate);
	}
}

static protected function bool OnUnrealCommand(int cmd, int arg)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_BUTTON_X && arg == class'UIUtilities_Input'.const.FXS_ACTION_RELEASE)
	{
		class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape();
		return true;
	}

	return false;
}