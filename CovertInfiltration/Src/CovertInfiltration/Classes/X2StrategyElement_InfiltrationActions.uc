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
	
	CovertActions.AddItem(CreateP1DarkEventTemplate());
	CovertActions.AddItem(CreateP1SupplyRaidTemplate());
	CovertActions.AddItem(CreateP1JailbreakTemplate());
	
	CovertActions.AddItem(CreateP2DarkEventTemplate());
	CovertActions.AddItem(CreateP2SupplyRaidTemplate());
	CovertActions.AddItem(CreateP2EngineerTemplate());
	CovertActions.AddItem(CreateP2ScientistTemplate());
	CovertActions.AddItem(CreateP2DarkVIPTemplate());
	
	return CovertActions;
}

static function X2DataTemplate CreateP1DarkEventTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertInfiltrationTemplate', Template, 'CovertAction_P1DarkEvent');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomContactedRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps"; // Yes, Firaxis did in fact call it Gorilla Ops
	
	Template.Narratives.AddItem('CovertActionNarrative_P1DarkEvent');
	Template.Rewards.AddItem('ActionReward_P1DarkEvent');
	
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_AdventPatrols');
	Template.Risks.AddItem('CovertActionRisk_IntelligenceLeak');
	Template.Risks.AddItem('CovertActionRisk_AdventAirPatrols');
	Template.Risks.AddItem('CovertActionRisk_GunneryEmplacements');
	Template.Risks.AddItem('CovertActionRisk_ShoddyIntel');
	
	return Template;
}

static function X2DataTemplate CreateP1SupplyRaidTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertInfiltrationTemplate', Template, 'CovertAction_P1SupplyRaid');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomContactedRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps"; // Yes, Firaxis did in fact call it Gorilla Ops
	
	Template.Narratives.AddItem('CovertActionNarrative_P1SupplyRaid');
	Template.Rewards.AddItem('ActionReward_P1SupplyRaid');

	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_AdventPatrols');
	Template.Risks.AddItem('CovertActionRisk_IntelligenceLeak');
	Template.Risks.AddItem('CovertActionRisk_AdventAirPatrols');
	Template.Risks.AddItem('CovertActionRisk_GunneryEmplacements');
	Template.Risks.AddItem('CovertActionRisk_ShoddyIntel');

	return Template;
}

static function X2DataTemplate CreateP1JailbreakTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertInfiltrationTemplate', Template, 'CovertAction_P1Jailbreak');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomContactedRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps"; // Yes, Firaxis did in fact call it Gorilla Ops
	
	Template.Narratives.AddItem('CovertActionNarrative_P1Jailbreak');
	Template.Rewards.AddItem('ActionReward_P1Jailbreak');

	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_AdventPatrols');
	Template.Risks.AddItem('CovertActionRisk_IntelligenceLeak');
	Template.Risks.AddItem('CovertActionRisk_AdventAirPatrols');
	Template.Risks.AddItem('CovertActionRisk_GunneryEmplacements');
	Template.Risks.AddItem('CovertActionRisk_ShoddyIntel');
	
	return Template;
}

static function X2DataTemplate CreateP2DarkEventTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertInfiltrationTemplate', Template, 'CovertAction_P2DarkEvent');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomContactedRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps"; // Yes, Firaxis did in fact call it Gorilla Ops
	
	Template.Narratives.AddItem('CovertActionNarrative_P2DarkEvent');
	Template.Rewards.AddItem('ActionReward_P2DarkEvent');

	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_AdventPatrols');
	Template.Risks.AddItem('CovertActionRisk_IntelligenceLeak');
	Template.Risks.AddItem('CovertActionRisk_AdventAirPatrols');
	Template.Risks.AddItem('CovertActionRisk_GunneryEmplacements');
	Template.Risks.AddItem('CovertActionRisk_ShoddyIntel');
	
	return Template;
}

static function X2DataTemplate CreateP2SupplyRaidTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_P2SupplyRaid');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomContactedRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps"; // Yes, Firaxis did in fact call it Gorilla Ops
	
	Template.Narratives.AddItem('CovertActionNarrative_P2SupplyRaid');
	Template.Rewards.AddItem('Reward_P2SupplyRaid');

	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));

	return Template;
}

static function X2DataTemplate CreateP2EngineerTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertInfiltrationTemplate', Template, 'CovertAction_P2Engineer');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomContactedRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps"; // Yes, Firaxis did in fact call it Gorilla Ops
	
	Template.Narratives.AddItem('CovertActionNarrative_P2Engineer');
	Template.Rewards.AddItem('ActionReward_P2Engineer');

	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_AdventPatrols');
	Template.Risks.AddItem('CovertActionRisk_IntelligenceLeak');
	Template.Risks.AddItem('CovertActionRisk_AdventAirPatrols');
	Template.Risks.AddItem('CovertActionRisk_GunneryEmplacements');
	Template.Risks.AddItem('CovertActionRisk_ShoddyIntel');
	
	return Template;
}

static function X2DataTemplate CreateP2ScientistTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertInfiltrationTemplate', Template, 'CovertAction_P2Scientist');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomContactedRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps"; // Yes, Firaxis did in fact call it Gorilla Ops
	
	Template.Narratives.AddItem('CovertActionNarrative_P2Scientist');
	Template.Rewards.AddItem('ActionReward_P2Scientist');

	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_AdventPatrols');
	Template.Risks.AddItem('CovertActionRisk_IntelligenceLeak');
	Template.Risks.AddItem('CovertActionRisk_AdventAirPatrols');
	Template.Risks.AddItem('CovertActionRisk_GunneryEmplacements');
	Template.Risks.AddItem('CovertActionRisk_ShoddyIntel');
	
	return Template;
}

static function X2DataTemplate CreateP2DarkVIPTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertInfiltrationTemplate', Template, 'CovertAction_P2DarkVIP');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomContactedRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps"; // Yes, Firaxis did in fact call it Gorilla Ops
	
	Template.Narratives.AddItem('CovertActionNarrative_P2DarkVIP');
	Template.Rewards.AddItem('ActionReward_P2DarkVIP');

	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultStaffSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));
	Template.Slots.AddItem(CreateDefaultOptionalSlot('InfiltrationStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_AdventPatrols');
	Template.Risks.AddItem('CovertActionRisk_IntelligenceLeak');
	Template.Risks.AddItem('CovertActionRisk_AdventAirPatrols');
	Template.Risks.AddItem('CovertActionRisk_GunneryEmplacements');
	Template.Risks.AddItem('CovertActionRisk_ShoddyIntel');
	
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

private static function CovertActionSlot CreateDefaultOptionalSlot(name SlotName, optional int iMinRank, optional bool bFactionClass)
{
	local CovertActionSlot OptionalSlot;

	OptionalSlot.StaffSlot = SlotName;
	OptionalSlot.bChanceFame = false;
	//OptionalSlot.bReduceRisk = true;
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
