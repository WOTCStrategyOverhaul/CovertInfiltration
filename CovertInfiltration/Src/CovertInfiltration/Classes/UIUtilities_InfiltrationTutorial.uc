class UIUtilities_InfiltrationTutorial extends Object;

var localized string strGeoscapeEntryHeader;
var localized string strGeoscapeEntryBody;

var localized string strCovertActionLoadoutHeader;
var localized string strCovertActionLoadoutBody;

var localized string strInfiltrationSelectionHeader;
var localized string strInfiltrationSelectionBody;

var localized string strCovertActionFinishedHeader;
var localized string strCovertActionFinishedBody;

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