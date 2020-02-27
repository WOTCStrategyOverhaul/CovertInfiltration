//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Template manager for X2InfiltrationMod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationModTemplateManager extends X2DataTemplateManager;

static function X2InfiltrationModTemplateManager GetInfilTemplateManager()
{
    return X2InfiltrationModTemplateManager(class'Engine'.static.GetTemplateManager(class'X2InfiltrationModTemplateManager'));
}

function X2InfiltrationModTemplate FindInfilTemplate(name TemplateName, EInfilModifierType TemplateType)
{
	return X2InfiltrationModTemplate(FindDataTemplate(class'X2InfiltrationMod'.static.GetInfilName(TemplateName, TemplateType)));
}

function X2InfiltrationModTemplate GetInfilTemplateFromItem(X2ItemTemplate Item)
{
	return FindInfilTemplate(Item.DataName, eIMT_Item);
}

function X2InfiltrationModTemplate GetInfilTemplateFromCategory(X2ItemTemplate Item)
{
	return FindInfilTemplate(Item.ItemCat, eIMT_Category);
}

function X2InfiltrationModTemplate GetInfilTemplateFromAbility(X2AbilityTemplate Ability)
{
	return FindInfilTemplate(Ability.DataName, eIMT_Ability);
}

function X2InfiltrationModTemplate GetInfilTemplateFromCharacter(X2CharacterTemplate Character)
{
	return FindInfilTemplate(Character.DataName, eIMT_Character);
}

DefaultProperties
{
	TemplateDefinitionClass=class'X2InfiltrationMod'
	ManagedTemplateClass=class'X2InfiltrationModTemplate'
}