class X2ActivityTemplate_Mission extends X2ActivityTemplate abstract;

var array<name> MissionFamilies; // Used for selecting mission type
var array<name> MissionRewards;
var string UIButtonIcon;

delegate OnSuccessDelegate(XComGameState NewGameState, XComGameState_MissionSite MissionState);
delegate OnFailureDelegate(XComGameState NewGameState, XComGameState_MissionSite MissionState);
delegate int GetMissionDifficulty(XComGameState_MissionSite MissionState);
delegate string GetOverworldMeshPath(XComGameState_MissionSite MissionState);
delegate bool WasMissionSuccessful(XComGameState_BattleData BattleDataState);