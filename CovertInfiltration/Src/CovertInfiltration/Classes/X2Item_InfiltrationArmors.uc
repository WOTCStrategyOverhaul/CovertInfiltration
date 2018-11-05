//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Creates basic templates for new armors.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Item_InfiltrationArmors extends X2Item_DefaultArmors;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Armors;

	Armors.AddItem(CreateCivilianDisguise());
	Armors.AddItem(CreateAdventDisguise());
	Armors.AddItem(CreateHolographicDisguise());

	return Armors;
}

static function X2DataTemplate CreateCivilianDisguise()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'CivilianDisguise');
	Template.strImage = "img:///UILibrary_DisguiseIcons.X2InventoryIcons.Ivn_Disguise_Civilian";
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	Template.Abilities.AddItem('CivilianDisguiseStats');
	Template.Abilities.AddItem('Phantom');
	Template.ArmorTechCat = 'conventional';
	Template.ArmorClass = 'basic';
	Template.Tier = 0;
	Template.AkAudioSoldierArmorSwitch = 'Conventional';
	Template.EquipSound = "StrategyUI_Armor_Equip_Conventional";

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, 0, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_InfiltrationAbilitySet'.default.CIVILIAN_DISGUISE_MOBILITY_BONUS);

	return Template;
}

static function X2DataTemplate CreateAdventDisguise()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'AdventDisguise');
	Template.strImage = "img:///UILibrary_DisguiseIcons.X2InventoryIcons.Ivn_Disguise_Advent";
	Template.ItemCat = 'armor';
	//Template.bAddsUtilitySlot = true;
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	Template.TradingPostValue = 15;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('AdventDisguiseStats');
	Template.Abilities.AddItem('Phantom');
	Template.ArmorTechCat = 'plated';
	Template.ArmorClass = 'medium';
	Template.Tier = 1;
	Template.AkAudioSoldierArmorSwitch = 'Predator';
	Template.EquipSound = "StrategyUI_Armor_Equip_Conventional";

	Template.CreatorTemplateName = 'AdventDisguise_Schematic'; // The schematic which creates this item
	Template.BaseItem = 'CivilianDisguise'; // Which item this will be upgraded from

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_InfiltrationAbilitySet'.default.ADVENT_DISGUISE_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_InfiltrationAbilitySet'.default.ADVENT_DISGUISE_MOBILITY_BONUS);

	return Template;
}

static function X2DataTemplate CreateHolographicDisguise()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'HolographicDisguise');
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Warden_Armor";
	Template.ItemCat = 'armor';
	//Template.bAddsUtilitySlot = true;
	Template.StartingItem = false; // false
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	Template.TradingPostValue = 50;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('HolographicDisguiseStats');
	Template.Abilities.AddItem('Phantom');
	Template.ArmorTechCat = 'powered';
	Template.ArmorClass = 'medium';
	Template.Tier = 3;
	Template.AkAudioSoldierArmorSwitch = 'Warden';
	Template.EquipSound = "StrategyUI_Armor_Equip_Powered";

	Template.CreatorTemplateName = 'HolographicDisguise_Schematic'; // The schematic which creates this item
	Template.BaseItem = 'AdventDisguise'; // Which item this will be upgraded from

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_InfiltrationAbilitySet'.default.HOLOGRAPHIC_DISGUISE_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_InfiltrationAbilitySet'.default.HOLOGRAPHIC_DISGUISE_MOBILITY_BONUS);
	
	return Template;
}