//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: "Manager" for the CI's tutorial messages/popups. The external code is 
//           supposed to call the public functions that correspond to the tutorial stages
//           and this class will handle internally checking, recording and showing
//           the messages
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIUtilities_InfiltrationTutorial extends Object;

// Welcome
var localized string strWelcomeHeader;
var localized string strWelcomeBody;

// On Geoscape
var localized string strGeoscapeEntryHeader;
var localized string strGeoscapeEntryBody;

// On Squad Select
var localized string strCovertActionLoadoutHeader;
var localized string strCovertActionLoadoutBody;
var localized string strInfiltrationLoadoutHeader;
var localized string strInfiltrationLoadoutBody;
var localized string strAssaultLoadoutHeader;
var localized string strAssaultLoadoutBody;

// On Mission Readout
var localized string strOverInfiltrationHeader;
var localized string strOverInfiltrationBody;

// On Covert Action Debrief
var localized string strCovertActionFinishedHeader;
var localized string strCovertActionFinishedBody;

// On Empty Room
var localized string strFacilityRingHeader;
var localized string strFacilityRingBody;

// On Chain Selected
var localized string strActivityChainsHeader;
var localized string strActivityChainsBody;

// On Chain Overview
var localized string strResistanceInformantsHeader;
var localized string strResistanceInformantsBody;

// On Alien Facility Built
var localized string strFacilityAssaultsHeader;
var localized string strFacilityAssaultsBody;

// On Dark Event Preview
var localized string strDarkEventsHeader;
var localized string strDarkEventsBody;

// On In-Progress Operation Selected
var localized string strCovertOpsAbortHeader;
var localized string strCovertOpsAbortBody;

// On Mission Start
var localized string strSupplyExtractHeader;
var localized string strSupplyExtractBody;
var localized string strAvatarCaptureHeader;
var localized string strAvatarCaptureBody;

// On Second Mission Completed
var localized string strCrewLimitHeader;
var localized string strCrewLimitBody;

// On Fifth Mission Completed
var localized string strAdvancedChainsHeader;
var localized string strAdvancedChainsBody;

// On GTS Facility Built
var localized string strFacilityGTSHeader;
var localized string strFacilityGTSBody;

// On Engineering Bay
var localized string strIndividualBuiltItemsHeader;
var localized string strIndividualBuiltItemsBody;

// On Living Quarters Upgraded
var localized string strCrewExpansionHeader;
var localized string strCrewExpansionBody;

// On mindshield on tired soldiers in squad select
var localized string strMindShieldOnTiredNerfHeader;
var localized string strMindShieldOnTiredNerfBody;

`include(CovertInfiltration\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

///////////////////////
/// Tutorial popups ///
///////////////////////
// Note for functions/stages that trigger more than one popup: 
// The popups will be shown in the reverse order - the last one will be shown first

static function Welcome ()
{
	if (!ShouldShowPopup('Welcome')) return;
	
	UITutorialBoxLarge(default.strWelcomeHeader, `XEXPAND.ExpandString(default.strWelcomeBody));
}

static function GeoscapeEntry ()
{
	if (!ShouldShowPopup('GeoscapeEntry')) return;
	
	UITutorialBoxLarge(default.strGeoscapeEntryHeader, `XEXPAND.ExpandString(default.strGeoscapeEntryBody));
}

static function CovertActionLoadout ()
{
	if (!ShouldShowPopup('CovertActionLoadout')) return;

	UITutorialBoxLarge(default.strCovertActionLoadoutHeader, `XEXPAND.ExpandString(default.strCovertActionLoadoutBody));
}

static function InfiltrationLoadout ()
{
	if (!ShouldShowPopup('InfiltrationLoadout')) return;

	UITutorialBoxLarge(default.strInfiltrationLoadoutHeader, `XEXPAND.ExpandString(default.strInfiltrationLoadoutBody));
}

static function AssaultLoadout ()
{
	if (!ShouldShowPopup('AssaultLoadout')) return;

	UITutorialBoxLarge(default.strAssaultLoadoutHeader, `XEXPAND.ExpandString(default.strAssaultLoadoutBody));
}

static function OverInfiltration ()
{
	if (!ShouldShowPopup('OverInfiltration')) return;

	UITutorialBoxLarge(default.strOverInfiltrationHeader, `XEXPAND.ExpandString(default.strOverInfiltrationBody));
}

static function CovertActionFinished ()
{
	if (!ShouldShowPopup('CovertActionFinished')) return;

	UITutorialBoxLarge(default.strCovertActionFinishedHeader, `XEXPAND.ExpandString(default.strCovertActionFinishedBody));
}

static function FacilityChanges ()
{
	if (!ShouldShowPopup('FacilityChanges')) return;

	UITutorialBoxLarge(default.strFacilityRingHeader, `XEXPAND.ExpandString(default.strFacilityRingBody));
}

static function GuerillaTactics ()
{
	if (!ShouldShowPopup('GuerillaTactics')) return;

	UITutorialBoxLarge(default.strFacilityGTSHeader, `XEXPAND.ExpandString(default.strFacilityGTSBody));
}

static function ActivityChains ()
{
	if (!ShouldShowPopup('ActivityChains')) return;

	UITutorialBoxLarge(default.strActivityChainsHeader, `XEXPAND.ExpandString(default.strActivityChainsBody));
}

static function ResistanceInformants ()
{
	if (!ShouldShowPopup('ResistanceInformants')) return;

	UITutorialBoxLarge(default.strResistanceInformantsHeader, `XEXPAND.ExpandString(default.strResistanceInformantsBody));
}

static function AlienFacilityBuilt ()
{
	if (!ShouldShowPopup('AlienFacilityBuilt')) return;

	UITutorialBoxLarge(default.strFacilityAssaultsHeader, `XEXPAND.ExpandString(default.strFacilityAssaultsBody));
}

static function DarkEventPreview ()
{
	if (!ShouldShowPopup('DarkEventPreview')) return;

	UITutorialBoxLarge(default.strDarkEventsHeader, `XEXPAND.ExpandString(default.strDarkEventsBody));
}

static function CovertOpsAbort ()
{
	if (!ShouldShowPopup('CovertOpsAbort')) return;

	UITutorialBoxLarge(default.strCovertOpsAbortHeader, `XEXPAND.ExpandString(default.strCovertOpsAbortBody));
}

static function CrewLimit ()
{
	if (!ShouldShowPopup('CrewLimit')) return;
	
	UITutorialBoxLarge(default.strCrewLimitHeader, `XEXPAND.ExpandString(default.strCrewLimitBody));
}

static function CrewExpansion ()
{
	if (!ShouldShowPopup('CrewExpansion')) return;
	
	UITutorialBoxLarge(default.strCrewExpansionHeader, `XEXPAND.ExpandString(default.strCrewExpansionBody));
}

static function AdvancedChains ()
{
	if (!ShouldShowPopup('AdvancedChains')) return;

	UITutorialBoxLarge(default.strAdvancedChainsHeader, `XEXPAND.ExpandString(default.strAdvancedChainsBody));
}

static function IndividualBuiltItems ()
{
	if (!ShouldShowPopup('IndividualBuiltItems')) return;

	UITutorialBoxLarge(default.strIndividualBuiltItemsHeader, `XEXPAND.ExpandString(default.strIndividualBuiltItemsBody));
}

static function MindShieldOnTiredNerf ()
{
	if (!ShouldShowPopupIgnoreMCM('MindShieldOnTiredNerf')) return;

	UITutorialBoxLarge(default.strMindShieldOnTiredNerfHeader, `XEXPAND.ExpandString(default.strMindShieldOnTiredNerfBody));
}

// This is required as we want to show the popup when the facility UI stuff is gone and Geoscape control is returned to the player
static function QueueAlienFacilityBuilt ()
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;

	// Set the tutorial flag, if we didn't see the tutorial before
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	if (!CIInfo.bAlienFacilityBuiltTutorialPending && CIInfo.TutorialStagesShown.Find('AlienFacilityBuilt') == INDEX_NONE)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Turn on bAlienFacilityBuiltTutorialPending");
		
		CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
		CIInfo.bAlienFacilityBuiltTutorialPending = true;
		
		`SubmitGameState(NewGameState);
	}
}

static function SupplyExtractMission ()
{
	if (!ShouldShowPopup('SupplyExtract')) return;

	class'XComGameStateContext_TutorialBox'.static.AddModalTutorialBoxToHistoryExplicit(default.strSupplyExtractHeader, default.strSupplyExtractBody, "img:///UILibrary_XPACK_StrategyImages.CovertOp_Recover_X_Supplies");
}

static function AvatarCaptureMission ()
{
	class'XComGameStateContext_TutorialBox'.static.AddModalTutorialBoxToHistoryExplicit(default.strAvatarCaptureHeader, default.strAvatarCaptureBody, "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress");
}

// TODO: need to standardize all the function names here, some are titled with the
// subject of their tutorials and some are titled with the event that triggers them

///////////////
/// Helpers ///
///////////////

static protected function bool ShouldShowPopupIgnoreMCM (name StageName, optional array<name> PrecedingStages)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;
	local name RequiredStageName;
	
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	
	// Check if this tutorial stage has been shown already
	if (CIInfo.TutorialStagesShown.Find(StageName) != INDEX_NONE) return false;

	// Check if all prerequisites have been met
	foreach PrecedingStages(RequiredStageName)
	{
		if (CIInfo.TutorialStagesShown.Find(RequiredStageName) == INDEX_NONE) return false;
	}

	// Record the stage as completed
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Marking tutorial stage complete");
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
	CIInfo.TutorialStagesShown.AddItem(StageName);
	`SubmitGameState(NewGameState);

	// Signal to show the popup
	return true;
}

static protected function bool ShouldShowPopup (name StageName, optional array<name> PrecedingStages)
{
	local bool EnableTutorial;

	EnableTutorial = `GETMCMVAR(ENABLE_TUTORIAL);
	if (!EnableTutorial) return false;

	return ShouldShowPopupIgnoreMCM(StageName, PrecedingStages);
}

static protected function UITutorialBoxLarge (string strTitle, string strDescription)
{
	local XComPresentationLayerBase PresBase;
	local UITutorialBoxLarge TheScreen;

	PresBase = `PRESBASE;

	TheScreen = PresBase.Spawn(class'UITutorialBoxLarge', PresBase);
	PresBase.ScreenStack.Push(TheScreen);

	TheScreen.SetContents(strTitle, strDescription);
}