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
	Template.MissionRewards.AddItem('Reward_GatherLeadActivity');
	Template.InitMissionFn = GenericInitMission;

	return Template;
}

static function X2DataTemplate CreateP1SupplyRaidMission()
{
	local X2CovertMissionInfoTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P1SupplyRaid'));
	
	Template.MissionSource = 'MissionSource_GatherLead';
	Template.MissionRewards.AddItem('Reward_GatherLeadTarget');
	Template.InitMissionFn = GenericInitMission;

	return Template;
}

static function X2DataTemplate CreateP1JailbreakMission()
{
	local X2CovertMissionInfoTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P1Jailbreak'));
	
	Template.MissionSource = 'MissionSource_GatherLead';
	Template.MissionRewards.AddItem('Reward_GatherLeadPersonnel');
	Template.InitMissionFn = GenericInitMission;

	return Template;
}

static function X2DataTemplate CreateP2DarkEventMission()
{
	local X2CovertMissionInfoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P2DarkEvent'));
	
	Template.MissionSource = 'MissionSource_DarkEvent';
	Template.MissionRewards.AddItem('Reward_Supplies');
	Template.InitMissionFn = DarkEventInitMission;

	return Template;
}

static function X2DataTemplate CreateP2DarkVIPMission()
{
	local X2CovertMissionInfoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P2DarkVIP'));

	Template.MissionSource = 'MissionSource_DarkVIP';
	Template.MissionRewards.AddItem('Reward_Intel');
	Template.InitMissionFn = GenericInitMission;

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
	Template.MissionRewards.AddItem('Reward_Engineer');
	Template.InitMissionFn = GenericInitMission;

	return Template;
}

static function X2DataTemplate CreateP2ScientistMission()
{
	local X2CovertMissionInfoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertMissionInfoTemplate', Template, GetCovertMissionInfoName('CovertAction_P2Scientist'));
	
	Template.MissionSource = 'MissionSource_Scientist';
	Template.MissionRewards.AddItem('Reward_Scientist');
	Template.InitMissionFn = GenericInitMission;

	return Template;
}

static function GenericInitMission(XComGameState NewGameState, XComGameState_CovertAction Action, XComGameState_MissionSiteInfiltration MissionSite)
{
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local X2CovertMissionInfoTemplate MissionInfo;
	local XComGameState_Reward RewardState;
	local array<X2RewardTemplate> RewardTemplates;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local Vector2D MissionLocation;
	local int i;

	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	MissionInfo = InfilMgr.GetCovertMissionInfoTemplateFromCA(Action.GetMyTemplateName());
	RewardTemplates = class'X2Helper_Infiltration'.static.GetCovertMissionRewards(MissionInfo);
	MissionSource = class'X2Helper_Infiltration'.static.GetCovertMissionSource(MissionInfo);
	
	for (i = 0; i < RewardTemplates.length; i++)
	{
		RewardState = RewardTemplates[i].CreateInstanceFromTemplate(NewGameState);
		RewardState.GenerateReward(NewGameState);
		MissionRewards.AddItem(RewardState);
	}

	// Set the location - required for camera pan to work properly
	MissionLocation.X = Action.Location.X;
	MissionLocation.Y = Action.Location.Y;

	// TODO: Region is messed up
	//ResistanceFaction = Faction;
	MissionSite.BuildMission(MissionSource, MissionLocation, MissionSite.Region, MissionRewards, true);
}

static function DarkEventInitMission(XComGameState NewGameState, XComGameState_CovertAction Action, XComGameState_MissionSiteInfiltration MissionSite)
{
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local X2CovertMissionInfoTemplate MissionInfo;
	local XComGameState_Reward RewardState, ActionReward;
	local array<X2RewardTemplate> RewardTemplates;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local Vector2D MissionLocation;
	local int i;

	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	MissionInfo = InfilMgr.GetCovertMissionInfoTemplateFromCA(Action.GetMyTemplateName());
	RewardTemplates = class'X2Helper_Infiltration'.static.GetCovertMissionRewards(MissionInfo);
	MissionSource = class'X2Helper_Infiltration'.static.GetCovertMissionSource(MissionInfo);
	
	for (i = 0; i < RewardTemplates.length; i++)
	{
		RewardState = RewardTemplates[i].CreateInstanceFromTemplate(NewGameState);
		RewardState.GenerateReward(NewGameState, 0.5); // Halve the reward size
		MissionRewards.AddItem(RewardState);
	}

	ActionReward = XComGameState_Reward(`XCOMHISTORY.GetGameStateForObjectID(Action.RewardRefs[0].ObjectID));
	MissionSite.DarkEvent = ActionReward.RewardObjectReference;

	// Set the location - required for camera pan to work properly
	MissionLocation.X = Action.Location.X;
	MissionLocation.Y = Action.Location.Y;

	// TODO: Region is messed up
	//ResistanceFaction = Faction;
	MissionSite.BuildMission(MissionSource, MissionLocation, MissionSite.Region, MissionRewards, true);
}