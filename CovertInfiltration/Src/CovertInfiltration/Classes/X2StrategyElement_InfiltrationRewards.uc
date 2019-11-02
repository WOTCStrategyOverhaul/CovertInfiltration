//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Creates a X2RewardTemplate that proxies all calls to
//           X2ActivityTemplate_Infiltration
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationRewards extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;
	
	// Dummy rewards
	Rewards.AddItem(CreateRumorRewardTemplate());
	Rewards.AddItem(CreateMaterielRewardTemplate());
	Rewards.AddItem(CreateProgressRewardTemplate());
	
	// Activity rewards
	Rewards.AddItem(CreateDatapadRewardTemplate());
	Rewards.AddItem(CreateContainerRewardTemplate());

	// POI rewards
	Rewards.AddItem(CreatePrototypeT2RewardTemplate());
	Rewards.AddItem(CreatePrototypeT3RewardTemplate());
	Rewards.AddItem(CreateSidegradeT1RewardTemplate());
	Rewards.AddItem(CreateSidegradeT2RewardTemplate());
	Rewards.AddItem(CreateSidegradeT3RewardTemplate());

	Rewards.AddItem(CreateInfiltrationActivityProxyReward());

	return Rewards;
}

static function X2DataTemplate CreateRumorRewardTemplate()
{
	local X2RewardTemplate Template;

	// This is a dummy reward, the Point of Interest is spawned using the mission complete code in DefaultActivities
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_Rumor');

	return Template;
}

static function X2DataTemplate CreateMaterielRewardTemplate()
{
	local X2RewardTemplate Template;

	// This is a dummy reward, the resources are in the mission's crates not the X2Reward
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_Materiel');

	return Template;
}

static function X2DataTemplate CreateProgressRewardTemplate()
{
	local X2RewardTemplate Template;

	// This is a dummy reward, does nothing
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_Progress');

	return Template;
}

static function X2DataTemplate CreateDatapadRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_Datapad');

	Template.RewardObjectTemplateName = 'AdventDatapad';

	Template.GenerateRewardFn = class'X2StrategyElement_DefaultRewards'.static.GenerateItemReward;
	Template.SetRewardFn = class'X2StrategyElement_DefaultRewards'.static.SetItemReward;
	Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GiveItemReward;
	Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetItemRewardString;
	Template.GetRewardImageFn = class'X2StrategyElement_DefaultRewards'.static.GetItemRewardImage;
	Template.GetBlackMarketStringFn = class'X2StrategyElement_DefaultRewards'.static.GetItemBlackMarketString;
	Template.GetRewardIconFn = class'X2StrategyElement_DefaultRewards'.static.GetGenericRewardIcon;
	Template.RewardPopupFn = class'X2StrategyElement_DefaultRewards'.static.ItemRewardPopup;

	return Template;
}

static function X2DataTemplate CreateContainerRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_Container');

	Template.SetRewardFn = SetContainerReward;
	Template.GiveRewardFn = GiveContainerReward;
	Template.GetRewardStringFn = GetContainerString;

	return Template;
}

static function SetContainerReward(XComGameState_Reward RewardState, optional StateObjectReference RewardObjectRef, optional int Amount)
{
	if (XComGameState_ResourceContainer(`XCOMHISTORY.GetGameStateForObjectID(RewardObjectRef.ObjectID)) != none)
	{
		RewardState.RewardObjectReference = RewardObjectRef;
	}
	else
	{
		`RedScreen("Invalid or missing resource container passed to SetContainerReward!");
	}
}

static function GiveContainerReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_ResourceContainer ResourceContainerState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Item ItemState;
	local XComGameStateHistory History;
	local X2ItemTemplateManager ItemManager;
	local X2ItemTemplate ItemTemplate;
	local ResourcePackage Package;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	History = `XCOMHISTORY;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		
	ResourceContainerState = XComGameState_ResourceContainer(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	
	if(ResourceContainerState.Packages.Length == 0)
		`CI_Log("No packages to grab from!");

	foreach ResourceContainerState.Packages(Package)
	{
		ItemTemplate = ItemManager.FindItemTemplate(Package.ItemType);

		ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		ItemState.Quantity = Package.ItemAmount;

		`CI_Log("Deposited Item: " $ ItemState.GetMyTemplateName() @ ItemState.Quantity);

		XComHQ.PutItemInInventory(NewGameState, ItemState);
	}
}

static function string GetContainerString(XComGameState_Reward RewardState)
{
	local XComGameState_ResourceContainer ResourceContainerState;
	local X2ItemTemplateManager ItemManager;
	local XComGameStateHistory History;
	local X2ItemTemplate ItemTemplate;
	local ResourcePackage Package;
	local string Result;
	
	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	History = `XCOMHISTORY;

	ResourceContainerState = XComGameState_ResourceContainer(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	
	if(ResourceContainerState.Packages.Length == 0)
		`CI_Log("No packages to read from!");

	foreach ResourceContainerState.Packages(Package)
	{
		ItemTemplate = ItemManager.FindItemTemplate(Package.ItemType);
		if(ItemTemplate != none)
		{
			`CI_Log("Reading package:" @ Package.ItemType);
			if(Result == "")
			{
				Result = string(Package.ItemAmount) @ (Package.ItemAmount == 1 ? ItemTemplate.GetItemFriendlyName() : ItemTemplate.GetItemFriendlyNamePlural());
			}
			else
			{
				Result = Result $ "," @ string(Package.ItemAmount) @ (Package.ItemAmount == 1 ? ItemTemplate.GetItemFriendlyName() : ItemTemplate.GetItemFriendlyNamePlural());
			}
		}
	}

	if(Result == "")
		`CI_Log("Something went wrong in reward string!");

	return Result;
}

static function X2DataTemplate CreateInfiltrationActivityProxyReward ()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_InfiltrationActivityProxy');
	Template.IsRewardAvailableFn = RewardNotAvaliable;
	Template.GetRewardPreviewStringFn = GetInfiltrationActionPreview;
	Template.GetRewardDetailsStringFn = GetInfiltrationActionDetails;
	Template.GenerateRewardFn = GenerateRewardDelegate;

	return Template;
}

static function string GetInfiltrationActionPreview (XComGameState_Reward RewardState)
{
	return GetInfiltrationTemplateFromReward(RewardState).ActionRewardDisplayName;
}

static function string GetInfiltrationActionDetails (XComGameState_Reward RewardState)
{
	return GetInfiltrationTemplateFromReward(RewardState).GetRewardDetailStringFn(class'XComGameState_Activity'.static.GetActivityFromSecondaryObjectID(RewardState.RewardObjectReference.ObjectID), RewardState);
}

static function GenerateRewardDelegate (XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef)
{
	// Store action in the reward state so it's easy to get it (and the activity) later
	RewardState.RewardObjectReference = AuxRef;
}

static function X2ActivityTemplate_Infiltration GetInfiltrationTemplateFromReward (XComGameState_Reward RewardState)
{
	local XComGameState_Activity Activity;

	Activity = class'XComGameState_Activity'.static.GetActivityFromSecondaryObjectID(RewardState.RewardObjectReference.ObjectID);

	return X2ActivityTemplate_Infiltration(Activity.GetMyTemplate());
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

///////////////////
/// POI rewards ///
///////////////////

static function X2DataTemplate CreatePrototypeT2RewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_PrototypeT2');
	Template.rewardObjectTemplateName = 'PrototypeT2';
	
	Template.SetRewardByTemplateFn = class'X2StrategyElement_DefaultRewards'.static.SetLootTableReward;
	Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GiveLootTableReward;
	Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetLootTableRewardString;

	return Template;
}

static function X2DataTemplate CreatePrototypeT3RewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_PrototypeT3');
	Template.rewardObjectTemplateName = 'PrototypeT3';
	
	Template.SetRewardByTemplateFn = class'X2StrategyElement_DefaultRewards'.static.SetLootTableReward;
	Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GiveLootTableReward;
	Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetLootTableRewardString;

	return Template;
}

static function X2DataTemplate CreateSidegradeT1RewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_SidegradeT1');
	Template.rewardObjectTemplateName = 'SidegradeT1';
	
	Template.SetRewardByTemplateFn = class'X2StrategyElement_DefaultRewards'.static.SetLootTableReward;
	Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GiveLootTableReward;
	Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetLootTableRewardString;

	return Template;
}

static function X2DataTemplate CreateSidegradeT2RewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_SidegradeT2');
	Template.rewardObjectTemplateName = 'SidegradeT2';
	
	Template.SetRewardByTemplateFn = class'X2StrategyElement_DefaultRewards'.static.SetLootTableReward;
	Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GiveLootTableReward;
	Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetLootTableRewardString;

	return Template;
}

static function X2DataTemplate CreateSidegradeT3RewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_SidegradeT3');
	Template.rewardObjectTemplateName = 'SidegradeT3';
	
	Template.SetRewardByTemplateFn = class'X2StrategyElement_DefaultRewards'.static.SetLootTableReward;
	Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GiveLootTableReward;
	Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetLootTableRewardString;

	return Template;
}
