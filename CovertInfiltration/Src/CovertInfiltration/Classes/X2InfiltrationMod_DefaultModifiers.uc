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
	
	//Templates.AddItem(BuildArmorTemplate(name DataName, eInfiltrationWeight Weight, optional float Mult, optional name MultCat));
	//Templates.AddItem(BuildWeaponTemplate(name DataName, eInfiltrationWeight Weight, optional float Mult, optional name MultCat));
	//Templates.AddItem(BuildCustomTemplate(name DataName, optional int Modifier, optional float Mult, optional name MultCat));
	
	Templates.AddItem(BuildArmorTemplate('KevlarArmor', eWeight_Medium));
	Templates.AddItem(BuildArmorTemplate('MediumPlatedArmor', eWeight_Medium));
	Templates.AddItem(BuildArmorTemplate('LightPlatedArmor', eWeight_Light));
	Templates.AddItem(BuildArmorTemplate('HeavyPlatedArmor', eWeight_Heavy));
	Templates.AddItem(BuildArmorTemplate('MediumPoweredArmor', eWeight_Medium));
	Templates.AddItem(BuildArmorTemplate('LightPoweredArmor', eWeight_Light));
	Templates.AddItem(BuildArmorTemplate('HeavyPoweredArmor', eWeight_Heavy));

	Templates.AddItem(BuildArmorTemplate('ReaperArmor', eWeight_Light));
	Templates.AddItem(BuildArmorTemplate('ReaperPlatedArmor', eWeight_Light));
	Templates.AddItem(BuildArmorTemplate('ReaperPoweredArmor', eWeight_Light));

	Templates.AddItem(BuildArmorTemplate('TemplarArmor', eWeight_Medium));
	Templates.AddItem(BuildArmorTemplate('TemplarPlatedArmor', eWeight_Medium));
	Templates.AddItem(BuildArmorTemplate('TemplarPoweredArmor', eWeight_Medium));

	Templates.AddItem(BuildArmorTemplate('SkirmisherArmor', eWeight_Heavy));
	Templates.AddItem(BuildArmorTemplate('SkirmisherPlatedArmor', eWeight_Heavy));
	Templates.AddItem(BuildArmorTemplate('SkirmisherPoweredArmor', eWeight_Heavy));
	
	Templates.AddItem(BuildArmorTemplate('SparkArmor', eWeight_Battle));
	Templates.AddItem(BuildArmorTemplate('PlatedSparkArmor', eWeight_Battle));
	Templates.AddItem(BuildArmorTemplate('PoweredSparkArmor', eWeight_Battle));

	// note to self: make actual X2Item templates
	Templates.AddItem(BuildArmorTemplate('CivilianDisguise', eWeight_Stealth, default.DISGUISE_T1_WEPMULT, 'weapon'));
	Templates.AddItem(BuildArmorTemplate('AdventDisguise', eWeight_Stealth, default.DISGUISE_T2_WEPMULT, 'weapon'));
	Templates.AddItem(BuildArmorTemplate('HolographicDisguise', eWeight_Stealth, default.DISGUISE_T3_WEPMULT, 'weapon'));
	
	Templates.AddItem(BuildWeaponTemplate('SMG_CV', eWeight_Stealth));
	Templates.AddItem(BuildWeaponTemplate('SMG_MG', eWeight_Stealth));
	Templates.AddItem(BuildWeaponTemplate('SMG_BM', eWeight_Stealth));
	
	Templates.AddItem(BuildWeaponTemplate('Shotgun_CV', eWeight_Light));
	Templates.AddItem(BuildWeaponTemplate('Shotgun_MG', eWeight_Light));
	Templates.AddItem(BuildWeaponTemplate('Shotgun_BM', eWeight_Light));
	
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_CV', eWeight_Medium));
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_MG', eWeight_Medium));
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_BM', eWeight_Medium));
	
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_CV', eWeight_Heavy));
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_MG', eWeight_Heavy));
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_BM', eWeight_Heavy));
	
	Templates.AddItem(BuildWeaponTemplate('Cannon_CV', eWeight_Battle));
	Templates.AddItem(BuildWeaponTemplate('Cannon_MG', eWeight_Battle));
	Templates.AddItem(BuildWeaponTemplate('Cannon_BM', eWeight_Battle));
	
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_CV', eWeight_Battle));
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_MG', eWeight_Battle));
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_BM', eWeight_Battle));
	
	Templates.AddItem(BuildWeaponTemplate('Bullpup_CV', eWeight_Light));
	Templates.AddItem(BuildWeaponTemplate('Bullpup_MG', eWeight_Light));
	Templates.AddItem(BuildWeaponTemplate('Bullpup_BM', eWeight_Light));
	
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_CV', eWeight_Medium));
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_MG', eWeight_Medium));
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_BM', eWeight_Medium));
	
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_CV', eWeight_Stealth));
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_MG', eWeight_Stealth));
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_BM', eWeight_Stealth));
	
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
