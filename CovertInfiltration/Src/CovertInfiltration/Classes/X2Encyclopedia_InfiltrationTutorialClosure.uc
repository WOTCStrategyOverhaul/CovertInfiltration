class X2Encyclopedia_InfiltrationTutorialClosure extends Object;

var name StageName;

`include(CovertInfiltration\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

function bool ShouldShow ()
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local bool EnableTutorial;

	EnableTutorial = `GETMCMVAR(ENABLE_TUTORIAL);
	if (!EnableTutorial) return true;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	
	return CIInfo.TutorialStagesShown.Find(StageName) != INDEX_NONE;
}
