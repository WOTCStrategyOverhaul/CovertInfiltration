//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
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
	local string Guerilla, Council, Supply;

	Guerilla = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_GOPS";
	Council = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Council";
	Supply = "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_SupplyRaid";
	
	// Infiltrations
	CreateStandardInfilActivity(Templates, "JailbreakSoldier", "UI_3D.Overwold_Final.Council_VIP", Council, 'Reward_Soldier');
	CreateStandardInfilActivity(Templates, "RescueEngineer", "UI_3D.Overwold_Final.Council_VIP", Council, 'Reward_Engineer');
	CreateStandardInfilActivity(Templates, "RescueScientist", "UI_3D.Overwold_Final.Council_VIP", Council, 'Reward_Scientist');
	CreateStandardInfilActivity(Templates, "CaptureInformant", "UI_3D.Overwold_Final.Council_VIP", Council, 'Reward_Intel');
	
	CreateStandardInfilActivity(Templates, "RecoverSchedule", "UI_3D.Overwold_Final.GorillaOps", Guerilla, 'Reward_None');
	CreateStandardInfilActivity(Templates, "HackLocation", "UI_3D.Overwold_Final.GorillaOps", Guerilla, 'Reward_None');
	CreateStandardInfilActivity(Templates, "CommanderSupply", "UI_3D.Overwold_Final.GorillaOps", Guerilla, 'Reward_None');
	CreateStandardInfilActivity(Templates, "CounterDarkEvent", "UI_3D.Overwold_Final.GorillaOps", Guerilla, 'Reward_Intel');
	
	CreateStandardInfilActivity(Templates, "SupplyRaid", "UI_3D.Overwold_Final.SupplyRaid_AdvConvoy", Supply, 'Reward_Supplies');
	
	// Assaults
	//CreateStandardAssaultActivity(Templates, "GatherIntel", "UI_3D.Overwold_Final.GorillaOps", Guerilla, 'Reward_Intel', true, 24, 4);
	//CreateStandardAssaultActivity(Templates, "GatherSupplies", "UI_3D.Overwold_Final.SupplyRaid_AdvATT", Supply, 'Reward_Supplies', true, 24, 4);

	// Covert Actions
	CreatePrepareCounterDE(Templates, "PrepareCounterDE", "UI_3D.Overwold_Final.CovertAction");
	CreatePrepareFactionJB(Templates, "PrepareFactionJailbreak", "UI_3D.Overwold_Final.CovertAction");
	
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
	CovertAction.Rewards.AddItem('Reward_None'); // TODO: POI

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
	CovertAction.Rewards.AddItem('Reward_None'); // TODO: POI

	Activity.CovertActionName = CovertAction.DataName;

	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

//////////////////////////////////////////////////////
//                    Helpers                       //
//////////////////////////////////////////////////////

static function CreateStandardInfilActivity (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon, name RewardName)
{
	local X2ActivityTemplate_Infiltration Activity;
	local X2CovertActionTemplate CovertAction;
	
	CovertAction = class'X2StrategyElement_InfiltrationActions'.static.CreateInfiltrationTemplate(name("CovertAction_" $ ActivityName $ "Infil"), true);
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Infiltration', Activity, name("Activity_" $ ActivityName));
	
	CovertAction.ChooseLocationFn = UseActivityPrimaryRegion;
	CovertAction.OverworldMeshPath = MeshPath;
	
	CovertAction.Narratives.AddItem(name("CovertActionNarrative_" $ ActivityName $ "Infil"));
	CovertAction.Rewards.AddItem('Reward_InfiltrationActivityProxy');

	Activity.CovertActionName = CovertAction.DataName;
	Activity.OverworldMeshPath = MeshPath;
	Activity.UIButtonIcon = MissionIcon;
	
	Activity.MissionRewards.AddItem(RewardName);
	Activity.GetMissionDifficulty = GetMissionDifficultyFromMonth;
	Activity.WasMissionSuccessful = class'X2StrategyElement_DefaultMissionSources'.static.OneStrategyObjectiveCompleted;
	
	Templates.AddItem(CovertAction);
	Templates.AddItem(Activity);
}

static function CreateStandardAssaultActivity (out array<X2DataTemplate> Templates, string ActivityName, string MeshPath, string MissionIcon, name RewardName, optional bool ExpBool = false, optional int ExpHours = -1, optional int ExpVar = -1)
{
	local X2ActivityTemplate_Assault Activity;
	
	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_Assault', Activity, name("Activity_" $ ActivityName));
	
	Activity.bExpires = ExpBool;
	Activity.ExpirationBaseTime = ExpHours * 3600;
	Activity.ExpirationVariance = ExpVar * 3600;

	Activity.OverworldMeshPath = MeshPath;
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
	CovertAction.OverworldMeshPath = MeshPath;
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