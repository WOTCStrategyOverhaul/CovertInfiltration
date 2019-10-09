//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Definitions for barracks size unlocks.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_BarracksUnlocks extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(BarracksSizeIUnlock());

	return Templates;
}

static function X2BarracksSizeUnlockTemplate BarracksSizeIUnlock()
{
	local X2BarracksSizeUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2BarracksSizeUnlockTemplate', Template, 'BarracksSizeIUnlock');

	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_SquadSize1";

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 3;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 50;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}