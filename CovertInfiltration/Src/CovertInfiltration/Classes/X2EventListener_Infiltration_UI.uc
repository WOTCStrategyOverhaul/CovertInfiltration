//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Listeners for various UI events (mostly CHL hooks)
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2EventListener_Infiltration_UI extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateGeoscapeListeners());
	Templates.AddItem(CreateAvengerHUDListeners());
	Templates.AddItem(CreateEventQueueListeners());
	Templates.AddItem(CreateArmoryListeners());
	Templates.AddItem(CreateSquadSelectListeners());

	return Templates;
}

////////////////
/// Geoscape ///
////////////////

static function CHEventListenerTemplate CreateGeoscapeListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_Geoscape');
	Template.AddCHEvent('Geoscape_ResInfoButtonVisible', GeoscapeResistanceButtonVisible, ELD_Immediate); // Relies on CHL #365, will be avaliable in v1.17
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn GeoscapeResistanceButtonVisible(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;
	local XComGameState_FacilityXCom FacilityState;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'Geoscape_ResInfoButtonVisible') return ELR_NoInterrupt;

	FacilityState = `XCOMHQ.GetFacilityByName('ResistanceRing');
	Tuple.Data[0].b = FacilityState != none && !Tuple.Data[1].b;
	
	return ELR_NoInterrupt;
}

///////////////////
/// Avenger HUD ///
///////////////////

static function CHEventListenerTemplate CreateAvengerHUDListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_AvengerHUD');
	Template.AddCHEvent('UIAvengerShortcuts_ShowCQResistanceOrders', ShortcutsResistanceButtonVisible, ELD_Immediate); // Relies on CHL #368, will be avaliable in v1.17
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn ShortcutsResistanceButtonVisible(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'UIAvengerShortcuts_ShowCQResistanceOrders') return ELR_NoInterrupt;

	// NEVAH!!!
	Tuple.Data[0].b = false;
	
	return ELR_NoInterrupt;
}

///////////////////
/// Event Queue ///
///////////////////

static function CHEventListenerTemplate CreateEventQueueListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_EventQueue');
	Template.AddCHEvent('GetCovertActionEvents_Settings', GetCovertActionEvents_Settings, ELD_Immediate); // Relies on CHL #391, will be avaliable in v1.18
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn GetCovertActionEvents_Settings(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'GetCovertActionEvents_Settings') return ELR_NoInterrupt;

	// Show all of them
	Tuple.Data[0].b = true;
	// Insert it sorted
	Tuple.Data[1].b = true;
	
	return ELR_NoInterrupt;
}

//////////////
/// Armory ///
//////////////

static function CHEventListenerTemplate CreateArmoryListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_Armory');
	Template.AddCHEvent('UIArmory_WeaponUpgrade_SlotsUpdated', WeaponUpgrade_SlotsUpdated, ELD_Immediate);
	Template.AddCHEvent('UIArmory_WeaponUpgrade_NavHelpUpdated', WeaponUpgrade_NavHelpUpdated, ELD_Immediate);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn WeaponUpgrade_SlotsUpdated(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIDropWeaponUpgradeButton DropButton;
	local UIArmory_WeaponUpgradeItem Slot;
	local UIList SlotsList;
	local UIPanel Panel;

	if (`ISCONTROLLERACTIVE)
	{
		// We add the button only if using mouse
		return ELR_NoInterrupt;
	}

	SlotsList = UIList(EventData);
	if (SlotsList == none)
	{
		`RedScreen("Recived UIArmory_WeaponUpgrade_SlotsUpdated but data isn't UIList");
		return ELR_NoInterrupt;
	}

	foreach SlotsList.ItemContainer.ChildPanels(Panel)
	{
		Slot = UIArmory_WeaponUpgradeItem(Panel);
		if (Slot == none || Slot.UpgradeTemplate == none || Slot.bIsDisabled) continue;

		DropButton = Slot.Spawn(class'UIDropWeaponUpgradeButton', Slot);
		DropButton.InitDropButton();
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn WeaponUpgrade_NavHelpUpdated(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIArmory_WeaponUpgrade Screen;
	local UINavigationHelp NavHelp;

	if (!`ISCONTROLLERACTIVE)
	{
		// We add the indicator only if using controller
		return ELR_NoInterrupt;
	}

	Screen = UIArmory_WeaponUpgrade(EventSource);
	NavHelp = UINavigationHelp(EventData);

	if (NavHelp == none)
	{
		`RedScreen("Recived UIArmory_WeaponUpgrade_NavHelpUpdated but data isn't UINavigationHelp");
		return ELR_NoInterrupt;
	}

	if (Screen == none)
	{
		`RedScreen("Recived UIArmory_WeaponUpgrade_NavHelpUpdated but source isn't UIArmory_WeaponUpgrade");
		return ELR_NoInterrupt;
	}

	if (Screen.ActiveList == Screen.SlotsList)
	{
		NavHelp.AddLeftHelp("Drop upgrade", class'UIUtilities_Input'.const.ICON_X_SQUARE);
	}

	return ELR_NoInterrupt;
}

////////////////////
/// Squad Select ///
////////////////////

static function CHEventListenerTemplate CreateSquadSelectListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_SquadSelect');
	Template.AddCHEvent('UISquadSelect_NavHelpUpdate', SSNavHelpUpdate, ELD_Immediate);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn SSNavHelpUpdate(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UINavigationHelp NavHelp;

	if (`ISCONTROLLERACTIVE)
	{
		// We add the button only if using mouse
		return ELR_NoInterrupt;
	}

	NavHelp = UINavigationHelp(EventData);
	NavHelp.AddCenterHelp("Make weapon upgrades avaliable",, class'UIUtilities_Infiltration'.static.OnStripWeaponUpgrades);

	return ELR_NoInterrupt;
}