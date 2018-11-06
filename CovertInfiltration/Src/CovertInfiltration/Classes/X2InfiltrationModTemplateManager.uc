//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains functions to control and
//           retrieve X2InfiltrationMod templates.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationModTemplateManager extends X2DataTemplateManager;

static function X2InfiltrationModTemplateManager GetInfilTemplateManager()
{
    return X2InfiltrationModTemplateManager(class'Engine'.static.GetTemplateManager(class'X2InfiltrationModTemplateManager'));
}

function X2InfiltrationModTemplate GetInfilTemplateFromItem(name ItemTemplate)
{
	return X2InfiltrationModTemplate(FindDataTemplate(class'X2InfiltrationMod'.static.GetInfilName(ItemTemplate)));
}

DefaultProperties
{
	TemplateDefinitionClass=class'X2InfiltrationMod'
	ManagedTemplateClass=class'X2InfiltrationModTemplate'
}