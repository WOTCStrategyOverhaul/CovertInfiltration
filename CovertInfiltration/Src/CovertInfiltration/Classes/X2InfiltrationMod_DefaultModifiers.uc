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
	
	//Templates.AddItem(BuildArmorTemplate(name ItemName, EInfiltrationWeight Weight, EDeterrenceLevel Deterrence, optional float Mult, optional name MultCat));
	//Templates.AddItem(BuildWeaponTemplate(name ItemName, EInfiltrationWeight Weight, EDeterrenceLevel Deterrence, optional float Mult, optional name MultCat));
	//Templates.AddItem(BuildCustomTemplate(name ItemName, optional int Modifier, optional float Mult, optional name MultCat));
	
	Templates.AddItem(BuildArmorTemplate('KevlarArmor', eInfilWeight_Medium, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildArmorTemplate('MediumPlatedArmor', eInfilWeight_Medium, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildArmorTemplate('LightPlatedArmor', eInfilWeight_Light, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildArmorTemplate('HeavyPlatedArmor', eInfilWeight_Heavy, eDeterrenceLevel_Threatening));
	Templates.AddItem(BuildArmorTemplate('MediumPoweredArmor', eInfilWeight_Medium, eDeterrenceLevel_Threatening));
	Templates.AddItem(BuildArmorTemplate('LightPoweredArmor', eInfilWeight_Light, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildArmorTemplate('HeavyPoweredArmor', eInfilWeight_Heavy, eDeterrenceLevel_Intimidating));

	Templates.AddItem(BuildArmorTemplate('ReaperArmor', eInfilWeight_Light, eDeterrenceLevel_Unnoticed));
	Templates.AddItem(BuildArmorTemplate('ReaperPlatedArmor', eInfilWeight_Light, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildArmorTemplate('ReaperPoweredArmor', eInfilWeight_Light, eDeterrenceLevel_Concerning));

	Templates.AddItem(BuildArmorTemplate('TemplarArmor', eInfilWeight_Medium, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildArmorTemplate('TemplarPlatedArmor', eInfilWeight_Medium, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildArmorTemplate('TemplarPoweredArmor', eInfilWeight_Medium, eDeterrenceLevel_Threatening));

	Templates.AddItem(BuildArmorTemplate('SkirmisherArmor', eInfilWeight_Heavy, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildArmorTemplate('SkirmisherPlatedArmor', eInfilWeight_Heavy, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildArmorTemplate('SkirmisherPoweredArmor', eInfilWeight_Heavy, eDeterrenceLevel_Threatening));
	
	Templates.AddItem(BuildArmorTemplate('SparkArmor', eInfilWeight_Battle, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildArmorTemplate('PlatedSparkArmor', eInfilWeight_Battle, eDeterrenceLevel_Threatening));
	Templates.AddItem(BuildArmorTemplate('PoweredSparkArmor', eInfilWeight_Battle, eDeterrenceLevel_Intimidating));

	// note to self: make actual X2Item templates
	Templates.AddItem(BuildArmorTemplate('CivilianDisguise', eInfilWeight_Stealth, eDeterrenceLevel_Unnoticed, default.DISGUISE_T1_WEPMULT, 'weapon'));
	Templates.AddItem(BuildArmorTemplate('AdventDisguise', eInfilWeight_Stealth, eDeterrenceLevel_Unnoticed, default.DISGUISE_T2_WEPMULT, 'weapon'));
	Templates.AddItem(BuildArmorTemplate('HolographicDisguise', eInfilWeight_Stealth, eDeterrenceLevel_Unnoticed, default.DISGUISE_T3_WEPMULT, 'weapon'));
	
	Templates.AddItem(BuildWeaponTemplate('SMG_CV', eInfilWeight_Stealth, eDeterrenceLevel_Unnoticed));
	Templates.AddItem(BuildWeaponTemplate('SMG_MG', eInfilWeight_Stealth, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildWeaponTemplate('SMG_BM', eInfilWeight_Stealth, eDeterrenceLevel_Concerning));
	
	Templates.AddItem(BuildWeaponTemplate('Shotgun_CV', eInfilWeight_Light, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildWeaponTemplate('Shotgun_MG', eInfilWeight_Light, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildWeaponTemplate('Shotgun_BM', eInfilWeight_Light, eDeterrenceLevel_Threatening));
	
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_CV', eInfilWeight_Medium, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_MG', eInfilWeight_Medium, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildWeaponTemplate('AssaultRifle_BM', eInfilWeight_Medium, eDeterrenceLevel_Threatening));
	
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_CV', eInfilWeight_Heavy, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_MG', eInfilWeight_Heavy, eDeterrenceLevel_Threatening));
	Templates.AddItem(BuildWeaponTemplate('SniperRifle_BM', eInfilWeight_Heavy, eDeterrenceLevel_Intimidating));
	
	Templates.AddItem(BuildWeaponTemplate('Cannon_CV', eInfilWeight_Battle, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildWeaponTemplate('Cannon_MG', eInfilWeight_Battle, eDeterrenceLevel_Threatening));
	Templates.AddItem(BuildWeaponTemplate('Cannon_BM', eInfilWeight_Battle, eDeterrenceLevel_Intimidating));
	
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_CV', eInfilWeight_Battle, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_MG', eInfilWeight_Battle, eDeterrenceLevel_Threatening));
	Templates.AddItem(BuildWeaponTemplate('SparkRifle_BM', eInfilWeight_Battle, eDeterrenceLevel_Intimidating));
	
	Templates.AddItem(BuildWeaponTemplate('Bullpup_CV', eInfilWeight_Light, eDeterrenceLevel_Unnoticed));
	Templates.AddItem(BuildWeaponTemplate('Bullpup_MG', eInfilWeight_Light, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildWeaponTemplate('Bullpup_BM', eInfilWeight_Light, eDeterrenceLevel_Concerning));
	
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_CV', eInfilWeight_Medium, eDeterrenceLevel_Unnoticed));
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_MG', eInfilWeight_Medium, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildWeaponTemplate('VektorRifle_BM', eInfilWeight_Medium, eDeterrenceLevel_Concerning));
	
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_CV', eInfilWeight_Stealth, eDeterrenceLevel_Trivial));
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_MG', eInfilWeight_Stealth, eDeterrenceLevel_Concerning));
	Templates.AddItem(BuildWeaponTemplate('ShardGauntlet_BM', eInfilWeight_Stealth, eDeterrenceLevel_Threatening));
	
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
	Templates.AddItem(BuildCustomTemplate('HoloProjector', ,, default.HOLOPROJECTOR_WEPMULT, 'weapon'));
	Templates.AddItem(BuildCustomTemplate('AdaptiveCamo', ,, default.ADAPTIVECAMO_ARMORMULT, 'armor'));

	return Templates;
}
