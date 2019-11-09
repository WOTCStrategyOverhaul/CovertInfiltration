//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains all the Covert Action templates
//           required for the mod, both Phase 1 and Phase 2
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationActions extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> CovertActions;
	
	CovertActions.AddItem(CreateAlienCorpsesTemplate());
	CovertActions.AddItem(CreateUtilityItemsTemplate());
	CovertActions.AddItem(CreateExperimentalItemTemplate());
	CovertActions.AddItem(CreateExhaustiveTrainingTemplate());
	CovertActions.AddItem(CreateTechnologyRushTemplate());
	
	return CovertActions;
}

static function X2DataTemplate CreateAlienCorpsesTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_AlienCorpses');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";

	Template.Narratives.AddItem('CovertActionNarrative_AlienLoot_Skirmishers');
	Template.Narratives.AddItem('CovertActionNarrative_AlienLoot_Reapers');
	Template.Narratives.AddItem('CovertActionNarrative_AlienLoot_Templars');

	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(class'X2StrategyElement_DefaultActivities'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('CovertActionSoldierStaffSlot', , , true));

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
	Template.Slots.AddItem(CreateDefaultOptionalSlot('CovertActionSoldierStaffSlot', , , true));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');

	Template.Rewards.AddItem('Reward_TechInspire');

	return Template;
}

/////////////////
//   Helpers   //
/////////////////

static function X2CovertInfiltrationTemplate CreateInfiltrationTemplate(name CovertActionName, optional bool bCreateSlots=false)
{
	local X2CovertInfiltrationTemplate Template;
	local ActionFlatRiskSitRep FlatRiskSitRep;

	`CREATE_X2TEMPLATE(class'X2CovertInfiltrationTemplate', Template, CovertActionName);

	foreach class'X2Helper_Infiltration'.default.FlatRiskSitReps(FlatRiskSitRep)
	{
		Template.Risks.AddItem(FlatRiskSitRep.FlatRiskName);
	}

	if (bCreateSlots)
	{
		Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
		Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
		Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
		Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
		Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));
		Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));
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

private static function CovertActionSlot CreateDefaultOptionalSlot(name SlotName, optional int iMinRank, optional bool bFactionClass, optional bool bReduceRisk)
{
	local CovertActionSlot OptionalSlot;

	OptionalSlot.StaffSlot = SlotName;
	OptionalSlot.bChanceFame = false;
	OptionalSlot.bReduceRisk = bReduceRisk;
	OptionalSlot.iMinRank = iMinRank;
	OptionalSlot.bFactionClass = bFactionClass;

	return OptionalSlot;
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