//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class adds several functions that help
//           in creating X2InfiltrationModTemplates
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationMod extends X2DataSet config(GameData);

var config int BATTLEARMORINFIL;
var config int HEAVYARMORINFIL;
var config int MEDIUMARMORINFIL;
var config int LIGHTARMORINFIL;
var config int STEALTHARMORINFIL;

var config int HEAVYWEAPONINFIL;
var config int MIDHEAVYWEAPONINFIL;
var config int MEDIUMWEAPONINFIL;
var config int MIDLIGHTWEAPONINFIL;
var config int LIGHTWEAPONINFIL;

static function X2InfiltrationModTemplate BuildArmorTemplate(name DataName, int Weight, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;
	local int	InfilMod;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, DataName);

	InfilMod = 0;
	switch(Weight)
	{
	case 1:
		InfilMod = default.STEALTHARMORINFIL;
	case 2:
		InfilMod = default.LIGHTARMORINFIL;
	case 3:
		InfilMod = default.MEDIUMARMORINFIL;
	case 4:
		InfilMod = default.HEAVYARMORINFIL;
	case 5:
		InfilMod = default.BATTLEARMORINFIL;
	}
	Template.InfilModifier = InfilMod;
	
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}

static function X2InfiltrationModTemplate BuildWeaponTemplate(name DataName, int Weight, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;
	local int	InfilMod;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, DataName);

	InfilMod = 0;
	switch(Weight)
	{
	case 1:
		InfilMod = default.LIGHTWEAPONINFIL;
	case 2:
		InfilMod = default.MIDLIGHTWEAPONINFIL;
	case 3:
		InfilMod = default.MEDIUMWEAPONINFIL;
	case 4:
		InfilMod = default.MIDHEAVYWEAPONINFIL;
	case 5:
		InfilMod = default.HEAVYWEAPONINFIL;
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

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, DataName);
	if(Modifier != 0)
		Template.InfilModifier = Modifier;
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}
