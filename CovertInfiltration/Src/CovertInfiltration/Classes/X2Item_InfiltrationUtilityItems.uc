//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Creates item templates for items added by this mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Item_InfiltrationUtilityItems extends X2Item_DefaultUtilityItems;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;

	Items.AddItem(CreateHoloProjector());
	Items.AddItem(CreateAdaptiveCamo());

	return Items;
}

static function X2EquipmentTemplate CreateHoloProjector()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'HoloProjector');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Battle_Scanner";
	Template.EquipSound = "StrategyUI_Skulljack_Equip";
	Template.InventorySlot = eInvSlot_Utility;
	Template.ItemCat = 'tech';

	Template.CanBeBuilt = true;
	Template.PointsToComplete = 0;
	Template.TradingPostValue = 6;

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('AutopsyFaceless');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 30;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Artifacts.ItemTemplateName = 'CorpseFaceless';
	Artifacts.Quantity = 1;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);
	
	return Template;
}

static function X2EquipmentTemplate CreateAdaptiveCamo()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'AdaptiveCamo');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Mimic_Beacon";
	Template.EquipSound = "StrategyUI_Vest_Equip";
	Template.InventorySlot = eInvSlot_Utility;
	Template.ItemCat = 'tech';

	Template.CanBeBuilt = true;
	Template.PointsToComplete = 0;
	Template.TradingPostValue = 15;

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('AutopsySpectre');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 45;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Artifacts.ItemTemplateName = 'CorpseSpectre';
	Artifacts.Quantity = 1;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	return Template;
}