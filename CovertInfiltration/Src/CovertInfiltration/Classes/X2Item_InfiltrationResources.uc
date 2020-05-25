class X2Item_InfiltrationResources extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Resources;

	Resources.AddItem(CreateActionableFacilityLead());
	
	return Resources;
}

static function X2DataTemplate CreateActionableFacilityLead ()
{
	local X2ItemTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, 'ActionableFacilityLead');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Facility_Lead"; // TODO: Add a checkmark or something?
	Template.ItemCat = 'resource';
	Template.CanBeBuilt = false;
	Template.HideInInventory = false;

	return Template;
}