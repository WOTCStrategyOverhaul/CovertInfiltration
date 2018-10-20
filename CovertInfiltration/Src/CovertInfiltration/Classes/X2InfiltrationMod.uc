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

enum WEIGHTINDEX {Num};

static function X2InfiltrationModTemplate BuildArmorTemplate(name DataName, WEIGHTINDEX Weight, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;
	local int	InfilMod;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, name(default.INFILPREFIX $ DataName));

	InfilMod = 0;
	switch(Weight)
	{
	case 1:
		InfilMod = default.STEALTH_ARMOR_INFIL;
	case 2:
		InfilMod = default.LIGHT_ARMOR_INFIL;
	case 3:
		InfilMod = default.MEDIUM_ARMOR_INFIL;
	case 4:
		InfilMod = default.HEAVY_ARMOR_INFIL;
	case 5:
		InfilMod = default.BATTLE_ARMOR_INFIL;
	}
	Template.InfilModifier = InfilMod;
	
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}

static function X2InfiltrationModTemplate BuildWeaponTemplate(name DataName, WEIGHTINDEX Weight, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;
	local int	InfilMod;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, name(default.INFILPREFIX $ DataName));

	InfilMod = 0;
	switch(Weight)
	{
	case 1:
		InfilMod = default.LIGHT_WEAPON_INFIL;
	case 2:
		InfilMod = default.MIDLIGHT_WEAPON_INFIL;
	case 3:
		InfilMod = default.MEDIUM_WEAPON_INFIL;
	case 4:
		InfilMod = default.MIDHEAVY_WEAPON_INFIL;
	case 5:
		InfilMod = default.HEAVY_WEAPON_INFIL;
	}
	Template.InfilModifier = InfilMod;
	
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}

static function X2InfiltrationModTemplate BuildCustomTemplate(name DataName, optional int Modifier = 0, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, name(default.INFILPREFIX $ DataName));
	if(Modifier != 0)
		Template.InfilModifier = Modifier;
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}

defaultproperties
{
	INFILPREFIX = "InfilMod_"
}