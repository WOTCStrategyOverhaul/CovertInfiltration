//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains all the MissionSource templates
//           required for the mod's infiltrations
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationMissionSources extends X2StrategyElement_DefaultMissionSources;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> MissionSources;
	
	MissionSources.AddItem(CreateActivitySourceTemplate());


	// Old
	MissionSources.AddItem(CreateGatherLeadTemplate());
	MissionSources.AddItem(CreateDarkEventTemplate());
	MissionSources.AddItem(CreateEngineerTemplate());
	MissionSources.AddItem(CreateScientistTemplate());
	MissionSources.AddItem(CreateDarkVIPTemplate());
	
	return MissionSources;
}

static function X2DataTemplate CreateActivitySourceTemplate()
{
	local X2MissionSourceTemplate Template;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, class'X2ActivityTemplate_Mission'.const.MISSION_SOURCE_NAME);
	Template.bShowRewardOnPin = true;

	Template.OnSuccessFn = ActivityOnSuccess;
	Template.OnFailureFn = ActivityOnFailure;
	Template.OnExpireFn = ActivityOnExpire;
	
	Template.OnTriadSuccessFn = ActivityOnTriadSuccess;
	Template.OnTriadFailureFn = ActivityOnTriadFailure;

	Template.GetMissionDifficultyFn = ActivityGetMissionDifficulty;
	Template.WasMissionSuccessfulFn = ActivityWasMissionSuccessful;
	Template.GetOverworldMeshPathFn = ActivityGetOverworldMeshPath;
	Template.GetSitrepsFn = ActivityGetSitreps;

	Template.RequireLaunchMissionPopupFn = ActivityRequireLaunchMissionPopup;
	Template.CanLaunchMissionFn = ActivityCanLaunchMission;

	return Template;
}

static function ActivityOnSuccess (XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.OnSuccess != none)
	{
		ActivityTemplate.OnSuccess(NewGameState, ActivityState);
	}
}

static function ActivityOnFailure (XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.OnFailure != none)
	{
		ActivityTemplate.OnFailure(NewGameState, ActivityState);
	}
}

static function ActivityOnExpire (XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.OnExpire != none)
	{
		ActivityTemplate.OnExpire(NewGameState, ActivityState);
	}
}

static function ActivityOnTriadSuccess (XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.OnTriadSuccess != none)
	{
		ActivityTemplate.OnTriadSuccess(NewGameState, ActivityState);
	}
}

static function ActivityOnTriadFailure (XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.OnTriadFailure != none)
	{
		ActivityTemplate.OnTriadFailure(NewGameState, ActivityState);
	}
}

static function int ActivityGetMissionDifficulty (XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.GetMissionDifficulty != none)
	{
		return ActivityTemplate.GetMissionDifficulty(ActivityState);
	}

	// Copied from XComGameState_MissionSite::GetMissionDifficulty
	`RedScreen("No difficulty function for activity. Defaulting to medium difficulty");
	return 2;
}

static function bool ActivityWasMissionSuccessful (XComGameState_BattleData BattleDataState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObjectID(BattleDataState.m_iMissionID);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.WasMissionSuccessful != none)
	{
		return ActivityTemplate.WasMissionSuccessful(BattleDataState);
	}

	// Default is won. See XComGameState_BattleData::SetVictoriousPlayer
	return true;
}

static function string ActivityGetOverworldMeshPath (XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.GetOverworldMeshPath != none)
	{
		return ActivityTemplate.GetOverworldMeshPath(ActivityState);
	}

	// See XComGameState_MissionSite::GetStaticMesh
	return "";
}

static function array<name> ActivityGetSitreps (XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	local array<name> EmptyArray;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.GetSitreps != none)
	{
		return ActivityTemplate.GetSitreps(MissionState, ActivityState);
	}

	// See XComGameState_MissionSite::SetMissionData
	EmptyArray.Length = 0; // Prevent compiler whining
	return EmptyArray;
}

static function bool ActivityRequireLaunchMissionPopup (XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.RequireLaunchMissionPopup != none)
	{
		return ActivityTemplate.RequireLaunchMissionPopup(MissionState, ActivityState);
	}

	return false;
}

static function bool ActivityCanLaunchMission (XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(MissionState);
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate.CanLaunchMission != none)
	{
		return ActivityTemplate.CanLaunchMission(MissionState, ActivityState);
	}

	return true;
}






///////////
/// Old ///
///////////

static function X2DataTemplate CreateGatherLeadTemplate()
{
	local X2MissionSourceTemplate Template;
	//local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_GatherLead');
	Template.bIncreasesForceLevel = false;
	Template.bShowRewardOnPin = true;
	Template.OnSuccessFn = GatherLeadOnSuccess;
	Template.OnFailureFn = GatherLeadOnFailure;
	Template.DifficultyValue = 1;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps";
	Template.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Guerrilla_Ops";
	Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonth;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;

	return Template;
}

// in p1s add spawning p2 on strategic success (if strat objectives were completed)
// also queue the ca alert so that the player is notified to go to covert ops screen when entering geoscape
static function GatherLeadOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	GiveRewards(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);
	`XEVENTMGR.TriggerEvent('GuerillaOpComplete', , , NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsCompleted');
}

static function GatherLeadOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	MissionState.RemoveEntity(NewGameState);
	`XEVENTMGR.TriggerEvent('GuerillaOpComplete', , , NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsFailed');
}

static function X2DataTemplate CreateDarkEventTemplate()
{
	local X2MissionSourceTemplate Template;
	//local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_DarkEvent');
	Template.bIncreasesForceLevel = false;
	Template.bShowRewardOnPin = true;
	Template.OnSuccessFn = DarkEventOnSuccess;
	Template.DifficultyValue = 1;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps";
	Template.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Guerrilla_Ops";
	Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonth;
	Template.WasMissionSuccessfulFn = StrategyObjectivePlusSweepCompleted;

	return Template;
}

static function DarkEventOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	if(MissionState.HasDarkEvent())
	{
		StopMissionDarkEvent(NewGameState, MissionState);
	}

	GiveRewards(NewGameState, MissionState);
	
	MissionState.RemoveEntity(NewGameState);
	`XEVENTMGR.TriggerEvent('GuerillaOpComplete', , , NewGameState);

	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsCompleted');
}

static function X2DataTemplate CreateEngineerTemplate()
{
	local X2MissionSourceTemplate Template;
	//local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_Engineer');
	Template.bIncreasesForceLevel = false;
	Template.OnSuccessFn = Phase2OnSuccess;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.Council_VIP";
	Template.MissionImage = "img://UILibrary_Common.Councilman_small";
	Template.GetMissionDifficultyFn = GetCouncilMissionDifficulty;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;

	return Template;
}

static function X2DataTemplate CreateScientistTemplate()
{
	local X2MissionSourceTemplate Template;
	//local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_Scientist');
	Template.bIncreasesForceLevel = false;
	Template.OnSuccessFn = Phase2OnSuccess;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.Council_VIP";
	Template.MissionImage = "img://UILibrary_Common.Councilman_small";
	Template.GetMissionDifficultyFn = GetCouncilMissionDifficulty;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;

	return Template;
}

static function X2DataTemplate CreateDarkVIPTemplate()
{
	local X2MissionSourceTemplate Template;
	//local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_DarkVIP');
	Template.bIncreasesForceLevel = false;
	Template.OnSuccessFn = Phase2OnSuccess;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.Council_VIP";
	Template.MissionImage = "img://UILibrary_Common.Councilman_small";
	Template.GetMissionDifficultyFn = GetCouncilMissionDifficulty;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;

	return Template;
}

static function Phase2OnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local array<int> ExcludeIndices;

	ExcludeIndices = GetCouncilExcludeRewards(MissionState);
	MissionState.bUsePartialSuccessText = (ExcludeIndices.Length > 0);
	GiveRewards(NewGameState, MissionState, ExcludeIndices);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_CouncilMissionsCompleted');
}