class UIListner_SSManageEquipment extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIManageEquipmentMenu ManageEquipment;
	local UIScreenStack ScreenStack;
	local UIScreen SecondScreen;

	ManageEquipment = UIManageEquipmentMenu(Screen);
	if (ManageEquipment == none) return;

	ScreenStack = Screen.Movie.Stack;
	SecondScreen = ScreenStack.Screens[2]; // 0 is UIManageEquipmentMenu, 1 is mouse guard and 2 should be UISquadSelect

	if (SecondScreen != none && SecondScreen.IsA(class'UISquadSelect'.Name))
	{
		ManageEquipment.AddItem("Remove weapon upgrades", class'UIUtilities_Infiltration'.static.OnStripWeaponUpgrades);
		//ManageEquipment.List.SetHeight(ManageEquipment.List.ShrinkToFit() + 10); // Does jack shit
	}
}