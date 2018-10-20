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
	
	//Templates.AddItem(BuildArmorTemplate(name DataName, WEIGHTINDEX Weight, optional float Mult, optional name MultCat));
	//Templates.AddItem(BuildWeaponTemplate(name DataName, WEIGHTINDEX Weight, optional float Mult, optional name MultCat));
	//Templates.AddItem(BuildCustomTemplate(name DataName, optional int Modifier, optional float Mult, optional name MultCat));
	
	Templates.AddItem(BuildArmorTemplate('KevlarArmor', medium));
	Templates.AddItem(BuildArmorTemplate('MediumPlatedArmor', medium));
	Templates.AddItem(BuildArmorTemplate('LightPlatedArmor', light));
	Templates.AddItem(BuildArmorTemplate('HeavyPlatedArmor', heavy));
	Templates.AddItem(BuildArmorTemplate('MediumPoweredArmor', medium));
	Templates.AddItem(BuildArmorTemplate('LightPoweredArmor', light));
	Templates.AddItem(BuildArmorTemplate('HeavyPoweredArmor', heavy));

	Templates.AddItem(BuildArmorTemplate('ReaperArmor', light));
	Templates.AddItem(BuildArmorTemplate('ReaperPlatedArmor', light));
	Templates.AddItem(BuildArmorTemplate('ReaperPoweredArmor', light));

	Templates.AddItem(BuildArmorTemplate('TemplarArmor', medium));
	Templates.AddItem(BuildArmorTemplate('TemplarPlatedArmor', medium));
	Templates.AddItem(BuildArmorTemplate('TemplarPoweredArmor', medium));

	Templates.AddItem(BuildArmorTemplate('SkirmisherArmor', heavy));
	Templates.AddItem(BuildArmorTemplate('SkirmisherPlatedArmor', heavy));
	Templates.AddItem(BuildArmorTemplate('SkirmisherPoweredArmor', heavy));
	
	Templates.AddItem(BuildArmorTemplate('SparkArmor', battle));
	Templates.AddItem(BuildArmorTemplate('PlatedSparkArmor', battle));
	Templates.AddItem(BuildArmorTemplate('PoweredSparkArmor', battle));

	// note to self: make actual X2Item templates
	Templates.AddItem(BuildArmorTemplate('CivilianDisguise', stealth, default.DISGUISE_T1_WEPMULT, 'weapon'));
	Templates.AddItem(BuildArmorTemplate('AdventDisguise', stealth, default.DISGUISE_T2_WEPMULT, 'weapon'));
	Templates.AddItem(BuildArmorTemplate('HolographicDisguise', stealth, default.DISGUISE_T3_WEPMULT, 'weapon'));
	
	Templates.AddItem(BuildWeaponTemplate('SMG_CV', stealth));
	Templates.AddItem(BuildWeaponTemplate('SMG_MG', stealth));
	Templates.AddItem(BuildWeaponTemplate('SMG_BM', stealth));
	
	Templates.AddItem(BuildWeaponTemplate('Shotgun_CV', light));
	Templates.AddItem(BuildWeaponTemplate('Shotgun_MG', light));
	Templates.AddItem(BuildWeaponTemplate('Shotgun_BM', light));
	
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_CV', medium));
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_MG', medium));
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_BM', medium));
	
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_CV', heavy));
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_MG', heavy));
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_BM', heavy));
	
	Templates.AddItem(BuildWeaponTemplate('Cannon_CV', battle));
	Templates.AddItem(BuildWeaponTemplate('Cannon_MG', battle));
	Templates.AddItem(BuildWeaponTemplate('Cannon_BM', battle));
	
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_CV', battle));
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_MG', battle));
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_BM', battle));
	
	Templates.AddItem(BuildWeaponTemplate('Bullpup_CV', light));
	Templates.AddItem(BuildWeaponTemplate('Bullpup_MG', light));
	Templates.AddItem(BuildWeaponTemplate('Bullpup_BM', light));
	
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_CV', medium));
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_MG', medium));
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_BM', medium));
	
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_CV', stealth));
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_MG', stealth));
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_BM', stealth));
	
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
