//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: This class creates the X2InfiltrationModTemplates from config
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationMod extends X2DataSet config(Infiltration);

var const name INFILPREFIX;
var const name ITEMPREFIX;
var const name CATEGORYPREFIX;
var const name ABILITYPREFIX;
var const name CHARACTERPREFIX;

var config array<InfiltrationModifier> InfilModifiers;

static function name GetInfilName(name ElementName, EInfilModifierType ElementType)
{
	local string TypeName;

	switch (ElementType)
	{
		case eIMT_Item:
			TypeName = ITEMPREFIX;
			break;
		case eIMT_Category:
			TypeName = CATEGORYPREFIX;
			break;
		case eIMT_Ability:
			TypeName = ABILITYPREFIX;
			break;
		case eIMT_Character:
			TypeName = CHARACTERPREFIX;
			break;
		default:
			return none;
	}

	return name(default.INFILPREFIX $ TypeName $ ElementName);
}

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local InfiltrationModifier Modifier;
	local X2InfiltrationModTemplate Template;
	
	foreach default.InfilModifiers(Modifier)
	{
		`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, GetInfilName(Modifier.DataName));
		
		Template.HoursAdded = Modifier.InfilHoursAdded;
		Template.Deterrence = Modifier.RiskReductionPercent;
		Template.ModifyType = Modifier.ModifyType;

		Templates.AddItem(Template);
	}

	return Templates;
}

defaultproperties
{
	INFILPREFIX = "InfilMod_"
	ITEMPREFIX = "Item_"
	CATEGORYPREFIX = "Attachment_"
	ABILITYPREFIX = "Ability_"
	CHARACTERPREFIX = "Character_"
}