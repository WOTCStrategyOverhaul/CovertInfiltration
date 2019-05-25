class X2ActivityTemplate_Mission extends X2ActivityTemplate abstract;

const MISSION_SOURCE_NAME = 'MissionSource_ActivityCI';

var array<name> MissionRewards;
var string UIButtonIcon;

delegate array<StateObjectReference> InitializeMissionRewards (XComGameState NewGameState, XComGameState_Activity ActivityState);
delegate PreMissionSetup (XComGameState NewGameState, XComGameState_Activity ActivityState);

////////////////////////////////////////////
/// Proxied from X2MissionSourceTemplate ///
////////////////////////////////////////////

delegate OnSuccess (XComGameState NewGameState, XComGameState_Activity ActivityState);
delegate OnFailure (XComGameState NewGameState, XComGameState_Activity ActivityState);
delegate OnExpire (XComGameState NewGameState, XComGameState_Activity ActivityState);

delegate OnTriadSuccess (XComGameState NewGameState, XComGameState_Activity ActivityState);
delegate OnTriadFailure (XComGameState NewGameState, XComGameState_Activity ActivityState);

delegate int GetMissionDifficulty (XComGameState_Activity ActivityState);
delegate string GetOverworldMeshPath (XComGameState_Activity ActivityState);
delegate bool WasMissionSuccessful (XComGameState_BattleData BattleDataState);
delegate array<name> GetSitreps (XComGameState_MissionSite MissionState, XComGameState_Activity ActivityState);

delegate bool RequireLaunchMissionPopup (XComGameState_MissionSite MissionState, XComGameState_Activity ActivityState);
delegate bool CanLaunchMission (XComGameState_MissionSite MissionState, XComGameState_Activity ActivityState);