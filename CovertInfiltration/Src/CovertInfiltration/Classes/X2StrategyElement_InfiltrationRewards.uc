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
	
	Rewards.AddItem(CreateDatapadRewardTemplate());
	Rewards.AddItem(CreateContainerRewardTemplate());

	Rewards.AddItem(CreateInfiltrationActivityProxyReward());

	return Rewards;
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

	//Template.GenerateRewardFn = GenerateContainerReward;
	Template.SetRewardFn = SetContainerReward;
	Template.GiveRewardFn = GiveContainerReward;
	/*
	Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetItemRewardString;
	Template.GetRewardImageFn = class'X2StrategyElement_DefaultRewards'.static.GetItemRewardImage;
	Template.GetBlackMarketStringFn = class'X2StrategyElement_DefaultRewards'.static.GetItemBlackMarketString;
	Template.GetRewardIconFn = class'X2StrategyElement_DefaultRewards'.static.GetGenericRewardIcon;
	Template.RewardPopupFn = class'X2StrategyElement_DefaultRewards'.static.ItemRewardPopup;
	*/
	return Template;
}
/*
static function GenerateContainerReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference RegionRef)
{
	local XComGameState_ResourceContainer ResConState;
	local XComGameState_Activity ActivityState;
	local XComGameState_MissionSite MissionState;
	local XComGameState_Reward MissionReward;
	local XComGameStateHistory History;
	local int x, y;
	
	History = `XCOMHISTORY;

	// Loop through all activities
	foreach History.IterateByClassType(class'XComGameState_Activity', ActivityState)
	{
		MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(ActivityState.PrimaryObjectRef.ObjectID));

		// Loop through all the activity's rewards
		for (x = 0; x < MissionState.Rewards.Length; x++)
		{
			MissionReward = XComGameState_Reward(History.GetGameStateForObjectID(MissionState.Rewards[x].ObjectID));
			
			// If this activity has this reward
			if (MissionReward == RewardState)
			{
				// Loop through the activity's refs
				for (y = 0; y < ActivityState.GetActivityChain().ChainObjectRefs.Length; y++)
				{
					ResConState = XComGameState_ResourceContainer(History.GetGameStateForObjectID(ActivityState.GetActivityChain().ChainObjectRefs[y].ObjectID));
					
					// Find the resource container in the activity's refs
					if (ResConState != none)
					{
						// Attach the container to the reward state for later use
						RewardState.RewardObjectReference = ResConState.GetReference();
					}
				}
			}
		}
	}
}
*/
static function SetContainerReward(XComGameState_Reward RewardState, optional StateObjectReference RewardObjectRef, optional int Amount)
{
	if (XComGameState_ResourceContainer(`XCOMHISTORY.GetGameStateForObjectID(RewardObjectRef.ObjectID)) != none)
		RewardState.RewardObjectReference = RewardObjectRef;
}

static function GiveContainerReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_ResourceContainer ResConState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Item ItemState;
	local XComGameStateHistory History;
	local bool bXComHQGameStateCreated;
	local X2ItemTemplateManager ItemManager;
	local X2ItemTemplate ItemTemplate;
	local ResourcePackage Package;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if (XComHQ == none)
	{
		XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	}
	
	ResConState = XComGameState_ResourceContainer(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));

	foreach ResConState.Packages(Package)
	{
		ItemTemplate = ItemManager.FindItemTemplate(Package.ItemType);

		ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		ItemState.Quantity = Package.ItemAmount;

		XComHQ.PutItemInInventory(NewGameState, ItemState);
	}
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
	return GetInfiltrationTemplateFromReward(RewardState).ActionRewardDetails;
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
