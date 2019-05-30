class X2ActivityTemplate_Assault extends X2ActivityTemplate_Mission;

static function DefaultAssaultSetup (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	CreateMission(NewGameState, ActivityState);
}

static function CreateMission (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_MissionSite MissionState;
	local X2MissionSourceTemplate MissionSource;
	local XComGameState_WorldRegion Region;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MissionSource = X2MissionSourceTemplate(TemplateManager.FindStrategyElementTemplate(MISSION_SOURCE_NAME));
	Region = ActivityState.GetActivityChain().GetPrimaryRegion();

	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));
	ActivityState.PrimaryObjectRef = MissionState.GetReference();
	
	MissionState.BuildMission(
		MissionSource, Region.GetRandom2DLocationInRegion(), Region.GetReference(), InitRewardsStates(NewGameState, ActivityState), true /*bAvailable*/, 
		false /* bExpiring */, -1 /* iHours */, -1 /* iSeconds */, // TODO: Expiry
		/* bUseSpecifiedLevelSeed */, /* LevelSeedOverride */, false /* bSetMissionData */
	);

	class'X2Helper_Infiltration'.static.InitalizeGeneratedMissionFromActivity(GetActivity());
	// TODO: Sitreps, plot, biome
}

static function array<XComGameState_Reward> InitRewardsStates (XComGameState NewGameState, XComGameState_Activity ActivityState, optional bool SubstituteNone = true)
{
	local array<XComGameState_Reward> RewardStates;
	local array<StateObjectReference> RewardRefs;
	local X2ActivityTemplate_Assault Template;
	local StateObjectReference RewardRef;
	local XComGameStateHistory History;

	Template = X2ActivityTemplate_Assault(ActivityState.GetMyTemplate());
	History = `XCOMHISTORY;

	RewardRefs = Template.InitializeMissionRewards(NewGameState, ActivityState);

	foreach RewardRefs(RewardRef)
	{
		RewardStates.AddItem(XComGameState_Reward(History.GetGameStateForObjectID(RewardRef.ObjectID)));
	}

	if (RewardRefs.Length == 0 && SubstituteNone)
	{
		RewardRefs.AddItem(class'X2Helper_Infiltration'.static.CreateRewardNone(NewGameState));
	}

	return RewardStates;
}