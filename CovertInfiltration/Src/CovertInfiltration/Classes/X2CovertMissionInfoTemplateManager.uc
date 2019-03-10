//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Template manager for X2CovertMissionInfos
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2CovertMissionInfoTemplateManager extends X2DataTemplateManager;

static function X2CovertMissionInfoTemplateManager GetCovertMissionInfoTemplateManager()
{
    return X2CovertMissionInfoTemplateManager(class'Engine'.static.GetTemplateManager(class'X2CovertMissionInfoTemplateManager'));
}

function X2CovertMissionInfoTemplate GetCovertMissionInfoTemplateFromCA(name TemplateName)
{
	return X2CovertMissionInfoTemplate(FindDataTemplate(class'X2CovertMissionInfo'.static.GetCovertMissionInfoName(TemplateName)));
}

defaultProperties
{
	TemplateDefinitionClass=class'X2CovertMissionInfo'
	ManagedTemplateClass=class'X2CovertMissionInfoTemplate'
}