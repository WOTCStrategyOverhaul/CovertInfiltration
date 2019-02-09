class X2StrategyElement_InfiltrationRewards extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;
	
	// P1 dummy action rewards
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P1SupplyRaid'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P1DarkEvent'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P1Jailbreak'));

	// P2 dummy action rewards
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P2DarkVIP'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P2DarkEvent'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P2Engineer'));
	Rewards.AddItem(CreateDummyActionRewardTemplate('ActionReward_P2Scientist'));

	// P1 actual rewards
	Rewards.AddItem(CreateGatherLeadActivityReward());
	Rewards.AddItem(CreateGatherLeadTargetReward());
	Rewards.AddItem(CreateGatherLeadPersonnelReward());
	
	// P2 actual rewards
	Rewards.AddItem(CreateP2SupplyRaidReward());

	return Rewards;
}

/////////////////////
/// Dummy rewards ///
/////////////////////
// Used to show something in CA UI

static function X2DataTemplate CreateDummyActionRewardTemplate(name TemplateName)
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, TemplateName);
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static protected function bool RewardNotAvaliable(optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	// Since these rewards are only used for display purposes, we flag them as unavaliable to prevent P1/P2 CAs from randomly spawning
	return false;
}

//////////////////////
/// Actual rewards ///
//////////////////////
// Granted when the mission is completed

static function X2RewardTemplate CreateGatherLeadActivityReward()
{
	local X2RewardTemplate Template;
	
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_GatherLeadActivity');
	Template.GetRewardStringFn = GatherLeadString;
	Template.GiveRewardFn = GiveGatherLeadActivity;

	return Template;
}

static function X2RewardTemplate CreateGatherLeadTargetReward()
{
	local X2RewardTemplate Template;
	
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_GatherLeadTarget');
	Template.GetRewardStringFn = GatherLeadString;
	Template.GiveRewardFn = GiveGatherLeadTarget;

	return Template;
}

static function X2RewardTemplate CreateGatherLeadPersonnelReward()
{
	local X2RewardTemplate Template;
	
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_GatherLeadPersonnel');
	Template.GetRewardStringFn = GatherLeadString;
	Template.GiveRewardFn = GiveGatherLeadPersonnel;

	return Template;
}

static protected function string GatherLeadString(XComGameState_Reward RewardState)
{
	return "Gather Lead";
}

static protected function GiveGatherLeadActivity(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder=false, optional int OrderHours=-1)
{
	local XComGameState_ResistanceFaction FactionState;

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FindRandomMetFaction().ObjectID));

	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2DarkEvent');
	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2DarkEvent');

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(AuxRef, NewGameState);
}

static protected function GiveGatherLeadTarget(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder=false, optional int OrderHours=-1)
{
	local XComGameState_ResistanceFaction FactionState;

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FindRandomMetFaction().ObjectID));

	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2SupplyRaid');
	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2DarkVIP');

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(AuxRef, NewGameState);
}

static protected function GiveGatherLeadPersonnel(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder=false, optional int OrderHours=-1)
{
	local XComGameState_ResistanceFaction FactionState;

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FindRandomMetFaction().ObjectID));

	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2Engineer');
	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2Scientist');

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(AuxRef, NewGameState);
}

static function StateObjectReference FindRandomMetFaction()
{
	local array<XComGameState_ResistanceFaction> MetFactions;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	
	// Find all met factions
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionState.bMetXCom)
		{
			MetFactions.AddItem(FactionState);
		}
	}

	// Pick one faction
	FactionState = MetFactions[`SYNC_RAND_STATIC(MetFactions.Length)];

	return FactionState.GetReference();
}

static protected function SpawnCovertAction(XComGameState NewGameState, XComGameState_ResistanceFaction FactionState, name ActionTemplateName)
{
	local X2StrategyElementTemplateManager StrategyTemplateManager;
	local X2CovertActionTemplate ActionTemplate;
	local array<Name> ExclusionList;
	
	StrategyTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(StrategyTemplateManager.FindStrategyElementTemplate(ActionTemplateName));
	
	FactionState.AddCovertAction(NewGameState, ActionTemplate, ExclusionList);
}

static function X2DataTemplate CreateP2SupplyRaidReward()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'ActionReward_P2SupplyRaid');

	Template.GiveRewardFn = GiveSupplyRaidReward;
	Template.GetRewardStringFn = GetMissionRewardString;
	Template.RewardPopupFn = MissionRewardPopup;
	
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static function GiveSupplyRaidReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));	

	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_None'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_SupplyRaid'));
	
	MissionDuration = float((class'X2StrategyElement_DefaultRewards'.default.MissionMinDuration + `SYNC_RAND_STATIC(class'X2StrategyElement_DefaultRewards'.default.MissionMaxDuration - class'X2StrategyElement_DefaultRewards'.default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	RewardState.RewardObjectReference = MissionState.GetReference();
}

static function string GetMissionRewardString(XComGameState_Reward RewardState)
{
	return RewardState.GetMyTemplate().DisplayName;
}

static function MissionRewardPopup(XComGameState_Reward RewardState)
{
	local XComGameState_MissionSite MissionSite;

	MissionSite = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	if (MissionSite != none && MissionSite.GetMissionSource().MissionPopupFn != none)
	{
		MissionSite.GetMissionSource().MissionPopupFn(MissionSite);
	}
}
