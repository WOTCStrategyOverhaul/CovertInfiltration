class X2StrategyElement_InfiltrationRewards extends X2StrategyElement
	dependson(X2RewardTemplate)
	config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;
	
	Rewards.AddItem(CreateP1SupplyRaidTemplate());
	Rewards.AddItem(CreateP1DarkEventTemplate());
	Rewards.AddItem(CreateP1JailbreakTemplate());

	Rewards.AddItem(CreateP2DarkVIPTemplate());
	//Rewards.AddItem(CreateP2SupplyRaidTemplate());
	Rewards.AddItem(CreateP2DarkEventTemplate());
	Rewards.AddItem(CreateP2EngineerTemplate());
	Rewards.AddItem(CreateP2ScientistTemplate());

	return Rewards;
}

static function X2DataTemplate CreateP1SupplyRaidTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P1SupplyRaid');
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static function X2DataTemplate CreateP1DarkEventTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P1DarkEvent');
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static function X2DataTemplate CreateP1JailbreakTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P1Jailbreak');
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static function X2DataTemplate CreateP2DarkVIPTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P2DarkVIP');
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}
/*
static function X2DataTemplate CreateP2SupplyRaidTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P2SupplyRaid');

	return Template;
}
*/
static function X2DataTemplate CreateP2DarkEventTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P2DarkEvent');
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static function X2DataTemplate CreateP2EngineerTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P2Engineer');
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static function X2DataTemplate CreateP2ScientistTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P2Scientist');
	Template.IsRewardAvailableFn = RewardNotAvaliable;

	return Template;
}

static protected function bool RewardNotAvaliable(optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	// Since these rewards are only used for display purposes, we flag them as unavaliable to prevent P1/P2 CAs from randomly spawning
	return false;
}