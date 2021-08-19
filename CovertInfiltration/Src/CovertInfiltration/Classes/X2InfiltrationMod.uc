//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: This class creates the X2InfiltrationModTemplates from config
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationMod extends X2DataSet config(Infiltration);

var const name ITEMPREFIX;
var const name CATEGORYPREFIX;
var const name ABILITYPREFIX;
var const name CHARACTERPREFIX;

var config array<InfiltrationModifier> InfilModifiers;

static function name GetInfilName(name ElementName, EInfilModifierType ElementType)
{
	local name TypeName;

	switch (ElementType)
	{
		case eIMT_Item:
			TypeName = default.ITEMPREFIX;
			break;
		case eIMT_Category:
			TypeName = default.CATEGORYPREFIX;
			break;
		case eIMT_Ability:
			TypeName = default.ABILITYPREFIX;
			break;
		case eIMT_Character:
			TypeName = default.CHARACTERPREFIX;
			break;
		default:
			`CI_Warn("X2InfiltrationMod failed to grab type for " $ string(ElementName));
			return '';
	}

	return name(string(TypeName) $ string(ElementName));
}

static function array<X2DataTemplate> CreateTemplates()
{
	local X2InfiltrationModTemplate Template;
	local array<X2DataTemplate> Templates;
	local InfiltrationModifier Modifier;
	local name TemplateName;
	
	foreach default.InfilModifiers(Modifier)
	{
		TemplateName = GetInfilName(Modifier.DataName, Modifier.ModifyType); 
		
		// Skip if this comes from a DLC that we don't have
		if (Modifier.DLC != "" && !class'X2Helper_Infiltration'.static.IsDLCLoaded(Modifier.DLC))
		{
			`CI_Trace("X2InfiltrationModTemplate" @ string(TemplateName) @ "requires" @ Modifier.DLC @ "which is not loaded - skipping creation");
			continue;
		}

		`CREATE_X2TEMPLATE(class'X2InfiltrationModTemplate', Template, TemplateName);
		
		Template.HoursAdded = Modifier.InfilHoursAdded;
		Template.Deterrence = Modifier.RiskReductionPercent;
		Template.ModifyType = Modifier.ModifyType;
		Template.ElementName = Modifier.DataName;

		Templates.AddItem(Template);
	}

	return Templates;
}

defaultproperties
{
	ITEMPREFIX = "Item_"
	CATEGORYPREFIX = "Attachment_"
	ABILITYPREFIX = "Ability_"
	CHARACTERPREFIX = "Character_"
}