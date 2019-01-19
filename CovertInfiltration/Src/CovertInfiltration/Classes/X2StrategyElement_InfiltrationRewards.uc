class X2StrategyElement_InfiltrationRewards extends X2StrategyElement
	dependson(X2RewardTemplate)
	config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;
	
	Rewards.AddItem(CreateP1SupplyRaidTemplate());
	Rewards.AddItem(CreateP1DarkEventTemplate());
	Rewards.AddItem(CreateP1JailbreakTemplate());

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
