//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Controller input handler for dropping weapon mods
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_WeaponUpgrade extends UIScreenListener;

///////////////////////////////////////////
/// Handling input (controller support) ///
///////////////////////////////////////////

event OnInit(UIScreen Screen)
{
	local UIArmory_WeaponUpgrade WeaponUpgradeScreen;

	WeaponUpgradeScreen = UIArmory_WeaponUpgrade(Screen);
	if (WeaponUpgradeScreen == none) return;

	HandleInput(true);
}

event OnReceiveFocus(UIScreen screen)
{
	if (UIArmory_WeaponUpgrade(Screen) == none) return;

	HandleInput(true);
}

event OnLoseFocus(UIScreen screen)
{
	if (UIArmory_WeaponUpgrade(Screen) == none) return;
	
	HandleInput(false);
}

event OnRemoved(UIScreen screen)
{
	if (UIArmory_WeaponUpgrade(Screen) == none) return;
	
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
	local UIArmory_WeaponUpgrade WeaponUpgradeScreen;
	local UIArmory_WeaponUpgradeItem CurrentSlot;
	local UIScreenStack ScreenStack;

	ScreenStack = `SCREENSTACK;
	WeaponUpgradeScreen = UIArmory_WeaponUpgrade(ScreenStack.GetCurrentScreen());

	if (WeaponUpgradeScreen.ActiveList == WeaponUpgradeScreen.SlotsList && cmd == class'UIUtilities_Input'.const.FXS_BUTTON_X && arg == class'UIUtilities_Input'.const.FXS_ACTION_RELEASE)
	{
		CurrentSlot = UIArmory_WeaponUpgradeItem(WeaponUpgradeScreen.SlotsList.GetSelectedItem());

		if (CurrentSlot != none && CurrentSlot.UpgradeTemplate != none)
		{
			class'UIUtilities_Infiltration'.static.RemoveWeaponUpgrade(CurrentSlot);
			`SOUNDMGR.PlaySoundEvent("Generic_Mouse_Click");
		}

		return true;
	}

	return false;
}