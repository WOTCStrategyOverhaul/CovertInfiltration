//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains functions to control and
//           retrieve X2CovertMissionInfo templates.
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
/*
function X2MissionSourceTemplate GetCovertMissionSource(X2CovertMissionInfoTemplate MissionInfo)
{
	local X2StrategyElementTemplateManager StratMgr;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	return X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate(MissionInfo.MissionSource));
}

function array<X2RewardTemplate> GetCovertMissionRewards(X2CovertMissionInfoTemplate MissionInfo)
{
	local array<X2RewardTemplate> Rewards;
	local int i;
	local X2StrategyElementTemplateManager StratMgr;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	for(i = 0; i < MissionInfo.MissionRewards.Length; i++)
	{
		Rewards.AddItem(X2RewardTemplate(StratMgr.FindStrategyElementTemplate(MissionInfo.MissionRewards[i])));
	}

	return Rewards;
}
*/
DefaultProperties
{
	TemplateDefinitionClass=class'X2CovertMissionInfo'
	ManagedTemplateClass=class'X2CovertMissionInfoTemplate'
}