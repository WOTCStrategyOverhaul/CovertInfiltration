class X2Encyclopedia_InfiltrationTutorialClosure extends Object;

var name StageName;

`include(CovertInfiltration/Src/CovertInfiltration/MCM_API_CfgHelpersStatic.uci)
`MCM_CH_VersionCheckerStatic(class'ModConfigMenu_Defaults'.default.iVERSION, class'UIListener_ModConfigMenu'.default.CONFIG_VERSION)

function bool ShouldShow ()
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local bool EnableTutorial;

	EnableTutorial = `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.ENABLE_TUTORIAL_DEFAULT, class'UIListener_ModConfigMenu'.default.ENABLE_TUTORIAL);
	if (!EnableTutorial) return true;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	
	return CIInfo.TutorialStagesShown.Find(StageName) != INDEX_NONE;
}
