//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class adds a button to Geoscape to allow players to access
//           the Covert Actions menu without the Resistance Ring built
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_StrategyMap_CAButton extends UIScreenListener;

/////////////////////
/// Adding button ///
/////////////////////

event OnInit(UIScreen Screen)
{
	local UIStrategyMap_CAButton CovertActionButton;
	local UIStrategyMap StrategyMap;

	StrategyMap = UIStrategyMap(Screen);
	if (StrategyMap == none) return;

	CovertActionButton = Screen.Spawn(class 'UIStrategyMap_CAButton', StrategyMap.StrategyMapHUD);
	CovertActionButton.InitCAButton();

	HandleInput(true);
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

event OnRemoved(UIScreen screen)
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
		if (class'XComEngine'.static.GetHQPres().StrategyMap2D.m_eUIState != eSMS_Flight)
		{
			// Cannot open screen during flight
			class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape();
		}

		return true;
	}

	return false;
}