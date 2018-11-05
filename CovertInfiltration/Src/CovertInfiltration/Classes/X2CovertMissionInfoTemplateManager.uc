//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains functions to control and
//           retrieve X2CovertMissionInfo templates.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2CovertMissionInfoTemplateManager extends X2StrategyElementTemplateManager;

static function X2CovertMissionInfoTemplateManager GetCovertMissionInfoTemplateManager()
{
    return X2CovertMissionInfoTemplateManager(class'Engine'.static.GetTemplateManager(class'X2CovertMissionInfoTemplateManager'));
}

function X2CovertMissionInfoTemplate GetCovertMissionInfoTemplateFromCA(name TemplateName)
{
	local X2CovertMissionInfoTemplate CovertMissionInfoTemplate;
	CovertMissionInfoTemplate = X2CovertMissionInfoTemplate(FindDataTemplate(class'X2CovertMissionInfo'.static.GetCovertMissionInfoName(TemplateName)));
	return CovertMissionInfoTemplate;
}

DefaultProperties
{
	TemplateDefinitionClass=class'X2CovertMissionInfo'
	ManagedTemplateClass=class'X2CovertMissionInfoTemplate'
}