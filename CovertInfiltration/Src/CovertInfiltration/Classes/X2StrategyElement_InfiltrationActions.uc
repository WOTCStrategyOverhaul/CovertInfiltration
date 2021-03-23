//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains all the non-activity Covert Action
//           templates required for the mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationActions extends X2StrategyElement config(GameData);

var config int InfiltrationMaxSquadSize;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> CovertActions;
	
	CovertActions.AddItem(CreateAlienCorpsesTemplate());
	CovertActions.AddItem(CreateUtilityItemsTemplate());
	CovertActions.AddItem(CreateExperimentalItemTemplate());
	CovertActions.AddItem(CreateExhaustiveTrainingTemplate());
	CovertActions.AddItem(CreateTechnologyRushTemplate());
	CovertActions.AddItem(CreatePatrolWildernessTemplate());
	CovertActions.AddItem(CreateBlackMarketTemplate());
	
	return CovertActions;
}

static function X2DataTemplate CreateAlienCorpsesTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_AlienCorpses');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";

	Template.Narratives.AddItem('CovertActionNarrative_AlienCorpses_Skirmishers');
	Template.Narratives.AddItem('CovertActionNarrative_AlienCorpses_Reapers');
	Template.Narratives.AddItem('CovertActionNarrative_AlienCorpses_Templars');

	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultOptionalSlot('CovertActionSoldierStaffSlot', , , true));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');
	Template.Risks.AddItem('CovertActionRisk_SoldierCaptured');
	Template.Risks.AddItem('CovertActionRisk_Ambush');

	Template.Rewards.AddItem('Reward_AlienCorpses');

	return Template;
}

static function X2DataTemplate CreateUtilityItemsTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_UtilityItems');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";

	Template.Narratives.AddItem('CovertActionNarrative_UtilityItems_Skirmishers');
	Template.Narratives.AddItem('CovertActionNarrative_UtilityItems_Reapers');
	Template.Narratives.AddItem('CovertActionNarrative_UtilityItems_Templars');
	
	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.OptionalCosts.AddItem(CreateOptionalCostSlot('Intel', 25));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');

	Template.Rewards.AddItem('Reward_UtilityItems');

	return Template;
}

static function X2DataTemplate CreateExperimentalItemTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_ExperimentalItem');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";

	Template.Narratives.AddItem('CovertActionNarrative_ExperimentalItem_Skirmishers');
	Template.Narratives.AddItem('CovertActionNarrative_ExperimentalItem_Reapers');
	Template.Narratives.AddItem('CovertActionNarrative_ExperimentalItem_Templars');

	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.OptionalCosts.AddItem(CreateOptionalCostSlot('Supplies', 25));
	
	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');
	Template.Risks.AddItem('CovertActionRisk_SoldierCaptured');
	Template.Risks.AddItem('CovertActionRisk_Ambush');

	Template.Rewards.AddItem('Reward_ExperimentalItem');

	return Template;
}

static function X2DataTemplate CreateExhaustiveTrainingTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_ExhaustiveTraining');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";

	Template.Narratives.AddItem('CovertActionNarrative_ExhaustiveTraining_Skirmishers');
	Template.Narratives.AddItem('CovertActionNarrative_ExhaustiveTraining_Reapers');
	Template.Narratives.AddItem('CovertActionNarrative_ExhaustiveTraining_Templars');
	
	Template.Slots.AddItem(CreateDefaultPromotionSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(CreateDefaultPromotionSlot('CovertActionSoldierStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');

	Template.Rewards.AddItem('Reward_Promotions');

	return Template;
}

static function X2DataTemplate CreateTechnologyRushTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_TechRush');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";
	Template.bMultiplesAllowed = true;
	Template.bUseRewardImage = true;

	Template.Narratives.AddItem('CovertActionNarrative_BreakthroughTech_Skirmishers');
	Template.Narratives.AddItem('CovertActionNarrative_BreakthroughTech_Reapers');
	Template.Narratives.AddItem('CovertActionNarrative_BreakthroughTech_Templars');

	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('CovertActionScientistStaffSlot'));
	Template.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultOptionalSlot('CovertActionSoldierStaffSlot', , , true));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');

	Template.Rewards.AddItem('Reward_TechInspire');

	return Template;
}

static function X2DataTemplate CreatePatrolWildernessTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_PatrolWilderness');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";

	Template.Narratives.AddItem('CovertActionNarrative_PatrolWilderness_Skirmishers');
	Template.Narratives.AddItem('CovertActionNarrative_PatrolWilderness_Reapers');
	Template.Narratives.AddItem('CovertActionNarrative_PatrolWilderness_Templars');

	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	//Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultOptionalSlot('CovertActionSoldierStaffSlot', , , true));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');

	Template.Rewards.AddItem('Reward_MultiPOI');

	return Template;
}

static function X2DataTemplate CreateBlackMarketTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_BlackMarket');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";
	Template.bGoldenPath = true;

	Template.Narratives.AddItem('CovertActionNarrative_BlackMarket_Skirmishers');
	Template.Narratives.AddItem('CovertActionNarrative_BlackMarket_Reapers');
	Template.Narratives.AddItem('CovertActionNarrative_BlackMarket_Templars');

	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));

	Template.Rewards.AddItem('Reward_BlackMarket');

	return Template;
}

/////////////////
//   Helpers   //
/////////////////

static function X2CovertActionTemplate CreateInfiltrationTemplate(name CovertActionName, optional bool bCreateSlots=false)
{
	local X2CovertActionTemplate Template;
	local ActionFlatRiskSitRep FlatRiskSitRep;
	local int i;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, CovertActionName);
	Template.bCanNeverBeRookie = true;

	foreach class'X2Helper_Infiltration'.default.FlatRiskSitReps(FlatRiskSitRep)
	{
		Template.Risks.AddItem(FlatRiskSitRep.FlatRiskName);
	}

	if (bCreateSlots)
	{
		for (i = 0; i < default.InfiltrationMaxSquadSize; i++)
		{
			// No point of using CreateDefaultOptionalSlot here since it doesn't actually help
			// See X2ActivityTemplate_Infiltration::PostActionInit for the fix
			Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
		}
	}

	return Template;
}

private static function CovertActionSlot CreateDefaultStaffSlot(name SlotName)
{
	local CovertActionSlot StaffSlot;
	
	// Same as Soldier Slot, but no rewards
	StaffSlot.StaffSlot = SlotName;
	StaffSlot.bReduceRisk = false;
	
	return StaffSlot;
}

private static function StrategyCostReward CreateOptionalCostSlot(name ResourceName, int Quantity)
{
	local StrategyCostReward ActionCost;
	local ArtifactCost Resources;

	Resources.ItemTemplateName = ResourceName;
	Resources.Quantity = Quantity;
	ActionCost.Cost.ResourceCosts.AddItem(Resources);
	ActionCost.Reward = 'Reward_DecreaseRisk';
	
	return ActionCost;
}

private static function CovertActionSlot CreateDefaultPromotionSlot(name SlotName)
{
	local CovertActionSlot SoldierSlot;

	SoldierSlot.StaffSlot = SlotName;
	SoldierSlot.Rewards.AddItem('Reward_RankUp');

	return SoldierSlot;
}