//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Creates basic templates for new armors (disguises).
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
	
	Armors.AddItem(CreateTLPKevlar());
	Armors.AddItem(CreateTLPPlated());
	Armors.AddItem(CreateTLPPowered());

	return Armors;
}

static function X2DataTemplate CreateCivilianDisguise()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'CivilianDisguise');
	Template.strImage = "img:///UILibrary_DisguiseIcons.X2InventoryIcons.Inv_Disguise_Civilian";
	Template.StartingItem = false;
	Template.CanBeBuilt = true;
	Template.TradingPostValue = 2;
	Template.bInfiniteItem = false;
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
	Template.strImage = "img:///UILibrary_DisguiseIcons.X2InventoryIcons.Inv_Disguise_Advent";
	Template.ItemCat = 'armor';
	Template.StartingItem = false;
	Template.CanBeBuilt = true;
	Template.bInfiniteItem = false;
	Template.TradingPostValue = 3;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('AdventDisguiseStats');
	Template.Abilities.AddItem('Phantom');
	Template.ArmorTechCat = 'plated';
	Template.ArmorClass = 'medium';
	Template.Tier = 1;
	Template.AkAudioSoldierArmorSwitch = 'Predator';
	Template.EquipSound = "StrategyUI_Armor_Equip_Conventional";

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_InfiltrationAbilitySet'.default.ADVENT_DISGUISE_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_InfiltrationAbilitySet'.default.ADVENT_DISGUISE_MOBILITY_BONUS);

	return Template;
}

static function X2DataTemplate CreateHolographicDisguise()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'HolographicDisguise');
	Template.strImage = "img:///UILibrary_DisguiseIcons.X2InventoryIcons.Inv_Disguise_Holo";
	Template.ItemCat = 'armor';
	Template.StartingItem = false;
	Template.CanBeBuilt = true;
	Template.bInfiniteItem = false;
	Template.TradingPostValue = 6;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('HolographicDisguiseStats');
	Template.Abilities.AddItem('Phantom');
	Template.ArmorTechCat = 'powered';
	Template.ArmorClass = 'medium';
	Template.Tier = 3;
	Template.AkAudioSoldierArmorSwitch = 'Warden';
	Template.EquipSound = "StrategyUI_Armor_Equip_Powered";

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_InfiltrationAbilitySet'.default.HOLOGRAPHIC_DISGUISE_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_InfiltrationAbilitySet'.default.HOLOGRAPHIC_DISGUISE_MOBILITY_BONUS);
	
	return Template;
}

static function X2DataTemplate CreateTLPKevlar()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'TLPKevlarArmor');
	Template.strImage = "img:///UILibrary_TLE_Common.TLE_Inv_Kevlar_Support";
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	Template.ArmorTechCat = 'conventional';
	Template.ArmorClass = 'basic';
	Template.Tier = 0;
	Template.AkAudioSoldierArmorSwitch = 'Conventional';
	Template.EquipSound = "StrategyUI_Armor_Equip_Conventional";

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, 0, true);

	Template.ArmorCat = 'soldier';

	return Template;
}

static function X2DataTemplate CreateTLPPlated()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'TLPPlatedArmor');
	Template.strImage = "img:///UILibrary_TLE_Common.TLE_Inv_PLT_Support";
	Template.ItemCat = 'armor';
	Template.bAddsUtilitySlot = true;
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	Template.TradingPostValue = 20;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('MediumPlatedArmorStats');
	Template.ArmorTechCat = 'plated';
	Template.ArmorClass = 'medium';
	Template.Tier = 1;
	Template.AkAudioSoldierArmorSwitch = 'Predator';
	Template.EquipNarrative = "X2NarrativeMoments.Strategy.CIN_ArmorIntro_PlatedMedium";
	Template.EquipSound = "StrategyUI_Armor_Equip_Plated";

	Template.CreatorTemplateName = 'MediumPlatedArmor_Schematic'; // The schematic which creates this item
	Template.BaseItem = 'TLPKevlarArmor'; // Which item this will be upgraded from

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_ItemGrantedAbilitySet'.default.MEDIUM_PLATED_HEALTH_BONUS, true);

	Template.ArmorCat = 'soldier';

	return Template;
}

static function X2DataTemplate CreateTLPPowered()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'TLPPoweredArmor');
	Template.strImage = "img:///UILibrary_TLE_Common.TLE_Inv_PWR_Support";
	Template.ItemCat = 'armor';
	Template.bAddsUtilitySlot = true;
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	Template.TradingPostValue = 60;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('MediumPoweredArmorStats');
	Template.ArmorTechCat = 'powered';
	Template.ArmorClass = 'medium';
	Template.Tier = 3;
	Template.AkAudioSoldierArmorSwitch = 'Warden';
	Template.EquipNarrative = "X2NarrativeMoments.Strategy.CIN_ArmorIntro_PoweredMedium";
	Template.EquipSound = "StrategyUI_Armor_Equip_Powered";

	Template.CreatorTemplateName = 'MediumPoweredArmor_Schematic'; // The schematic which creates this item
	Template.BaseItem = 'TLPPlatedArmor'; // Which item this will be upgraded from

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_ItemGrantedAbilitySet'.default.MEDIUM_POWERED_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_ItemGrantedAbilitySet'.default.MEDIUM_POWERED_MITIGATION_AMOUNT);

	Template.ArmorCat = 'soldier';

	return Template;
}

defaultproperties
{
	bShouldCreateDifficultyVariants = true
}
