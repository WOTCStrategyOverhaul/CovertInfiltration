class X2ActivityTemplate_Infiltration extends X2ActivityTemplate_Assault;

var name CovertActionName;
var name MissionSourceName;

var array<name> MissionFamilies; // Used for selecting mission type
var array<name> MissionRewards;
var string UIButtonIcon;

delegate array<StateObjectReference> InitializeRewards(XComGameState NewGameState, XComGameState_MissionSiteInfiltration MissionSite);

delegate OnSuccessDelegate(XComGameState NewGameState, XComGameState_MissionSite MissionState);
delegate OnFailureDelegate(XComGameState NewGameState, XComGameState_MissionSite MissionState);
delegate int GetMissionDifficulty(XComGameState_MissionSite MissionState);
delegate string GetOverworldMeshPath(XComGameState_MissionSite MissionState);
delegate bool WasMissionSuccessful(XComGameState_BattleData BattleDataState);

// TODO:
// (1) Remove X2CovertMissionInfoTemplate
// (2) Make just one infiltration mission source
// (3) Create XComGameState_MissionSiteInfiltration when the covert action itself is created and pick the mission type then