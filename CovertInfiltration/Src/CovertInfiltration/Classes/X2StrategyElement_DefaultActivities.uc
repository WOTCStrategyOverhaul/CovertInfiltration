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
	local string Guerilla, Council, SupplyRaid, SupplyLift, Radio, Advent, Resistance, Rescue, Ambush, DarkEvent/*, Chosen, Facility*/;

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
	//Facility = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Alien";
	//Chosen = "img:///UILibrary_XPACK_Common.MissionIcon_ChosenStronghold";
	
	// Infiltrations
	CreateStandardInfilActivity(Templates, "JailbreakSoldier", "RescueOps", Rescue, 'Reward_SoldierCaptured');
	CreateStandardInfilActivity(Templates, "JailbreakChosenSoldier", "RescueOps", Rescue, 'Reward_ChosenSoldierCaptured');
	CreateStandardInfilActivity(Templates, "JailbreakFactionSoldier", "RescueOps", Rescue, 'Reward_ExtraFactionSoldier');
	CreateStandardInfilActivity(Templates, "RescueEngineer", "Council_VIP", Council, 'Reward_Engineer');
	CreateStandardInfilActivity(Templates, "RescueScientist", "Council_VIP", Council, 'Reward_Scientist');
	CreateStandardInfilActivity(Templates, "RecoverInformant", "ResOps", Resistance, 'Reward_None', true);
	//CreateStandardInfilActivity(Templates, "RecoverChosen", "ResOps", Resistance, 'Reward_None', true);
	CreateStandardInfilActivity(Templates, "RecoverPersonnel", "ResOps", Resistance, 'Reward_None', true);
	CreateStandardInfilActivity(Templates, "RecoverUFO", "ResOps", Resistance, 'Reward_None', true);
	CreateStandardInfilActivity(Templates, "CommanderSupply", "GorillaOps", Guerilla, 'Reward_None', true);
	//CreateStandardInfilActivity(Templates, "CommanderChosen", "GorillaOps", Guerilla, 'Reward_None', true);
	CreateStandardInfilActivity(Templates, "CounterDarkEvent", "Retribution", DarkEvent, 'Reward_None', true, true);
	CreateStandardInfilActivity(Templates, "SupplyRaid", "SupplyRaid_AdvConvoy", SupplyRaid, 'Reward_None');
	
	CreateStandardDVIPActivity(Templates, "CaptureInformant", "EscapeAmbush", Ambush, 'Reward_Datapad', 'Reward_Intel');
	CreateStandardDVIPActivity(Templates, "FacilityInformant", "EscapeAmbush", Ambush, 'Reward_None', 'Reward_FacilityLead');

	// Assaults
	CreateStandardAssaultActivity(Templates, "GatherIntel", "RadioTower", Radio, 'Reward_Intel');
	CreateStandardAssaultActivity(Templates, "GatherSupplies", "SupplyExtraction", SupplyLift, 'Reward_None');
	CreateStandardAssaultActivity(Templates, "LandedUFO", "Landed_UFO", Advent, 'Reward_None');
	//CreateStandardAssaultActivity(Templates, "AvatarFacility", "AlienFacility", Facility, 'Reward_None');
	//CreateStandardAssaultActivity(Templates, "ChosenBase", "Chosen_Sarcophagus", Chosen, 'Reward_None');

	// Covert Actions
	CreatePrepareCounterDE(Templates, "PrepareCounterDE", "CovertAction");
	CreatePrepareFactionJB(Templates, "PrepareFactionJB", "CovertAction");
	//CreatePrepareChosen(Templates, "PrepareChosen", "CovertAction");
	CreatePrepareFacility(Templates, "PrepareFacility", "CovertAction");
	CreatePrepareUFO(Templates, "PrepareUFO", "CovertAction");
	
	// Misc
	CreateWaitActivity(Templates);

	return Templates;
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
/*
static function CreatePrepareChosen (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath)
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
*/
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

static function CreateWaitActivity (out array<X2DataTemplate> Templates)
{
	local X2ActivityTemplate Activity;

	// This is a special "activity" which does nothing but waits and triggers the next stage at some point in time
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate', Activity, 'Activity_Wait');
	Activity.StateClass = class'XComGameState_Activity_Wait';

	Templates.AddItem(Activity);
}

///////////////
/// Helpers ///
///////////////

static function CreateStandardInfilActivity (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon, name RewardName, optional bool bPOI, optional bool bDarkEvent)
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

	if (bPOI) Activity.OnSuccess = OnSuccessPOI;
	if (bDarkEvent) Activity.PreMissionSetup = PreMissionSetup_DE;
	
	Activity.MissionRewards.AddItem(RewardName);
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
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

static function CreateStandardAssaultActivity (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon, name RewardName)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, name("Activity_" $ ActivityName));
	
	Activity.OverworldMeshPath = "UI_3D.Overwold_Final." $ MeshPath;
	Activity.UIButtonIcon = MissionIcon;
	
	Activity.MissionRewards.AddItem(RewardName);
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
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