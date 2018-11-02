//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class adds several functions that help
//           in creating X2InfiltrationModTemplates
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationMod extends X2DataSet config(Infiltration);

var config int BATTLE_ARMOR_INFIL;
var config int HEAVY_ARMOR_INFIL;
var config int MEDIUM_ARMOR_INFIL;
var config int LIGHT_ARMOR_INFIL;
var config int STEALTH_ARMOR_INFIL;

var config int HEAVY_WEAPON_INFIL;
var config int MIDHEAVY_WEAPON_INFIL;
var config int MEDIUM_WEAPON_INFIL;
var config int MIDLIGHT_WEAPON_INFIL;
var config int LIGHT_WEAPON_INFIL;

var const name INFILPREFIX;

enum EInfiltrationWeight
{
	eInfilWeight_Stealth,
	eInfilWeight_Light,
	eInfilWeight_Medium,
	eInfilWeight_Heavy,
	eInfilWeight_Battle
};

var config int ARMOR_DETER_5;
var config int ARMOR_DETER_4;
var config int ARMOR_DETER_3;
var config int ARMOR_DETER_2;
var config int ARMOR_DETER_1;

var config int WEAPON_DETER_5;
var config int WEAPON_DETER_4;
var config int WEAPON_DETER_3;
var config int WEAPON_DETER_2;
var config int WEAPON_DETER_1;

enum EDeterrenceValue
{
	eDeterrenceValue_Invisible,
	eDeterrenceValue_Trivial,
	eDeterrenceValue_Concerning,
	eDeterrenceValue_Threatening,
	eDeterrenceValue_Intimidating
};

static function name GetInfilName(name ItemName)
{
	local name InfilName;
	Infilname = name(default.INFILPREFIX $ ItemName);
	return InfilName;
}

static function X2InfiltrationModTemplate BuildArmorTemplate(name ItemName, EInfiltrationWeight Weight, EDeterrenceValue Deterrence, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;
	local int	InfilMod;
	local int	DeterrenceMod;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, GetInfilName(ItemName));

	InfilMod = CalcArmorInfil(Weight);
	Template.InfilModifier = InfilMod;
	DeterrenceMod = CalcArmorDeterrence(Deterrence);
	Template.Deterrence = DeterrenceMod;
	
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}

static function X2InfiltrationModTemplate BuildWeaponTemplate(name ItemName, EInfiltrationWeight Weight, EDeterrenceValue Deterrence, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;
	local int	InfilMod;
	local int	DeterrenceMod;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, GetInfilName(ItemName));
	
	InfilMod = CalcWeaponInfil(Weight);
	Template.InfilModifier = InfilMod;
	DeterrenceMod = CalcWeaponDeterrence(Deterrence);
	Template.Deterrence = DeterrenceMod;
	
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}

static function X2InfiltrationModTemplate BuildCustomTemplate(name ItemName, optional int Modifier = 0, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, GetInfilName(ItemName));
	if(Modifier != 0)
		Template.InfilModifier = Modifier;
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}

static function int CalcArmorInfil(EInfiltrationWeight Weight)
{
	local int InfilMod;
	InfilMod = 0;
	switch(Weight)
	{
	case eInfilWeight_Stealth:
		InfilMod = default.STEALTH_ARMOR_INFIL;
	case eInfilWeight_Light:
		InfilMod = default.LIGHT_ARMOR_INFIL;
	case eInfilWeight_Medium:
		InfilMod = default.MEDIUM_ARMOR_INFIL;
	case eInfilWeight_Heavy:
		InfilMod = default.HEAVY_ARMOR_INFIL;
	case eInfilWeight_Battle:
		InfilMod = default.BATTLE_ARMOR_INFIL;
	}
	return InfilMod;
}

static function int CalcWeaponInfil(EInfiltrationWeight Weight)
{
	local int InfilMod;
	InfilMod = 0;
	switch(Weight)
	{
	case eInfilWeight_Stealth:
		InfilMod = default.LIGHT_WEAPON_INFIL;
	case eInfilWeight_Light:
		InfilMod = default.MIDLIGHT_WEAPON_INFIL;
	case eInfilWeight_Medium:
		InfilMod = default.MEDIUM_WEAPON_INFIL;
	case eInfilWeight_Heavy:
		InfilMod = default.MIDHEAVY_WEAPON_INFIL;
	case eInfilWeight_Battle:
		InfilMod = default.HEAVY_WEAPON_INFIL;
	}
	return InfilMod;
}

static function int CalcArmorDeterrence(EDeterrenceValue Deterrence)
{
	local int DeterrenceMod;
	DeterrenceMod = 0;
	switch(Deterrence)
	{
	case eDeterrenceValue_Invisible:
		DeterrenceMod = default.ARMOR_DETER_1;
	case eDeterrenceValue_Trivial:
		DeterrenceMod = default.ARMOR_DETER_2;
	case eDeterrenceValue_Concerning:
		DeterrenceMod = default.ARMOR_DETER_3;
	case eDeterrenceValue_Threatening:
		DeterrenceMod = default.ARMOR_DETER_4;
	case eDeterrenceValue_Intimidating:
		DeterrenceMod = default.ARMOR_DETER_5;
	}
	return DeterrenceMod;
}

static function int CalcWeaponDeterrence(EDeterrenceValue Deterrence)
{
	local int DeterrenceMod;
	DeterrenceMod = 0;
	switch(Deterrence)
	{
	case eDeterrenceValue_Invisible:
		DeterrenceMod = default.WEAPON_DETER_1;
	case eDeterrenceValue_Trivial:
		DeterrenceMod = default.WEAPON_DETER_2;
	case eDeterrenceValue_Concerning:
		DeterrenceMod = default.WEAPON_DETER_3;
	case eDeterrenceValue_Threatening:
		DeterrenceMod = default.WEAPON_DETER_4;
	case eDeterrenceValue_Intimidating:
		DeterrenceMod = default.WEAPON_DETER_5;
	}
	return DeterrenceMod;
}

defaultproperties
{
	INFILPREFIX = "InfilMod_"
}