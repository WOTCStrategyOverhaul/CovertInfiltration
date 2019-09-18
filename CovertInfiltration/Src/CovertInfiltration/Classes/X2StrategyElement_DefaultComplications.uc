
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

	// Guaranteed to happen
	Template.MinChance = 100;
	Template.MaxChance = 100;
	Template.AlwaysSelect = true;

	Template.OnChainComplete = SpawnRescueMission;
	//Template.OnChainBlocked = DoNothing;
	//Template.OnManualTrigger = SpawnRescueMission;
	Template.CanBeChosen = SupplyAndIntelChains;

	return Template;
}

function SpawnRescueMission(XComGameState NewGameState, XComGameState_ActivityChain InterceptedChainState)
{
	local XComGameState_ActivityChain SpawnedChainState;
	local X2ActivityChainTemplate ChainTemplate;
	local XComGameState_Activity ActivityState;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityTemplate_Mission ActivityTemplate;
	local array<XComGameState_Item> SavedItems;
	local XComGameState_ResourceContainer ResContainer;
	local XComGameState_Complication ComplicationState;
	local int i;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	ActivityState = InterceptedChainState.GetLastActivity();
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate == none) return;
	
	if (ActivityTemplate.MissionRewards.Find('Reward_Intel') > -1)
	{
		ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate('ActivityChain_IntelIntercept'));
	}
	else
	{
		ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate('ActivityChain_SupplyIntercept'));
	}

	SpawnedChainState = ChainTemplate.CreateInstanceFromTemplate(NewGameState);
	SpawnedChainState.FactionRef = InterceptedChainState.FactionRef;
	SpawnedChainState.PrimaryRegionRef = InterceptedChainState.PrimaryRegionRef;

	ComplicationState = InterceptedChainState.FindComplication('Complication_RewardInterception');
	
	for (i = 0; i < ComplicationState.ComplicationObjectRefs.Length; i++)
	{
		ResContainer = XComGameState_ResourceContainer(`XCOMHISTORY.GetGameStateForObjectID(ComplicationState.ComplicationObjectRefs[i].ObjectID));

		if (ResContainer != none)
		{
			SpawnedChainState.ChainObjectRefs.AddItem(ResContainer.GetReference());
		}
	}

	SpawnedChainState.StartNextStage(NewGameState);
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
		/*
		foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
		{
			if (OtherChainState.bEnded == false && OtherChainState.HasComplication('Complication_RewardInterception'))
			{
				return false;
			}
		}
		*/
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