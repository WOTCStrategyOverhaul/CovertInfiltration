
class X2StrategyElement_DefaultComplications extends X2StrategyElement config(Infiltration);

var config array<name> LootcrateMissions;

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
	Template.OnChainBlocked = DoNothing;
	Template.CanBeChosen = SupplyAndIntelChains;

	// TODO: Subtract half of last chain's resource reward then give it back upon successful completion of intercept chain

	return Template;
}

function DoNothing(XComGameState NewGameState, XComGameState_ActivityChain ChainState) {}

function SpawnRescueMission(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local array<StateObjectReference> PassRefs;
	local XComGameState_ActivityChain NewChainState;
	local X2ActivityChainTemplate ChainTemplate;
	local XComGameState_Activity ActivityState;
	local X2ActivityTemplate_Mission ActivityTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	
	PassRefs.AddItem(ChainState.FactionRef);
	PassRefs.AddItem(ChainState.PrimaryRegionRef);

	ActivityState = ChainState.GetLastActivity();
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate == none) return;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	if (ActivityTemplate.MissionRewards.Find('Reward_Intel') > -1)
	{
		ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate('ActivityChain_IntelIntercept'));;
	}
	else
	{
		ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate('ActivityChain_SupplyIntercept'));;
	}

	NewChainState = ChainTemplate.CreateInstanceFromTemplate(NewGameState, PassRefs);
	NewChainState.StartNextStage(NewGameState);
}

function bool SupplyAndIntelChains(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameState_ActivityChain OtherChainState;
	local XComGameState_Activity ActivityState;
	local X2ActivityTemplate_Mission ActivityTemplate;

	ActivityState = ChainState.GetLastActivity();
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate == none) return false;

	// If there is a supply or intel rewarding chain
	if (IsLootcrateActivity(ActivityTemplate) || ActivityTemplate.MissionRewards.Find('Reward_Intel') > -1)
	{
		// and if no other chains already have this complication
		foreach NewGameState.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
		{
			if (OtherChainState.bEnded == false && OtherChainState.Complications.Find('Complication_RewardInterception') > -1)
			{
				return false;
			}
		}

		// then add this complication to the chain
		return true;
	}

	return false;
}

static function bool IsLootcrateActivity(X2ActivityTemplate Template)
{
	return (default.LootcrateMissions.Find(Template.DataName) > -1);
}