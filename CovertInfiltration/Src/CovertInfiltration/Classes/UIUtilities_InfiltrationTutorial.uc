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

// On Geoscape
var localized string strGeoscapeEntryHeader;
var localized string strGeoscapeEntryBody;
var localized string strCrewLimitHeader;
var localized string strCrewLimitBody;

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
var localized string strFacilityGTSHeader;
var localized string strFacilityGTSBody;

// On Chain Selected
var localized string strActivityChainsHeader;
var localized string strActivityChainsBody;

// On Facility Built
var localized string strAdvancedChainsHeader;
var localized string strAdvancedChainsBody;

`include(CovertInfiltration/Src/CovertInfiltration/MCM_API_CfgHelpersStatic.uci)
`MCM_CH_VersionCheckerStatic(class'ModConfigMenu_Defaults'.default.iVERSION, class'UIListener_ModConfigMenu'.default.CONFIG_VERSION)

///////////////////////
/// Tutorial popups ///
///////////////////////

static function GeoscapeEntry ()
{
	if (!ShouldShowPopup('GeoscapeEntry')) return;
	
	UITutorialBoxLarge(default.strGeoscapeEntryHeader, default.strGeoscapeEntryBody, GeoscapeEntry2);
}

static protected function GeoscapeEntry2 ()
{
	UITutorialBoxLarge(default.strCrewLimitHeader, default.strCrewLimitBody);
}

static function CovertActionLoadout ()
{
	if (!ShouldShowPopup('CovertActionLoadout')) return;

	UITutorialBoxLarge(default.strCovertActionLoadoutHeader, default.strCovertActionLoadoutBody);
}

static function InfiltrationLoadout ()
{
	if (!ShouldShowPopup('InfiltrationLoadout')) return;

	UITutorialBoxLarge(default.strInfiltrationLoadoutHeader, default.strInfiltrationLoadoutBody);
}

static function AssaultLoadout ()
{
	if (!ShouldShowPopup('AssaultLoadout')) return;

	UITutorialBoxLarge(default.strAssaultLoadoutHeader, default.strAssaultLoadoutBody);
}

static function OverInfiltration ()
{
	if (!ShouldShowPopup('OverInfiltration')) return;

	UITutorialBoxLarge(default.strOverInfiltrationHeader, default.strOverInfiltrationBody);
}

static function CovertActionFinished ()
{
	if (!ShouldShowPopup('CovertActionFinished')) return;

	UITutorialBoxLarge(default.strCovertActionFinishedHeader, default.strCovertActionFinishedBody);
}

static function FacilityChanges ()
{
	if (!ShouldShowPopup('FacilityChanges')) return;

	UITutorialBoxLarge(default.strFacilityRingHeader, default.strFacilityRingBody, FacilityChanges2);
}

static function FacilityChanges2 ()
{
	UITutorialBoxLarge(default.strFacilityGTSHeader, default.strFacilityGTSBody);
}

static function ActivityChains ()
{
	if (!ShouldShowPopup('ActivityChains')) return;

	UITutorialBoxLarge(default.strActivityChainsHeader, default.strActivityChainsBody);
}

static function AlienFacilityBuilt ()
{
	if (!ShouldShowPopup('AlienFacilityBuilt')) return;

	UITutorialBoxLarge(default.strAdvancedChainsHeader, default.strAdvancedChainsBody);
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

///////////////
/// Helpers ///
///////////////

static protected function bool ShouldShowPopup (name StageName, optional array<name> PrecedingStages)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;
	local name RequiredStageName;
	local bool EnableTutorial;
	
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	
	// Check if tutorial is enabled
	EnableTutorial = `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.ENABLE_TUTORIAL_DEFAULT, class'UIListener_ModConfigMenu'.default.ENABLE_TUTORIAL);
	if (!EnableTutorial) return false;

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

static protected function UITutorialBoxLarge (string strTitle, string strDescription, optional delegate<CI_DataStructures.NoArgsNoReturn> OnRemovedFn)
{
	local XComPresentationLayerBase PresBase;
	local UITutorialBoxLarge TheScreen;

	PresBase = `PRESBASE;

	TheScreen = PresBase.Spawn(class'UITutorialBoxLarge', PresBase);
	PresBase.ScreenStack.Push(TheScreen);

	TheScreen.SetContents(strTitle, strDescription);
	if (OnRemovedFn != none) TheScreen.OnRemovedNoArgsFns.AddItem(OnRemovedFn);
}