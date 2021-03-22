//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and ArcaneData
//  PURPOSE: This class houses static helper methods that are used by
//           different UI classes
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIUtilities_Infiltration extends Object;

var localized string strReinforcementsBodyWarning;
var localized string strReinforcementsBodyImminent;

var localized string strOpportunityAvaliableUnknownLocation;
var localized string strAssaultAvaliableHeader;
var localized string strInfiltrationAvaliableHeader;
var localized string strCovertActionAvaliableHeader;
var localized string strAssaultExpiringHeader;
var localized string strCovertActionExpiringHeader;
var localized string strInfiltrationExpiringHeader;

// Non-native packages don't seem to support BoundEnum (or something, no idea) so we manually list the completion statuses
var localized string strCompletionStatusLabel_NotReached;
var localized string strCompletionStatusLabel_NotCompleted;
var localized string strCompletionStatusLabel_Expired;
var localized string strCompletionStatusLabel_Failure;
var localized string strCompletionStatusLabel_PartialSuccess;
var localized string strCompletionStatusLabel_Success;

// Custom statuses for more specific display of strCompletionStatusLabel_NotCompleted
var localized string strCompletionStatusLabel_Available;
var localized string strCompletionStatusLabel_Ongoing;
var localized string strCompletionStatusLabel_Infiltrating;

// Prefix of the form (X/Y) where X is the current stage and Y is the number of stages in the chain
var localized string strChainStatusPrefix;

// Post-facility mission global effect
var localized string strActionableLeadUsed;
var localized string strLastActionableLeadUsed;

`include(CovertInfiltration\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

//////////////////
/// Game state ///
//////////////////
       
// Adapted from UICovertActions           
static function bool ShouldShowCovertAction(XComGameState_CovertAction ActionState)
{
	local XComGameState_ResistanceFaction FactionState;
	FactionState = ActionState.GetFaction();

	// Only display actions which are actually stored by the Faction. Safety check to prevent
	// actions which were supposed to have been deleted from showing up in the UI and being accessed.
	if (
		FactionState.CovertActions.Find('ObjectID', ActionState.ObjectID) == INDEX_NONE &&
		FactionState.GoldenPathActions.Find('ObjectID', ActionState.ObjectID) == INDEX_NONE
	) {
		return false;
	}
	
	// Always show in-progess actions
	if (ActionState.bStarted) return true;
	
	return ActionState.CanActionBeDisplayed() && (ActionState.GetMyTemplate().bGoldenPath || FactionState.bSeenFactionHQReveal);;
}

///////////////
/// UI/Text ///
///////////////

static function UICovertActionsGeoscape(optional StateObjectReference ActionToFocus)
{
	local XComHQPresentationLayer HQPres;
	local UICovertActionsGeoscape TheScreen;

	HQPres = `HQPRES;
	if (HQPres.ScreenStack.GetFirstInstanceOf(class'UICovertActionsGeoscape') != none) return;

	TheScreen = HQPres.Spawn(class'UICovertActionsGeoscape', HQPres);
	TheScreen.ActionToShowOnInitRef = ActionToFocus;
	
	HQPres.ScreenStack.Push(TheScreen);
}

static function UIChainsOverview (optional StateObjectReference ChainToFocus, optional bool bRestoreCamEarthViewOnClose)
{
	local XComHQPresentationLayer HQPres;
	local UIChainsOverview TheScreen;

	HQPres = `HQPRES;
	if (HQPres.ScreenStack.GetFirstInstanceOf(class'UIChainsOverview') != none) return;

	TheScreen = HQPres.Spawn(class'UIChainsOverview', HQPres);
	TheScreen.ChainToFocusOnInit = ChainToFocus;
	TheScreen.bRestoreCamEarthViewOnClose = bRestoreCamEarthViewOnClose;
	HQPres.ScreenStack.Push(TheScreen);
}

static function UIPersonnel_PreSetList(array<StateObjectReference> UnitRefs, optional string Header)
{
	local XComHQPresentationLayer HQPres;
	local UIPersonnel_PreSetList TheScreen;

	HQPres = `HQPRES;
	TheScreen = HQPres.Spawn(class'UIPersonnel_PreSetList', HQPres);
	TheScreen.PrepareFromArray(UnitRefs);
	
	HQPres.ScreenStack.Push(TheScreen);

	if (Header != "")
	{
		TheScreen.SetScreenHeader(Header);
	}
}

static function UIInfiltrationDetails (StateObjectReference InfiltrationRef)
{
	local XComHQPresentationLayer HQPres;
	local UIInfiltrationDetails TheScreen;

	HQPres = `HQPRES;

	TheScreen = HQPres.Spawn(class'UIInfiltrationDetails', HQPres);
	TheScreen.InfiltrationRef = InfiltrationRef;
	
	HQPres.ScreenStack.Push(TheScreen);
}

static function string ColourText(string strValue, string strColour)
{
	return "<font color='#" $ strColour $ "'>" $ strValue $ "</font>";
}

static function string MakeFirstCharCapOnly(string strValue)
{
	return Caps(Left(strValue, 1)) $ Locs(Right(strValue, Len(strValue) - 1));
}

static function string SetTextLeading (string strValue, int Leading)
{
	return "<textformat leading='" $ string(Leading) $ "'>" $ strValue $ "</textformat>";
}

static function array<ActionRiskDisplayInfo> GetRisksForDisplay(XComGameState_CovertAction CovertAction)
{
	local X2StrategyElementTemplateManager StratMgr;
	local array<ActionRiskDisplayInfo> Result;
	local array<CovertActionRisk> Risks;
	local CovertActionRisk Risk;
	local X2CovertActionRiskTemplate RiskTemplate;
	local int RiskChance;
	local ActionRiskDisplayInfo DisplayInfo, EmptyDisplayInfo;
	local X2ActionRiskDescriptionTemplateManager RiskDescriptionManager;
	local X2ActionRiskDescriptionTemplate RiskDescriptionTemplate;

	RiskDescriptionManager = class'X2ActionRiskDescriptionTemplateManager'.static.GetActionRiskDescriptionTemplateManager();
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Risks = CovertAction.Risks;
	Risks.Sort(SortRisksByDifficulty);

	foreach Risks(Risk)
	{
		RiskTemplate = X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(Risk.RiskTemplateName));

		if (RiskTemplate == none || CovertAction.NegatedRisks.Find(Risk.RiskTemplateName) != INDEX_NONE)
		{
			continue;
		}
		
		RiskChance = Risk.ChanceToOccur + Risk.ChanceToOccurModifier;

		DisplayInfo = EmptyDisplayInfo;
		DisplayInfo.ChanceText = GetRiskDifficultyColouredString(ConvertChanceToRiskLevel(RiskChance));
		DisplayInfo.RiskName = RiskTemplate.RiskName;

		RiskDescriptionTemplate = RiskDescriptionManager.FindDescriptionTemplate(Risk.RiskTemplateName, false);
		if (RiskDescriptionTemplate != none) DisplayInfo.Description = RiskDescriptionTemplate.GetDescriptionText(RiskDescriptionTemplate);

		Result.AddItem(DisplayInfo);
	}

	return Result;
}

static function string GetRiskDifficultyColouredString(int RiskLevel)
{
	local string Text, TextColor;

	Text = class'X2StrategyGameRulesetDataStructures'.default.CovertActionRiskLabels[RiskLevel];
	
	switch (RiskLevel)
	{
	case 0: TextColor = "53b45e";   break; // green
	case 1: TextColor = "fdce2b";   break; // yellow
	case 2: TextColor = "e6af31";   break; // yellow-orange
	case 3: TextColor = "e69831";   break; // orange
	case 4: TextColor = "e66d31";   break; // orange-red
	case 5: TextColor = "bf1e2e";   break; // red
	}

	return ColourText(Text, TextColor);
}

protected static function int SortRisksByDifficulty(CovertActionRisk a, CovertActionRisk b)
{
	if (a.Level > b.Level)
		return 1;
	else if (a.Level < b.Level)
		return -1;
	else
		return 0;
}

protected static function int ConvertChanceToRiskLevel(int chanceToOccur)
{
	local array<int> RiskThresholds;
	local int Threshold, iRiskLevel;

	RiskThresholds = class'X2StrategyGameRulesetDataStructures'.default.RiskThresholds;

	foreach RiskThresholds(Threshold, iRiskLevel)
	{
		if (chanceToOccur <= Threshold)
		{
			break;
		}
	}

	return iRiskLevel;
}

// Does same thing as UIUtilities_Strategy::GetStrategyCostString but doesn't colour the text
static function String GetStrategyCostStringNoColors(StrategyCost StratCost, array<StrategyCostScalar> CostScalars, optional float DiscountPercent)
{
	local int iResource, iArtifact, Quantity;
	local String strCost, strResourceCost, strArtifactCost;
	local StrategyCost ScaledStratCost;
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	ScaledStratCost = XComHQ.GetScaledStrategyCost(StratCost, CostScalars, DiscountPercent);

	for (iArtifact = 0; iArtifact < ScaledStratCost.ArtifactCosts.Length; iArtifact++)
	{
		Quantity = ScaledStratCost.ArtifactCosts[iArtifact].Quantity;
		strArtifactCost = String(Quantity) @ class'UIUtilities_Strategy'.static.GetResourceDisplayName(ScaledStratCost.ArtifactCosts[iArtifact].ItemTemplateName, Quantity);

		if (iArtifact < ScaledStratCost.ArtifactCosts.Length - 1)
		{
			strArtifactCost $= ",";
		}
		else if (ScaledStratCost.ResourceCosts.Length > 0)
		{
			strArtifactCost $= ",";
		}

		if (strCost == "")
		{
			strCost $= strArtifactCost; 
		}
		else
		{
			strCost @= strArtifactCost;
		}
	}

	for (iResource = 0; iResource < ScaledStratCost.ResourceCosts.Length; iResource++)
	{
		Quantity = ScaledStratCost.ResourceCosts[iResource].Quantity;
		strResourceCost = String(Quantity) @ class'UIUtilities_Strategy'.static.GetResourceDisplayName(ScaledStratCost.ResourceCosts[iResource].ItemTemplateName, Quantity);

		if (iResource < ScaledStratCost.ResourceCosts.Length - 1)
		{
			strResourceCost $= ",";
		}

		if (strCost == "")
		{
			strCost $= strResourceCost;
		}
		else
		{
			strCost @= strResourceCost;
		}
	}

	return class'UIUtilities_Text'.static.FormatCommaSeparatedNouns(strCost);
}

static function CamRingView(float InterpTime)
{
	local XComGameState_FacilityXCom FacilityState;

	FacilityState = `XCOMHQ.GetFacilityByName('ResistanceRing');
	if (FacilityState == none) return;

	`HQPRES.CAMLookAtRoom(FacilityState.GetRoom(), InterpTime);
}

static function BuildUIAlert_CovertInfiltration (
	out DynamicPropertySet PropertySet,
	Name AlertName,
	delegate<X2StrategyGameRulesetDataStructures.AlertCallback> CallbackFunction,
	Name EventToTrigger,
	string SoundToPlay,
	bool bImmediateDisplay = true
)
{
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert_CovertInfiltration', AlertName, CallbackFunction, bImmediateDisplay, true, true, false);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicNameProperty(PropertySet, 'EventToTrigger', EventToTrigger);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicStringProperty(PropertySet, 'SoundToPlay', SoundToPlay);
}

static function RewardsIntercepted (StateObjectReference ContainerRef)
{
	local XComHQPresentationLayer HQPres;
	local DynamicPropertySet PropertySet;

	HQPres = `HQPRES;

	BuildUIAlert_CovertInfiltration(PropertySet, 'eAlert_RewardsIntercepted', none, 'RewardsInterceptedPopup', "Geoscape_DoomIncrease");
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicIntProperty(PropertySet, 'ContainerObjectID', ContainerRef.ObjectID);
	HQPres.QueueDynamicPopup(PropertySet);
}

static function InfiltrationActionAvaliable(optional StateObjectReference ActionRef, optional XComGameState NewGameState)
{
	local XComHQPresentationLayer HQPres;
	local DynamicPropertySet PropertySet;

	HQPres = `HQPRES;

	HQPres.BuildUIAlert(PropertySet, 'eAlert_CovertActions', InfiltrationActionAvaliableCB, 'NewInfiltrationPopup', "Geoscape_NewResistOpsMissions", NewGameState == none);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicIntProperty(PropertySet, 'ActionObjectID', ActionRef.ObjectID);
	HQPres.QueueDynamicPopup(PropertySet, NewGameState);
}

simulated protected function InfiltrationActionAvaliableCB(Name eAction, out DynamicPropertySet AlertData, optional bool bInstant = false)
{
	local XComHQPresentationLayer HQPres;
	local StateObjectReference ActionRef;

	ActionRef.ObjectID = class'X2StrategyGameRulesetDataStructures'.static.GetDynamicIntProperty(AlertData, 'ActionObjectID');
	HQPres = `HQPRES;

	if (eAction == 'eUIAction_Accept')
	{
		UICovertActionsGeoscape(ActionRef);

		if (`GAME.GetGeoscape().IsScanning())
		{
			HQPres.StrategyMap2D.ToggleScan();
		}
	}
}

static function AssaultMissionAvaliable (XComGameState_MissionSite MissionState)
{
	GeoscapeOpportunityNotification(MissionState, default.strAssaultAvaliableHeader, MissionState.GetUIButtonIcon(), MissionState.GetMissionObjectiveText());
}

static function AssaultMissionExpiring (XComGameState_MissionSite MissionState)
{
	GeoscapeOpportunityNotification(MissionState, default.strAssaultExpiringHeader, MissionState.GetUIButtonIcon(), MissionState.GetMissionObjectiveText(), eUIState_Warning);
}

static function InfiltrationAvaliable (XComGameState_MissionSiteInfiltration InfiltrationState)
{
	GeoscapeOpportunityNotification(InfiltrationState, default.strInfiltrationAvaliableHeader, InfiltrationState.GetUIButtonIcon(), InfiltrationState.GetMissionObjectiveText());
}

static function InfiltrationExpiring (XComGameState_MissionSiteInfiltration InfiltrationState)
{
	GeoscapeOpportunityNotification(InfiltrationState, default.strInfiltrationExpiringHeader, InfiltrationState.GetUIButtonIcon(), InfiltrationState.GetMissionObjectiveText(), eUIState_Warning);
}

static function CovertActionAvaliable (XComGameState_CovertAction ActionState)
{
	GeoscapeOpportunityNotification(ActionState, default.strCovertActionAvaliableHeader, "img:///UILibrary_XPACK_Common.MissionIcon_CovertAction", GetActionObjective(ActionState));
}

static function CovertActionExpiring (XComGameState_CovertAction ActionState)
{
	GeoscapeOpportunityNotification(ActionState, default.strCovertActionExpiringHeader, "img:///UILibrary_XPACK_Common.MissionIcon_CovertAction", GetActionObjective(ActionState), eUIState_Warning);
}

static function GeoscapeOpportunityNotification (XComGameState_GeoscapeEntity GeoscapeEntity, string Header, string IconPath, string Description, optional EUIState eState = eUIState_Normal)
{
	local XComGameState_Continent ContinentState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Activity ActivityState;
	local XComHQPresentationLayer HQPres;
	local string strLocation;

	ContinentState = GeoscapeEntity.GetContinent();
	RegionState = GeoscapeEntity.GetWorldRegion();

	if (RegionState != none) strLocation = RegionState.GetDisplayName();
	else if (ContinentState != none) strLocation = ContinentState.GetMyTemplate().DisplayName;
	else strLocation = default.strOpportunityAvaliableUnknownLocation;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromObject(GeoscapeEntity);

	HQPres = `HQPRES;
	HQPres.NotifyBanner(Header, IconPath, strLocation, Description, eState);
	`XSTRATEGYSOUNDMGR.PlaySoundEvent(ActivityState.GetMyTemplate().AvailableSound);
	
	// If we are currently looking at the map, refresh the list of missions in the HUD
	// so that the new one appears there
	if (HQPres.ScreenStack.GetCurrentScreen() == HQPres.StrategyMap2D)
	{
		HQPres.StrategyMap2D.UpdateMissions();
	}

	if (`GAME.GetGeoscape().IsScanning())
	{
		HQPres.StrategyMap2D.ToggleScan();
	}
}

static function string GetActionObjective (XComGameState_CovertAction ActionState)
{
	local XComGameState_Activity ActivityState;
	local XComGameState_ActivityChain ChainState;
	local XGParamTag Tag;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(ActionState);
	if (ActivityState == none) ActivityState = class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(ActionState);

	if (ActivityState != none)
	{
		ChainState = ActivityState.GetActivityChain();

		Tag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		Tag.IntValue0 = ActivityState.GetStageIndex() + 1;
		Tag.IntValue1 = ChainState.StageRefs.Length;
		
		return `XEXPAND.ExpandString(default.strChainStatusPrefix) @ ChainState.GetOverviewTitle();
	}

	if (ActionState.GetObjective() != "")
	{
		return ActionState.GetObjective();
	}
	
	return ActionState.GetDisplayName();
}

static function bool SetCountdownTextAndColor(int Turns, XComLWTuple Tuple)
{
	local XGParamTag kTag;

	if (Turns > 2)
	{
		kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		kTag.StrValue0 = string(Turns);

		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Good);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(`XEXPAND.ExpandString(default.strReinforcementsBodyWarning), eUIState_Good);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Good);
	}
	else if (Turns > 1)
	{
		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Warning);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(default.strReinforcementsBodyImminent, eUIState_Warning);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Warning);
	}
	else if (Turns > 0)
	{
		Tuple.Data[1].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsTitle, eUIState_Bad);
		Tuple.Data[2].s = class'UIUtilities_Text'.static.GetColoredText(class'UITacticalHUD_Countdown'.default.m_strReinforcementsBody, eUIState_Bad);
		Tuple.Data[3].s = class'UIUtilities_Colors'.static.GetHexColorFromState(eUIState_Bad);
	}
	else
	{
		return false;
	}

	return true;
}

static function string GetAcademyTargetRank (XComGameState_Unit UnitState)
{
	return UnitState.GetSoldierRankName(
		class'X2Helper_Infiltration'.static.GetAcademyTrainingTargetRank(
			UnitState.GetReference()
		)
	);
}

static function string GetAcademyMaxRank ()
{
	return class'X2ExperienceConfig'.static.GetRankName(class'X2Helper_Infiltration'.static.GetAcademyTrainingMaxRank(), '');
}

static function string GetLabelForActivityCompletionStatus (EActivityCompletion eCompletion)
{
	switch (eCompletion)
	{
		case eActivityCompletion_NotReached:
			return default.strCompletionStatusLabel_NotReached;

		case eActivityCompletion_NotCompleted:
			return default.strCompletionStatusLabel_NotCompleted;

		case eActivityCompletion_Expired:
			return default.strCompletionStatusLabel_Expired;

		case eActivityCompletion_Failure:
			return default.strCompletionStatusLabel_Failure;

		case eActivityCompletion_PartialSuccess:
			return default.strCompletionStatusLabel_PartialSuccess;

		case eActivityCompletion_Success:
			return default.strCompletionStatusLabel_Success;
	}

	return "WRONG EActivityCompletion";
}