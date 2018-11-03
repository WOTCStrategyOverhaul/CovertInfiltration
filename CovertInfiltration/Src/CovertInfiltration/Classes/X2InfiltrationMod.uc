//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class adds several functions that help
//           in creating X2InfiltrationModTemplates
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationMod extends X2DataSet config(Infiltration);

var const name INFILPREFIX;

enum EInfiltrationWeight
{
	eInfilWeight_Stealth,
	eInfilWeight_Light,
	eInfilWeight_Medium,
	eInfilWeight_Heavy,
	eInfilWeight_Battle
};

var config int ArmourInfiltration[EInfiltrationWeight.EnumCount]<BoundEnum=EInfiltrationWeight>;
var config int WeaponInfiltration[EInfiltrationWeight.EnumCount]<BoundEnum=EInfiltrationWeight>;

enum EDeterrenceLevel
{
	eDeterrenceLevel_Unnoticed,
	eDeterrenceLevel_Trivial,
	eDeterrenceLevel_Concerning,
	eDeterrenceLevel_Threatening,
	eDeterrenceLevel_Intimidating
};

var config int ItemDeterrence[EDeterrenceLevel.EnumCount]<BoundEnum=EDeterrenceLevel>;

static function name GetInfilName(name ItemName)
{
	local name InfilName;
	Infilname = name(default.INFILPREFIX $ ItemName);
	return InfilName;
}

static function X2InfiltrationModTemplate BuildArmorTemplate(name ItemName, EInfiltrationWeight Weight, EDeterrenceLevel Deterrence, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, GetInfilName(ItemName));

	Template.InfilModifier = default.ArmourInfiltration[Weight];
	Template.Deterrence = default.ItemDeterrence[Deterrence];
	
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}

static function X2InfiltrationModTemplate BuildWeaponTemplate(name ItemName, EInfiltrationWeight Weight, EDeterrenceLevel Deterrence, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, GetInfilName(ItemName));
	
	Template.InfilModifier = default.WeaponInfiltration[Weight];
	Template.Deterrence = default.ItemDeterrence[Deterrence];
	
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	
	return Template;
}

static function X2InfiltrationModTemplate BuildCustomTemplate(name ItemName, optional int Modifier = 0, optional int Deterrence, optional float Mult = 1, optional name MultCat = '')
{
	local X2InfiltrationModTemplate		Template;

	`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, GetInfilName(ItemName));
	if(Modifier != 0)
		Template.InfilModifier = Modifier;
	if(Mult != 1)
		Template.InfilMultiplier = Mult;
	if(MultCat != '')
		Template.MultCategory = MultCat;
	if(Deterrence != 0)
		Template.Deterrence = Deterrence;
	
	return Template;
}

defaultproperties
{
	INFILPREFIX = "InfilMod_"
}