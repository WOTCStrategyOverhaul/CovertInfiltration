
class X2StrategyElement_DefaultComplications extends X2StrategyElement config(Infiltration);

// Missions that feature lootcrates or other rewards not otherwise listed
var config array<name> LootcrateMissions;

// Items that can have their quantity halved by interception complications
var config array<name> InterceptableItems;

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

	//Template.OnChainComplete = SpawnRescueMission;
	//Template.OnChainBlocked = DoNothing;
	Template.OnManualTrigger = SpawnRescueMission;
	Template.CanBeChosen = SupplyAndIntelChains;

	// TODO: Subtract half of last chain's resource reward then give it back upon successful completion of intercept chain

	return Template;
}

function SpawnRescueMission(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameState_ActivityChain NewChainState;
	local X2ActivityChainTemplate ChainTemplate;
	local XComGameState_Activity ActivityState;
	local X2ActivityTemplate_Mission ActivityTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_Item ItemState;
	local array<XComGameState_Item> SavedItems;
	local int i;

	ActivityState = ChainState.GetLastActivity();
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate == none) return;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	if (ActivityTemplate.MissionRewards.Find('Reward_Intel') > -1)
	{
		ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate('ActivityChain_IntelIntercept'));
	}
	else
	{
		ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate('ActivityChain_SupplyIntercept'));
	}
	
	NewChainState = ChainTemplate.CreateInstanceFromTemplate(NewGameState);
	NewChainState.FactionRef = ChainState.FactionRef;
	NewChainState.PrimaryRegionRef = ChainState.PrimaryRegionRef;

	for (i = 0; i < ChainState.ChainObjectRefs.Length; i++)
	{
		if (ChainState.ChainObjectRefs[i].ObjectID > 0)
		{
			ItemState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ChainState.ChainObjectRefs[i].ObjectID));

			if (ItemState != none)
			{
				NewChainState.ChainObjectRefs.AddItem(ChainState.ChainObjectRefs[i]);
				// TODO: in spawned chain, make the rewards reflect the saved items
			}
		}
	}

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
		foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
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
	return default.LootcrateMissions.Find(Template.DataName) > -1;
}

static function bool IsInterceptableItem(X2ItemTemplate Template)
{
	return default.InterceptableItems.Find(Template.DataName) > -1;
}