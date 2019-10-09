//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Definitions for barracks size unlocks.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------
class X2StrategyElement_CIFacilityUpgrades extends X2StrategyElement_DefaultFacilityUpgrades;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Upgrades;

	Upgrades.AddItem(CreateLivingQuarters_BarracksSizeI());
	Upgrades.AddItem(CreateLivingQuarters_BarracksSizeII());
	
	return Upgrades;
}

static function X2DataTemplate CreateLivingQuarters_BarracksSizeI()
{
	local X2FacilityUpgradeTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2FacilityUpgradeTemplate', Template, 'LivingQuarters_BarracksSizeI');
	Template.PointsToComplete = 0;
	Template.MaxBuild = 1;
	Template.strImage = "img:///UILibrary_StrategyImages.FacilityIcons.ChooseFacility_PowerConduitUpgrade";
	Template.OnUpgradeAddedFn = OnUpgradeAdded_IncreaseBarracksSizeI;

	// Stats
	Template.iPower = 2;
	Template.UpkeepCost = 10;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 80;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

static function X2DataTemplate CreateLivingQuarters_BarracksSizeII()
{
	local X2FacilityUpgradeTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2FacilityUpgradeTemplate', Template, 'LivingQuarters_BarracksSizeII');
	Template.PointsToComplete = 0;
	Template.MaxBuild = 1;
	Template.strImage = "img:///UILibrary_StrategyImages.FacilityIcons.ChooseFacility_EleriumConduitUpgrade";
	Template.OnUpgradeAddedFn = OnUpgradeAdded_IncreaseBarracksSizeII;

	// Stats
	Template.iPower = 6;
	Template.UpkeepCost = 20;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 150;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

static function OnUpgradeAdded_IncreaseBarracksSizeI(XComGameState NewGameState, XComGameState_FacilityUpgrade Upgrade, XComGameState_FacilityXCom Facility)
{
	//Facility.UnlockStaffSlot(NewGameState);
}

static function OnUpgradeAdded_IncreaseBarracksSizeII(XComGameState NewGameState, XComGameState_FacilityUpgrade Upgrade, XComGameState_FacilityXCom Facility)
{
	//Facility.UnlockStaffSlot(NewGameState);
}