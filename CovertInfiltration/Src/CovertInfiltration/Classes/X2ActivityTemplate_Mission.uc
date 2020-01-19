//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Base template for missions as activity. Contains code common to both
//           assault (instant) and infiltration missions. Note that this is also used
//           by many event listeners. Note that the mission families used are specified
//           in X2Helper_Infiltration::ActivityMissionFamily config to allow for easy
//           changes by other mods
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ActivityTemplate_Mission extends X2ActivityTemplate abstract;

const MISSION_SOURCE_NAME = 'MissionSource_ActivityCI';

var class<UIMission> ScreenClass;
var array<name> MissionRewards;
var int Difficulty; // Meaning depends on the GetMissionDifficulty delegate used
var string OverworldMeshPath;
var string UIButtonIcon;
var string MissionImage;
var bool bAssignFactionToMissionSite;

delegate array<StateObjectReference> InitializeMissionRewards (XComGameState NewGameState, XComGameState_Activity ActivityState);
delegate PreMissionSetup (XComGameState NewGameState, XComGameState_Activity ActivityState);
delegate OnStrategyMapSelected (XComGameState_Activity ActivityState);
delegate OverrideStrategyMapIconTooltip (XComGameState_Activity ActivityState, out string Title, out string Body);
delegate string GetMissionImage (XComGameState_Activity ActivityState);

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
		
		// If this is a dark event reward, and the chain has a dark event attached, connect the two
		if (RewardState.GetMyTemplateName() == 'Reward_DarkEvent')
		{
			if (ActivityState.GetActivityChain().GetChainDarkEvent() != none)
			{
				RewardState.SetReward(ActivityState.GetActivityChain().GetChainDarkEvent().GetReference());
			}
		}

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

	ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityState.ObjectID));
	ActivityState.MarkSuccess(NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, class'X2Helper_Infiltration'.static.GetPostMissionText(ActivityState, true), false);
}

static function GenericOnFailure (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSite MissionState;
	
	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	MissionState.RemoveEntity(NewGameState);
	
	ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityState.ObjectID));
	ActivityState.MarkFailed(NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, class'X2Helper_Infiltration'.static.GetPostMissionText(ActivityState, false), true);
}

static function DefaultOnStrategyMapSelected (XComGameState_Activity ActivityState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComHQPresentationLayer HQPres;
	local UIMission MissionUI;
	
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	HQPres = `HQPRES;

	MissionUI = HQPres.Spawn(ActivityTemplate.ScreenClass, HQPres);
	MissionUI.MissionRef = ActivityState.PrimaryObjectRef;
	HQPres.ScreenStack.Push(MissionUI);
}

static function DefaultOverrideStrategyMapIconTooltip (XComGameState_Activity ActivityState, out string Title, out string Body)
{
	local XComGameState_MissionSite MissionSite;
	
	MissionSite = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	
	// Otherwise no title as the default version is "GetMissionSource().MissionPinLabel"
	// which is useless in our case
	Title = MissionSite.GetMissionObjectiveText();
}

static function string DefaultGetMissionImage (XComGameState_Activity ActivityState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	return ActivityTemplate.MissionImage;
}

static function bool DefaultShouldProgressChain (XComGameState_Activity ActivityState)
{
	return ActivityState.CompletionStatus == eActivityCompletion_Success || ActivityState.CompletionStatus == eActivityCompletion_PartialSuccess;
}

defaultproperties
{
	bAssignFactionToMissionSite = true

	InitializeMissionRewards = GenericInitializeMissionRewards
	GetOverworldMeshPath = GenericGetOverworldMeshPath
	OnStrategyMapSelected = DefaultOnStrategyMapSelected
	OverrideStrategyMapIconTooltip = DefaultOverrideStrategyMapIconTooltip
	GetMissionImage = DefaultGetMissionImage

	OnSuccess = GenericOnSuccess
	OnFailure = GenericOnFailure

	ShouldProgressChain = DefaultShouldProgressChain
	ScreenClass = class'UIMission_Council'
}