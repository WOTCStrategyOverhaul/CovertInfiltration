//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: This class creates the X2InfiltrationModTemplates from config
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationMod extends X2DataSet config(Infiltration);

var const name INFILPREFIX;

struct InfiltrationModifier
{
	var name Item;
	var int HoursAdded;
	var float RiskReductionPercent;
	var name MultiplierCategory;
	var float InfilMultiplier;

	structdefaultproperties
    {
        InfilMultiplier=1.0
    }
};

var config array<InfiltrationModifier> InfilModifiers;

static function name GetInfilName(name ItemName)
{
	return name(default.INFILPREFIX $ ItemName);
}

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local InfiltrationModifier Modifier;
	local X2InfiltrationModTemplate Template;
	
	foreach default.InfilModifiers(Modifier)
	{
		`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, GetInfilName(Modifier.Item));
		
		Template.HoursAdded = Modifier.HoursAdded;
		Template.Deterrence = Modifier.RiskReductionPercent;
		Template.MultCategory = Modifier.MultiplierCategory;
		Template.InfilMultiplier = Modifier.InfilMultiplier;

		Templates.AddItem(Template);
	}

	return Templates;
}

defaultproperties
{
	INFILPREFIX = "InfilMod_"
}