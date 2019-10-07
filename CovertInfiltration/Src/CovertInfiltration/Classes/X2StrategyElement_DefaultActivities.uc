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


var const string Guerilla;
var const string Council;
var const string SupplyRaid;
var const string Radio;
var const string Advent;
var const string SupplyLift;
var const string Resistance;
var const string Rescue;
var const string Ambush;
var const string DarkEvent;
var const string Facility;
var const string Chosen;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	CreateRecoverPersonnel(Templates, "RecoverPersonnel", "ResOps", default.Resistance);
	CreateRescueEngineer(Templates, "RescueEngineer", "Council_VIP", default.Council);
	CreateRescueScientist(Templates, "RescueScientist", "Council_VIP", default.Council);
	
	CreateRecoverInformant(Templates, "RecoverInformant", "ResOps", default.Resistance);
	CreateCaptureInformant(Templates, "CaptureInformant", "EscapeAmbush", default.Ambush);

	CreateDEWaitActivity(Templates);
	CreatePrepareCounterDE(Templates, "PrepareCounterDE", "CovertAction");
	CreateCounterDarkEvent(Templates, "CounterDarkEvent", "Retribution", default.DarkEvent);
	
	CreatePrepareFactionJB(Templates, "PrepareFactionJB", "CovertAction");
	CreateJailbreakSoldier(Templates, "JailbreakSoldier", "RescueOps", default.Rescue);
	CreateJailbreakChosenSoldier(Templates, "JailbreakChosenSoldier", "RescueOps", default.Rescue);
	CreateJailbreakFactionSoldier(Templates, "JailbreakFactionSoldier", "RescueOps", default.Rescue);
	
	CreateRecoverUFO(Templates, "RecoverUFO", "ResOps", default.Resistance);
	CreatePrepareUFO(Templates, "PrepareUFO", "CovertAction");
	CreateLandedUFO(Templates, "LandedUFO", "Landed_UFO", default.Advent);
	
	CreateCommanderSupply(Templates, "CommanderSupply", "GorillaOps", default.Guerilla);
	CreateSupplyRaid(Templates, "SupplyRaid", "SupplyRaid_AdvConvoy", default.SupplyRaid);
	
	CreatePrepareFacility(Templates, "PrepareFacility", "CovertAction");
	CreateFacilityInformant(Templates, "FacilityInformant", "EscapeAmbush", default.Ambush);
	
	CreateGatherIntel(Templates, "GatherIntel", "RadioTower", default.Radio);
	CreateGatherSupplies(Templates, "GatherSupplies", "SupplyExtraction", default.SupplyLift);
	
	CreateIntelRescue(Templates, "IntelRescue", "ResOps", default.Resistance);
	CreateSupplyRescue(Templates, "SupplyRescue", "ResOps", default.Resistance);
	
	return Templates;
}

static function CreateRecoverPersonnel (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.OnSuccess = OnSuccessPOI;
	Activity.MissionRewards.AddItem('Reward_None');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateRescueEngineer (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.MissionRewards.AddItem('Reward_Engineer');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateRescueScientist (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.MissionRewards.AddItem('Reward_Scientist');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateRecoverInformant (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.OnSuccess = OnSuccessPOI;
	Activity.MissionRewards.AddItem('Reward_None');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateCaptureInformant (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);
	
	Activity.MissionRewards.AddItem('Reward_Datapad');
	Activity.MissionRewards.AddItem('Reward_Intel');

	Activity.OnSuccess = DarkVIPOnSuccess;
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateDEWaitActivity (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate Activity;

	// This is a special "activity" which does nothing but waits and triggers the next stage at some point in time
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate', Activity, 'Activity_WaitDE');
	Activity.StateClass = class'XComGameState_Activity_Wait';

	Templates.AddItem(Activity);
}

static function CreatePrepareCounterDE (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, name("Activity_" $ ActivityName));
	CovertAction = CreateStandardActivityCA(ActivityName, MeshPath);

	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.OptionalCosts.AddItem(CreateOptionalCostSlot('Supplies', 25));

	CovertAction.Risks.AddItem('CovertActionRisk_SoldierWounded');
	CovertAction.Rewards.AddItem('Reward_None');

	Activity.CovertActionName = CovertAction.DataName;

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateCounterDarkEvent (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.OnSuccess = OnSuccessPOI;
	Activity.MissionRewards.AddItem('Reward_None');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreatePrepareFactionJB (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, name("Activity_" $ ActivityName));
	CovertAction = CreateStandardActivityCA(ActivityName, MeshPath);

	CovertAction.RequiredFactionInfluence = eFactionInfluence_Influential;
	CovertAction.bDisplayIgnoresInfluence = true;

	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot', 3));
	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Rewards.AddItem('Reward_None');

	Activity.CovertActionName = CovertAction.DataName;

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateJailbreakSoldier (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.MissionRewards.AddItem('Reward_SoldierCaptured');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateJailbreakChosenSoldier (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.MissionRewards.AddItem('Reward_ChosenSoldierCaptured');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateJailbreakFactionSoldier (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.MissionRewards.AddItem('Reward_ExtraFactionSoldier');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.GetRewardDetailStringFn = GetUnitDetails;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateRecoverUFO (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.OnSuccess = OnSuccessPOI;
	Activity.MissionRewards.AddItem('Reward_None');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreatePrepareUFO (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, name("Activity_" $ ActivityName));
	CovertAction = CreateStandardActivityCA(ActivityName, MeshPath);

	CovertAction.RequiredFactionInfluence = eFactionInfluence_Influential;
	CovertAction.bDisplayIgnoresInfluence = true;

	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Risks.AddItem('CovertActionRisk_SoldierCaptured');
	CovertAction.Risks.AddItem('CovertActionRisk_SoldierWounded');
	CovertAction.Rewards.AddItem('Reward_None');

	Activity.CovertActionName = CovertAction.DataName;

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateLandedUFO (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, name("Activity_" $ ActivityName));
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	Activity.UIButtonIcon = MissionIcon;
	Activity.ScreenClass = class'UIMission_LandedUFO';
	Activity.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_UFO_Landed";
	
	Activity.MissionRewards.AddItem('Reward_None');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;

	Templates.AddItem(Activity);
}

static function CreateCommanderSupply (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.OnSuccess = OnSuccessPOI;
	Activity.MissionRewards.AddItem('Reward_None');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateSupplyRaid (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.MissionRewards.AddItem('Reward_None');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreatePrepareFacility (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, name("Activity_" $ ActivityName));
	CovertAction = CreateStandardActivityCA(ActivityName, MeshPath);

	CovertAction.RequiredFactionInfluence = eFactionInfluence_Influential;
	CovertAction.bDisplayIgnoresInfluence = true;

	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Risks.AddItem('CovertActionRisk_Ambush');
	CovertAction.Rewards.AddItem('Reward_None');

	Activity.CovertActionName = CovertAction.DataName;

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateFacilityInformant (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);
	
	Activity.MissionRewards.AddItem('Reward_Datapad');
	Activity.MissionRewards.AddItem('Reward_FacilityLead');

	Activity.OnSuccess = DarkVIPOnSuccess;
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateGatherIntel (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, name("Activity_" $ ActivityName));
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	Activity.UIButtonIcon = MissionIcon;
	Activity.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Recover_X_Intel";
	
	Activity.MissionRewards.AddItem('Reward_Intel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;

	Templates.AddItem(Activity);
}

static function CreateGatherSupplies (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, name("Activity_" $ ActivityName));
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	Activity.UIButtonIcon = MissionIcon;
	Activity.ScreenClass = class'UIMission_LandedUFO';
	Activity.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Recover_X_Supplies";
	
	Activity.MissionRewards.AddItem('Reward_None');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;

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

static function CreateIntelRescue (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.MissionRewards.AddItem('Reward_Container');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateSupplyRescue (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	Activity = CreateStandardInfilActivity(CovertAction, ActivityName, MeshPath, MissionIcon);

	Activity.MissionRewards.AddItem('Reward_Container');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
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

static function OnSuccessPOI(XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSite MissionState;

	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	class'X2StrategyElement_DefaultMissionSources'.static.GiveRewards(NewGameState, MissionState);

	class'X2StrategyElement_DefaultMissionSources'.static.SpawnPointOfInterest(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);

	ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityState.ObjectID));
	ActivityState.MarkSuccess(NewGameState);
}

static function CreateStandardDVIPActivity (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon, name AlwaysReward, name CaptureReward)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Infiltration', Activity, name("Activity_" $ ActivityName));
	
	CovertAction.ChooseLocationFn = UseActivityPrimaryRegion;
	CovertAction.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	
	CovertAction.Narratives.AddItem(name("CovertActionNarrative_" $ ActivityName $ "Infil"));
	CovertAction.Rewards.AddItem('Reward_InfiltrationActivityProxy');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	Activity.UIButtonIcon = MissionIcon;
	
	Activity.MissionRewards.AddItem(AlwaysReward);
	Activity.MissionRewards.AddItem(CaptureReward);

	Activity.OnSuccess = DarkVIPOnSuccess;

	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function DarkVIPOnSuccess(XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local array<int> ExcludeIndices;
	local XComGameState_MissionSite MissionState;

	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	ExcludeIndices = class'X2StrategyElement_DefaultMissionSources'.static.GetCouncilExcludeRewards(MissionState);

	MissionState.bUsePartialSuccessText = (ExcludeIndices.Length > 0);
	class'X2StrategyElement_DefaultMissionSources'.static.GiveRewards(NewGameState, MissionState, ExcludeIndices);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_CouncilMissionsCompleted');
}

static function CreateStandardAssaultActivity (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon, name RewardName, optional class<UIMission> ScreenClass, optional string MissionImage)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, name("Activity_" $ ActivityName));
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	Activity.UIButtonIcon = MissionIcon;
	Activity.MissionImage = MissionImage;
	
	Activity.MissionRewards.AddItem(RewardName);
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	if (ScreenClass != none)
	{
		Activity.ScreenClass = ScreenClass;
	}

	Templates.AddItem(Activity);
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

static function string GetUnitDetails (XComGameState_Reward RewardState)
{
	local XComGameState_Unit UnitState;
	local XGParamTag kTag;
	local string UnitString;
	
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	
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
			UnitString = class'X2StrategyElement_DefaultRewards'.default.DoctorPrefixText @ UnitState.GetName(eNameType_Full) @ "-" @ RewardState.GetMyTemplate().DisplayName;
		}
	}
	else
	{
		UnitString = "UNITNOTFOUND";
	}

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	kTag.StrValue0 = UnitString;

	return `XEXPAND.ExpandString(class'X2StrategyElement_InfiltrationRewards'.static.GetInfiltrationTemplateFromReward(RewardState).ActionRewardDetails);
}

//////////////////////////////////////////////////////////
/// Copied from X2StrategyElement_DefaultCovertActions ///
//////////////////////////////////////////////////////////

static function CovertActionSlot CreateDefaultSoldierSlot(name SlotName, optional int iMinRank, optional bool bRandomClass, optional bool bFactionClass)
{
	local CovertActionSlot SoldierSlot;

	SoldierSlot.StaffSlot = SlotName;
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHP');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostAim');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostMobility');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostDodge');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostWill');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHacking');
	SoldierSlot.Rewards.AddItem('Reward_RankUp');
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
	Guerilla = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_GOPS";
	Council = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Council";
	SupplyRaid = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_SupplyRaid";
	Radio = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_ResHQ";
	Advent = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Advent";
	SupplyLift = "img:///UILibrary_XPACK_Common.MissionIcon_SupplyExtraction";
	Resistance = "img:///UILibrary_XPACK_Common.MissionIcon_ResOps";
	Rescue = "img:///UILibrary_XPACK_Common.MissionIcon_RescueSoldier";
	Ambush = "img:///UILibrary_XPACK_Common.MissionIcon_EscapeAmbush";
	DarkEvent = "img:///UILibrary_XPACK_Common.MissionIcon_Retribution";
	Facility = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Alien";
	Chosen = "img:///UILibrary_XPACK_Common.MissionIcon_ChosenStronghold";
}