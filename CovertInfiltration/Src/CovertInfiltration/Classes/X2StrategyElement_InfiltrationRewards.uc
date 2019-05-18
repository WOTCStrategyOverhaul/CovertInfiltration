//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf and Xymanek
//  PURPOSE: Rewards used in infiltration actions and missions
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationRewards extends X2StrategyElement config(Infiltration);

var config int P2_EXPIRATION_BASE_TIME;
var config int P2_EXPIRATION_VARIANCE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;
	
	// TODO
	Rewards.Length = 0;

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