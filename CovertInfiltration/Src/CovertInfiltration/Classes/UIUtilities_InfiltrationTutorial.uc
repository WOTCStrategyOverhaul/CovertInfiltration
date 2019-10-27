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

var localized string strGeoscapeEntryHeader;
var localized string strGeoscapeEntryBody;

var localized string strCovertActionLoadoutHeader;
var localized string strCovertActionLoadoutBody;

var localized string strInfiltrationSelectionHeader;
var localized string strInfiltrationSelectionBody;

var localized string strCovertActionFinishedHeader;
var localized string strCovertActionFinishedBody;

var localized string strFacilityChangesHeader;
var localized string strFacilityChangesBody;

var localized string strActivityChainsHeader;
var localized string strActivityChainsBody;

var localized string strAlienFacilityBuiltHeader;
var localized string strAlienFacilityBuiltBody;

`include(CovertInfiltration/Src/CovertInfiltration/MCM_API_CfgHelpersStatic.uci)
`MCM_CH_VersionCheckerStatic(class'ModConfigMenu_Defaults'.default.iVERSION, class'UIListener_ModConfigMenu'.default.CONFIG_VERSION)

///////////////////////
/// Tutorial popups ///
///////////////////////

static function GeoscapeEntry ()
{
	if (!ShouldShowPopup('GeoscapeEntry')) return;

	`PRESBASE.UITutorialBox(default.strGeoscapeEntryHeader, default.strGeoscapeEntryBody, "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress");
}

static function CovertActionLoadout ()
{
	if (!ShouldShowPopup('CovertActionLoadout')) return;

	`PRESBASE.UITutorialBox(default.strCovertActionLoadoutHeader, default.strCovertActionLoadoutBody, "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress");
}

static function InfiltrationSelection ()
{
	if (!ShouldShowPopup('InfiltrationSelection')) return;

	`PRESBASE.UITutorialBox(default.strInfiltrationSelectionHeader, default.strInfiltrationSelectionBody, "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress");
}

static function CovertActionFinished ()
{
	if (!ShouldShowPopup('CovertActionFinished')) return;

	`PRESBASE.UITutorialBox(default.strCovertActionFinishedHeader, default.strCovertActionFinishedBody, "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress");
}

static function FacilityChanges ()
{
	if (!ShouldShowPopup('FacilityChanges')) return;

	`PRESBASE.UITutorialBox(default.strFacilityChangesHeader, default.strFacilityChangesBody, "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress");
}

static function ActivityChains ()
{
	if (!ShouldShowPopup('ActivityChains')) return;

	`PRESBASE.UITutorialBox(default.strActivityChainsHeader, default.strActivityChainsBody, "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress");
}

static function AlienFacilityBuilt ()
{
	if (!ShouldShowPopup('AlienFacilityBuilt')) return;

	`PRESBASE.UITutorialBox(default.strAlienFacilityBuiltHeader, default.strAlienFacilityBuiltBody, "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress");
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