//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Template which controls mission type and rewards for infiltration CAs
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2CovertMissionInfoTemplate extends X2DataTemplate;

var array<name> MissionRewards;
var name MissionSource;

delegate array<StateObjectReference> InitializeRewards(XComGameState NewGameState, XComGameState_MissionSiteInfiltration MissionSite, X2CovertMissionInfoTemplate CovertMissionTemplate);

// Use this for arbitrary editing of MissionSite (when not covered by delegates above)
delegate PreMissionSetup(XComGameState NewGameState, XComGameState_MissionSiteInfiltration MissionSite, X2CovertMissionInfoTemplate CovertMissionTemplate);

defaultproperties
{
	bShouldCreateDifficultyVariants=false
	TemplateAvailability=BITFIELD_GAMEAREA_Singleplayer
}
