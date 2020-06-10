//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Creates a X2RewardTemplate that proxies all calls to
//           X2ActivityTemplate_Infiltration
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationRewards extends X2StrategyElement config(GameData);

var config array<int> SmallIntelRewardMin;
var config array<int> SmallIntelRewardMax;

var config array<int> SmallIncomeIncreaseRewardMin;
var config array<int> SmallIncomeIncreaseRewardMax;

var config array<int> FacilityDelayRewardMin;
var config array<int> FacilityDelayRewardMax;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;
	
	// Dummy rewards
	Rewards.AddItem(CreateRumorRewardTemplate());
	Rewards.AddItem(CreateMaterielRewardTemplate());
	Rewards.AddItem(CreateProgressRewardTemplate());
	Rewards.AddItem(CreatePromotionsRewardTemplate());
	
	// Activity rewards
	Rewards.AddItem(CreateSmallIntelRewardTemplate());
	Rewards.AddItem(CreateSmallIncreaseIncomeRewardTemplate());
	Rewards.AddItem(CreateFacilityDelayRewardTemplate());
	Rewards.AddItem(CreateDatapadRewardTemplate());
	Rewards.AddItem(CreateContainerRewardTemplate());
	Rewards.AddItem(CreateDarkEventRewardTemplate());

	// CA rewards
	Rewards.AddItem(CreateLootTableRewardTemplate('Reward_AlienCorpses', 'AlienCorpses'));
	Rewards.AddItem(CreateLootTableRewardTemplate('Reward_UtilityItems', 'UtilityItems'));
	Rewards.AddItem(CreateLootTableRewardTemplate('Reward_ExperimentalItem', 'ExperimentalItem'));
	Rewards.AddItem(CreateTechInspireRewardTemplate());
	
	Rewards.AddItem(CreateInfiltrationActivityProxyReward());
	Rewards.AddItem(CreateActivityChainProxyReward());

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

static function X2DataTemplate CreatePromotionsRewardTemplate()
{
	local X2RewardTemplate Template;

	// This is a dummy reward, does nothing
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_Promotions');

	return Template;
}

static function X2DataTemplate CreateSmallIntelRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_SmallIntel');
	Template.rewardObjectTemplateName = 'Intel';
	Template.RewardImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Intel";
	Template.bResourceReward = true;

	Template.GenerateRewardFn = GenerateSmallIntelReward;
	Template.SetRewardFn = class'X2StrategyElement_DefaultRewards'.static.SetResourceReward;
	Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GiveResourceReward;
	Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetResourceRewardString;
	Template.GetRewardPreviewStringFn = class'X2StrategyElement_DefaultRewards'.static.GetResourceRewardString;
	Template.GetRewardImageFn = class'X2StrategyElement_DefaultRewards'.static.GetResourceRewardImage;
	Template.GetRewardIconFn = class'X2StrategyElement_DefaultRewards'.static.GetGenericRewardIcon;

	return Template;
}

static function GenerateSmallIntelReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference RegionRef)
{
	RewardState.Quantity = GetSmallIntelReward();
}

static function int GetSmallIntelReward()
{
	local int IntelMin;
	local int IntelMax;
	
	IntelMin = `ScaleStrategyArrayInt(default.SmallIntelRewardMin);
	IntelMax = `ScaleStrategyArrayInt(default.SmallIntelRewardMax);
	
	return IntelMin + `SYNC_RAND_STATIC(IntelMax - IntelMin);
}

static function X2DataTemplate CreateSmallIncreaseIncomeRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_SmallIncreaseIncome');

	Template.GenerateRewardFn = GenerateSmallIncomeReward;
	Template.SetRewardFn = class'X2StrategyElement_DefaultRewards'.static.SetIncreaseIncomeReward;
	Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GiveIncreaseIncomeReward;
	Template.GetRewardDetailsStringFn = class'X2StrategyElement_DefaultRewards'.static.GetIncreaseIncomeRewardString;
	Template.GetRewardStringFn = GetIncreaseIncomeRewardString;
	Template.CleanUpRewardFn = class'X2StrategyElement_DefaultRewards'.static.CleanUpRewardWithoutRemoval;

	return Template;
}

static function GenerateSmallIncomeReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef)
{
	local XComGameStateHistory History;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_CovertAction ActionState;

	History = `XCOMHISTORY;
	RegionState = XComGameState_WorldRegion(History.GetGameStateForObjectID(AuxRef.ObjectID));
	ActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(AuxRef.ObjectID));
	if (ActionState != none)
	{
		RewardState.RewardObjectReference = ActionState.GetWorldRegion().GetReference();
	}
	else
	{
		RewardState.RewardObjectReference = RegionState.GetReference();
	}

	RewardState.Quantity = Round(float(GetSmallIncomeReward()) * RewardScalar);
}

static function int GetSmallIncomeReward()
{
	local int IncomeMin;
	local int IncomeMax;
	
	IncomeMin = `ScaleStrategyArrayInt(default.SmallIncomeIncreaseRewardMin);
	IncomeMax = `ScaleStrategyArrayInt(default.SmallIncomeIncreaseRewardMax);
	
	return IncomeMin + `SYNC_RAND_STATIC(IncomeMax - IncomeMin);
}

static function string GetIncreaseIncomeRewardString(XComGameState_Reward RewardState)
{
	return RewardState.GetMyTemplate().DisplayName;
}

static function X2DataTemplate CreateFacilityDelayRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_FacilityDelay');

	Template.GenerateRewardFn = GenerateFacilityDelayReward;
	Template.SetRewardFn = SetFacilityDelayReward;
	Template.GiveRewardFn = GiveFacilityDelayReward;
	Template.GetRewardDetailsStringFn = GetFacilityDelayRewardDetails;
	Template.GetRewardStringFn = GetFacilityDelayRewardString;

	return Template;
}

static function GenerateFacilityDelayReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef)
{
	RewardState.Quantity = Round(float(GetFacilityDelayReward()) * RewardScalar);
}

static function SetFacilityDelayReward(XComGameState_Reward RewardState, optional StateObjectReference RewardObjectRef, optional int Amount)
{
	RewardState.Quantity = Amount;
}

static function GiveFacilityDelayReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_HeadquartersAlien AlienHQ;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersAlien', AlienHQ)
	{
		break;
	}

	if (AlienHQ == none)
	{
		AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
		AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
	}

	AlienHQ.DelayFacilityTimer(RewardState.Quantity * 24);
}

static function int GetFacilityDelayReward()
{
	local int DelayMin;
	local int DelayMax;
	
	DelayMin = `ScaleStrategyArrayInt(default.FacilityDelayRewardMin);
	DelayMax = `ScaleStrategyArrayInt(default.FacilityDelayRewardMax);
	
	return DelayMin + `SYNC_RAND_STATIC(DelayMax - DelayMin);
}

static function string GetFacilityDelayRewardString(XComGameState_Reward RewardState)
{
	return RewardState.GetMyTemplate().DisplayName;
}

static function string GetFacilityDelayRewardDetails(XComGameState_Reward RewardState)
{
	local XGParamTag kTag;

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	kTag.IntValue0 = RewardState.Quantity;

	return `XEXPAND.ExpandString(RewardState.GetMyTemplate().RewardDetails);
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

static function X2DataTemplate CreateDarkEventRewardTemplate()
{
	local X2RewardTemplate Template;
	
	// This is a dummy reward, does nothing
	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_DarkEvent');
	
	Template.SetRewardFn = SetDarkEventReward;
	Template.GetRewardStringFn = GetDarkEventRewardString;
	Template.GetRewardPreviewStringFn = GetDarkEventRewardString;

	return Template;
}

static function SetDarkEventReward(XComGameState_Reward RewardState, optional StateObjectReference RewardObjectRef, optional int Amount)
{
	local XComGameState_DarkEvent DarkEventState;

	DarkEventState = XComGameState_DarkEvent(`XCOMHISTORY.GetGameStateForObjectID(RewardObjectRef.ObjectID));
	
	if (DarkEventState == none)
	{
		`Redscreen("Invalid DarkEventState passed to SetDarkEventReward!");
	}
	else
	{
		RewardState.RewardObjectReference = RewardObjectRef;
	}
}

static function string GetDarkEventRewardString(XComGameState_Reward RewardState)
{
	local XComGameState_DarkEvent DarkEventState;
	local XGParamTag ParamTag;
	
	DarkEventState = XComGameState_DarkEvent(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.StrValue0 = DarkEventState.GetDisplayName();

	return `XEXPAND.ExpandString(RewardState.GetMyTemplate().DisplayName);
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

static function X2DataTemplate CreateActivityChainProxyReward ()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_ChainProxy');

	Template.IsRewardAvailableFn = RewardNotAvaliable;
	Template.SetRewardFn = SetProxyReward;
	Template.GiveRewardFn = GiveProxyReward;
	Template.GetRewardStringFn = GetProxyRewardString;
	Template.GetRewardPreviewStringFn = GetProxyRewardPreview;
	Template.GetRewardDetailsStringFn = GetProxyRewardDetails;
	Template.GetBlackMarketStringFn = GetProxyBlackMarketString;
	Template.GetRewardImageFn = GetProxyRewardImage;
	Template.GetRewardIconFn = GetProxyRewardIcon;
	Template.RewardPopupFn = DisplayProxyRewardPopup;
	Template.GenerateRewardFn = GenerateProxyReward;

	return Template;
}

static function SetProxyReward (XComGameState_Reward RewardState, optional StateObjectReference RewardObjectRef, optional int Amount)
{
	GetProxyReward(RewardState).SetReward(RewardObjectRef, Amount);
}

static function GiveProxyReward (XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	GetProxyReward(RewardState).GiveReward(NewGameState, AuxRef, bOrder, OrderHours);
}

static function string GetProxyRewardString (XComGameState_Reward RewardState)
{
	return GetProxyReward(RewardState).GetRewardString();
}

static function string GetProxyRewardPreview (XComGameState_Reward RewardState)
{
	return GetProxyReward(RewardState).GetRewardPreviewString();
}

static function string GetProxyRewardDetails (XComGameState_Reward RewardState)
{
	return GetProxyReward(RewardState).GetRewardDetailsString();
}

static function string GetProxyBlackMarketString (XComGameState_Reward RewardState)
{
	return GetProxyReward(RewardState).GetBlackMarketString();
}

static function string GetProxyRewardImage (XComGameState_Reward RewardState)
{
	return GetProxyReward(RewardState).GetRewardImage();
}

static function string GetProxyRewardIcon (XComGameState_Reward RewardState)
{
	return GetProxyReward(RewardState).GetRewardIcon();
}

static function DisplayProxyRewardPopup (XComGameState_Reward RewardState)
{
	GetProxyReward(RewardState).DisplayRewardPopup();
}

static function GenerateProxyReward (XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef)
{
	`REDSCREEN("Reward_ChainProxy was generated! This should never happen! This reward should not be used for any mission outside of an activity chain!");
}

static function XComGameState_Reward GetProxyReward (XComGameState_Reward RewardState)
{
	return XComGameState_Reward(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
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

static function X2DataTemplate CreateLootTableRewardTemplate (name RewardName, name LootTableName)
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, RewardName);
	Template.rewardObjectTemplateName = LootTableName;
	
	Template.GiveRewardFn = GiveLootTableReward;
	Template.GetRewardStringFn = GetLootTableRewardString;

	return Template;
}

static function GiveLootTableReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateManager;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local X2LootTableManager LootManager;
	local LootResults LootToGive;
	local name LootName;
	local int LootIndex, idx;
	local string LootString;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	LootManager = class'X2LootTableManager'.static.GetLootTableManager();
	LootIndex = LootManager.FindGlobalLootCarrier(RewardState.GetMyTemplate().rewardObjectTemplateName);
	if (LootIndex >= 0)
	{
		LootManager.RollForGlobalLootCarrier(LootIndex, LootToGive);
	}
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	// First give each piece of loot to XComHQ so it can be collected and added to LootRecovered, which will stack it automatically
	foreach LootToGive.LootToBeCreated(LootName)
	{
		ItemTemplate = ItemTemplateManager.FindItemTemplate(LootName);
		ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		XComHQ.PutItemInInventory(NewGameState, ItemState, true);
	}

	// Then create the loot string for the room
	for (idx = 0; idx < XComHQ.LootRecovered.Length; idx++)
	{
		ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(XComHQ.LootRecovered[idx].ObjectID));

		if (ItemState != none)
		{
			LootString $= ItemState.GetMyTemplate().GetItemFriendlyName() $ " x" $ ItemState.Quantity;

			if (idx < XComHQ.LootRecovered.Length - 1)
			{
				LootString $= ", ";
			}
		}
	}
	RewardState.RewardString = LootString;
	
	// Actually add the loot which was generated to the inventory
	class'XComGameStateContext_StrategyGameRule'.static.AddLootToInventory(NewGameState);
}

static function string GetLootTableRewardString(XComGameState_Reward RewardState)
{
	return RewardState.RewardString;
}

static function X2DataTemplate CreateTechInspireRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_TechInspire');

	Template.SetRewardFn = SetTechInspireReward;
	Template.GiveRewardFn = GiveTechInspireReward;
	Template.GenerateRewardFn = GenerateTechInspireReward;
	Template.GetRewardStringFn = GetTechInspireRewardString;
	Template.GetRewardPreviewStringFn = GetTechInspireRewardString;
	Template.GetRewardDetailsStringFn = GetTechInspireRewardDetails;
	Template.GetRewardImageFn = GetTechInspireRewardImage;
	Template.GetRewardIconFn = class'X2StrategyElement_DefaultRewards'.static.GetGenericRewardIcon;
	Template.CleanUpRewardFn = class'X2StrategyElement_DefaultRewards'.static.CleanUpRewardWithoutRemoval;

	return Template;
}

static function SetTechInspireReward(XComGameState_Reward RewardState, optional StateObjectReference RewardObjectRef, optional int Amount)
{
	local XComGameState_Tech TechState;

	TechState = XComGameState_Tech(`XCOMHISTORY.GetGameStateForObjectID(RewardObjectRef.ObjectID));
	
	if (TechState == none)
	{
		`Redscreen("Invalid TechState passed to SetTechInspireReward!");
	}
	else
	{
		RewardState.RewardObjectReference = RewardObjectRef;
		RewardState.Quantity = TechState.TimesResearched;
	}
}

static function GiveTechInspireReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersProjectResearch ProjectState;
	local XComGameState_Tech TechState;

	History = `XCOMHISTORY;

	// Adjust Tech's time reduction value
	TechState = XComGameState_Tech(NewGameState.ModifyStateObject(class'XComGameState_Tech', RewardState.RewardObjectReference.ObjectID));
	if(TechState != None && TechState.TimesResearched == RewardState.Quantity)
	{
		TechState.TimeReductionScalar = class'X2StrategyElement_DefaultRewards'.static.GetTechRushReductionScalar();

		// If there is already a project rush it
		foreach History.IterateByClassType(class'XComGameState_HeadquartersProjectResearch', ProjectState)
		{
			if (ProjectState.ProjectPointsRemaining > 0 && ProjectState.ProjectFocus == RewardState.RewardObjectReference)
			{
				ProjectState = XComGameState_HeadquartersProjectResearch(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersProjectResearch', ProjectState.ObjectID));
				ProjectState.RushResearch(NewGameState);
				return;
			}
		}
	}
}

static function GenerateTechInspireReward (XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef)
{
	local array<XComGameState_Tech> TechList;

	TechList = GetCandidatesForTechRush();
	RewardState.SetReward(TechList[`SYNC_RAND_STATIC(TechList.Length)].GetReference());
}

static function string GetTechInspireRewardString(XComGameState_Reward RewardState)
{
	local XComGameStateHistory History;
	local XComGameState_Tech TechState;

	History = `XCOMHISTORY;
	TechState = XComGameState_Tech(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));

	return class'X2StrategyElement_DefaultRewards'.default.TechRushText @ TechState.GetDisplayName();
}

static function string GetTechInspireRewardDetails(XComGameState_Reward RewardState)
{
	local XComGameStateHistory History;
	local XComGameState_Tech TechState;

	History = `XCOMHISTORY;
	TechState = XComGameState_Tech(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));

	return "Halve the remaining research time of the" @ TechState.GetDisplayName() @ "project.";
}

static function string GetTechInspireRewardImage(XComGameState_Reward RewardState)
{
	local XComGameStateHistory History;
	local XComGameState_Tech TechState;

	History = `XCOMHISTORY;
	TechState = XComGameState_Tech(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));

	return TechState.GetMyTemplate().strImage;
}

static function array<XComGameState_Tech> GetCandidatesForTechRush()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local array<XComGameState_Tech> ChosenTechs;
	local XComGameState_Tech TechState;
	local array<StateObjectReference> AvailableTechRefs;
	local XComGameState_HeadquartersProjectResearch ProjectState;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2CovertActionTemplate Template;
	local int WorkPerHour, ProjectPoints, HoursToComplete, CovertActionHours, idx;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	// Grab all available techs
	AvailableTechRefs = XComHQ.GetAvailableTechsForResearch();

	// Include current Tech being researched
	ProjectState = XComHQ.GetCurrentResearchProject();
	TechState = XComHQ.GetCurrentResearchTech();

	if (ProjectState != none && TechState != none)
	{
		WorkPerHour = ProjectState.GetCurrentWorkPerHour();
		ProjectPoints = TechState.GetProjectPoints(WorkPerHour);
		HoursToComplete = ProjectPoints / WorkPerHour;

		Template = X2CovertActionTemplate(TemplateManager.FindStrategyElementTemplate('CovertAction_TechRush'));
		CovertActionHours = `ScaleStrategyArrayInt(Template.default.MaxActionHours);

		// Only include current tech if it won't be finished before the Covert Action is complete (+33% in case a new scientist is acquired)
		if (HoursToComplete > CovertActionHours * 1.33)
		{
			AvailableTechRefs.AddItem(TechState.GetReference());
		}
	}

	// Filter Techs (no instant, repeatable, priority)
	for(idx = 0; idx < AvailableTechRefs.Length; idx++)
	{
		TechState = XComGameState_Tech(History.GetGameStateForObjectID(AvailableTechRefs[idx].ObjectID));

		if(TechState != none && TechState.CanBeRushed())
		{
			ChosenTechs.AddItem(TechState);
		}
	}

	return ChosenTechs;
}
