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

	return Template;
}

static function X2DataTemplate CreateP1DarkEventTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P1DarkEvent');

	return Template;
}

static function X2DataTemplate CreateP1JailbreakTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P1Jailbreak');

	return Template;
}

static function X2DataTemplate CreateP2DarkVIPTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P2DarkVIP');

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

	return Template;
}

static function X2DataTemplate CreateP2EngineerTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P2Engineer');

	return Template;
}

static function X2DataTemplate CreateP2ScientistTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_P2Scientist');

	return Template;
}
