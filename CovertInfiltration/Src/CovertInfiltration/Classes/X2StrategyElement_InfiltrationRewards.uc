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
	Rewards.AddItem(CreateGatherLeadDarkEventReward());

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

static function X2RewardTemplate CreateGatherLeadDarkEventReward()
{
	local X2RewardTemplate Template;
	
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_GatherLeadDarkEvent');
	Template.GetRewardStringFn = GatherLeadString;
	Template.GiveRewardFn = GiveGatherLeadDarkEvent;

	return Template;
}

static protected function string GatherLeadString(XComGameState_Reward RewardState)
{
	return "Gather lead";
}

static protected function GiveGatherLeadDarkEvent(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder=false, optional int OrderHours=-1)
{
	local XComGameState_ResistanceFaction FactionState;

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FindRandomMetFaction().ObjectID));

	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2DarkEvent');
	SpawnCovertAction(NewGameState, FactionState, 'CovertAction_P2DarkEvent');
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