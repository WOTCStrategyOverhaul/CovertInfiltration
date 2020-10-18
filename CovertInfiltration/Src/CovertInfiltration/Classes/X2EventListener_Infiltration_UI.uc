//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek, robojumper and statusNone
//  PURPOSE: Houses X2EventListenerTemplates that affect UI. Mostly CHL hooks
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2EventListener_Infiltration_UI extends X2EventListener config(UI);

var localized string strInfiltrationReady;
var localized string strCanWaitForBonusOrLaunch;
var localized string strReadySoldiers;
var localized string strTiredSoldiers;
var localized string strAcademyTrainingRank;
var localized string strInformantsTitle;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateGeoscapeListeners());
	Templates.AddItem(CreateAvengerHUDListeners());
	Templates.AddItem(CreateEventQueueListeners());
	Templates.AddItem(CreateArmoryListeners());
	Templates.AddItem(CreateStrategyPolicyListeners());
	Templates.AddItem(CreateResearchListeners());
	Templates.AddItem(CreateTacticalHUDListeners());

	return Templates;
}

////////////////
/// Geoscape ///
////////////////

static function CHEventListenerTemplate CreateGeoscapeListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_Geoscape');
	Template.AddCHEvent('Geoscape_ResInfoButtonVisible', GeoscapeResistanceButtonVisible, ELD_Immediate, 99);
	Template.AddCHEvent('CovertAction_CanInteract', CovertAction_CanInteract, ELD_Immediate, 99);
	Template.AddCHEvent('CovertAction_ShouldBeVisible', CovertAction_ShouldBeVisible, ELD_Immediate, 99);
	Template.AddCHEvent('CovertAction_ActionSelectedOverride', CovertAction_ActionSelectedOverride, ELD_Immediate, 99);
	Template.AddCHEvent('CovertAction_ModifyNarrativeParamTag', CovertAction_ModifyNarrativeParamTag, ELD_Immediate, 99);
	Template.AddCHEvent('OnGeoscapeEntry', OnGeoscapeEntry, ELD_OnStateSubmitted, 99);
	Template.AddCHEvent('CovertActionCompleted', CovertActionCompleted, ELD_OnStateSubmitted, 99); // On submitted as we are going to pause geoscape which will cause a gamestate
	Template.AddCHEvent('OverrideMissionSiteIconImage', OverrideMissionSiteIconImage, ELD_Immediate, 99);
	Template.AddCHEvent('StrategyMapMissionSiteSelected', StrategyMapMissionSiteSelected, ELD_Immediate, 99);
	Template.AddCHEvent('OverrideMissionSiteTooltip', OverrideMissionSiteTooltip, ELD_Immediate, 99);
	Template.AddCHEvent('CovertActionAllowEngineerPopup', CovertActionAllowEngineerPopup, ELD_Immediate, 99);
	Template.AddCHEvent('CovertActionStarted', CovertActionStarted, ELD_Immediate, 99);
	Template.AddCHEvent('MissionIconSetMissionSite', MissionIconSetMissionSite, ELD_Immediate, 99);
	Template.AddCHEvent('OverrideCanTakeFacilityMission', OverrideCanTakeFacilityMission, ELD_Immediate, 99);
	Template.AddCHEvent('OverrideMissionImage', OverrideMissionImage, ELD_Immediate, 99);
	Template.AddCHEvent('UIResistanceReport_ShowCouncil', UIResistanceReport_ShowCouncil, ELD_Immediate, 99);
	Template.AddCHEvent('OverrideNextRetaliationDisplay', OverrideNextRetaliationDisplay, ELD_Immediate, 99);
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
	local XComGameState_Activity ActivityState;
	local XComGameState_CovertAction Action;
	local XGParamTag Tag;
	local int SavedInt0, SavedInt1, SavedInt2;
	local string SavedStr0, SavedStr1, SavedStr2, SavedStr3, SavedStr4;

	Action = XComGameState_CovertAction(EventSource);
	Tag = XGParamTag(EventData);
	
	if (Action == none || Tag == none) return ELR_NoInterrupt;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(Action);
	if (ActivityState == none) ActivityState = class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(Action);
	if (ActivityState == none) return ELR_NoInterrupt;
	
	// XGParamTag is a singleton, which means when we change the values of it
	// in GetNarrativeObjective they will be altered here as well, therefore
	// they must be saved and restored before and after the function call...

	SavedInt0 = Tag.IntValue0;
	SavedInt1 = Tag.IntValue1;
	SavedInt2 = Tag.IntValue2;

	SavedStr0 = Tag.StrValue0;
	SavedStr1 = Tag.StrValue1;
	SavedStr2 = Tag.StrValue2;
	SavedStr3 = Tag.StrValue3;

	// ...except for StrValue4, which we actually intend to override
	SavedStr4 = ActivityState.GetActivityChain().GetNarrativeObjective();
	
	Tag.IntValue0 = SavedInt0;
	Tag.IntValue1 = SavedInt1;
	Tag.IntValue2 = SavedInt2;

	Tag.StrValue0 = SavedStr0;
	Tag.StrValue1 = SavedStr1;
	Tag.StrValue2 = SavedStr2;
	Tag.StrValue3 = SavedStr3;

	Tag.StrValue4 = SavedStr4;

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
	local XComGameState_Analytics Analytics;
	local int iMissions;

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
	
	Analytics = XComGameState_Analytics(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_Analytics'));
	iMissions = int(Analytics.GetFloatValue("BATTLES_WON") + Analytics.GetFloatValue("BATTLES_LOST"));

	// If the player has returned from their second mission, display the crew limit tutorial
	if (iMissions > 1)
	{
		class'UIUtilities_InfiltrationTutorial'.static.CrewLimit();
	}

	// If the player has returned from their fifth mission, display the advanced chains tutorial
	if (iMissions > 4)
	{
		class'UIUtilities_InfiltrationTutorial'.static.AdvancedChains();
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
		`XSTRATEGYSOUNDMGR.PlaySoundEvent(X2ActivityTemplate_Infiltration(Activity.GetMyTemplate()).MissionReadySound);

		if (class'XComGameState_MissionSiteInfiltration'.static.ShouldPauseGeoscapeAtMilestone('MissionReady'))
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
	local XComGameState_MissionSite MissionState;
	local UIStrategyMap_MissionIcon MissionIcon;

	MissionIcon = UIStrategyMap_MissionIcon(EventSource);
	if (MissionIcon == none) return ELR_NoInterrupt;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();

	if (CIInfo.MissionsToShowAlertOnStrategyMap.Find('ObjectID', MissionIcon.MissionSite.ObjectID) != INDEX_NONE)
	{
		MissionIcon.AS_SetAlert(true);
	}

	MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(MissionIcon.MissionSite.ObjectID));

	if (MissionState != none && MissionState.Source == 'MissionSource_AlienNetwork')
	{
		MissionIcon.AS_SetLock(!class'X2Helper_Infiltration'.static.CanTakeFacilityMission(MissionState));
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OverrideCanTakeFacilityMission (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_MissionSite MissionSite;
	local XComLWTuple Tuple;

	MissionSite = XComGameState_MissionSite(EventSource);
	Tuple = XComLWTuple(EventData);

	if (MissionSite == none || Tuple == none) return ELR_NoInterrupt;

	Tuple.Data[0].b = class'X2Helper_Infiltration'.static.CanTakeFacilityMission(MissionSite);

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

static protected function EventListenerReturn UIResistanceReport_ShowCouncil (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none) return ELR_NoInterrupt;
	
	Tuple.Data[0].b =
		class'UIUtilities_Strategy'.static.GetXComHQ().IsObjectiveCompleted('T2_M0_L0_BlacksiteReveal') && // We saw the "Welcome to resistance" cinematic
		!class'UIUtilities_Strategy'.static.GetXComHQ().IsObjectiveCompleted('T5_M1_AutopsyTheAvatar'); // And the guy isn't toodled yet
	
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OverrideNextRetaliationDisplay (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none) return ELR_NoInterrupt;
	
	Tuple.Data[0].b = false;
	
	return ELR_NoInterrupt;
}

///////////////////
/// Avenger HUD ///
///////////////////

static function CHEventListenerTemplate CreateAvengerHUDListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_AvengerHUD');
	Template.AddCHEvent('UIAvengerShortcuts_ShowCQResistanceOrders', ShortcutsResistanceButtonVisible, ELD_Immediate, 99);
	Template.AddCHEvent('UpdateResources', UpdateResources, ELD_Immediate, 99);
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
	local BarracksStatusReport CurrentBarracksStatus;
	local X2StrategyElementTemplateManager StrategyElementTemplateManager; 
	local X2FacilityTemplate AcademyTemplate;
	local UIMission_AlienFacility AlienFacilityScreen;
	local int Quantity;

	AvengerHUD = `HQPRES.m_kAvengerHUD;
	ScreenStack = AvengerHUD.Movie.Pres.ScreenStack;
	CurrentScreen = ScreenStack.GetCurrentScreen();

	///////////////////////////////////////
	/// New covert ops screen + loadout ///
	///////////////////////////////////////

	CovertActions = UICovertActionsGeoscape(ScreenStack.GetFirstInstanceOf(class'UICovertActionsGeoscape'));
	if (CovertActions != none)
	{
		if (
			CurrentScreen == CovertActions ||
			(CovertActions.SSManager != none && CovertActions.SSManager.ShouldShowResourceBar() && CurrentScreen.IsA(class'UISquadSelect'.Name)))
		{

			// Just do same thing as done for UICovertActions
			AvengerHUD.UpdateSupplies();
			AvengerHUD.UpdateIntel();
			AvengerHUD.UpdateAlienAlloys();
			AvengerHUD.UpdateEleriumCrystals();

			// Resource bar is hidden by default, show it
			AvengerHUD.ShowResources();
		}
	}

	//////////////////////
	/// Soldier counts ///
	//////////////////////

	if (UIMission(CurrentScreen) != none && CurrentScreen != UIMission_Infiltrated(ScreenStack.GetFirstInstanceOf(class'UIMission_Infiltrated')) ||
		CurrentScreen == CovertActions)
	{
		CurrentBarracksStatus = class'X2Helper_Infiltration'.static.GetBarracksStatusReport();

		AvengerHUD.AddResource(default.strTiredSoldiers, class'UIUtilities_Text'.static.GetColoredText(string(CurrentBarracksStatus.Tired), eUIState_Warning));
		AvengerHUD.AddResource(default.strReadySoldiers, class'UIUtilities_Text'.static.GetColoredText(string(CurrentBarracksStatus.Ready), eUIState_Good));

		// Resource bar is hidden by default, show it
		AvengerHUD.ShowResources();
	}

	/////////////////////////
	/// GTS training rank ///
	/////////////////////////

	StrategyElementTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	AcademyTemplate = X2FacilityTemplate(StrategyElementTemplateManager.FindStrategyElementTemplate('OfficerTrainingSchool'));

	if (ScreenStack.GetFirstInstanceOf(AcademyTemplate.UIFacilityClass) != none)
	{
		AvengerHUD.AddResource(
			default.strAcademyTrainingRank,
			class'UIUtilities_Infiltration'.static.GetAcademyTargetRank()
		);

		AvengerHUD.ShowResources();
	}

	//////////////////////////
	/// Chain spawner rate ///
	//////////////////////////

	if (ScreenStack.GetFirstInstanceOf(class'UIChainsOverview') != none)
	{
		AvengerHUD.AddResource(
			default.strInformantsTitle, 
			class'UIUtilities_Text'.static.GetColoredText(
				string(class'XComGameState_ActivityChainSpawner'.static.GetCurrentWorkRate()), 
				eUIState_Cash
			)
		);
		
		AvengerHUD.ShowResources();
	}
	
	////////////////////////
	/// Actionable leads ///
	////////////////////////

	AlienFacilityScreen = UIMission_AlienFacility(ScreenStack.GetCurrentScreen());
	if (
		AlienFacilityScreen != none &&
		class'X2Helper_Infiltration'.static.DoesFacilityRequireLead(AlienFacilityScreen.GetMission())
	)
	{
		Quantity = `XCOMHQ.GetResourceAmount('ActionableFacilityLead');

		AvengerHUD.AddResource(
			Caps(class'UIUtilities_Strategy'.static.GetResourceDisplayName('ActionableFacilityLead', Quantity)),
			class'UIUtilities_Text'.static.GetColoredText(string(Quantity), (Quantity > 0) ? eUIState_Normal : eUIState_Bad)
		);

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
	Template.AddCHEvent('GetCovertActionEvents_Settings', GetCovertActionEvents_Settings, ELD_Immediate, 99);
	Template.AddCHEvent('OverrideNoCaEventMinMonths', OverrideNoCaEventMinMonths, ELD_Immediate, 99);
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
	Template.AddCHEvent('OverridePersonnelStatus', OverridePersonnelStatus, ELD_Immediate, 99);
	Template.AddCHEvent('SoldierListItem_ShouldDisplayMentalStatus', SoldierListItem_ShouldDisplayMentalStatus, ELD_Immediate, 99);
	Template.RegisterInStrategy = true;

	return Template;
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
	local XComGameState_HeadquartersProjectTrainAcademy AcademyProjectState;
	local string TimeValue, TimeLabel;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'OverridePersonnelStatus') return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(EventSource);
	OccupiedSlot = UnitState.GetStaffSlot();

	if (OccupiedSlot != none)
	{
		Action = OccupiedSlot.GetCovertAction();
		AcademyProjectState = class'X2Helper_Infiltration'.static.GetAcademyProjectForUnit(UnitState.GetReference());

		if (OccupiedSlot.GetMyTemplateName() == 'InfiltrationStaffSlot')
		{
			Tuple.Data[0].s = OccupiedSlot.GetBonusDisplayString();	

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
					Tuple.Data[4].i = eUIState_Normal;
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
		else if (Action != none && !Action.bStarted)
		{
			// Squad select (change color to differ from ongoing CAs)
			Tuple.Data[0].s = OccupiedSlot.GetBonusDisplayString();
			Tuple.Data[4].i = eUIState_Normal;
			Tuple.Data[5].b = true;
		}
		else if (AcademyProjectState != none)
		{
			Tuple.Data[0].s = OccupiedSlot.GetBonusDisplayString();
			Tuple.Data[3].i = AcademyProjectState.GetCurrentNumHoursRemaining();
			Tuple.Data[4].i = eUIState_Warning;
			Tuple.Data[6].b = true;
		}
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn SoldierListItem_ShouldDisplayMentalStatus (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;
	local XComGameState_Unit UnitState;
	local XComGameState_StaffSlot OccupiedSlot;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none) return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(Tuple.Data[1].o);
	OccupiedSlot = UnitState.GetStaffSlot();

	if (
		OccupiedSlot != none &&
		`SCREENSTACK.IsInStack(class'UISquadSelect') &&
		OccupiedSlot.GetCovertAction() != none &&
		!OccupiedSlot.GetCovertAction().bStarted &&
		class'UIUtilities_Strategy'.static.GetXComHQ().Squad.Find('ObjectID', UnitState.ObjectID) != INDEX_NONE
	)
	{
		Tuple.Data[0].b = true;
	}

	return ELR_NoInterrupt;
}

//////////////////////////
/// UI Strategy Policy ///
//////////////////////////

static function CHEventListenerTemplate CreateStrategyPolicyListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_StrategyPolicy');
	Template.AddCHEvent('UIStrategyPolicy_ScreenInit', StrategyPolicyInit, ELD_Immediate, 99);
	Template.AddCHEvent('UIStrategyPolicy_ShowCovertActionsOnClose', StrategyPolicy_ShowCovertActionsOnClose, ELD_Immediate, 99);
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

//////////////////////////
/// UI Strategy Policy ///
//////////////////////////

static function CHEventListenerTemplate CreateResearchListeners ()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_Research');
	Template.AddCHEvent('OnResearchReport', OnResearchReport_AlienFacilityLead, ELD_OnStateSubmitted, 99);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn OnResearchReport_AlienFacilityLead (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Tech TechState;
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;

	TechState = XComGameState_Tech(EventData);
	if (TechState == none) return ELR_NoInterrupt;

	if (TechState.GetMyTemplateName() == 'Tech_AlienFacilityLead')
	{
		ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
		ItemTemplate = ItemTemplateManager.FindItemTemplate('ActionableFacilityLead');

		`HQPRES.UIItemReceived(ItemTemplate);
	}

	return ELR_NoInterrupt;
}

////////////////////
/// Tactical HUD ///
////////////////////

static function CHEventListenerTemplate CreateTacticalHUDListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_UI_TacticalHUD');
	Template.AddCHEvent('OverrideReinforcementsAlert', IncomingReinforcementsDisplay, ELD_Immediate, 99);
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
