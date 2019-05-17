class X2ActivityTemplate_Infiltration extends X2ActivityTemplate_Mission;

var name CovertActionName;

delegate array<StateObjectReference> InitializeRewards(XComGameState NewGameState, XComGameState_MissionSiteInfiltration MissionSite);

// TODO:
// (1) Remove X2CovertMissionInfoTemplate
// (2) Make just one infiltration mission source
// (3) Create XComGameState_MissionSiteInfiltration when the covert action itself is created and pick the mission type then