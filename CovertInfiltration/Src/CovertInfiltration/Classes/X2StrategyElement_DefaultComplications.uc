
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

	Template.OnChainComplete = SpawnRescueMission;
	//Template.OnChainBlocked = DoNothing;
	//Template.OnManualTrigger = SpawnRescueMission;
	Template.CanBeChosen = SupplyAndIntelChains;

	// TODO: Subtract half of last chain's resource reward then give it back upon successful completion of intercept chain

	return Template;
}

function SpawnRescueMission(XComGameState NewGameState, XComGameState_ActivityChain InterceptedChainState)
{
	local XComGameState_ActivityChain SpawnedChainState;
	local X2ActivityChainTemplate ChainTemplate;
	local XComGameState_Activity ActivityState;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_Item ItemState;
	local array<XComGameState_Item> SavedItems;
	local XComGameState_ResourceContainer ResContainer;
	local XComGameState_Complication CompState;
	local ResourcePackage Package;
	local int i;

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

	ResContainer = XComGameState_ResourceContainer(NewGameState.CreateNewStateObject(class'XComGameState_ResourceContainer'));
	
	CompState = InterceptedChainState.FindComplication('Complication_RewardInterception');
	
	for (i = 0; i < CompState.ComplicationObjectRefs.Length; i++)
	{
		ItemState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(CompState.ComplicationObjectRefs[i].ObjectID));

		if (ItemState != none)
		{
			Package.ItemType = ItemState.GetMyTemplateName();
			Package.ItemAmount = ItemState.Quantity;
			ResContainer.Packages.AddItem(Package);
		}
	}
	
	SpawnedChainState = ChainTemplate.CreateInstanceFromTemplate(NewGameState);
	SpawnedChainState.FactionRef = InterceptedChainState.FactionRef;
	SpawnedChainState.PrimaryRegionRef = InterceptedChainState.PrimaryRegionRef;
	SpawnedChainState.ChainObjectRefs.AddItem(ResContainer.GetReference());
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
		foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
		{
			if (OtherChainState.bEnded == false && OtherChainState.HasComplication('Complication_RewardInterception'))
			{
				return false;
			}
		}

		`CI_Log("ADDING COMPLICATION");
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