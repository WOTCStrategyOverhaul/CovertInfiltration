//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and NotSoLoneWolf
//  PURPOSE: Activites that are introduced by this mod. Note that many activities need
//           multiple templates (eg. X2ActivityTemplate + X2CovertActionTemplate) so
//           the templates array is passed to individual Create[...] methods, instead of
//           returning the template and adding it inside CreateTemplates() as usual
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_DefaultActivities extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	CreateRecoverPersonnel(Templates);
	CreatePreparePersonnel(Templates);
	CreateRescueEngineer(Templates);
	CreateRescueScientist(Templates);
	
	CreateRecoverInformant(Templates);
	CreateCaptureInformant(Templates);

	CreateDEWaitActivity(Templates);
	CreatePrepareCounterDE(Templates);
	CreateRecoverDarkEvent(Templates);
	CreateCounterDarkEvent(Templates);
	
	CreatePrepareFactionJB(Templates);
	CreateJailbreakSoldier(Templates);
	CreateJailbreakChosenSoldier(Templates);
	CreateJailbreakFactionSoldier(Templates);
	
	CreateRecoverUFO(Templates);
	CreatePrepareUFO(Templates);
	CreateLandedUFO(Templates);
	
	CreateCommanderSupply(Templates);
	CreateSupplyRaid(Templates);
	
	CreatePrepareFacility(Templates);
	CreateFacilityInformant(Templates);
	
	CreateGatherIntel(Templates);
	CreateGatherSupplies(Templates);
	
	CreateIntelRescue(Templates);
	CreateSupplyRescue(Templates);
	
	return Templates;
}

static function CreateRecoverPersonnel (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_RecoverPersonnelInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "RecoverPersonnel", "ResOps", "img:///UILibrary_XPACK_Common.MissionIcon_ResOps");

	Activity.bNeedsPOI = true;
	
	Activity.MissionRewards.AddItem('Reward_Rumor');
	Activity.MissionRewards.AddItem('Reward_SmallIntel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreatePreparePersonnel (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, 'Activity_PreparePersonnel');
	CovertAction = CreateStandardActivityCA("PreparePersonnel", "CovertAction");

	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.OptionalCosts.AddItem(CreateOptionalCostSlot('Supplies', 25));

	CovertAction.Risks.AddItem('CovertActionRisk_SoldierWounded');
	CovertAction.Rewards.AddItem('Reward_Progress');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateRescueEngineer (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_RescueEngineerInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "RescueEngineer", "Council_VIP", "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Council");

	Activity.MissionRewards.AddItem('Reward_Engineer');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateRescueScientist (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_RescueScientistInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "RescueScientist", "Council_VIP", "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Council");

	Activity.MissionRewards.AddItem('Reward_Scientist');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateRecoverInformant (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_RecoverInformantInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "RecoverInformant", "ResOps", "img:///UILibrary_XPACK_Common.MissionIcon_ResOps");
	
	Activity.bNeedsPOI = true;
	
	Activity.MissionRewards.AddItem('Reward_Rumor');
	Activity.MissionRewards.AddItem('Reward_SmallIntel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateCaptureInformant (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_CaptureInformantInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "CaptureInformant", "EscapeAmbush", "img:///UILibrary_XPACK_Common.MissionIcon_EscapeAmbush");
	
	Activity.MissionRewards.AddItem('Reward_Datapad');
	Activity.MissionRewards.AddItem('Reward_Intel');

	Activity.OnSuccess = DarkVIPOnSuccess;
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateDEWaitActivity (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate Activity;

	// This is a special "activity" which does nothing but waits and triggers the next stage at some point in time
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate', Activity, 'Activity_WaitDE');
	Activity.StateClass = class'XComGameState_Activity_Wait';
	Activity.GetOverviewStatus = DEWaitGetOverviewStatus;

	Templates.AddItem(Activity);
}

static function string DEWaitGetOverviewStatus (XComGameState_Activity ActivityState)
{
	if (ActivityState.IsOngoing())
	{
		return class'UIUtilities_Infiltration'.default.strCompletionStatusLabel_Ongoing;
	}

	return class'X2ActivityTemplate'.static.DefaultGetOverviewStatus(ActivityState);
}

static function CreatePrepareCounterDE (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, 'Activity_PrepareCounterDE');
	CovertAction = CreateStandardActivityCA("PrepareCounterDE", "CovertAction");

	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.OptionalCosts.AddItem(CreateOptionalCostSlot('Supplies', 25));

	CovertAction.Risks.AddItem('CovertActionRisk_SoldierWounded');
	CovertAction.Rewards.AddItem('Reward_Progress');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateRecoverDarkEvent (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_RecoverDarkEventInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "RecoverDarkEvent", "ResOps", "img:///UILibrary_XPACK_Common.MissionIcon_ResOps");
	
	Activity.bNeedsPOI = true;
	
	Activity.MissionRewards.AddItem('Reward_Rumor');
	Activity.MissionRewards.AddItem('Reward_SmallIntel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}
/*
static function CreateCounterDarkEvent (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_CounterDarkEventInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "CounterDarkEvent", "Retribution", "img:///UILibrary_XPACK_Common.MissionIcon_Retribution");
	
	Activity.bNeedsPOI = true;
	
	Activity.MissionRewards.AddItem('Reward_Rumor');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}
*/
static function CreateCounterDarkEvent (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, 'Activity_CounterDarkEvent');
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final.Retribution";
	Activity.UIButtonIcon = "img:///UILibrary_XPACK_Common.MissionIcon_Retribution";
	Activity.MissionImage = "img:///UILibrary_StrategyImages.Alert_Advent_Ops_Appear";
	Activity.Difficulty = 2;
	
	Activity.bNeedsPOI = true;
	
	Activity.MissionRewards.AddItem('Reward_DarkEvent');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "GeoscapeFanfares_GuerillaOps";

	Templates.AddItem(Activity);
}

static function CreatePrepareFactionJB (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, 'Activity_PrepareFactionJB');
	CovertAction = CreateStandardActivityCA("PrepareFactionJB", "CovertAction");

	CovertAction.RequiredFactionInfluence = eFactionInfluence_Influential;
	CovertAction.bDisplayIgnoresInfluence = true;

	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot', 3));
	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Rewards.AddItem('Reward_Progress');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateJailbreakSoldier (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_JailbreakSoldierInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "JailbreakSoldier", "RescueOps", "img:///UILibrary_XPACK_Common.MissionIcon_RescueSoldier");

	Activity.MissionRewards.AddItem('Reward_SoldierCaptured');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateJailbreakChosenSoldier (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_JailbreakChosenSoldierInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "JailbreakChosenSoldier", "RescueOps", "img:///UILibrary_XPACK_Common.MissionIcon_RescueSoldier");

	Activity.MissionRewards.AddItem('Reward_ChosenSoldierCaptured');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateJailbreakFactionSoldier (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_JailbreakFactionSoldierInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "JailbreakFactionSoldier", "RescueOps", "img:///UILibrary_XPACK_Common.MissionIcon_RescueSoldier");

	Activity.MissionRewards.AddItem('Reward_ExtraFactionSoldier');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateRecoverUFO (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_RecoverUFOInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "RecoverUFO", "ResOps", "img:///UILibrary_XPACK_Common.MissionIcon_ResOps");
	
	Activity.bNeedsPOI = true;
	
	Activity.MissionRewards.AddItem('Reward_Rumor');
	Activity.MissionRewards.AddItem('Reward_SmallIntel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreatePrepareUFO (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, 'Activity_PrepareUFO');
	CovertAction = CreateStandardActivityCA("PrepareUFO", "CovertAction");

	CovertAction.RequiredFactionInfluence = eFactionInfluence_Influential;
	CovertAction.bDisplayIgnoresInfluence = true;

	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Risks.AddItem('CovertActionRisk_SoldierCaptured');
	CovertAction.Risks.AddItem('CovertActionRisk_SoldierWounded');
	CovertAction.Rewards.AddItem('Reward_Progress');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateLandedUFO (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, 'Activity_LandedUFO');
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final.Landed_UFO";
	Activity.UIButtonIcon = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Advent";
	Activity.ScreenClass = class'UIMission_LandedUFO';
	Activity.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_UFO_Landed";
	Activity.Difficulty = 3;
	
	Activity.MissionRewards.AddItem('Reward_Materiel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_UFO_Landed";

	Templates.AddItem(Activity);
}

static function CreateCommanderSupply (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_CommanderSupplyInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "CommanderSupply", "GorillaOps", "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_GOPS");
	
	Activity.bNeedsPOI = true;
	
	Activity.MissionRewards.AddItem('Reward_Rumor');
	Activity.MissionRewards.AddItem('Reward_SmallIntel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateSupplyRaid (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_SupplyRaidInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "SupplyRaid", "SupplyRaid_AdvConvoy", "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_SupplyRaid");

	Activity.MissionRewards.AddItem('Reward_Materiel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_Supply_Raid_Popup";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreatePrepareFacility (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, 'Activity_PrepareFacility');
	CovertAction = CreateStandardActivityCA("PrepareFacility", "CovertAction");

	CovertAction.RequiredFactionInfluence = eFactionInfluence_Influential;
	CovertAction.bDisplayIgnoresInfluence = true;

	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Risks.AddItem('CovertActionRisk_Ambush');
	CovertAction.Rewards.AddItem('Reward_Progress');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateFacilityInformant (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_FacilityInformantInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "FacilityInformant", "EscapeAmbush", "img:///UILibrary_XPACK_Common.MissionIcon_EscapeAmbush");
	
	Activity.MissionRewards.AddItem('Reward_Datapad');
	Activity.MissionRewards.AddItem('Reward_FacilityLead');

	Activity.OnSuccess = DarkVIPOnSuccess;
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateGatherIntel (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, 'Activity_GatherIntel');
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final.RadioTower";
	Activity.UIButtonIcon = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_ResHQ";
	Activity.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Recover_X_Intel";
	Activity.Difficulty = 2;
	
	Activity.MissionRewards.AddItem('Reward_Intel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

	Templates.AddItem(Activity);
}

static function CreateGatherSupplies (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, 'Activity_GatherSupplies');
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final.SupplyExtraction";
	Activity.UIButtonIcon = "img:///UILibrary_XPACK_Common.MissionIcon_SupplyExtraction";
	Activity.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Recover_X_Supplies";
	Activity.Difficulty = 2;
	
	Activity.MissionRewards.AddItem('Reward_Materiel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_Supply_Raid_Popup";

	Templates.AddItem(Activity);
}

static function CreateRescueWaitActivity (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate Activity;

	// This is a special "activity" which does nothing but waits and triggers the next stage at some point in time
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate', Activity, 'Activity_WaitRescue');
	Activity.StateClass = class'XComGameState_Activity_Wait';

	Templates.AddItem(Activity);
}

static function CreateIntelRescue (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_IntelRescueInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "IntelRescue", "ResOps", "img:///UILibrary_XPACK_Common.MissionIcon_ResOps");

	Activity.MissionRewards.AddItem('Reward_Container');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateSupplyRescue (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_SupplyRescueInfil', true);
	Activity = CreateStandardInfilActivity(CovertAction, "SupplyRescue", "ResOps", "img:///UILibrary_XPACK_Common.MissionIcon_ResOps");

	Activity.MissionRewards.AddItem('Reward_Container');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

///////////////
/// Helpers ///
///////////////

static function X2ActivityTemplate_Infiltration CreateStandardInfilActivity (X2CovertActionTemplate CovertAction, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;

	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Infiltration', Activity, name("Activity_" $ ActivityName));
	
	CovertAction.ChooseLocationFn = UseActivityPrimaryRegion;
	CovertAction.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	
	CovertAction.Narratives.AddItem(name("CovertActionNarrative_" $ ActivityName $ "Infil"));
	CovertAction.Rewards.AddItem('Reward_InfiltrationActivityProxy');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	Activity.UIButtonIcon = MissionIcon;

	return Activity;
}

static function DarkVIPOnSuccess(XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local array<int> ExcludeIndices;
	local XComGameState_MissionSite MissionState;

	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	ExcludeIndices = class'X2StrategyElement_DefaultMissionSources'.static.GetCouncilExcludeRewards(MissionState);

	MissionState.bUsePartialSuccessText = (ExcludeIndices.Length > 0);
	class'X2StrategyElement_DefaultMissionSources'.static.GiveRewards(NewGameState, MissionState, ExcludeIndices);
	class'X2Helper_Infiltration'.static.HandlePostMissionPOI(NewGameState, ActivityState, true);
	MissionState.RemoveEntity(NewGameState);

	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_CouncilMissionsCompleted');
	
	ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityState.ObjectID));
	ActivityState.MarkSuccess(NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, class'X2Helper_Infiltration'.static.GetPostMissionText(ActivityState, true), false);
}

static function X2CovertActionTemplate CreateStandardActivityCA (string ActivityName, string MeshPath)
{
	local X2CovertActionTemplate CovertAction;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', CovertAction, name("CovertAction_" $ ActivityName));

	CovertAction.ChooseLocationFn = UseActivityPrimaryRegion;
	CovertAction.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	CovertAction.Narratives.AddItem(name("CovertActionNarrative_" $ ActivityName));

	return CovertAction;
}

static function UseActivityPrimaryRegion (XComGameState NewGameState, XComGameState_CovertAction ActionState, out array<StateObjectReference> ExcludeLocations)
{
	local XComGameState_Activity Activity;

	Activity = class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(ActionState);

	if (Activity == none)
	{
		Activity = class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(ActionState);
	}
	
	ActionState.LocationEntity = Activity.GetActivityChain().PrimaryRegionRef;
}

static function int GetMissionDifficultyFromMonth (XComGameState_Activity ActivityState)
{
	local TDateTime StartDate;
	local array<int> MonthlyDifficultyAdd;
	local int Difficulty, MonthDiff;

	class'X2StrategyGameRulesetDataStructures'.static.SetTime(StartDate, 0, 0, 0, class'X2StrategyGameRulesetDataStructures'.default.START_MONTH,
		class'X2StrategyGameRulesetDataStructures'.default.START_DAY, class'X2StrategyGameRulesetDataStructures'.default.START_YEAR);

	Difficulty = 1;
	MonthDiff = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInMonths(class'XComGameState_GeoscapeEntity'.static.GetCurrentTime(), StartDate);
	MonthlyDifficultyAdd = class'X2StrategyElement_DefaultMissionSources'.static.GetMonthlyDifficultyAdd();

	if(MonthDiff >= MonthlyDifficultyAdd.Length)
	{
		MonthDiff = MonthlyDifficultyAdd.Length - 1;
	}

	Difficulty += MonthlyDifficultyAdd[MonthDiff];

	Difficulty = Clamp(Difficulty, class'X2StrategyGameRulesetDataStructures'.default.MinMissionDifficulty,
						class'X2StrategyGameRulesetDataStructures'.default.MaxMissionDifficulty);

	return Difficulty;
}

static function int GetMissionDifficultyFromMonthPlusTemplate (XComGameState_Activity ActivityState)
{
	local TDateTime StartDate;
	local array<int> MonthlyDifficultyAdd;
	local int Difficulty, MonthDiff;

	class'X2StrategyGameRulesetDataStructures'.static.SetTime(StartDate, 0, 0, 0, class'X2StrategyGameRulesetDataStructures'.default.START_MONTH,
		class'X2StrategyGameRulesetDataStructures'.default.START_DAY, class'X2StrategyGameRulesetDataStructures'.default.START_YEAR);

	Difficulty = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate()).Difficulty;
	MonthDiff = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInMonths(class'XComGameState_GeoscapeEntity'.static.GetCurrentTime(), StartDate);
	MonthlyDifficultyAdd = class'X2StrategyElement_DefaultMissionSources'.static.GetMonthlyDifficultyAdd();

	if(MonthDiff >= MonthlyDifficultyAdd.Length)
	{
		MonthDiff = MonthlyDifficultyAdd.Length - 1;
	}

	Difficulty += MonthlyDifficultyAdd[MonthDiff];

	Difficulty = Clamp(Difficulty, class'X2StrategyGameRulesetDataStructures'.default.MinMissionDifficulty,
						class'X2StrategyGameRulesetDataStructures'.default.MaxMissionDifficulty);

	return Difficulty;
}

static function PreMissionSetup_DE (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSite MissionState;
	local XComGameState_DarkEvent DarkEventState;

	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	DarkEventState = ActivityState.GetActivityChain().GetChainDarkEvent();

	if (DarkEventState != none)
	{
		MissionState.DarkEvent = DarkEventState.GetReference();
	}
}

static function string GetUnitDetails (XComGameState_Activity ActivityState, XComGameState_Reward RewardState)
{
	local XComGameStateHistory History;
	local XComGameState_MissionSiteInfiltration MissionState;
	local XComGameState_Reward MissionRewardState;
	local XComGameState_Unit UnitState;
	local XGParamTag kTag;
	local string UnitString;
	
	History = `XCOMHISTORY;

	MissionState = XComGameState_MissionSiteInfiltration(History.GetGameStateForObjectID(ActivityState.PrimaryObjectRef.ObjectID));
	MissionRewardState = XComGameState_Reward(History.GetGameStateForObjectID(MissionState.Rewards[0].ObjectID));

	if(MissionRewardState != none)
	{
		if(MissionRewardState.RewardObjectReference.ObjectID > 0)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(MissionRewardState.RewardObjectReference.ObjectID));
		}
		else
		{
			`Redscreen("GetUnitDetails: mission reward has a null RewardObjectReference!");
		}
	}
	else
	{
		`Redscreen("GetUnitDetails: activity has no mission rewards!");
	}

	if(UnitState != none)
	{
		if(UnitState.IsSoldier())
		{
			if(UnitState.GetRank() > 0)
			{
				UnitString = UnitState.GetName(eNameType_RankFull) @ "-" @ UnitState.GetSoldierClassTemplate().DisplayName;
			}
			else
			{
				UnitString = UnitState.GetName(eNameType_RankFull);
			}
		}
		else
		{
			UnitString = class'X2StrategyElement_DefaultRewards'.default.DoctorPrefixText @ UnitState.GetName(eNameType_Full) @ "-" @ MissionRewardState.GetMyTemplate().DisplayName;
		}
	}
	else
	{
		`Redscreen("GetUnitDetails: mission reward does not contain a UnitState!");
		UnitString = "UNITNOTFOUND";
	}

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	kTag.StrValue0 = UnitString;
	
	return `XEXPAND.ExpandString(X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate()).ActionRewardDetails);
}

//////////////////////////////////////////////////////////
/// Copied from X2StrategyElement_DefaultCovertActions ///
//////////////////////////////////////////////////////////

static function CovertActionSlot CreateDefaultSoldierSlot(name SlotName, optional int iMinRank, optional bool bRandomClass, optional bool bFactionClass, optional bool bPromotionAllowed = false)
{
	local CovertActionSlot SoldierSlot;

	SoldierSlot.StaffSlot = SlotName;
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHP');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostAim');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostMobility');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostDodge');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostWill');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHacking');
	if (bPromotionAllowed) SoldierSlot.Rewards.AddItem('Reward_RankUp');

	SoldierSlot.iMinRank = iMinRank;
	SoldierSlot.bChanceFame = false;
	SoldierSlot.bRandomClass = bRandomClass;
	SoldierSlot.bFactionClass = bFactionClass;

	if (SlotName == 'CovertActionRookieStaffSlot')
	{
		SoldierSlot.bChanceFame = false;
	}

	return SoldierSlot;
}

static function StrategyCostReward CreateOptionalCostSlot(name ResourceName, int Quantity)
{
	local StrategyCostReward ActionCost;
	local ArtifactCost Resources;

	Resources.ItemTemplateName = ResourceName;
	Resources.Quantity = Quantity;
	ActionCost.Cost.ResourceCosts.AddItem(Resources);
	ActionCost.Reward = 'Reward_DecreaseRisk';
	
	return ActionCost;
}

defaultproperties
{

}