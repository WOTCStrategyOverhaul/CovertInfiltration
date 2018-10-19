//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains all the X2InfiltrationModTemplates
//           required for the mod, covering all basegame armors and weapons
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationMod_DefaultModifiers extends X2InfiltrationMod;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2InfiltrationMod Base;
	Base = new class'X2InfiltrationMod';
	
	//Templates.AddItem(Base.static.BuildArmorTemplate(name DataName, int Weight, optional float Mult, optional name MultCat));
	//Templates.AddItem(Base.static.BuildWeaponTemplate(name DataName, int Weight, optional float Mult, optional name MultCat));
	//Templates.AddItem(Base.static.BuildCustomTemplate(name DataName, optional int Modifier, optional float Mult, optional name MultCat));
	
	Templates.AddItem(Base.static.BuildArmorTemplate('KevlarArmor_InfilMod', 3));
	Templates.AddItem(Base.static.BuildArmorTemplate('CivilianArmor_InfilMod', 1, 2, 'weapon')); // note to self: make actual X2Item
	Templates.AddItem(Base.static.BuildArmorTemplate('MediumPlatedArmor_InfilMod', 3));
	Templates.AddItem(Base.static.BuildArmorTemplate('LightPlatedArmor_InfilMod', 2));
	Templates.AddItem(Base.static.BuildArmorTemplate('HeavyPlatedArmor_InfilMod', 4));
	Templates.AddItem(Base.static.BuildArmorTemplate('AdventArmor_InfilMod', 1, 1.5, 'weapon')); // note to self: make actual X2Item
	Templates.AddItem(Base.static.BuildArmorTemplate('MediumPoweredArmor_InfilMod', 3));
	Templates.AddItem(Base.static.BuildArmorTemplate('LightPoweredArmor_InfilMod', 2));
	Templates.AddItem(Base.static.BuildArmorTemplate('HeavyPoweredArmor_InfilMod', 4));
	
	Templates.AddItem(Base.static.BuildArmorTemplate('ReaperArmor_InfilMod', 2));
	Templates.AddItem(Base.static.BuildArmorTemplate('ReaperPlatedArmor_InfilMod', 2));
	Templates.AddItem(Base.static.BuildArmorTemplate('ReaperPoweredArmor_InfilMod', 2));

	Templates.AddItem(Base.static.BuildArmorTemplate('TemplarArmor_InfilMod', 3));
	Templates.AddItem(Base.static.BuildArmorTemplate('TemplarPlatedArmor_InfilMod', 3));
	Templates.AddItem(Base.static.BuildArmorTemplate('TemplarPoweredArmor_InfilMod', 3));

	Templates.AddItem(Base.static.BuildArmorTemplate('SkirmisherArmor_InfilMod', 4));
	Templates.AddItem(Base.static.BuildArmorTemplate('SkirmisherPlatedArmor_InfilMod', 4));
	Templates.AddItem(Base.static.BuildArmorTemplate('SkirmisherPoweredArmor_InfilMod', 4));
	
	Templates.AddItem(Base.static.BuildArmorTemplate('SparkArmor_InfilMod', 5));
	Templates.AddItem(Base.static.BuildArmorTemplate('PlatedSparkArmor_InfilMod', 5));
	Templates.AddItem(Base.static.BuildArmorTemplate('PoweredSparkArmor_InfilMod', 5));
	
	Templates.AddItem(Base.static.BuildWeaponTemplate('SMG_CV_InfilMod', 1));
	Templates.AddItem(Base.static.BuildWeaponTemplate('SMG_MG_InfilMod', 1));
	Templates.AddItem(Base.static.BuildWeaponTemplate('SMG_BM_InfilMod', 1));
	
	Templates.AddItem(Base.static.BuildWeaponTemplate('Shotgun_CV_InfilMod', 2));
	Templates.AddItem(Base.static.BuildWeaponTemplate('Shotgun_MG_InfilMod', 2));
	Templates.AddItem(Base.static.BuildWeaponTemplate('Shotgun_BM_InfilMod', 2));
	
	Templates.AddItem(Base.static.BuildWeaponTemplate('AssaultRifle_CV_InfilMod', 3));
	Templates.AddItem(Base.static.BuildWeaponTemplate('AssaultRifle_MG_InfilMod', 3));
	Templates.AddItem(Base.static.BuildWeaponTemplate('AssaultRifle_BM_InfilMod', 3));
	
	Templates.AddItem(Base.static.BuildWeaponTemplate('SniperRifle_CV_InfilMod', 4));
	Templates.AddItem(Base.static.BuildWeaponTemplate('SniperRifle_MG_InfilMod', 4));
	Templates.AddItem(Base.static.BuildWeaponTemplate('SniperRifle_BM_InfilMod', 4));
	
	Templates.AddItem(Base.static.BuildWeaponTemplate('Cannon_CV_InfilMod', 5));
	Templates.AddItem(Base.static.BuildWeaponTemplate('Cannon_MG_InfilMod', 5));
	Templates.AddItem(Base.static.BuildWeaponTemplate('Cannon_BM_InfilMod', 5));
	
	Templates.AddItem(Base.static.BuildWeaponTemplate('SparkRifle_CV_InfilMod', 5));
	Templates.AddItem(Base.static.BuildWeaponTemplate('SparkRifle_MG_InfilMod', 5));
	Templates.AddItem(Base.static.BuildWeaponTemplate('SparkRifle_BM_InfilMod', 5));
	
	Templates.AddItem(Base.static.BuildWeaponTemplate('Bullpup_CV_InfilMod', 2));
	Templates.AddItem(Base.static.BuildWeaponTemplate('Bullpup_MG_InfilMod', 2));
	Templates.AddItem(Base.static.BuildWeaponTemplate('Bullpup_BM_InfilMod', 2));
	
	Templates.AddItem(Base.static.BuildWeaponTemplate('VektorRifle_CV_InfilMod', 3));
	Templates.AddItem(Base.static.BuildWeaponTemplate('VektorRifle_MG_InfilMod', 3));
	Templates.AddItem(Base.static.BuildWeaponTemplate('VektorRifle_BM_InfilMod', 3));
	
	Templates.AddItem(Base.static.BuildWeaponTemplate('ShardGauntlet_CV_InfilMod', 1));
	Templates.AddItem(Base.static.BuildWeaponTemplate('ShardGauntlet_MG_InfilMod', 1));
	Templates.AddItem(Base.static.BuildWeaponTemplate('ShardGauntlet_BM_InfilMod', 1));

	return Templates;
}
