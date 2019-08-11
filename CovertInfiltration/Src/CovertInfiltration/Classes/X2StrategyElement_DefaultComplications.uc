
class X2StrategyElement_DefaultComplications extends X2StrategyElement config(Infiltration);

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

	Template.OnChainComplete = SpawnRescueMission;
	Template.OnChainFailed = DoNothing;
	Template.CanBeChosen = AlwaysChoose; // TODO: change this to something that detects supply/intel rewards

	return Template;
}

function DoNothing(XComGameState NewGameState, XComGameState_ActivityChain ChainState) {}

function SpawnRescueMission(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	// TODO: make this spawn something
}

function bool AlwaysChoose(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	return true;
}