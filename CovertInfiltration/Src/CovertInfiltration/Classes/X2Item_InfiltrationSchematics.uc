class X2Item_InfiltrationSchematics extends X2Item_DefaultSchematics;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Schematics;
	
	Schematics.AddItem(CreateTemplate_AdventDisguise_Schematic());
	Schematics.AddItem(CreateTemplate_HolographicDisguise_Schematic());

	return Schematics;
}

static function X2DataTemplate CreateTemplate_AdventDisguise_Schematic()
{
	local X2SchematicTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SchematicTemplate', Template, 'AdventDisguise_Schematic');

	Template.ItemCat = 'armor';
	Template.strImage = "img:///UILibrary_DisguiseIcons.X2InventoryIcons.Ivn_Disguise_Advent";
	Template.PointsToComplete = 0;
	Template.Tier = 1;
	Template.OnBuiltFn = UpgradeItems;

	// Reference Item
	Template.ReferenceItemTemplate = 'AdventDisguise';
	Template.HideIfPurchased = 'HolographicDisguise';

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('AutopsyFaceless');

	// Cost
 	Resources.ItemTemplateName = 'Supplies';
 	Resources.Quantity = 25;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'EleriumDust';
	Resources.Quantity = 5;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

static function X2DataTemplate CreateTemplate_HolographicDisguise_Schematic()
{
	local X2SchematicTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SchematicTemplate', Template, 'HolographicDisguise_Schematic');

	Template.ItemCat = 'armor';
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Warden_Armor";
	Template.PointsToComplete = 0;
	Template.Tier = 2;
	Template.OnBuiltFn = UpgradeItems;

	// Reference Item
	Template.ReferenceItemTemplate = 'HolographicDisguise';

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('PoweredArmor');

	// Cost
 	Resources.ItemTemplateName = 'Supplies';
 	Resources.Quantity = 50;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'AlienAlloy';
	Resources.Quantity = 10;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'EleriumDust';
	Resources.Quantity = 5;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}