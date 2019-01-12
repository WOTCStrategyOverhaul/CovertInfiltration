//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains all the X2CovertMissionInfoTemplates
//           required for the mod, covering all missions that can
//           be infiltrated through Covert Actions
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2CovertMissionInfo_DefaultMissions extends X2CovertMissionInfo;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CreatePrepareGOpMission());
	Templates.AddItem(CreatePrepareRaidMission());

	return Templates;
}
/*
static function X2DataTemplate CreatePrepareGOpMission()
{
	local X2CovertMissionInfoTemplate Template;
	local X2StrategyElementTemplateManager StratMgr;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_PrepareGOp'));

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	Template.MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_GuerillaOp'));
	Template.MissionRewards.AddItem(X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Supplies')));

	return Template;
}

static function X2DataTemplate CreatePrepareRaidMission()
{
	local X2CovertMissionInfoTemplate Template;
	local X2StrategyElementTemplateManager StratMgr;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_PrepareRaid'));

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	Template.MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_SupplyRaid'));
	Template.MissionRewards.AddItem(X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Supplies')));

	return Template;
}
*/
static function X2DataTemplate CreatePrepareGOpMission()
{
	local X2CovertMissionInfoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_PrepareGOp'));

	Template.MissionSource = 'MissionSource_GuerillaOp';
	Template.MissionRewards.AddItem('Reward_Supplies');

	return Template;
}

static function X2DataTemplate CreatePrepareRaidMission()
{
	local X2CovertMissionInfoTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_PrepareRaid'));

	Template.MissionSource = 'MissionSource_SupplyRaid';
	Template.MissionRewards.AddItem('Reward_None');

	return Template;
}
