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
	
	Templates.AddItem(CreateP1DarkEventMission());
	Templates.AddItem(CreateP1SupplyRaidMission());
	Templates.AddItem(CreateP1JailbreakMission());

	Templates.AddItem(CreateP2DarkVIPMission());
	//Templates.AddItem(CreateP2SupplyRaidMission());
	Templates.AddItem(CreateP2EngineerMission());
	Templates.AddItem(CreateP2ScientistMission());
	Templates.AddItem(CreateP2DarkEventMission());

	return Templates;
}

static function X2DataTemplate CreateP1DarkEventMission()
{
	local X2CovertMissionInfoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P1DarkEvent'));

	Template.MissionSource = 'MissionSource_GatherLead';
	//Template.MissionRewards.AddItem('Reward_None');

	return Template;
}

static function X2DataTemplate CreateP1SupplyRaidMission()
{
	local X2CovertMissionInfoTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P1SupplyRaid'));
	
	Template.MissionSource = 'MissionSource_GatherLead';
	//Template.MissionRewards.AddItem('Reward_None');

	return Template;
}

static function X2DataTemplate CreateP1JailbreakMission()
{
	local X2CovertMissionInfoTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P1Jailbreak'));
	
	Template.MissionSource = 'MissionSource_GatherLead';
	//Template.MissionRewards.AddItem('Reward_None');

	return Template;
}

static function X2DataTemplate CreateP2DarkEventMission()
{
	local X2CovertMissionInfoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P2DarkEvent'));
	
	Template.MissionSource = 'MissionSource_DarkEvent';
	//Template.MissionRewards.AddItem('Reward_Supplies');

	return Template;
}

static function X2DataTemplate CreateP2DarkVIPMission()
{
	local X2CovertMissionInfoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P2DarkVIP'));

	Template.MissionSource = 'MissionSource_DarkVIP';
	//Template.MissionRewards.AddItem('Reward_Intel');

	return Template;
}
/*
static function X2DataTemplate CreateP2SupplyRaidMission()
{
	local X2CovertMissionInfoTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P2SupplyRaid'));

	Template.MissionSource = 'MissionSource_GuerillaOp';
	//Template.MissionRewards.AddItem('Reward_Supplies');

	return Template;
}
*/
static function X2DataTemplate CreateP2EngineerMission()
{
	local X2CovertMissionInfoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P2Engineer'));
	
	Template.MissionSource = 'MissionSource_Engineer';
	//Template.MissionRewards.AddItem('Reward_Engineer');

	return Template;
}

static function X2DataTemplate CreateP2ScientistMission()
{
	local X2CovertMissionInfoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P2Scientist'));
	
	Template.MissionSource = 'MissionSource_Scientist';
	//Template.MissionRewards.AddItem('Reward_Scientist');

	return Template;
}
