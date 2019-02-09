class UIDropWeaponUpgradeButton extends UIPanel;

var UIArmory_WeaponUpgradeItem Slot;

simulated function InitDropButton()
{
	InitPanel();

	Slot = UIArmory_WeaponUpgradeItem(GetParent(class'UIArmory_WeaponUpgradeItem'));
	
	if (Slot == none)
	{
		`RedScreen("UIDropWeaponUpgradeButton must be child of UIArmory_WeaponUpgradeItem");
	}
	else
	{
		Slot.MC.SetBool("showClearButton", true);
		Slot.MC.FunctionVoid("realize");
	}

	// FixMe - doesn't work
	SetTooltipText("Drop item");
}

// Cannot use UIPanel version since we are eventually parented to UIList
// But we aren't an item in the list so focus events get lost
simulated function OnMouseEvent(int cmd, array<string> args)
{
	if (bShouldPlayGenericUIAudioEvents)
	{
		switch( cmd )
		{
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_UP:
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_DOUBLE_UP:
			`SOUNDMGR.PlaySoundEvent("Generic_Mouse_Click");
			break;

		case class'UIUtilities_Input'.const.FXS_L_MOUSE_IN:
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_OVER:
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_DRAG_OVER:
			`SOUNDMGR.PlaySoundEvent("Play_Mouseover");
			break;
		}
	}

	switch(cmd)
	{
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_IN:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_OVER:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_DRAG_OVER:
		Slot.OnLoseFocus();
		OnReceiveFocus();
		break;

	case class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_DRAG_OUT:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_RELEASE_OUTSIDE:
		OnLoseFocus();
		Slot.OnReceiveFocus();
		break;

	case class'UIUtilities_Input'.const.FXS_L_MOUSE_UP:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_DOUBLE_UP:
		class'UIUtilities_Infiltration'.static.RemoveWeaponUpgrade(Slot);
		break;
	}

	if (OnMouseEventDelegate != none)
		OnMouseEventDelegate(self, cmd);
}

defaultproperties
{
	MCName = "DropItemButton"
	bProcessesMouseEvents = true;
}