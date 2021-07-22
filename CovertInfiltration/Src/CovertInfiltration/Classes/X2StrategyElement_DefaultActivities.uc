//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and NotSoLoneWolf
//  PURPOSE: Activites that are introduced by this mod. Note that many activities need
//           multiple templates (eg. X2ActivityTemplate + X2CovertActionTemplate) so
//           the templates array is passed to individual Create[...] methods, instead of
//           returning the template and adding it inside CreateTemplates() as usual
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_DefaultActivities extends X2StrategyElement config(GameBoard);

// These 2 control the interval in which the counter-DE ops will pop
var const config int MinDarkEventWaitDays;
var const config int MaxDarkEventWaitDays;

var const config int MinGenericWaitDays;
var const config int MaxGenericWaitDays;

// Initial difficulty values before monthly difficulty is applied
var config int IntelligenceDifficulty;
var config int InformantDifficulty;
var config int SabotageDifficulty;
var config int DatatapDifficulty;
var config int DistractionDifficulty;
var config int ExtractionDifficulty;
var config int ConvoyDifficulty;
var config int LandedDifficulty;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	CreateDatatapAssault(Templates);
	CreateIntelligenceAssault(Templates);
	CreateIntelligenceInfiltration(Templates);
	CreateInformantAssault(Templates);
	CreateInformantInfiltration(Templates);
	CreateDistractionAssault(Templates);
	CreateDistractionInfiltration(Templates);
	CreateSabotageAssault(Templates);
	CreateSabotageInfiltration(Templates);
	CreatePersonnelGeneric(Templates);

	CreateDarkEventWaitActivity(Templates);
	CreateGenericWaitActivity(Templates);
	
	CreateSupplyConvoy(Templates);
	CreateSupplyExtract(Templates);
	CreateSecureUFO(Templates);
	CreateCaptureDVIP(Templates);
	
	CreatePreparePersonnel(Templates);
	CreatePrepareFactionJB(Templates);
	CreatePrepareUFO(Templates);
	CreatePrepareFacility(Templates);

	return Templates;
}

/////////////////////////
/// Random Activities ///
/////////////////////////

static function CreateDatatapAssault (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault ActivityAssault;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', ActivityAssault, 'Activity_DatatapAssault');
	
	ActivityAssault.OverworldMeshPath = "GeoscapeMesh_CI.CI_Geoscape.CI_HackDevice";
	ActivityAssault.UIButtonIcon = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_ResHQ";
	ActivityAssault.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Recover_X_Intel";
	ActivityAssault.Difficulty = default.DatatapDifficulty;
	
	ActivityAssault.ActivityTag = 'Tag_Datatap';
	ActivityAssault.bNeedsPOI = true;
	ActivityAssault.MissionRewards.AddItem('Reward_Rumor');
	ActivityAssault.MissionRewards.AddItem('Reward_SmallIntel');
	ActivityAssault.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	ActivityAssault.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityAssault.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(ActivityAssault);
}

static function CreateIntelligenceAssault (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault ActivityAssault;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', ActivityAssault, 'Activity_IntelligenceAssault');
	
	ActivityAssault.OverworldMeshPath = "GeoscapeMesh_CI.CI_Geoscape.CI_HackDevice";
	ActivityAssault.UIButtonIcon = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_ResHQ";
	ActivityAssault.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Recover_X_Intel";
	ActivityAssault.Difficulty = default.IntelligenceDifficulty;
	
	ActivityAssault.ActivityTag = 'Tag_Intelligence';
	ActivityAssault.bNeedsPOI = true;
	ActivityAssault.MissionRewards.AddItem('Reward_Rumor');
	ActivityAssault.MissionRewards.AddItem('Reward_SmallIntel');
	ActivityAssault.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	ActivityAssault.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityAssault.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(ActivityAssault);
}

static function CreateIntelligenceInfiltration (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration ActivityInfil;
	local X2CovertActionTemplate CovertAction;

	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_IntelligenceInfiltrate', true);
	ActivityInfil = CreateStandardInfilActivity(CovertAction, "IntelligenceInfiltrate", "GeoscapeMesh_CI.CI_Geoscape.CI_HackDevice", "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_ResHQ");
	
	ActivityInfil.ActivityTag = 'Tag_Intelligence';
	ActivityInfil.bNeedsPOI = true;
	ActivityInfil.MissionRewards.AddItem('Reward_Rumor');
	ActivityInfil.MissionRewards.AddItem('Reward_SmallIntel');
	ActivityInfil.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	ActivityInfil.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityInfil.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(ActivityInfil);
}

static function CreateInformantAssault (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault ActivityAssault;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', ActivityAssault, 'Activity_InformantAssault');
	
	ActivityAssault.OverworldMeshPath = "UI_3D.Overwold_Final.Council_VIP";
	ActivityAssault.UIButtonIcon = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Council";
	ActivityAssault.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Resistance_Ops_Appear";
	ActivityAssault.Difficulty = default.InformantDifficulty;
	
	ActivityAssault.ActivityTag = 'Tag_Informant';
	ActivityAssault.bNeedsPOI = true;
	ActivityAssault.SetupStage = InformantAssaultSetup;
	ActivityAssault.OnPreMission = InformantAssaultOnPreMission;
	ActivityAssault.OnSuccess = InformantAssaultOnSuccess;
	ActivityAssault.OnFailure = InformantAssaultOnFailure;
	ActivityAssault.MissionRewards.AddItem('Reward_Rumor');
	ActivityAssault.MissionRewards.AddItem('Reward_SmallIntel');
	ActivityAssault.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	ActivityAssault.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityAssault.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(ActivityAssault);
}

static function InformantAssaultSetup (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSite MissionState;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2RewardTemplate SoldierRewardTemplate;
	local XComGameState_Reward RewardState;
	local XComGameState_HeadquartersResistance ResHQ;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	SoldierRewardTemplate = X2RewardTemplate(TemplateManager.FindStrategyElementTemplate('Reward_Soldier'));
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	class'X2ActivityTemplate_Assault'.static.CreateMission(NewGameState, ActivityState);

	foreach NewGameState.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if (MissionState.ObjectID != ActivityState.PrimaryObjectRef.ObjectID)
		{
			MissionState = none;
			continue;
		}
		
		// Found the correct one
		break;
	}

	if (MissionState == none)
	{
		`REDSCREEN("CI InformantAssaultSetup: Could not fetch mission from creation state for chain " $ ActivityState.GetActivityChain().GetMyTemplateName());
	}

	if (MissionState.GeneratedMission.Mission.sType == "GatherSurvivors")
	{
		RewardState = SoldierRewardTemplate.CreateInstanceFromTemplate(NewGameState);
		RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), ActivityState.GetActivityChain().PrimaryRegionRef);
		AddTacticalTagToRewardUnit(NewGameState, RewardState, 'SoldierRewardA');
		MissionState.Rewards.AddItem(RewardState.GetReference());

		RewardState = SoldierRewardTemplate.CreateInstanceFromTemplate(NewGameState);
		RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), ActivityState.GetActivityChain().PrimaryRegionRef);
		AddTacticalTagToRewardUnit(NewGameState, RewardState, 'SoldierRewardB');
		MissionState.Rewards.AddItem(RewardState.GetReference());
	}

	if (MissionState.GeneratedMission.Mission.sType == "RecoverExpedition")
	{
		RewardState = SoldierRewardTemplate.CreateInstanceFromTemplate(NewGameState);
		RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), ActivityState.GetActivityChain().PrimaryRegionRef);
		AddTacticalTagToRewardUnit(NewGameState, RewardState, 'SoldierRewardA');
		MissionState.Rewards.AddItem(RewardState.GetReference());
	}

	class'X2ActivityTemplate_Assault'.static.MarkMissionForStrategyMapAlert(NewGameState, ActivityState);
}

static function InformantAssaultOnPreMission (XComGameState StartGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_Unit VipUnitState, RewardUnitState;
	local XGCharacterGenerator CharacterGenerator;
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_BattleData BattleData;
	local TSoldier CharacterGeneratorResult;
	local X2CharacterTemplate VipTemplate;
	local name Country;

	`CI_Log("InformantAssaultOnPreMission");

	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	foreach StartGameState.IterateByClassType(class'XComGameState_BattleData', BattleData)
	{
		break;
	}

	// Get the country to use

	RegionState = MissionState.GetWorldRegion();
	if (RegionState != none)
	{
		Country = RegionState.GetMyTemplate().GetRandomCountryInRegion();
	}

	// Grab the char template (FriendlyVIPCivilian) and spawn one
	VipTemplate = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate('FriendlyVIPCivilian');
	VipUnitState = VipTemplate.CreateInstanceFromTemplate(StartGameState);

	// Replicate CreateCharacter in char pool manager, last branch
	// No need to destroy the char generator manually since the whole world is about to be torn down anyway
	CharacterGenerator = `XCOMGRI.Spawn(VipTemplate.CharacterGeneratorClass);
	CharacterGeneratorResult = CharacterGenerator.CreateTSoldier('FriendlyVIPCivilian',, Country);

	VipUnitState.SetTAppearance(CharacterGeneratorResult.kAppearance);
	VipUnitState.SetCharacterName(CharacterGeneratorResult.strFirstName, CharacterGeneratorResult.strLastName, CharacterGeneratorResult.strNickName);
	VipUnitState.SetCountry(CharacterGeneratorResult.nmCountry);
	
	if (!VipUnitState.HasBackground())
	{
		VipUnitState.GenerateBackground(, CharacterGenerator.BioCountryName);
	}
	
	class'XComGameState_Unit'.static.NameCheck(CharacterGenerator, VipUnitState, eNameType_Full);

	VipUnitState.StoreAppearance();

	// Set the battleData.RewardUnits as first (+ original), replicate XGStrategy proxy logic
	VipUnitState.TacticalTag = 'VIPReward';
	RewardUnitState = InformantAssaultOnPreMission_PrepareRewardUnit(StartGameState, VipUnitState, BattleData);
	BattleData.RewardUnits.InsertItem(0, RewardUnitState.GetReference());
	BattleData.RewardUnitOriginals.InsertItem(0, RewardUnitState.GetReference());

	// test
}

// Copied from XGStrategy::LaunchTacticalBattle
static protected function XComGameState_Unit InformantAssaultOnPreMission_PrepareRewardUnit (XComGameState StartGameState, XComGameState_Unit StrategyUnitState, XComGameState_BattleData BattleData)
{
	local XComGameState_Unit ProxySoldierState;

	// create a proxy if needed. This allows the artists and LDs to create simpler standin versions of units,
	// for example soldiers without weapons.
	// Unless the reward is a soldier with a tactical tag to be specifically passed into the mission
	ProxySoldierState = none;
	if (/*RewardStateObject.GetMyTemplateName() != 'Reward_Soldier'*/ true || StrategyUnitState.TacticalTag == '')
	{
		ProxySoldierState = class'XComTacticalMissionManager'.static.CreateProxyRewardUnitIfNeeded(StrategyUnitState, StartGameState);
	}

	if(ProxySoldierState == none)
	{
		// no proxy needed, so just send the original
		ProxySoldierState = StrategyUnitState;
	}

	// all reward units start on the neutral team
	ProxySoldierState.SetControllingPlayer( BattleData.CivilianPlayerRef );

	return ProxySoldierState;
}

static function InformantAssaultOnSuccess (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local array<int> ExcludeIndices;
	local XComGameState_MissionSite MissionState;

	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	ExcludeIndices = class'X2StrategyElement_XPackMissionSources'.static.GetResOpExcludeRewards(MissionState);

	MissionState.bUsePartialSuccessText = (ExcludeIndices.Length > 0);
	class'X2StrategyElement_DefaultMissionSources'.static.GiveRewards(NewGameState, MissionState, ExcludeIndices);
	class'X2Helper_Infiltration'.static.HandlePostMissionPOI(NewGameState, ActivityState, true);
	MissionState.RemoveEntity(NewGameState);
	
	ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityState.ObjectID));
	ActivityState.MarkSuccess(NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsCompleted');
	class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, class'X2Helper_Infiltration'.static.GetPostMissionText(ActivityState, true), false);
}

static function InformantAssaultOnFailure (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local array<int> ExcludeIndices;
	local XComGameState_MissionSite MissionState;

	MissionState = class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState);
	
	// Even though the primary objective was failed, we still want to check if secondary objectives were completed and award those soldiers
	ExcludeIndices = class'X2StrategyElement_XPackMissionSources'.static.GetResOpExcludeRewards(MissionState);
	ExcludeIndices.AddItem(0); // Exclude the primary VIP
	ExcludeIndices.AddItem(1); // Exclude the Intel reward
	class'X2StrategyElement_DefaultMissionSources'.static.GiveRewards(NewGameState, MissionState, ExcludeIndices);
	
	class'X2Helper_Infiltration'.static.HandlePostMissionPOI(NewGameState, ActivityState, false);
	MissionState.RemoveEntity(NewGameState);
	
	ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityState.ObjectID));
	ActivityState.MarkFailed(NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsFailed');
	class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, class'X2Helper_Infiltration'.static.GetPostMissionText(ActivityState, false), true);
}

static function CreateInformantInfiltration (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration ActivityInfil;
	local X2CovertActionTemplate CovertAction;

	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_InformantInfiltrate', true);
	ActivityInfil = CreateStandardInfilActivity(CovertAction, "InformantInfiltrate", "UI_3D.Overwold_Final.Council_VIP", "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Council");
	
	ActivityInfil.ActivityTag = 'Tag_Informant';
	ActivityInfil.bNeedsPOI = true;
	ActivityInfil.MissionRewards.AddItem('Reward_Rumor');
	ActivityInfil.MissionRewards.AddItem('Reward_SmallIntel');
	ActivityInfil.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	ActivityInfil.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityInfil.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(ActivityInfil);
}

static function CreatePersonnelGeneric(out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration ActivityInfil;
	local X2CovertActionTemplate CovertAction;

	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_PersonnelRescue', true);
	ActivityInfil = CreateStandardInfilActivity(CovertAction, "PersonnelRescue", "Council_VIP", "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Council");
	
	ActivityInfil.ActivityTag = 'Tag_Personnel';
	// Requires reward override from the chain
	ActivityInfil.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	ActivityInfil.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityInfil.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(ActivityInfil);
}

static function CreateDistractionAssault (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault ActivityAssault;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', ActivityAssault, 'Activity_DistractionAssault');
	
	ActivityAssault.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps";
	ActivityAssault.UIButtonIcon = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_GOPS";
	ActivityAssault.MissionImage = "img:///UILibrary_StrategyImages.Alert_Advent_Ops_Appear";
	ActivityAssault.Difficulty = default.DistractionDifficulty;
	
	ActivityAssault.ActivityTag = 'Tag_Distraction';
	ActivityAssault.MissionRewards.AddItem('Reward_SmallIncreaseIncome');
	ActivityAssault.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	ActivityAssault.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityAssault.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(ActivityAssault);
}
	
static function CreateDistractionInfiltration (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration ActivityInfil;
	local X2CovertActionTemplate CovertAction;

	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_DistractionInfiltrate', true);
	ActivityInfil = CreateStandardInfilActivity(CovertAction, "DistractionInfiltrate", "UI_3D.Overwold_Final.GorillaOps", "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_GOPS");
	
	ActivityInfil.ActivityTag = 'Tag_Distraction';
	ActivityInfil.MissionRewards.AddItem('Reward_SmallIncreaseIncome');
	ActivityInfil.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	ActivityInfil.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityInfil.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(ActivityInfil);
}

static function CreateSabotageAssault (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault ActivityAssault;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', ActivityAssault, 'Activity_SabotageAssault');
	
	ActivityAssault.OverworldMeshPath = "UI_3D.Overwold_Final.Retribution";
	ActivityAssault.UIButtonIcon = "img:///UILibrary_XPACK_Common.MissionIcon_Retribution";
	ActivityAssault.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress";
	ActivityAssault.Difficulty = default.SabotageDifficulty;
	
	ActivityAssault.ActivityTag = 'Tag_Sabotage';
	ActivityAssault.MissionRewards.AddItem('Reward_FacilityDelay');
	ActivityAssault.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	ActivityAssault.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityAssault.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(ActivityAssault);
}
	
static function CreateSabotageInfiltration (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration ActivityInfil;
	local X2CovertActionTemplate CovertAction;

	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_SabotageInfiltrate', true);
	ActivityInfil = CreateStandardInfilActivity(CovertAction, "SabotageInfiltrate", "UI_3D.Overwold_Final.Retribution", "img:///UILibrary_XPACK_Common.MissionIcon_Retribution");
	
	ActivityInfil.ActivityTag = 'Tag_Sabotage';
	ActivityInfil.MissionRewards.AddItem('Reward_FacilityDelay');
	ActivityInfil.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	ActivityInfil.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	ActivityInfil.AvailableSound = "GeoscapeFanfares_GuerillaOps";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(ActivityInfil);
}

static function CreateDarkEventWaitActivity(out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate Activity;

	// This is a special "activity" which does nothing but waits and triggers the next stage at some point in time
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate', Activity, 'Activity_WaitDarkEvent');
	
	Activity.ActivityTag = 'Tag_Wait';
	Activity.ActivityType = 'eActivityType_Wait';
	Activity.StateClass = class'XComGameState_Activity_Wait';
	Activity.GetOverviewStatus = WaitGetOverviewStatus;

	Templates.AddItem(Activity);
}

static function CreateGenericWaitActivity(out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate Activity;

	// This is a special "activity" which does nothing but waits and triggers the next stage at some point in time
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate', Activity, 'Activity_WaitGeneric');
	
	Activity.ActivityTag = 'Tag_Wait';
	Activity.ActivityType = 'eActivityType_Wait';
	Activity.StateClass = class'XComGameState_Activity_Wait';
	Activity.GetOverviewStatus = WaitGetOverviewStatus;
	Activity.SetupStage = WaitSetup;

	Templates.AddItem(Activity);
}

/////////////////////////
/// Preset Activities ///
/////////////////////////

static function CreateSupplyConvoy(out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault Activity;

	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, 'Activity_SupplyConvoy');
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final.SupplyRaid_AdvConvoy";
	Activity.UIButtonIcon = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_SupplyRaid";
	Activity.MissionImage = "img:///UILibrary_StrategyImages.Alert_Supply_Raid";
	Activity.Difficulty = default.ConvoyDifficulty;
	
	Activity.ActivityTag = 'Tag_Convoy';
	Activity.MissionRewards.AddItem('Reward_Materiel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_Supply_Raid_Popup";
	
	Templates.AddItem(Activity);
}

static function CreateSupplyExtract(out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, 'Activity_SupplyExtract');
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final.SupplyExtraction";
	Activity.UIButtonIcon = "img:///UILibrary_XPACK_Common.MissionIcon_SupplyExtraction";
	Activity.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Recover_X_Supplies";
	Activity.Difficulty = default.ExtractionDifficulty;
	
	Activity.ActivityTag = 'Tag_Extract';
	Activity.MissionRewards.AddItem('Reward_Materiel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_Supply_Raid_Popup";

	Templates.AddItem(Activity);
}

static function CreateSecureUFO(out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, 'Activity_SecureUFO');
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final.Landed_UFO";
	Activity.UIButtonIcon = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Advent";
	Activity.ScreenClass = class'UIMission_LandedUFO';
	Activity.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_UFO_Landed";
	Activity.Difficulty = default.LandedDifficulty;
	
	Activity.ActivityTag = 'Tag_UFO';
	Activity.MissionRewards.AddItem('Reward_Materiel');
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonthPlusTemplate;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_UFO_Landed";

	Templates.AddItem(Activity);
}

static function CreateCaptureDVIP(out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate('CovertAction_CaptureDVIP', true);
	Activity = CreateStandardInfilActivity(CovertAction, "CaptureDVIP", "UI_3D.Overwold_Final.EscapeAmbush", "img:///UILibrary_XPACK_Common.MissionIcon_EscapeAmbush");
	
	Activity.ActivityTag = 'Tag_DVIP';
	Activity.MissionRewards.AddItem('Reward_SmallIncreaseIncome');
	Activity.MissionRewards.AddItem('Reward_SmallIntel');
	Activity.OnSuccess = DarkVIPOnSuccess;
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

//////////////////////
/// Covert Actions ///
//////////////////////

static function CreatePreparePersonnel (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate_CovertAction Activity;
	local X2CovertActionTemplate CovertAction;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Activity, 'Activity_PreparePersonnel');
	CovertAction = CreateStandardActivityCA("PreparePersonnel", "CovertAction");

	CovertAction.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.OptionalCosts.AddItem(class'X2Helper_Infiltration'.static.CreateOptionalCostSlot('Supplies', 25));

	CovertAction.Risks.AddItem('CovertActionRisk_SoldierWounded');
	CovertAction.Rewards.AddItem('Reward_Progress');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

	Templates.AddItem(CovertAction);
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

	CovertAction.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot', 3));
	CovertAction.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Rewards.AddItem('Reward_Progress');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

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

	CovertAction.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Risks.AddItem('CovertActionRisk_SoldierCaptured');
	CovertAction.Risks.AddItem('CovertActionRisk_SoldierWounded');
	CovertAction.Rewards.AddItem('Reward_Progress');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

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

	CovertAction.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Slots.AddItem(class'X2Helper_Infiltration'.static.CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	CovertAction.Risks.AddItem('CovertActionRisk_Ambush');
	CovertAction.Rewards.AddItem('Reward_Progress');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.AvailableSound = "Geoscape_NewResistOpsMissions";

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
	CovertAction.OverworldMeshPath = MeshPath;
	
	CovertAction.Narratives.AddItem(name("CovertActionNarrative_" $ ActivityName));
	CovertAction.Rewards.AddItem('Reward_InfiltrationActivityProxy');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.OverworldMeshPath = MeshPath;
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
	MissionState.RemoveEntity(NewGameState);
	
	ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityState.ObjectID));
	ActivityState.MarkSuccess(NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsCompleted');
	class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, class'X2Helper_Infiltration'.static.GetPostMissionText(ActivityState, true), false);
}

static function X2CovertActionTemplate CreateStandardActivityCA (string ActivityName, string MeshPath)
{
	local X2CovertActionTemplate CovertAction;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', CovertAction, name("CovertAction_" $ ActivityName));

	CovertAction.bCanNeverBeRookie = true;
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

static function WaitSetup (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local int SecondsWaitDuration;
	local XComGameState_Activity_Wait WaitActivity;

	`CI_Log("Setting up wait stage");

	SecondsWaitDuration = class'X2Helper_Infiltration'.static.GetWaitPeriodDuration(
		default.MinGenericWaitDays, 
		default.MaxGenericWaitDays);
	
	WaitActivity = XComGameState_Activity_Wait(ActivityState);
	// No need to call NewGameState.ModifyStateObject here as SetupStage is passed an already modified state

	if (WaitActivity == none)
	{
		`RedScreen(ActivityState.GetMyTemplateName() $ " is not a wait activity but calls WaitSetup!");
		return;
	}

	WaitActivity.ProgressAt = `STRATEGYRULES.GameTime;
	class'X2StrategyGameRulesetDataStructures'.static.AddTime(WaitActivity.ProgressAt, SecondsWaitDuration);
}

static function string WaitGetOverviewStatus (XComGameState_Activity ActivityState)
{
	if (ActivityState.IsOngoing())
	{
		return class'UIUtilities_Infiltration'.default.strCompletionStatusLabel_Ongoing;
	}

	return class'X2ActivityTemplate'.static.DefaultGetOverviewStatus(ActivityState);
}

// Copied from X2StrategyElement_XpackMissionSources
private static function AddTacticalTagToRewardUnit(XComGameState NewGameState, XComGameState_Reward RewardState, name TacticalTag)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	if (UnitState != none)
	{
		UnitState.TacticalTag = TacticalTag;
	}
}

defaultproperties
{

}