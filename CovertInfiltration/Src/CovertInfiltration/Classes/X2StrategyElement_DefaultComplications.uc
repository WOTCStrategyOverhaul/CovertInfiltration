
class X2StrategyElement_DefaultComplications extends X2StrategyElement config(Infiltration);

// Missions that feature lootcrates or other rewards not otherwise listed
var config array<name> LootcrateMissions;

// Items that can have their quantity halved by interception complications
var config array<name> InterceptableItems;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Complications;
	
	Complications.AddItem(CreateRewardInterceptionTemplate());
	Complications.AddItem(CreateChosenSurveillanceTemplate());

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
	local XComGameState_ResourceContainer TotalResContainer;
	local XComGameState_Complication ComplicationState;
	local int i, j;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	ActivityState = InterceptedChainState.GetLastActivity();
	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate == none)
	{
		`RedScreen("Failed to find source activity!");
		return;
	}

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
	TotalResContainer = NewGameState.CreateStateObject(class'XComGameState_ResourceContainer');

	if (ComplicationState != none)
	{
		for (i = 0; i < ComplicationState.ComplicationObjectRefs.Length; i++)
		{
			ResContainer = XComGameState_ResourceContainer(`XCOMHISTORY.GetGameStateForObjectID(ComplicationState.ComplicationObjectRefs[i].ObjectID));

			if (ResContainer != none)
			{
				for (j = 0; j < ResContainer.Packages.Length; j++)
				{
					TotalResContainer.Packages.AddItem(ResContainer.Packages[j]);
				}
			}
			else
			{
				`RedScreen("Failed to get container from ComplicationState!");
			}
		}
		if (i == 0)
		{
			// CURRENT PROBLEM LIES HERE
			`RedScreen("ComplicationState has no stored objects!");
		}
	}
	else
	{
		`RedScreen("Failed to get ComplicationState!");
	}

	SpawnedChainState.ChainObjectRefs.AddItem(TotalResContainer.GetReference());
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
	
	// if this chain doesn't have any other complications

	if(ChainState.ComplicationRefs.Length != 0)
	{
		return false;
	}
	
	// and if there is a supply or intel rewarding chain
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

static function X2DataTemplate CreateChosenSurveillanceTemplate()
{
	local X2ComplicationTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ComplicationTemplate', Template, 'Complication_ChosenSurveillance');

	// Guaranteed to happen
	Template.MinChance = 100;
	Template.MaxChance = 100;
	Template.AlwaysSelect = true;

	//Template.OnChainComplete = SpawnRescueMission;
	//Template.OnChainBlocked = DoNothing;
	//Template.OnManualTrigger = SpawnRescueMission;
	Template.CanBeChosen = AnyUncomplicatedChain;

	return Template;
}

function bool AnyUncomplicatedChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState)
{
	local XComGameState_ActivityChain OtherChainState;

	// if no other chains already have this complication
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
	{
		if (OtherChainState.bEnded == false && OtherChainState.HasComplication('Complication_ChosenSurveillance'))
		{
			return false;
		}
	}

	// and if this chain doesn't have any other complications

	if(ChainState.ComplicationRefs.Length != 0)
	{
		return false;
	}
	
	// then add this complication to the chain
	return true;
}
