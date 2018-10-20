//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains all the X2InfiltrationModTemplates
//           required for the mod, covering all basegame armors and weapons
//           as well as CI's own custom items
//  NOTE:    Still need to add all the Alien Hunters items
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationMod_DefaultModifiers extends X2InfiltrationMod;

var config float DISGUISE_T1_WEPMULT;
var config float DISGUISE_T2_WEPMULT;
var config float DISGUISE_T3_WEPMULT;
var config float HOLOPROJECTOR_WEPMULT;
var config float ADAPTIVECAMO_ARMORMULT;

var config int SIDEARM_WEAPON_INFIL;
var config int LAUNCHER_WEAPON_INFIL;
var config int DRONE_WEAPON_INFIL;
var config int SWORD_WEAPON_INFIL;
var config int PSI_WEAPON_INFIL;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	//Templates.AddItem(BuildArmorTemplate(name DataName, int Weight, optional float Mult, optional name MultCat));
	//Templates.AddItem(BuildWeaponTemplate(name DataName, int Weight, optional float Mult, optional name MultCat));
	//Templates.AddItem(BuildCustomTemplate(name DataName, optional int Modifier, optional float Mult, optional name MultCat));
	
	Templates.AddItem(BuildArmorTemplate('KevlarArmor', 3));
	Templates.AddItem(BuildArmorTemplate('MediumPlatedArmor', 3));
	Templates.AddItem(BuildArmorTemplate('LightPlatedArmor', 2));
	Templates.AddItem(BuildArmorTemplate('HeavyPlatedArmor', 4));
	Templates.AddItem(BuildArmorTemplate('MediumPoweredArmor', 3));
	Templates.AddItem(BuildArmorTemplate('LightPoweredArmor', 2));
	Templates.AddItem(BuildArmorTemplate('HeavyPoweredArmor', 4));

	Templates.AddItem(BuildArmorTemplate('ReaperArmor', 2));
	Templates.AddItem(BuildArmorTemplate('ReaperPlatedArmor', 2));
	Templates.AddItem(BuildArmorTemplate('ReaperPoweredArmor', 2));

	Templates.AddItem(BuildArmorTemplate('TemplarArmor', 3));
	Templates.AddItem(BuildArmorTemplate('TemplarPlatedArmor', 3));
	Templates.AddItem(BuildArmorTemplate('TemplarPoweredArmor', 3));

	Templates.AddItem(BuildArmorTemplate('SkirmisherArmor', 4));
	Templates.AddItem(BuildArmorTemplate('SkirmisherPlatedArmor', 4));
	Templates.AddItem(BuildArmorTemplate('SkirmisherPoweredArmor', 4));
	
	Templates.AddItem(BuildArmorTemplate('SparkArmor', 5));
	Templates.AddItem(BuildArmorTemplate('PlatedSparkArmor', 5));
	Templates.AddItem(BuildArmorTemplate('PoweredSparkArmor', 5));

	// note to self: make actual X2Item templates
	Templates.AddItem(BuildArmorTemplate('CivilianDisguise', 1, default.DISGUISE_T1_WEPMULT, 'weapon'));
	Templates.AddItem(BuildArmorTemplate('AdventDisguise', 1, default.DISGUISE_T2_WEPMULT, 'weapon'));
	Templates.AddItem(BuildArmorTemplate('HolographicDisguise', 1, default.DISGUISE_T3_WEPMULT, 'weapon'));
	
	Templates.AddItem(BuildWeaponTemplate('SMG_CV', 1));
	Templates.AddItem(BuildWeaponTemplate('SMG_MG', 1));
	Templates.AddItem(BuildWeaponTemplate('SMG_BM', 1));
	
	Templates.AddItem(BuildWeaponTemplate('Shotgun_CV', 2));
	Templates.AddItem(BuildWeaponTemplate('Shotgun_MG', 2));
	Templates.AddItem(BuildWeaponTemplate('Shotgun_BM', 2));
	
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_CV', 3));
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_MG', 3));
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_BM', 3));
	
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_CV', 4));
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_MG', 4));
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_BM', 4));
	
	Templates.AddItem(BuildWeaponTemplate('Cannon_CV', 5));
	Templates.AddItem(BuildWeaponTemplate('Cannon_MG', 5));
	Templates.AddItem(BuildWeaponTemplate('Cannon_BM', 5));
	
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_CV', 5));
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_MG', 5));
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_BM', 5));
	
	Templates.AddItem(BuildWeaponTemplate('Bullpup_CV', 2));
	Templates.AddItem(BuildWeaponTemplate('Bullpup_MG', 2));
	Templates.AddItem(BuildWeaponTemplate('Bullpup_BM', 2));
	
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_CV', 3));
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_MG', 3));
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_BM', 3));
	
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_CV', 1));
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_MG', 1));
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_BM', 1));
	
	Templates.AddItem(BuildCustomTemplate('Pistol_CV', default.SIDEARM_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('Pistol_MG', default.SIDEARM_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('Pistol_BM', default.SIDEARM_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('Sidearm_CV', default.SIDEARM_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('Sidearm_MG', default.SIDEARM_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('Sidearm_BM', default.SIDEARM_WEAPON_INFIL));
	
	Templates.AddItem(BuildCustomTemplate('GrenadeLauncher_CV', default.LAUNCHER_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('GrenadeLauncher_MG', default.LAUNCHER_WEAPON_INFIL));
	
	Templates.AddItem(BuildCustomTemplate('Gremlin_CV', default.DRONE_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('Gremlin_MG', default.DRONE_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('Gremlin_BM', default.DRONE_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('SparkBit_CV', default.DRONE_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('SparkBit_MG', default.DRONE_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('SparkBit_BM', default.DRONE_WEAPON_INFIL));
	
	Templates.AddItem(BuildCustomTemplate('Sword_CV', default.SWORD_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('Sword_MG', default.SWORD_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('Sword_BM', default.SWORD_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('WristBlade_CV', default.SWORD_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('WristBlade_MG', default.SWORD_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('WristBlade_BM', default.SWORD_WEAPON_INFIL));

	Templates.AddItem(BuildCustomTemplate('PsiAmp_CV', default.PSI_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('PsiAmp_MG', default.PSI_WEAPON_INFIL));
	Templates.AddItem(BuildCustomTemplate('PsiAmp_BM', default.PSI_WEAPON_INFIL));

	// note to self: make actual X2Item templates
	Templates.AddItem(BuildCustomTemplate('HoloProjector', , default.HOLOPROJECTOR_WEPMULT, 'weapon'));
	Templates.AddItem(BuildCustomTemplate('AdaptiveCamo', , default.ADAPTIVECAMO_ARMORMULT, 'armor'));

	return Templates;
}
