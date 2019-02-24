class X2StrategyElement_InfiltrationUnlocks extends X2StrategyElement config(Infiltration);

var config int INFILTRATION_1_COST; // 50
var config int INFILTRATION_2_COST; // 75
var config int INFILTRATION_1_RANK; // 3
var config int INFILTRATION_2_RANK; // 5

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateInfilSize1Unlock());
	Templates.AddItem(CreateInfilSize2Unlock());

	return Templates;
}

static function X2SoldierUnlockTemplate CreateInfilSize1Unlock()
{
	local X2SoldierUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierUnlockTemplate', Template, 'InfiltrationSize1');

	Template.bAllClasses = true;
	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_SquadSize1";

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = default.INFILTRATION_1_RANK;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = default.INFILTRATION_1_COST;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

static function X2SoldierUnlockTemplate CreateInfilSize2Unlock()
{
	local X2SoldierUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierUnlockTemplate', Template, 'InfiltrationSize2');

	Template.bAllClasses = true;
	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_SquadSize2";

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = default.INFILTRATION_2_RANK;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;
	Template.Requirements.SpecialRequirementsFn = Infiltration2UnlockFn;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = default.INFILTRATION_2_COST;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

function bool Infiltration2UnlockFn()
{
	// Infil 2 requires Infil 1 to be purchased first
	return `XCOMHQ.HasSoldierUnlockTemplate('InfiltrationSize1');
}
