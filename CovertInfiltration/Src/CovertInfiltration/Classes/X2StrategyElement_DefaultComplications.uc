
class X2StrategyElement_DefaultComplications extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Complications;
	
	Complications.AddItem(CreateRewardInterceptionTemplate());

	return Complications;
}


static function X2DataTemplate CreateRewardInterceptionTemplate()
{
	local X2ComplicationTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ComplicationTemplate', Template, 'Complication_RewardInterception');
	
	Template.CompName = 'Reward Interception';

	Template.AlwaysSelect = false;
	Template.MinChance = 30;
	Template.MaxChance = 70;

	Template.CompEffect = SpawnRescueMission;
	Template.CanBeChosen = Always;

	return Template;
}

function SpawnRescueMission(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{

}

function bool Always(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	return true;
}