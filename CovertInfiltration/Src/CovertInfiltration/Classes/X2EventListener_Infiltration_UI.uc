//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek, robojumper and statusNone
//  PURPOSE: Houses X2EventListenerTemplates that affect UI. Mostly CHL hooks
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2EventListener_Infiltration_UI extends X2EventListener config(UI);

// The replacements set directly in config. Will be preferred
var config array<ItemAvaliableImageReplacement> ItemAvaliableImageReplacements;

// Replacements pulled from schematics during OPTC when items are converted to individual build
var array<ItemAvaliableImageReplacement> ItemAvaliableImageReplacementsAutomatic;

var localized string strInfiltrationReady;
var localized string strCanWaitForBonusOrLaunch;
var localized string strBarracksSizeTitle;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateGeoscapeListeners());
	Templates.AddItem(CreateAvengerHUDListeners());
	Templates.AddItem(CreateEventQueueListeners());
	Templates.AddItem(CreateArmoryListeners());
	Templates.AddItem(CreateSquadSelectListeners());
	Templates.AddItem(CreateStrategyPolicyListeners());
	Templates.AddItem(CreateTacticalHUDListeners());
	Templates.AddItem(CreateAlertListeners());

	return Templates;
}

////////////////
/// Geoscape ///
////////////////

static function CHEventListenerTemplate CreateGeoscapeListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_Geoscape');
	Template.AddCHEvent('Geoscape_ResInfoButtonVisible', GeoscapeResistanceButtonVisible, ELD_Immediate);
	Template.AddCHEvent('CovertAction_CanInteract', CovertAction_CanInteract, ELD_Immediate);
	Template.AddCHEvent('CovertAction_ShouldBeVisible', CovertAction_ShouldBeVisible, ELD_Immediate);
	Template.AddCHEvent('CovertAction_ActionSelectedOverride', CovertAction_ActionSelectedOverride, ELD_Immediate);
	Template.AddCHEvent('CovertAction_ModifyNarrativeParamTag', CovertAction_ModifyNarrativeParamTag, ELD_Immediate);
	Template.AddCHEvent('OnGeoscapeEntry', OnGeoscapeEntry);
	Template.AddCHEvent('CovertActionCompleted', CovertActionCompleted); // On submitted as we are going to pause geoscape which will cause a gamestate
	Template.AddCHEvent('OverrideMissionSiteIconImage', OverrideMissionSiteIconImage, ELD_Immediate);
	Template.AddCHEvent('StrategyMapMissionSiteSelected', StrategyMapMissionSiteSelected, ELD_Immediate);
	Template.AddCHEvent('OverrideMissionSiteTooltip', OverrideMissionSiteTooltip, ELD_Immediate);
	Template.AddCHEvent('CovertActionAllowEngineerPopup', CovertActionAllowEngineerPopup, ELD_Immediate);
	Template.AddCHEvent('CovertActionStarted', CovertActionStarted, ELD_Immediate);
	Template.AddCHEvent('MissionIconSetMissionSite', MissionIconSetMissionSite, ELD_Immediate);
	Template.AddCHEvent('OverrideMissionImage', OverrideMissionImage, ELD_Immediate);
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

static protected function EventListenerReturn CovertAction_CanInteract(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);

	if (Action == none || Tuple == none || Tuple.Id != 'CovertAction_CanInteract') return ELR_NoInterrupt;

	// All CAs can be interacted with
	Tuple.Data[0].b = true;
	
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CovertAction_ShouldBeVisible(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);

	if (Action == none || Tuple == none || Tuple.Id != 'CovertAction_ShouldBeVisible') return ELR_NoInterrupt;

	Tuple.Data[0].b = class'UIUtilities_Infiltration'.static.ShouldShowCovertAction(Action);
	
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CovertAction_ActionSelectedOverride(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);

	if (Action == none || Tuple == none || Tuple.Id != 'CovertAction_ActionSelectedOverride') return ELR_NoInterrupt;

	// Stop highlighting the icon
	UIStrategyMapItem(Action.GetVisualizer()).OnMouseOut();

	// Open our custom screen
	class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape(Action.GetReference());

	// Prevent default bahaviour
	Tuple.Data[0].b = true;
	
	// Stop other listeners since we opened a screen already
	return ELR_InterruptListeners;
}

static protected function EventListenerReturn CovertAction_ModifyNarrativeParamTag(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_DarkEvent DarkEventState;
	local XComGameState_Activity ActivityState;
	local XComGameState_CovertAction Action;
	local XGParamTag Tag;

	Action = XComGameState_CovertAction(EventSource);
	Tag = XGParamTag(EventData);
	
	if (Action == none || Tag == none) return ELR_NoInterrupt;

	if (
		Action.GetMyNarrativeTemplateName() != 'CovertActionNarrative_PrepareCounterDE' &&
		Action.GetMyNarrativeTemplateName() != 'CovertActionNarrative_CounterDarkEventInfil'
	)
	{
		return ELR_NoInterrupt;
	}

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(Action);
	if (ActivityState == none) ActivityState = class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(Action);
	
	if (ActivityState == none)
	{
		`Redscreen("CA with" @ Action.GetMyNarrativeTemplateName() @ "narrative doesn't belong to an activity");
		return ELR_NoInterrupt;
	}

	DarkEventState = ActivityState.GetActivityChain().GetChainDarkEvent();
	if (DarkEventState == none)
	{
		`Redscreen("CA with" @ Action.GetMyNarrativeTemplateName() @ "narrative belongs to a chain with no DE");
		return ELR_NoInterrupt;
	}
	
	Tag.StrValue4 = DarkEventState.GetDisplayName();

	return ELR_NoInterrupt;
}

static protected function string GetDarkEventString(XComGameState_CovertAction Action)
{
	local XComGameState_Reward RewardState;
	local XComGameState_DarkEvent DarkEventState;

	RewardState = XComGameState_Reward(`XCOMHISTORY.GetGameStateForObjectID(Action.RewardRefs[0].ObjectID));
	DarkEventState = XComGameState_DarkEvent(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));

	if (DarkEventState == none)
	{
		return "<Missing DE>";
	}

	return DarkEventState.GetMyTemplate().DisplayName;
}

static protected function EventListenerReturn OnGeoscapeEntry(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertInfiltrationInfo Info;
	local XComGameState NewGameState;
	local UIScreenStack ScreenStack;

	Info = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	ScreenStack = `SCREENSTACK;

	if (Info.bPopupNewActionOnGeoscapeEntrance)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: show new actions avaliable popup");
		
		// Turn off the flag
		Info = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', Info.ObjectID));
		Info.bPopupNewActionOnGeoscapeEntrance = false;

		// Check that UICovertActionsGeoscape isn't open already or we aren't queued to open it (give preference to clicks from event queue)
		if (!ScreenStack.HasInstanceOf(class'UICovertActionsGeoscape') && !class'UIMapToCovertActionsForcer'.static.IsQueued())
		{
			class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(, NewGameState);
		}

		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CovertActionCompleted(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_MissionSiteInfiltration MissionState;
	local XComGameState_CovertAction CovertAction;
	local XComGameState_Activity Activity;
	local XComHQPresentationLayer HQPres;

	CovertAction = XComGameState_CovertAction(EventSource);

	if (CovertAction == none)
	{
		return ELR_NoInterrupt;
	}

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(CovertAction))
	{
		Activity = class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(CovertAction);
		MissionState = XComGameState_MissionSiteInfiltration(class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(Activity));

		HQPres = `HQPRES;
		HQPres.NotifyBanner(default.strInfiltrationReady, MissionState.GetUIButtonIcon(), MissionState.GetMissionObjectiveText(), default.strCanWaitForBonusOrLaunch, eUIState_Good);
		HQPres.PlayUISound(eSUISound_SoldierPromotion);

		if (`GAME.GetGeoscape().IsScanning())
		{
			`HQPRES.StrategyMap2D.ToggleScan();
		}
	}
	
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OverrideMissionSiteIconImage(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_MissionSite MissionSite;
	local XComGameState_Activity ActivityState;
	local XComLWTuple Tuple;

	MissionSite = XComGameState_MissionSite(EventSource);
	Tuple = XComLWTuple(EventData);

	if (MissionSite == none || Tuple == none || Tuple.Id != 'OverrideMissionSiteIconImage') return ELR_NoInterrupt;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionSite);
	if (ActivityState == none) return ELR_NoInterrupt;
	
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	if (ActivityTemplate == none) return ELR_NoInterrupt;
	
	Tuple.Data[0].s = ActivityTemplate.UIButtonIcon;
	
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn StrategyMapMissionSiteSelected(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_MissionSite MissionSite;
	local XComGameState_Activity ActivityState;

	MissionSite = XComGameState_MissionSite(EventSource);
	if (MissionSite == none) return ELR_NoInterrupt;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionSite);
	if (ActivityState == none) return ELR_NoInterrupt;
	
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	if (ActivityTemplate == none) return ELR_NoInterrupt;
	
	ActivityTemplate.OnStrategyMapSelected(ActivityState);
	
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OverrideMissionSiteTooltip(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	local UIStrategyMap_MissionIcon Icon;
	local string Title, Body;
	local XComLWTuple Tuple;

	Icon = UIStrategyMap_MissionIcon(EventSource);
	Tuple = XComLWTuple(EventData);

	if (Icon == none || Icon.MissionSite == none || Tuple == none || Tuple.Id != 'OverrideMissionSiteTooltip') return ELR_NoInterrupt;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(Icon.MissionSite);
	if (ActivityState == none) return ELR_NoInterrupt;
	
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	if (ActivityTemplate == none) return ELR_NoInterrupt;
	
	// Not allowed to pass a dynamic array element as the value for an out parameter
	// So, proxy vars

	Title = Tuple.Data[0].s;
	Body = Tuple.Data[1].s;
	
	ActivityTemplate.OverrideStrategyMapIconTooltip(ActivityState, Title, Body);
	
	Tuple.Data[0].s = Title;
	Tuple.Data[1].s = Body;

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CovertActionAllowEngineerPopup (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);

	if (Action == none || Tuple == none || Tuple.Id != 'CovertActionAllowEngineerPopup') return ELR_NoInterrupt;

	// Ring no longer deals with CAs
	Tuple.Data[0].b = false;

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CovertActionStarted (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction ActionState;

	ActionState = XComGameState_CovertAction(EventSource);
	if (ActionState == none) return ELR_NoInterrupt;
	
	// Get the pending state (EventData always comes from history which isn't updated yet)
	ActionState = XComGameState_CovertAction(GameState.GetGameStateForObjectID(ActionState.ObjectID));

	// If we launched while the mission was still flagged as 'new' we need to unflag or it will be stuck
	ActionState.bNewAction = false;

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn MissionIconSetMissionSite (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local UIStrategyMap_MissionIcon MissionIcon;

	MissionIcon = UIStrategyMap_MissionIcon(EventSource);
	if (MissionIcon == none) return ELR_NoInterrupt;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();

	if (CIInfo.MissionsToShowAlertOnStrategyMap.Find('ObjectID', MissionIcon.MissionSite.ObjectID) != INDEX_NONE)
	{
		MissionIcon.AS_SetAlert(true);
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OverrideMissionImage (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_MissionSite MissionSite;
	local XComGameState_Activity ActivityState;
	local XComLWTuple Tuple;

	MissionSite = XComGameState_MissionSite(EventSource);
	Tuple = XComLWTuple(EventData);

	if (MissionSite == none || Tuple == none || Tuple.Id != 'OverrideMissionImage') return ELR_NoInterrupt;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionSite);
	if (ActivityState == none) return ELR_NoInterrupt;
	
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	if (ActivityTemplate == none) return ELR_NoInterrupt;
	
	Tuple.Data[0].s = ActivityTemplate.GetMissionImage(ActivityState);
	
	return ELR_NoInterrupt;
}

///////////////////
/// Avenger HUD ///
///////////////////

static function CHEventListenerTemplate CreateAvengerHUDListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_AvengerHUD');
	Template.AddCHEvent('UIAvengerShortcuts_ShowCQResistanceOrders', ShortcutsResistanceButtonVisible, ELD_Immediate);
	Template.AddCHEvent('UpdateResources', UpdateResources, ELD_Immediate);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn ShortcutsResistanceButtonVisible(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'UIAvengerShortcuts_ShowCQResistanceOrders') return ELR_NoInterrupt;

	// Only when the Ring is built
	Tuple.Data[0].b = `XCOMHQ.GetFacilityByName('ResistanceRing') != none;
	
	return ELR_NoInterrupt;
}

static function EventListenerReturn UpdateResources(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local UIAvengerHUD AvengerHUD;
	local UIScreenStack ScreenStack;
	local UIScreen CurrentScreen;
	local UICovertActionsGeoscape CovertActions;
	local int CurrentBarracksSize, CurrentBarracksLimit, MessageColor;
	
	AvengerHUD = `HQPRES.m_kAvengerHUD;
	ScreenStack = AvengerHUD.Movie.Pres.ScreenStack;
	CurrentScreen = ScreenStack.GetCurrentScreen();
	
	if (UIFacility_LivingQuarters(CurrentScreen) != none ||
		UIStrategyMap(CurrentScreen) != none ||
		UIFacilityGrid(CurrentScreen) != none ||
		UIRecruitSoldiers(CurrentScreen) != none ||
		(UIChooseUpgrade(CurrentScreen) != none && UIFacility_LivingQuarters(ScreenStack.GetFirstInstanceOf(class'UIFacility_LivingQuarters')) != none))
	{
		CurrentBarracksSize = class'X2Helper_Infiltration'.static.GetCurrentBarracksSize();
		CurrentBarracksLimit = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().CurrentBarracksLimit;

		if (CurrentBarracksSize > CurrentBarracksLimit)
		{
			MessageColor = eUIState_Bad;
		}
		else if (CurrentBarracksSize == CurrentBarracksLimit)
		{
			MessageColor = eUIState_Warning;
		}
		else
		{
			MessageColor = eUIState_Cash;
		}
		
		AvengerHUD.AddResource(default.strBarracksSizeTitle, class'UIUtilities_Text'.static.GetColoredText(CurrentBarracksSize $ "/" $ CurrentBarracksLimit, MessageColor));
		
		AvengerHUD.ShowResources();
	}

	CovertActions = UICovertActionsGeoscape(ScreenStack.GetFirstInstanceOf(class'UICovertActionsGeoscape'));

	if (
		CurrentScreen == CovertActions ||
		(CovertActions.SSManager != none && CovertActions.SSManager.ShouldShowResourceBar() && CurrentScreen.IsA(class'UISquadSelect'.Name))
	) {
		// Just do same thing as done for UICovertActions
		AvengerHUD.UpdateSupplies();
		AvengerHUD.UpdateIntel();
		AvengerHUD.UpdateAlienAlloys();
		AvengerHUD.UpdateEleriumCrystals();

		// Resource bar is hidden by default, show it
		AvengerHUD.ShowResources();
	}

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
	Template.AddCHEvent('OverrideNoCaEventMinMonths', OverrideNoCaEventMinMonths, ELD_Immediate);
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

static protected function EventListenerReturn OverrideNoCaEventMinMonths(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'OverrideNoCaEventMinMonths') return ELR_NoInterrupt;
	
	// set to 0 to force nag
	Tuple.Data[0].i = 0;

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
	Template.AddCHEvent('OverridePersonnelStatus', OverridePersonnelStatus, ELD_Immediate);
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
		NavHelp.AddLeftHelp(class'UIUtilities_Infiltration'.default.strDropUpgrade, class'UIUtilities_Input'.const.ICON_X_SQUARE);
	}

	return ELR_NoInterrupt;
}

/*
	OverrideTuple.Data[0].s = Status;
	OverrideTuple.Data[1].s = TimeLabel;
	OverrideTuple.Data[2].s = TimeValueOverride;
	OverrideTuple.Data[3].i = TimeNum;
	OverrideTuple.Data[4].i = int(eState);
	OverrideTuple.Data[5].b = HideTime != 0;
	OverrideTuple.Data[6].b = DoTimeConversion != 0;
*/
static protected function EventListenerReturn OverridePersonnelStatus(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;
	local StateObjectReference UnitRef;
	local XComGameState_Unit UnitState;
	local XComGameState_StaffSlot OccupiedSlot;
	local XComGameState_CovertAction Action;
	local XComGameState_MissionSiteInfiltration MissionSite;
	local string TimeValue, TimeLabel;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'OverridePersonnelStatus') return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(EventSource);
	OccupiedSlot = UnitState.GetStaffSlot();

	if (OccupiedSlot != none && OccupiedSlot.GetMyTemplateName() == 'InfiltrationStaffSlot')
	{
		Tuple.Data[0].s = OccupiedSlot.GetBonusDisplayString();	

		Action = OccupiedSlot.GetCovertAction();

		if (Action != none && !Action.bRemoved)
		{
			if (Action.bStarted)
			{
				class'UIUtilities_Text'.static.GetTimeValueAndLabel(Action.GetNumHoursRemaining(), TimeValue, TimeLabel);

				Tuple.Data[1].s = TimeLabel $ "->100%";
				Tuple.Data[3].i = int(TimeValue);
				Tuple.Data[4].i = eUIState_Warning;
				Tuple.Data[6].b = false;
			}
			else
			{
				// Squad select
				Tuple.Data[0].s = class'UIUtilities_Strategy'.default.m_strOnMissionStatus;
				Tuple.Data[1].s = "";
				Tuple.Data[5].b = true;
			}
		}
		else
		{
			foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_MissionSiteInfiltration', MissionSite)
			{
				foreach MissionSite.SoldiersOnMission(UnitRef)
				{
					if (UnitState == XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID)))
					{
						Tuple.Data[1].s = "";
						Tuple.Data[2].s = MissionSite.GetCurrentInfilInt() $ "%";
						Tuple.Data[4].i = eUIState_Warning;
					}
				}
			}
		}
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
	NavHelp.AddCenterHelp(
		class'UIUtilities_Infiltration'.default.strStripUpgrades,,
		class'UIUtilities_Infiltration'.static.OnStripWeaponUpgrades,,
		class'UIUtilities_Infiltration'.default.strStripUpgradesTooltip
	);

	return ELR_NoInterrupt;
}

//////////////////////////
/// UI Strategy Policy ///
//////////////////////////

static function CHEventListenerTemplate CreateStrategyPolicyListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_StrategyPolicy');
	Template.AddCHEvent('UIStrategyPolicy_ScreenInit', StrategyPolicyInit, ELD_Immediate);
	Template.AddCHEvent('UIStrategyPolicy_ShowCovertActionsOnClose', StrategyPolicy_ShowCovertActionsOnClose, ELD_Immediate);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn StrategyPolicyInit(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertInfiltrationInfo Info;
	local UIStrategyPolicy StrategyPolicy;
	local XComGameState NewGameState;

	StrategyPolicy = UIStrategyPolicy(EventSource);
	if (StrategyPolicy == none) return ELR_NoInterrupt;

	// Pre-first change - use smooth camera transition instead of instant jump from commander's quaters
	if (StrategyPolicy.Movie.Stack.Screens[1].IsA(class'UIFacility_CIC'.Name))
	{
		StrategyPolicy.bInstantInterp = false;
	}

	// First and main change - redirect the camera. This cannot be done in UISL as there will be a frame of camera jump
	class'UIUtilities_Infiltration'.static.CamRingView(StrategyPolicy.bInstantInterp ? float(0) : `HQINTERPTIME);

	// Second change - allow editing cards if did not assign before. This can be done in UISL but why have so many places?
	if (!StrategyPolicy.bResistanceReport && !class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bCompletedFirstOrdersAssignment)
	{
		StrategyPolicy.bResistanceReport = true;
	}

	// Last change: set bCompletedFirstOrdersAssignment to true. Cannot be inside previous if block as player may build the ring
	// and then wait until supply drop to assign orders. Can also be in UISL
	if (!class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bCompletedFirstOrdersAssignment)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Completing first order assignment");
		
		Info = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
		Info = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', Info.ObjectID));
		Info.bCompletedFirstOrdersAssignment = true;
		
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

static protected function EventListenerReturn StrategyPolicy_ShowCovertActionsOnClose(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'UIStrategyPolicy_ShowCovertActionsOnClose') return ELR_NoInterrupt;

	// Never show actions popup after UIStrategyPolicy
	Tuple.Data[0].b = false;
	
	return ELR_NoInterrupt;
}

////////////////////
/// Tactical HUD ///
////////////////////

static function CHEventListenerTemplate CreateTacticalHUDListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_TacticalHUD');
	Template.AddCHEvent('OverrideReinforcementsAlert', IncomingReinforcementsDisplay, ELD_Immediate);
	Template.RegisterInTactical = true;

	return Template;
}

static function EventListenerReturn IncomingReinforcementsDisplay(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_AIReinforcementSpawner ReinforcementSpawner;
	local UITacticalHUD_Countdown UICountdown;
	local XComGameState AssociatedGameState;
	local int DelayedRNF, NextRNF;
	local XComLWTuple Tuple;

	UICountdown = UITacticalHUD_Countdown(EventSource);
	Tuple = XComLWTuple(EventData);

	if (UICountdown == none || Tuple == none || Tuple.Id != 'OverrideReinforcementsAlert')
	{
		return ELR_NoInterrupt;
	}

	AssociatedGameState = XComGameState(Tuple.Data[4].o);
	NextRNF = -1;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AIReinforcementSpawner', ReinforcementSpawner,,, AssociatedGameState.HistoryIndex)
	{
		if (ReinforcementSpawner.Countdown > 0 && (NextRNF == -1 || NextRNF > ReinforcementSpawner.Countdown))
		{
			NextRNF = ReinforcementSpawner.Countdown;
		}
	}
	
	DelayedRNF = class'XComGameState_CIReinforcementsManager'.static.GetNextReinforcements(AssociatedGameState);

	if (NextRNF == -1 || (DelayedRNF != -1 && NextRNF > DelayedRNF))
	{
		NextRNF = DelayedRNF;
	}

	if (class'UIUtilities_Infiltration'.static.SetCountdownTextAndColor(NextRNF, Tuple))
	{
		Tuple.Data[0].b = true;
	}
	else
	{
		// Hide previously shown alert. Anything wants to show it again will unhide it anyway
		UICountdown.Hide();
	}

	return ELR_NoInterrupt;
}

//////////////
/// Alerts ///
//////////////

static function CHEventListenerTemplate CreateAlertListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_Alerts');
	Template.AddCHEvent('OverrideImageForItemAvaliable', OverrideImageForItemAvaliable, ELD_Immediate);
	Template.RegisterInStrategy = true;

	return Template;
}

static function EventListenerReturn OverrideImageForItemAvaliable(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local ItemAvaliableImageReplacement Replacement;
	local X2ItemTemplateManager TemplateManager;
	local X2ItemTemplate CurrentItemTemplate, ImageSourceTemplate;
	local XComLWTuple Tuple;
	local int i;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'OverrideImageForItemAvaliable') return ELR_NoInterrupt;

	CurrentItemTemplate = X2ItemTemplate(Tuple.Data[1].o);
	
	// Check if we have a manual replacement first
	i = default.ItemAvaliableImageReplacements.Find('TargetItem', CurrentItemTemplate.DataName);
	if (i != INDEX_NONE)
	{
		`CI_Trace("Replacing image for" @ CurrentItemTemplate.DataName @ "with a manually configured option");
		Replacement = default.ItemAvaliableImageReplacements[i];
	}

	// If we don't, check for an automatic one
	else
	{
		i = default.ItemAvaliableImageReplacementsAutomatic.Find('TargetItem', CurrentItemTemplate.DataName);

		if (i != INDEX_NONE)
		{
			`CI_Trace("Replacing image for" @ CurrentItemTemplate.DataName @ "with an automatically generated option");
			Replacement = default.ItemAvaliableImageReplacementsAutomatic[i];
		}
	}
	
	if (i != INDEX_NONE)
	{
		// Found a replacement

		if (Replacement.strImage != "")
		{
			Tuple.Data[0].s = Replacement.strImage;
		}
		else
		{
			TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
			ImageSourceTemplate = TemplateManager.FindItemTemplate(Replacement.ImageSourceItem);
			
			if (ImageSourceTemplate != none && ImageSourceTemplate.strImage != "")
			{
				Tuple.Data[0].s = ImageSourceTemplate.strImage;
			}
			else
			{
				`CI_Warn(CurrentItemTemplate.DataName @ "has a replacement with image from" @ Replacement.ImageSourceItem @ "but the latter has no image or doesn't exist");
			}
		}
	}

	return ELR_NoInterrupt;
}