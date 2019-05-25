class X2ActivityTemplate_Mission extends X2ActivityTemplate abstract;

const MISSION_SOURCE_NAME = 'MissionSource_ActivityCI';

var array<name> MissionRewards;
var string OverworldMeshPath;
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

///////////////////////////////////////
/// Generic/default implementations ///
///////////////////////////////////////

static function array<StateObjectReference> GenericInitializeMissionRewards (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityTemplate_Mission ActivityTemplate;
	local array<StateObjectReference> RewardRefs;
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local name RewardName;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	
	foreach ActivityTemplate.MissionRewards(RewardName)
	{
		RewardTemplate = X2RewardTemplate(TemplateManager.FindStrategyElementTemplate(RewardName));
		
		RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
		RewardState.GenerateReward(NewGameState,, ActivityState.GetActivityChain().PrimaryRegionRef);

		RewardRefs.AddItem(RewardState.GetReference());
	}

	return RewardRefs;
}

static function string GenericGetOverworldMeshPath (XComGameState_Activity ActivityState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	return ActivityTemplate.OverworldMeshPath;
}

static function GenericOnSuccess (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSite MissionState;

	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	class'X2StrategyElement_DefaultMissionSources'.static.GiveRewards(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);

	ActivityState.MarkSuccess(NewGameState);
}

static function GenericOnFailure (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSite MissionState;
	
	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	MissionState.RemoveEntity(NewGameState);
	
	ActivityState.MarkFailed(NewGameState);
}

defaultproperties
{
	InitializeMissionRewards = GenericInitializeMissionRewards
	GetOverworldMeshPath = GenericGetOverworldMeshPath

	OnSuccess = GenericOnSuccess
	OnFailure = GenericOnFailure
}