//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Definitions for barracks size unlocks.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------
class X2StrategyElement_InfiltrationFacilityUpgrades extends X2StrategyElement_DefaultFacilityUpgrades config(Infiltration);

var config int BarracksSizeI_Power;
var config int BarracksSizeI_UpkeepCost;
var config StrategyCost BarracksSizeI_Cost;

var config int BarracksSizeII_Power;
var config int BarracksSizeII_UpkeepCost;
var config StrategyCost BarracksSizeII_Cost;

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

	`CREATE_X2TEMPLATE(class'X2FacilityUpgradeTemplate', Template, 'LivingQuarters_BarracksSizeI');
	Template.PointsToComplete = 0;
	Template.MaxBuild = 1;
	Template.strImage = "img:///UILibrary_StrategyImages.FacilityIcons.ChooseFacility_PowerConduitUpgrade";
	Template.OnUpgradeAddedFn = OnUpgradeAdded_IncreaseBarracksSizeI;

	Template.iPower = default.BarracksSizeI_Power;
	Template.UpkeepCost = default.BarracksSizeI_UpkeepCost;
	Template.Cost = default.BarracksSizeI_Cost;

	return Template;
}

static function X2DataTemplate CreateLivingQuarters_BarracksSizeII()
{
	local X2FacilityUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2FacilityUpgradeTemplate', Template, 'LivingQuarters_BarracksSizeII');
	Template.PointsToComplete = 0;
	Template.MaxBuild = 1;
	Template.strImage = "img:///UILibrary_StrategyImages.FacilityIcons.ChooseFacility_EleriumConduitUpgrade";
	Template.OnUpgradeAddedFn = OnUpgradeAdded_IncreaseBarracksSizeII;

	Template.iPower = default.BarracksSizeII_Power;
	Template.UpkeepCost = default.BarracksSizeII_UpkeepCost;
	Template.Cost = default.BarracksSizeII_Cost;

	return Template;
}

static function OnUpgradeAdded_IncreaseBarracksSizeI(XComGameState NewGameState, XComGameState_FacilityUpgrade Upgrade, XComGameState_FacilityXCom Facility)
{
	IncreaseBarracksSize(NewGameState, class'X2Helper_Infiltration'.default.BARRACKS_LIMIT_INCREASE_I);
}

static function OnUpgradeAdded_IncreaseBarracksSizeII(XComGameState NewGameState, XComGameState_FacilityUpgrade Upgrade, XComGameState_FacilityXCom Facility)
{
	IncreaseBarracksSize(NewGameState, class'X2Helper_Infiltration'.default.BARRACKS_LIMIT_INCREASE_II);
}

static function IncreaseBarracksSize(XComGameState UpdateState, int amount)
{
	local XComGameState_CovertInfiltrationInfo UpdatedInfo;

	UpdatedInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().ChangeForGamestate(UpdateState);

	UpdatedInfo.CurrentBarracksLimit += amount;
}