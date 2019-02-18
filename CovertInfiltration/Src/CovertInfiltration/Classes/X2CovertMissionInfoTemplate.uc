//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class adds a new template which controls
//           mission type and rewards for infiltration CAs
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2CovertMissionInfoTemplate extends X2DataTemplate;

var array<name> MissionRewards;
var name MissionSource;
var Delegate<InitInfilDelegate> InitMissionFn;

delegate InitInfilDelegate(XComGameState NewGameState, XComGameState_CovertAction Action, XComGameState_MissionSiteInfiltration MissionSite);

defaultproperties
{
	bShouldCreateDifficultyVariants=false
	TemplateAvailability=BITFIELD_GAMEAREA_Singleplayer
}
