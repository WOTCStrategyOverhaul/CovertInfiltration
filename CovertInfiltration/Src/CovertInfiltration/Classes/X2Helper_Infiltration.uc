//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf, Xymanek, statusNone and ArcaneData
//  PURPOSE: Houses various common functionality used in various places by this mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Helper_Infiltration extends Object config(Infiltration) abstract;

struct TrainingTimeModByRank
{
	var int PrePromotionRank; // Example: if you want to affect rookie -> squaddie promotion, set this to 0
	var int Difficulty;

	var int AdditionalHours;
	var float Multiplier;

	structdefaultproperties
	{
		PrePromotionRank = -1;
		Difficulty = -1;

		Multiplier = 1;
	}
};

struct XpMissionStartingEnemiesOverride
{
	var string MissionType;
	var int NumEnemies;
};

struct XpMultiplerEntry
{
	var float GroupStartingCountRatio;
	var float XpMultipler;
};

var config int EXFIL_INTEL_COST_BASEAMOUNT;
var config int EXFIL_INTEL_COST_MULTIPLIER;

var config array<float> OVERLOADED_MULT;
var config array<int> MAX_INFIL_PER_EXTRA_SOLDIER;

var config array<int> RANKS_DETER;

var config array<int> RANKS_BONDMATE_BONUS;

var config array<ActionFlatRiskSitRep> FlatRiskSitReps;
var config(MissionSources) array<ActivityMissionFamilyMapping> ActivityMissionFamily;

var config int ASSAULT_MISSION_SITREPS_CHANCE;
var config name ASSAULT_MISSION_POSITIVE_SITREP_MILESTONE;
var config int ENVIROMENTAL_SITREP_CHANCE;
var config(GameData) array<name> ENVIROMENTAL_SITREPS_EXCLUDE;

var config int ACADEMY_HOURS_PER_RANK;
var config array<TrainingTimeModByRank> ACADEMY_DURATION_MODS;

// The value by which all kill XP will be multiplied before any kill-count-based scaling will be done
var config float XP_GLOBAL_KILL_MULTIPLER;

// Starting enemies * this = how many enemies of one character group the player can kill before xp throttling kicks in
var config float XP_GROUP_TO_STARTING_RATIO; 

// An array of steps of num kills -> xp multiplication. The final value will be derived using multi-step lerp
// 1 kill and 0% xp at the end will added automatically
// When exceeding the entry with largest GroupStartingCountRatio, no more kill XP will be given
var config array<XpMultiplerEntry> XP_GROUP_MULTIPLIERS; 

// Intended for use by mission mods with missions that use RNFs instead of preplaced enemies
var config array<XpMissionStartingEnemiesOverride> XP_STARTING_ENEMIES_OVERRIDE; 

// The max count of locked/unlocked leads in the HQ inventory at which point the "casual" sources
// of leads will stop showing up. E.g. chain, hack reward, etc
var config int CasualFacilityLeadGainCap;

// Messages displayed in mission debrief under "Global Effects" header
var localized string strChainEffect_Finished;
var localized string strChainEffect_InProgress;
var localized string strChainEffect_Halted;

// useful when squad is not in HQ
static function array<StateObjectReference> GetCovertActionSquad(XComGameState_CovertAction CovertAction)
{
	local array<StateObjectReference> CurrentSquad;
	local CovertActionStaffSlot CovertActionSlot;
	local XComGameState_StaffSlot SlotState;
	local XComGameState_Unit UnitState;
	
	foreach CovertAction.StaffSlots(CovertActionSlot)
	{
		SlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		if (SlotState.IsSlotFilled())
		{
			UnitState = SlotState.GetAssignedStaff();
			if (UnitState.IsSoldier())	
			{
				CurrentSquad.AddItem(UnitState.GetReference());
			}
		}
	}

	return CurrentSquad;
}

static function array<X2InfiltrationModTemplate> GetUnitInfilModifiers(StateObjectReference UnitRef)
{
	local XComGameStateHistory             History;
	local XComGameState_Unit               UnitState;
	local array<XComGameState_Item>        CurrentInventory;
	local XComGameState_Item               InventoryItem;
	local X2WeaponTemplate                 WeaponTemplate;
	local array<X2WeaponUpgradeTemplate>   EquippedUpgrades;
	local X2WeaponUpgradeTemplate          UpgradeTemplate;
	local X2AbilityTemplateManager         AbilityTemplateManager;
	local X2AbilityTemplate                AbilityTemplate;
	local SoldierClassAbilityType          SoldierAbility;
	local array<SoldierClassAbilityType>   SoldierAbilities;
	local X2InfiltrationModTemplateManager InfilTemplateManager;
	local X2InfiltrationModTemplate        InfilTemplate;
	local array<X2InfiltrationModTemplate> UnitModifiers;

	if(UnitRef.ObjectID <= 0) return UnitModifiers;
	
	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
	InfilTemplateManager = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	// check character
	InfilTemplate = InfilTemplateManager.GetInfilTemplateFromCharacter(UnitState.GetMyTemplate());

	if (InfilTemplate != none)
	{
		UnitModifiers.AddItem(InfilTemplate);
	}

	// loop through abilities
	SoldierAbilities = UnitState.GetEarnedSoldierAbilities();
	foreach SoldierAbilities(SoldierAbility)
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(SoldierAbility.AbilityName);

		// check ability
		InfilTemplate = InfilTemplateManager.GetInfilTemplateFromAbility(AbilityTemplate);
		
		if (InfilTemplate != none)
		{
			UnitModifiers.AddItem(InfilTemplate);
		}
	}

	// loop through items
	CurrentInventory = UnitState.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		// check item
		InfilTemplate = InfilTemplateManager.GetInfilTemplateFromItem(InventoryItem.GetMyTemplate());

		if (InfilTemplate != none)
		{
			UnitModifiers.AddItem(InfilTemplate);
		}
		else
		{
			// check category
			InfilTemplate = InfilTemplateManager.GetInfilTemplateFromCategory(InventoryItem.GetMyTemplate());
			
			if (InfilTemplate != none)
			{
				UnitModifiers.AddItem(InfilTemplate);
			}
		}
		
		// check if item supports upgrades
		WeaponTemplate = X2WeaponTemplate(InventoryItem.GetMyTemplate());

		if (WeaponTemplate != none && InventoryItem.GetMyTemplate().iItemSize > 0 && 
			WeaponTemplate.NumUpgradeSlots > 0 && InventoryItem.HasBeenModified())
		{
			EquippedUpgrades = InventoryItem.GetMyWeaponUpgradeTemplates();
			
			// loop through weapon upgrades
			foreach EquippedUpgrades(UpgradeTemplate)
			{
				// check weapon upgrade
				InfilTemplate = InfilTemplateManager.GetInfilTemplateFromItem(UpgradeTemplate);
					
				if (InfilTemplate != none)
				{
					UnitModifiers.AddItem(InfilTemplate);
				}
			}
		}
	}
	
	return UnitModifiers;
}

static function int GetUnitInfilHours(StateObjectReference UnitRef)
{
	local int UnitInfilHours;
	local X2InfiltrationModTemplate Modifier;
	local array<X2InfiltrationModTemplate> UnitModifiers;

	UnitInfilHours = 0;
	UnitModifiers = GetUnitInfilModifiers(UnitRef);
	
	foreach UnitModifiers(Modifier)
	{
		UnitInfilHours += Modifier.HoursAdded;
	}

	return UnitInfilHours;
}

static function int GetUnitRiskReduction(StateObjectReference UnitRef)
{
	local int UnitRiskReduction;
	local X2InfiltrationModTemplate Modifier;
	local array<X2InfiltrationModTemplate> UnitModifiers;
	local XComGameState_Unit UnitState;

	UnitRiskReduction = 0;
	UnitModifiers = GetUnitInfilModifiers(UnitRef);
	
	foreach UnitModifiers(Modifier)
	{
		UnitRiskReduction += Modifier.Deterrence;
	}

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
	if (UnitState.IsSoldier())
	{
		// check soldier ranks
		UnitRiskReduction += default.RANKS_DETER[UnitState.GetSoldierRank()];
	}

	return UnitRiskReduction;
}

static function int GetSquadRiskReduction(array<StateObjectReference> Soldiers)
{
	local StateObjectReference	UnitRef;
	local int					TotalRiskReduction;

	TotalRiskReduction = 0;
	foreach Soldiers(UnitRef)
	{
		TotalRiskReduction += GetUnitRiskReduction(UnitRef);
	}

	return TotalRiskReduction;
}

static function float GetSquadBondingPercentReduction(array<StateObjectReference> Soldiers)
{
	local XComGameStateHistory History;
	local int TotalBonus;
	local StateObjectReference FirstUnitRef, SecondUnitRef, BondedUnitRef;
	local XComGameState_Unit FirstUnitState;
	local SoldierBond BondData;

	History = `XCOMHISTORY;
	
	TotalBonus = 0;

	foreach Soldiers(FirstUnitRef)
	{
		FirstUnitState = XComGameState_Unit(History.GetGameStateForObjectID(FirstUnitRef.ObjectID));

		if (FirstUnitState != none && FirstUnitState.HasSoldierBond(BondedUnitRef))
		{
			foreach Soldiers(SecondUnitRef)
			{
				if (SecondUnitRef == BondedUnitRef)
				{
					FirstUnitState.GetBondData(SecondUnitRef, BondData);
					TotalBonus += default.RANKS_BONDMATE_BONUS[BondData.BondLevel - 1];
					break;
				}
			}
		}		
	}

	TotalBonus /= 2; // divide by two, as each reduction has been added once for each bondmate

	return TotalBonus / float(100);
}

static function DestroyWillRecoveryProject(XComGameState NewGameState, StateObjectReference UnitRef)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersProjectRecoverWill WillProject;

	History = `XCOMHISTORY;
	XComHQ = class'X2StrategyElement_DefaultMissionSources'.static.GetAndAddXComHQ(NewGameState);
	
	foreach History.IterateByClassType(class'XComGameState_HeadquartersProjectRecoverWill', WillProject)
	{
		if(WillProject.ProjectFocus == UnitRef)
		{
			XComHQ.Projects.RemoveItem(WillProject.GetReference());
			NewGameState.RemoveStateObject(WillProject.ObjectID);
		}
	}
}

static function CreateWillRecoveryProject(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	local XComGameState_HeadquartersProjectRecoverWill WillProject;
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'X2StrategyElement_DefaultMissionSources'.static.GetAndAddXComHQ(NewGameState);
	WillProject = XComGameState_HeadquartersProjectRecoverWill(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectRecoverWill'));
	WillProject.SetProjectFocus(UnitState.GetReference(), NewGameState);

	XComHQ.Projects.AddItem(WillProject.GetReference());
}

static function StrategyCost GetExfiltrationStrategyCost(XComGameState_CovertAction CovertAction)
{
	local StrategyCost ExfiltrateCost;
	local ArtifactCost IntelCost;

	IntelCost.Quantity = GetExfiltrationIntegerCost(CovertAction);
	IntelCost.ItemTemplateName = 'Intel';

	ExfiltrateCost.ResourceCosts.AddItem(IntelCost);

	return ExfiltrateCost;
}

static function int GetExfiltrationIntegerCost(XComGameState_CovertAction CovertAction)
{
	local TDateTime CurrentTime;
	local float Days;

	CurrentTime = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
	Days = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInHours(CurrentTime, CovertAction.StartDateTime) / 24;

	return default.EXFIL_INTEL_COST_BASEAMOUNT + Round(Days * default.EXFIL_INTEL_COST_MULTIPLIER);
}

static function bool IsInfiltrationAction(XComGameState_CovertAction Action)
{
	return class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(Action) != none;
}

static function XComGameState_MissionSite GetMissionSiteFromAction (XComGameState_CovertAction Action)
{
	local XComGameState_MissionSite MissionSite;
	local XComGameState_Activity ActivityState;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(Action);
	
	if (ActivityState != none)
	{
		MissionSite = GetMissionStateFromActivity(ActivityState);
	}

	return MissionSite;
}

static function bool ReturnFalse()
{
	return false;
}

static function RecalculateActionRisks(StateObjectReference ActionRef)
{
	local XComGameState_CovertAction ActionState;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: recalculate action risk chances");
	ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionRef.ObjectID));
	ActionState.RecalculateRiskChanceToOccurModifiers();

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

static function int GetRequiredStaffSlots(XComGameState_CovertAction CovertAction)
{
	local int	Count, i;

	Count = 0;
	for (i = 0; i < CovertAction.StaffSlots.Length; i++)
	{
		if (!CovertAction.StaffSlots[i].bOptional)
			Count++;
	}

	return Count;
}

static function int GetSquadInfiltration(array<StateObjectReference> Soldiers, XComGameState_CovertAction CovertAction)
{
	local int BaseDuration, Result;
	
	BaseDuration = GetSquadInfilWithoutPenalty(Soldiers);
	Result = BaseDuration;
	
	if (IsInfiltrationAction(CovertAction))
	{
		Result *= float(1) - GetSquadBondingPercentReduction(Soldiers);
		Result += GetSquadOverloadPenalty(Soldiers, CovertAction, BaseDuration);
	}

	return Result;
}

static function int GetSquadInfilWithoutPenalty(array<StateObjectReference> Soldiers)
{
	local StateObjectReference UnitRef;
	local int                  TotalInfiltration;

	TotalInfiltration = 0;

	foreach Soldiers(UnitRef)
	{
		TotalInfiltration += GetUnitInfilHours(UnitRef);
	}

	return TotalInfiltration;
}

static function int GetSquadSize(array<StateObjectReference> Soldiers)
{
	local StateObjectReference UnitRef;
	local int                  Size;

	Size = 0;

	foreach Soldiers(UnitRef)
	{
		if (UnitRef.ObjectID > 0)
		{
			Size++;
		}
	}

	return Size;
}

static function int CountUnupgradedSlots(array<StateObjectReference> Soldiers, XComGameState_CovertAction CovertAction)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local int SquadSize, MaxSize;

	XComHQ = `XCOMHQ;

	MaxSize = GetRequiredStaffSlots(CovertAction);
	MaxSize += XComHQ.HasSoldierUnlockTemplate('InfiltrationSize1') ? 1 : 0;
	MaxSize += XComHQ.HasSoldierUnlockTemplate('InfiltrationSize2') ? 1 : 0;
	
	SquadSize = GetSquadSize(Soldiers);

	return Max(SquadSize - MaxSize, 0);

}

static function int GetSquadOverloadPenalty(array<StateObjectReference> Soldiers, XComGameState_CovertAction CovertAction, int TotalInfiltration)
{
	local int OverloadSlot, UnupgradedSlots;
	local float Multiplier;

	UnupgradedSlots = CountUnupgradedSlots(Soldiers, CovertAction);

	for (OverloadSlot = 0; OverloadSlot < UnupgradedSlots; OverloadSlot++)
	{
		Multiplier += default.OVERLOADED_MULT[OverloadSlot];
	}

	return TotalInfiltration * Multiplier;
}

static function int GetMaxAllowedInfil (array<StateObjectReference> Soldiers, XComGameState_CovertAction CovertAction)
{
	local int UnupgradedSlots, i;
	
	UnupgradedSlots = CountUnupgradedSlots(Soldiers, CovertAction);
	i = Min(default.MAX_INFIL_PER_EXTRA_SOLDIER.Length, UnupgradedSlots);
	
	return default.MAX_INFIL_PER_EXTRA_SOLDIER[i];
}

// Must call ActionState.RecalculateRiskChanceToOccurModifiers() after using this
static function AddRiskToAction (X2CovertActionRiskTemplate RiskTemplate, XComGameState_CovertAction ActionState)
{
	local CovertActionRisk SelectedRisk;

	SelectedRisk.RiskTemplateName = RiskTemplate.DataName;
	SelectedRisk.ChanceToOccur = (RiskTemplate.MinChanceToOccur + `SYNC_RAND_STATIC(RiskTemplate.MaxChanceToOccur - RiskTemplate.MinChanceToOccur + 1));

	ActionState.Risks.AddItem(SelectedRisk);
}

static function MissionDefinition GetMissionDefinitionForActivity (XComGameState_Activity ActivityState)
{
	local XComTacticalMissionManager MissionManager;
	local X2CardManager CardManager;
	
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_MissionSite MissionState;
	local ActivityMissionFamilyMapping Mapping;
	local MissionDefinition MissionDef;
	
	local array<string> ValidMissionFamilies;
	local array<string> MissionFamiliesDeck;
	local array<string> MissionTypesDeck;
	local string MissionFamily;
	local string MissionType;

	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (ActivityTemplate == none)
	{
		`RedScreen(nameof(GetMissionDefinitionForActivity) @ "only works for activitites based on X2ActivityTemplate_Mission");
		return MissionDef;
	}

	CardManager = class'X2CardManager'.static.GetCardManager();
	MissionState = GetMissionStateFromActivity(ActivityState);

	MissionManager = `TACTICALMISSIONMGR;
	MissionManager.CacheMissionManagerCards();

	foreach default.ActivityMissionFamily (Mapping)
	{
		if (
			Mapping.ActivityTemplate == ActivityTemplate.DataName &&
			MissionState.ExcludeMissionFamilies.Find(Mapping.MissionFamily) == INDEX_NONE
		)
		{
			ValidMissionFamilies.AddItem(Mapping.MissionFamily);
		}
	}

	if (ValidMissionFamilies.Length == 0)
	{
		`Redscreen("Could not find a mission family for activity: " $ ActivityTemplate.DataName);
		ValidMissionFamilies.AddItem(MissionManager.arrSourceRewardMissionTypes[0].MissionFamily);
	}

	// select the first mission type off the deck that is valid for this mapping
	CardManager.GetAllCardsInDeck('MissionFamilies', MissionFamiliesDeck);
	foreach MissionFamiliesDeck(MissionFamily)
	{
		if (ValidMissionFamilies.Find(MissionFamily) != INDEX_NONE)
		{
			CardManager.MarkCardUsed('MissionFamilies', MissionFamily);
			break;
		}
	}

	// now that we have a mission family, determine the mission type to use
	CardManager.GetAllCardsInDeck('MissionTypes', MissionTypesDeck);
	foreach MissionTypesDeck(MissionType)
	{
		if (
			MissionState.ExcludeMissionTypes.Find(MissionType) == INDEX_NONE &&
			MissionManager.GetMissionDefinitionForType(MissionType, MissionDef) &&
			(
				MissionDef.MissionFamily == MissionFamily ||
				(MissionDef.MissionFamily == "" && MissionDef.sType == MissionFamily) // missions without families are their own family
			)
		)
		{
			CardManager.MarkCardUsed('MissionTypes', MissionType);
			return MissionDef;
		}
	}

	`Redscreen("Could not find a mission type for MissionFamily: " $ MissionFamily);
	return MissionManager.arrMissions[0];
}

static function XComGameState_MissionSite GetMissionStateFromActivity (XComGameState_Activity ActivityState)
{
	return XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(ActivityState.PrimaryObjectRef.ObjectID));
}

static function StateObjectReference CreateRewardNone (XComGameState NewGameState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2RewardTemplate Template;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Template = X2RewardTemplate(TemplateManager.FindStrategyElementTemplate('Reward_None'));

	return Template.CreateInstanceFromTemplate(NewGameState).GetReference();
}

static function bool GeoscapeReadyForUpdate ()
{
	local UIStrategyMap StrategyMap;

	StrategyMap = `HQPRES.StrategyMap2D;

	return
		StrategyMap != none &&
		StrategyMap.m_eUIState != eSMS_Flight &&
		StrategyMap.Movie.Pres.ScreenStack.GetCurrentScreen() == StrategyMap;
}

static function InitalizeGeneratedMissionFromActivity (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSite MissionState;
	local X2RewardTemplate MissionReward;
	local GeneratedMissionData EmptyData;
	local string AdditionalTag;

	MissionState = GetMissionStateFromActivity(ActivityState);
	MissionReward = XComGameState_Reward(`XCOMHISTORY.GetGameStateForObjectID(MissionState.Rewards[0].ObjectID)).GetMyTemplate();
	MissionState.GeneratedMission = EmptyData;
	
	MissionState.GeneratedMission.MissionID = MissionState.ObjectID;
	MissionState.GeneratedMission.LevelSeed = class'Engine'.static.GetEngine().GetSyncSeed();
	
	MissionState.GeneratedMission.Mission = GetMissionDefinitionForActivity(ActivityState);
	MissionState.GeneratedMission.SitReps = MissionState.GeneratedMission.Mission.ForcedSitreps;

	if (MissionState.GeneratedMission.Mission.sType == "")
	{
		`Redscreen("GetMissionDefinitionForActivity() failed to generate a mission with: \n"
						$ " Activity: " $ ActivityState.GetMyTemplateName() $ "\n RewardType: " $ MissionReward.DisplayName);
	}

	foreach MissionState.AdditionalRequiredPlotObjectiveTags(AdditionalTag)
	{
		MissionState.GeneratedMission.Mission.RequiredPlotObjectiveTags.AddItem(AdditionalTag);
	}

	SetActivityMissionQuestItem(MissionState);
	
	if (X2ActivityTemplate_Mission(ActivityState.GetMyTemplate()).bNeedsPOI)
	{
		MissionState.PickPOI(NewGameState);
	}

	// Cosmetic stuff

	MissionState.GeneratedMission.BattleOpName = class'XGMission'.static.GenerateOpName(false);
	MissionState.GenerateMissionFlavorText();
}

static protected function SetActivityMissionQuestItem (XComGameState_MissionSite MissionState)
{
	local XComTacticalMissionManager MissionMgr;
	local XComGameState_Reward RewardState;

	MissionMgr = `TACTICALMISSIONMGR;
	RewardState = XComGameState_Reward(`XCOMHISTORY.GetGameStateForObjectID(MissionState.Rewards[0].ObjectID));

	// "Unwrap" if chain proxy
	if (RewardState.GetMyTemplateName() == 'Reward_ChainProxy')
	{
		RewardState = class'X2StrategyElement_InfiltrationRewards'.static.GetProxyReward(RewardState);
	}

	MissionState.GeneratedMission.MissionQuestItemTemplate = MissionMgr.ChooseQuestItemTemplate(
		MissionState.Source,
		RewardState.GetMyTemplate(),
		MissionState.GeneratedMission.Mission,
		MissionState.DarkEvent.ObjectID > 0
	);
}

static function SetFactionOnMissionSite (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local X2ActivityTemplate_Mission ActivityTemplate;
	local XComGameState_MissionSite MissionState;
	local XComGameState_ActivityChain ChainState;

	ActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	if (!ActivityTemplate.bAssignFactionToMissionSite) return;

	ChainState = ActivityState.GetActivityChain();
	if (ChainState.FactionRef.ObjectID == 0) return;

	MissionState = GetMissionStateFromActivity(ActivityState);
	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

	MissionState.ResistanceFaction = ChainState.FactionRef;
}

static function BuildFlatRisksDeck ()
{
	local ActionFlatRiskSitRep FlatRiskDef;
	local X2CardManager CardManager;
	
	CardManager = class'X2CardManager'.static.GetCardManager();
	
	foreach default.FlatRiskSitReps(FlatRiskDef)
	{
		CardManager.AddCardToDeck('FlatRisks', string(FlatRiskDef.FlatRiskName));
	}
}

// Note that we add directly to state instead of returning the array so that the MeetsRequirements call later accounts for this sitrep
static function array<name> GetSitrepsForAssaultMission (XComGameState_MissionSite MissionState)
{
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2SitRepTemplateManager SitRepManager;
	local X2SitRepTemplate SitRepTemplate;
	local X2CardManager CardManager;
	local array<string> CardLabels;
	local array<name> EmptyArray;
	local string Card;
	local int i;

	// Select the risk + bonus
	if (class'X2StrategyGameRulesetDataStructures'.static.Roll(default.ASSAULT_MISSION_SITREPS_CHANCE))
	{
		StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
		SitRepManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
		CardManager = class'X2CardManager'.static.GetCardManager();
	
		// Prepare the decks
		class'XComGameState_MissionSiteInfiltration'.static.BuildBonusesDeck();
		BuildFlatRisksDeck();

		// Select a positive sitrep
		CardLabels.Length = 0;
		CardManager.GetAllCardsInDeck('OverInfiltrationBonuses', CardLabels);

		foreach CardLabels(Card)
		{
			BonusTemplate = X2OverInfiltrationBonusTemplate(StratMgr.FindStrategyElementTemplate(name(Card)));

			if (
				BonusTemplate == none || // Something changed
				BonusTemplate.Milestone != default.ASSAULT_MISSION_POSITIVE_SITREP_MILESTONE || // Different tier
				!BonusTemplate.bSitRep // We only consider sitrep bonuses here
			)
			{
				continue;
			}

			SitRepTemplate = SitRepManager.FindSitRepTemplate(BonusTemplate.MetatdataName);
			if (SitRepTemplate == none || !SitRepTemplate.MeetsRequirements(MissionState))
			{
				continue;
			}

			// All good, use the sitrep
			MissionState.GeneratedMission.SitReps.AddItem(SitRepTemplate.DataName);

			if (!BonusTemplate.DoNotMarkUsed)
			{
				CardManager.MarkCardUsed('OverInfiltrationBonuses', Card);
			}

			// We are done
			break;
		}

		// Select a negative sitrep. Do this after positive sitreps, since there are more risks and some are not compatible
		CardManager.GetAllCardsInDeck('FlatRisks', CardLabels);
		foreach CardLabels(Card)
		{
			i = default.FlatRiskSitReps.Find('FlatRiskName', name(Card));

			if (i != INDEX_NONE)
			{
				SitRepTemplate = SitRepManager.FindSitRepTemplate(default.FlatRiskSitReps[i].SitRepName);

				if (SitRepTemplate != none && SitRepTemplate.MeetsRequirements(MissionState))
				{
					MissionState.GeneratedMission.SitReps.AddItem(SitRepTemplate.DataName);
					break;
				}
			}
		}
	}

	// Select enviromental sitreps
	// Do this after since this pool is most likely bigger and as such more likely to "survive" exclusions
	SelectEnviromentalSitreps(MissionState);

	return EmptyArray;

	// Prevent compiler warning
	EmptyArray.Length = 0;
}

// Retaliations are not eligible for random positive and negative sitreps
static function array<name> GetSitrepsForRetaliationMission (XComGameState_MissionSite MissionState)
{
	local array<name> EmptyArray;

	// Select enviromental sitreps
	SelectEnviromentalSitreps(MissionState);
	
	// Note that we add directly to state instead of returning the array so that the MeetsRequirements call later accounts for this sitrep
	return EmptyArray;

	// Prevent compiler warning
	EmptyArray.Length = 0;
}

static function array<name> GetAllEnviromentalSitreps ()
{
	local X2StrategyElementTemplateManager StrategyTemplateManager;
	local X2SitRepTemplateManager SitRepTemplateManager;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local ActionFlatRiskSitRep FlatRiskSitRep;
	local X2SitRepTemplate SitRepTemplate;
	local X2DataTemplate DataTemplate;
	local array<name> SitReps;
	local name SitRep;

	StrategyTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	SitRepTemplateManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();

	// Get all sitreps
	foreach SitRepTemplateManager.IterateTemplates(DataTemplate)
	{
		SitRepTemplate = X2SitRepTemplate(DataTemplate);
		
		if (SitRepTemplate == none) continue;
		if (SitRepTemplate.bExcludeFromStrategy) continue;

		SitReps.AddItem(SitRepTemplate.DataName);
	}

	// Remove explictly disabled
	foreach default.ENVIROMENTAL_SITREPS_EXCLUDE(SitRep)
	{
		SitReps.RemoveItem(SitRep);
	}

	// Remove risks
	foreach default.FlatRiskSitReps(FlatRiskSitRep)
	{
		SitReps.RemoveItem(FlatRiskSitRep.SitRepName);
	}

	// Remove bonuses
	foreach StrategyTemplateManager.IterateTemplates(DataTemplate)
	{
		BonusTemplate = X2OverInfiltrationBonusTemplate(DataTemplate);

		if (BonusTemplate == none) continue;
		if (!BonusTemplate.bSitRep) continue;

		SitReps.RemoveItem(BonusTemplate.MetatdataName);
	}

	return SitReps;
}

// Note that we add directly to state instead of returning the array so that the MeetsRequirements call later accounts for this sitrep
static function SelectEnviromentalSitreps (XComGameState_MissionSite MissionState)
{
	local X2DownloadableContentInfo_CovertInfiltration DLCInfo;
	local array<name> EnviromentalSitreps, AllSitReps;
	local X2SitRepTemplateManager SitRepMgr;
	local X2SitRepTemplate SitRepTemplate;
	local int MaxNumSitReps, NumSelected;
	local array<string> SitRepCards;
	local X2CardManager CardMgr;
	local string sSitRep;
	local name nSitRep;

	// Check if enviromental sitreps are disabled
	if (`SecondWaveEnabled('NoEnviromentalSitreps')) return;

	// Check cheats
	DLCInfo = class'X2DownloadableContentInfo_CovertInfiltration'.static.GetCDO();
	if (DLCInfo.ForcedNextEnviromentalSitrep != '')
	{
		MissionState.GeneratedMission.SitReps.AddItem(DLCInfo.ForcedNextEnviromentalSitrep);
		DLCInfo.ForcedNextEnviromentalSitrep = '';
		return;
	}

	// Get how many we want to pick
	// If we ever decide to have more than 1, this would be the place to change
	MaxNumSitReps = 0;
	if (class'X2StrategyGameRulesetDataStructures'.static.Roll(default.ENVIROMENTAL_SITREP_CHANCE))
	{
		MaxNumSitReps++;
	}

	// Skip the rest of logic if no sitreps are to be selected
	if (MaxNumSitReps == 0) return;

	SitRepMgr = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
	CardMgr = class'X2CardManager'.static.GetCardManager();
	EnviromentalSitreps = GetAllEnviromentalSitreps();

	// Ensure that the generic sitreps deck is up-to-date
	foreach EnviromentalSitreps(nSitRep)
	{
		CardMgr.AddCardToDeck('SitReps', string(nSitRep));
	}

	// Get all of the currently existing sitreps
	// This is used to prevent redscreens from FindSitRepTemplate due to old cards in the deck
	SitRepMgr.GetTemplateNames(AllSitReps);

	// Select the sitreps until we fill out the array (or run out of candidates)
	CardMgr.GetAllCardsInDeck('SitReps', SitRepCards);
	foreach SitRepCards(sSitRep)
	{
		nSitRep = name(sSitRep);
		
		// Redscreen prevention
		if (AllSitReps.Find(nSitRep) == INDEX_NONE) continue;

		// Actual fetch
		SitRepTemplate = SitRepMgr.FindSitRepTemplate(nSitRep);

		if (
			SitRepTemplate != none &&
			EnviromentalSitreps.Find(SitRepTemplate.DataName) != INDEX_NONE &&
			SitRepTemplate.MeetsRequirements(MissionState)
		)
		{
			MissionState.GeneratedMission.SitReps.AddItem(SitRepTemplate.DataName);
			CardMgr.MarkCardUsed('SitReps', sSitRep);
			NumSelected++;

			if (NumSelected >= MaxNumSitReps) break;
		}
	}
}

static function int GetAcademyTrainingTargetRank ()
{
	return 1 + `XCOMHQ.BonusTrainingRanks;
}

static function int GetAcademyTrainingHours (StateObjectReference UnitRef)
{
	local float TotalHours, IterationHours, Multiplier;
	local TrainingTimeModByRank DurationMod;
	local XComGameState_Unit UnitState;
	local int IterationRank;
	
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
	
	for (IterationRank = UnitState.GetSoldierRank(); IterationRank < GetAcademyTrainingTargetRank(); IterationRank++)
	{
		IterationHours = default.ACADEMY_HOURS_PER_RANK;
		Multiplier = 1;

		foreach default.ACADEMY_DURATION_MODS(DurationMod)
		{
			if (
				(DurationMod.PrePromotionRank != -1 && DurationMod.PrePromotionRank == IterationRank) ||
				(DurationMod.Difficulty != -1 && DurationMod.Difficulty == `StrategyDifficultySetting)
			)
			{
				IterationHours += DurationMod.AdditionalHours;
				Multiplier *= DurationMod.Multiplier;
			}
		}

		TotalHours += IterationHours * Multiplier;
	}

	return Round(TotalHours);
}

static function XComGameState_HeadquartersProjectTrainAcademy GetAcademyProjectForUnit (StateObjectReference UnitRef)
{
	local XComGameState_HeadquartersProjectTrainAcademy ProjectState;
	local XComGameState_HeadquartersXCom XComHQ;
	local StateObjectReference ProjectRef;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	XComHQ = `XCOMHQ;

	foreach XComHQ.Projects(ProjectRef)
	{
		ProjectState = XComGameState_HeadquartersProjectTrainAcademy(History.GetGameStateForObjectID(ProjectRef.ObjectID));

		if (ProjectState != none && ProjectState.ProjectFocus == UnitRef)
		{
			return ProjectState;
		}
	}

	return none;
}

static function BarracksStatusReport GetBarracksStatusReport()
{
	local BarracksStatusReport CurrentBarracksStatus;
	local array<XComGameState_Unit> Soldiers;
	local XComGameState_Unit Soldier;
	
	Soldiers = `XCOMHQ.GetSoldiers();

	foreach Soldiers(Soldier)
	{
		if (Soldier.GetStaffSlot() != none && Soldier.GetStaffSlot().GetMyTemplateName() == 'InfiltrationStaffSlot')
		{
			CurrentBarracksStatus.Infiltrating++;
		}
		else if (Soldier.IsOnCovertAction())
		{
			CurrentBarracksStatus.OnCovertAction++;
		}
		else if (Soldier.IsInjured())
		{
			CurrentBarracksStatus.Wounded++;
		}
		else if (Soldier.GetMentalState() == eMentalState_Tired)
		{
			CurrentBarracksStatus.Tired++;
		}
		else if (Soldier.CanGoOnMission())
		{
			CurrentBarracksStatus.Ready++;
		}
		else
		{
			CurrentBarracksStatus.Unavailable++;
		}
	}

	return CurrentBarracksStatus;
}

static function string GetPostMissionText (XComGameState_Activity ActivityState, bool bVictory)
{
	local XComGameState_ActivityChain ChainState;
	local XGParamTag ParamTag;

	ChainState = ActivityState.GetActivityChain();
	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.StrValue0 = ChainState.GetMyTemplate().strTitle;

	if (bVictory)
	{
		if (ChainState.GetLastActivity().ObjectID == ActivityState.ObjectID)
		{
			return `XEXPAND.ExpandString(default.strChainEffect_Finished);
		}
		else
		{
			return `XEXPAND.ExpandString(default.strChainEffect_InProgress);
		}
	}
	else
	{
		return `XEXPAND.ExpandString(default.strChainEffect_Halted);
	}
}

static function bool IsDLCLoaded (coerce string DLCName)
{
	local array<string> DLCs;
  
	DLCs = class'Helpers'.static.GetInstalledDLCNames();

	return DLCs.Find(DLCName) != INDEX_NONE;
}

static function SetBlackMarketSpawningBegun (XComGameState NewGameState, bool Value)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);

	CIInfo.bBlackMarketSpawningBegun = Value;
}

static function SpawnBlackMarketCovertAction ()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState_BlackMarket BlackMarketState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_ResistanceFaction FactionState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2CovertActionTemplate ActionTemplate;
	local array<name> ActionExclusionList;
	
	BlackMarketState = XComGameState_BlackMarket(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BlackMarket'));

	if (BlackMarketState.bIsOpen || BlackMarketState.bForceClosed || BlackMarketState.bNeedsScan) return;
	
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();

	if (CIInfo.bBlackMarketSpawningBegun) return;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(StratMgr.FindStrategyElementTemplate('CovertAction_BlackMarket'));

	if (ActionTemplate == none)
	{
		`REDSCREEN("Cannot spawn black market covert action - invalid template name");
		return;
	}

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Create Black Market Covert Action");

	// Find starting faction
	RegionState = XComGameState_WorldRegion(History.GetGameStateForObjectID(`XCOMHQ.StartingRegion.ObjectID));		
	FactionState = RegionState.GetResistanceFaction();
	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
	
	if (FactionState == none)
	{
		`REDSCREEN("Cannot spawn black market covert action - invalid faction template name");
		History.CleanupPendingGameState(NewGameState);
	}
	else
	{
		FactionState.AddCovertAction(NewGameState, ActionTemplate, ActionExclusionList);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

///////////////
/// Kill XP ///
///////////////

static function SetStartingEnemiesForXp (XComGameState NewGameState)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComTacticalMissionManager MissionManager;
	local array <XComGameState_Unit> arrUnits;
	local XGPlayer LocalPlayer, OtherPlayer;
	local XGBattle Battle;
	local int i;

	MissionManager = `TACTICALMISSIONMGR;
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
	i = default.XP_STARTING_ENEMIES_OVERRIDE.Find('MissionType', MissionManager.ActiveMission.sType);

	if (i != INDEX_NONE)
	{
		CIInfo.NumEnemiesAtMissionStart = default.XP_STARTING_ENEMIES_OVERRIDE[i].NumEnemies;
		return;
	}
	
	// No override, do the maths manually
	Battle = `BATTLE;
	LocalPlayer = Battle.GetLocalPlayer();
	CIInfo.NumEnemiesAtMissionStart = 0;

	for (i = 0; i < Battle.m_iNumPlayers; i++)
	{
		OtherPlayer = Battle.m_arrPlayers[i];

		if (OtherPlayer == none) continue;
		if (OtherPlayer == LocalPlayer) continue;
		if (!LocalPlayer.IsEnemy(OtherPlayer)) continue;

		arrUnits.Length = 0;
		OtherPlayer.GetPlayableUnits(arrUnits);

		CIInfo.NumEnemiesAtMissionStart += arrUnits.Length;
	}
}

// IMPORTANT!!! This assumes that the kill was already recorded in CIInfo tracker
static function float GetKillContributionMultiplerForKill (name VictimCharacterGroup)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local MultiStepLerpConfig AlgorithmConfig;
	local MultiStepLerpStep AlgorithmStep;
	local XpMultiplerEntry XpConfigEntry;
	local float GroupKillsReferenceCount;
	local int NumKills;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();

	// Do not grant kill XP if there were no enemies at mission start
	// This makes the logic below easier as we can assume that at least 1 enemy was present
	if (CIInfo.NumEnemiesAtMissionStart <= 0) return 0;

	NumKills = CIInfo.GetCharacterGroupsKills(VictimCharacterGroup);
	GroupKillsReferenceCount = CIInfo.NumEnemiesAtMissionStart * default.XP_GROUP_TO_STARTING_RATIO;

	`CI_Trace("GroupKillsReferenceCount=" $ GroupKillsReferenceCount $ ", VictimCharacterGroup=" $ VictimCharacterGroup $ ", NumKills=" $ NumKills);

	// Convert XP_GROUP_MULTIPLIERS to AlgorithmConfig.Steps
	foreach default.XP_GROUP_MULTIPLIERS(XpConfigEntry)
	{
		AlgorithmStep.X = XpConfigEntry.GroupStartingCountRatio * GroupKillsReferenceCount;
		AlgorithmStep.Y = XpConfigEntry.XpMultipler;
		AlgorithmConfig.Steps.AddItem(AlgorithmStep);
	}

	// Add 1 kill
	AlgorithmStep.X = 1;
	AlgorithmStep.Y = 1;
	AlgorithmConfig.Steps.AddItem(AlgorithmStep);

	// Configure excesses
	AlgorithmConfig.ResultIfXExceedsBottomBoundary = 1; // No idea how this can happen, but just grant full XP in this case
	AlgorithmConfig.ResultIfXExceedsUpperBoundary = 0; // Oh boy, you are really taking your time, aren't you? *evil grin*

	// Scale by global modifier and then by the character group one
	return default.XP_GLOBAL_KILL_MULTIPLER * ExecuteMultiStepLerp(NumKills, AlgorithmConfig);
}

static function ValidateXpMultiplers ()
{
	if (default.XP_GROUP_MULTIPLIERS.Length < 2)
	{
		`RedScreen("X2Helper_Infiltration::XP_GROUP_MULTIPLIERS needs at least 2 elements");
	}
}

///////////////////////
/// Multi step lerp ///
///////////////////////

static function float ExecuteMultiStepLerp (float DesiredX, MultiStepLerpConfig AlgorithmConfig)
{
	local array<MultiStepLerpStep> SortedSteps;
	local float Result;
	local bool bFound;
	local int i;

	if (AlgorithmConfig.Steps.Length == 0)
	{
		return AlgorithmConfig.ResultIfNoSteps;
	}

	SortedSteps = AlgorithmConfig.Steps;
	SortedSteps.Sort(SortMultiStepLerpSteps);

	if (DesiredX < SortedSteps[i].X)
	{
		return AlgorithmConfig.ResultIfXExceedsBottomBoundary;
	}

	for (i = 0; i < SortedSteps.Length; i++)
	{
		if (DesiredX == SortedSteps[i].X)
		{
			Result = SortedSteps[i].Y;
			bFound = true;
			break;
		}
		else if (i != 0)
		{
			if (DesiredX > SortedSteps[i - 1].X && DesiredX < SortedSteps[i].X)
			{
				Result = Lerp(
					SortedSteps[i - 1].Y, SortedSteps[i].Y,
					(DesiredX - SortedSteps[i - 1].X) / (SortedSteps[i].X - SortedSteps[i - 1].X)
				);
				bFound = true;
				break;
			}
		}
	}

	if (!bFound)
	{
		return AlgorithmConfig.ResultIfXExceedsUpperBoundary;
	}

	return Result;
}

static protected function int SortMultiStepLerpSteps (MultiStepLerpStep A, MultiStepLerpStep B)
{
	if (A.X == B.X) return 0;

	return A.X < B.X ? 1 : -1;
}

static function HandlePostMissionPOI(XComGameState NewGameState, XComGameState_Activity ActivityState, bool bSuccess)
{
	local XComGameState_PointOfInterest POIState;
	local XComGameState_MissionSite MissionState;
	local X2ActivityTemplate_Mission Template;
	
	MissionState = GetMissionStateFromActivity(ActivityState);
	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
	Template = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());

	if (Template != none && Template.bNeedsPOI)
	{
		if (bSuccess)
		{
			if (MissionState.POIToSpawn.ObjectID <= 0)
			{
				MissionState.PickPOI(NewGameState);
				`CI_Warn(ActivityState.GetMyTemplateName() $ " has no POI and is marked as requiring one! Spawning replacement");
			}

			POIState = XComGameState_PointOfInterest(`XCOMHISTORY.GetGameStateForObjectID(MissionState.POIToSpawn.ObjectID));

			if (POIState != none)
			{
				POIState = XComGameState_PointOfInterest(NewGameState.ModifyStateObject(class'XComGameState_PointOfInterest', POIState.ObjectID));
				POIState.Spawn(NewGameState);
			}
		}
		else
		{
			if (MissionState.POIToSpawn.ObjectID > 0)
			{
				class'XComGameState_HeadquartersResistance'.static.DeactivatePOI(NewGameState, MissionState.POIToSpawn);
			}
		}
	}
}

static function bool ValidateActivityType(eActivityType Type)
{
	switch (Type)
	{
		case eActivityType_Assault:
			return true;
		case eActivityType_Action:
			return true;
		case eActivityType_Infiltration:
			return true;
	}

	return false;
}

static function int GetWaitPeriodDuration (int MinDays, int MaxDays)
{
	local int Min, Max;

	Min = MinDays;
	Max = MaxDays;

	// Make sure that the values are sensible
	if (Min < 0) Min = 0;
	if (Max < Min) Max = Min; // This probably won't work properly -.-

	// Convert to seconds
	Min *= 86400;
	Max *= 86400;

	// Return
	return Min + `SYNC_RAND_STATIC(Max - Min);
}

static function string GetUnitDetails (XComGameState_Activity ActivityState)
{
	local XComGameStateHistory History;
	local XComGameState_Reward RewardState;
	local XComGameState_Unit UnitState;
	local StateObjectReference RewardRef;
	local string UnitString;
	
	History = `XCOMHISTORY;
	
	foreach ActivityState.GetActivityChain().ClaimedChainRewardRefs(RewardRef)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(RewardRef.ObjectID));

		if (RewardState != none)
		{
			if (RewardState.RewardObjectReference.ObjectID > 0)
			{
				UnitState = XComGameState_Unit(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
				
				if (UnitState != none)
				{
					break;
				}
			}
		}
	}
	
	if (UnitState == none)
	{
		foreach ActivityState.GetActivityChain().UnclaimedChainRewardRefs(RewardRef)
		{
			RewardState = XComGameState_Reward(History.GetGameStateForObjectID(RewardRef.ObjectID));

			if (RewardState != none)
			{
				if (RewardState.RewardObjectReference.ObjectID > 0)
				{
					UnitState = XComGameState_Unit(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
				
					if (UnitState != none)
					{
						break;
					}
				}
			}
		}
	}

	if (UnitState != none)
	{
		if (UnitState.IsSoldier())
		{
			if (UnitState.GetRank() > 0)
			{
				UnitString = UnitState.GetName(eNameType_RankFull) @ "(" $ UnitState.GetSoldierClassTemplate().DisplayName $ ")";
			}
			else
			{
				UnitString = UnitState.GetName(eNameType_RankFull);
			}
		}
		else
		{
			UnitString = class'X2StrategyElement_DefaultRewards'.default.DoctorPrefixText @ UnitState.GetName(eNameType_Full) @ "(" $ RewardState.GetMyTemplate().DisplayName $ ")";
		}
	}
	else
	{
		`Redscreen("GetUnitDetails: chain has no personnel rewards!");
		return "UNITNOTFOUND";
	}

	return UnitString;
}

////////////////////////
/// Actionable Leads ///
////////////////////////

// A generic check that's called in various places to gate various things
// related to assaulting facilities
static function bool IsLeadsSystemEngaged ()
{
	return class'UIUtilities_Strategy'.static.GetAlienHQ().bHasSeenFacility;
}

static function bool ShouldAllowCasualLeadGain ()
{
	return GetCountOfAnyLeads() <= default.CasualFacilityLeadGainCap;
}

// No leads are required if you have a relay in the region
static function bool DoesFacilityRequireLead (XComGameState_MissionSite MissionState)
{
	local XComGameState_WorldRegion RegionState;

	RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(MissionState.Region.ObjectID));
	if (RegionState == none) return true;

	return RegionState.ResistanceLevel < eResLevel_Outpost;
}

static function bool CanTakeFacilityMission (XComGameState_MissionSite MissionState)
{
	if (!DoesFacilityRequireLead(MissionState))
	{
		return true;
	}
	else
	{
		return `XCOMHQ.GetResourceAmount('ActionableFacilityLead') > 0;
	}
}

static function int GetCountOfAnyLeads ()
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = `XCOMHQ;

	return XComHQ.GetResourceAmount('FacilityLeadItem') + XComHQ.GetResourceAmount('ActionableFacilityLead');
}

// This method is idempotent and can be called as many times as needed
// If NewGameState is not provided, this method will create a new one on its own
// but will not submit it (i.e. will clean up) if no changes are made
// TODO: Call this on region res level change. Need event in SetResistanceLevel (#874)
static function UpdateFacilityMissionLocks (optional XComGameState NewGameState)
{
	// It turns out that all places that check whether the player can take the mission, do so in the following manner:
	//
	// bMissionLocked = ((MissionRegion != none) && !MissionRegion.HaveMadeContact() && MissionSite.bNotAtThreshold);
	//
	// This is redundant (as making contact sets bNotAtThreshold = false) but most importantly, means that we cannot use 
	// bNotAtThreshold to deny access to mission in contacted regions.
	//
	// As such, the whole situation was reworked using UI hooks (see MissionIconSetMissionSite and
	// OverrideCanTakeFacilityMission in X2EventListener_Infiltration_UI) and the below code
	// turned out to be useless *sob*

//	local bool bSubmitLocally, bNotAtThresholdExpected;
//	local XComGameState_MissionSite MissionState;
//	local XComGameStateHistory History;
//	local int LeadsCount, MissionID;
//	local array<int> MissionIDs;
//
//	LeadsCount = `XCOMHQ.GetResourceAmount('ActionableFacilityLead');
//	History = `XCOMHISTORY;
//
//	if (NewGameState == none)
//	{
//		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating facility mission locks");
//		bSubmitLocally = true;
//	}
//
//	// History.IterateByClassType does not include changes from the pending state,
//	// so if we were given one, collect mission IDs there.
//	// Covers the case when the facility/mission was created in the passed NewGameState
//	if (!bSubmitLocally)
//	{
//		foreach NewGameState.IterateByClassType(class'XComGameState_MissionSite', MissionState)
//		{
//			if (MissionState.Source == 'MissionSource_AlienNetwork')
//			{
//				`AddUniqueItemToArray(MissionIDs, MissionState.ObjectID)
//			}
//		}
//	}
//
//	// Grab the rest
//	foreach History.IterateByClassType(class'XComGameState_MissionSite', MissionState)
//	{
//		if (MissionState.Source == 'MissionSource_AlienNetwork')
//		{
//			`AddUniqueItemToArray(MissionIDs, MissionState.ObjectID)
//		}
//	}
//
//	// Process each mission
//	foreach MissionIDs(MissionID)
//	{
//		// This is safe to do without caring for pending/history stuff, since History.GetGameStateForObjectID
//		// will return the pending state (if exists)
//		MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(MissionID));
//
//		if (!DoesFacilityRequireLead(MissionState))
//		{
//			bNotAtThresholdExpected = false;
//		}
//		else
//		{
//			// If we have no actionable leads, then we cannot launch the mission (not at threshold)
//			bNotAtThresholdExpected = LeadsCount == 0;
//		}
//
//		// If the mission state is correct already, don't do anything
//		if (MissionState.bNotAtThreshold == bNotAtThresholdExpected) continue;
//
//		// Set the correct flag
//		MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
//		MissionState.bNotAtThreshold = bNotAtThresholdExpected;
//	}
//
//	if (bSubmitLocally)
//	{
//		if (NewGameState.GetNumGameStateObjects() > 0)
//		{
//			`SubmitGameState(NewGameState);
//		}
//		else
//		{
//			History.CleanupPendingGameState(NewGameState);
//		}
//	}
}

static function bool UnitHasIrrelevantItems (StateObjectReference UnitRef)
{
	local XComGameStateHistory             History;
	local XComGameState_Unit               UnitState;
	local array<XComGameState_Item>        CurrentInventory;
	local XComGameState_Item               InventoryItem;
	local X2InfiltrationModTemplateManager InfilTemplateManager;
	local X2InfiltrationModTemplate        InfilTemplate;

	if (UnitRef.ObjectID <= 0) return false;
	
	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
	InfilTemplateManager = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();

	// loop through items
	CurrentInventory = UnitState.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		if (InventoryItem.GetMyTemplate().bInfiniteItem) continue;

		// check item
		InfilTemplate = InfilTemplateManager.GetInfilTemplateFromItem(InventoryItem.GetMyTemplate());

		if (InfilTemplate != none)
		{
			if (InfilTemplate.HoursAdded >= 0 && InfilTemplate.Deterrence <= 0)
			{
				return true;
			}
		}
		else
		{
			// check category
			InfilTemplate = InfilTemplateManager.GetInfilTemplateFromCategory(InventoryItem.GetMyTemplate());
			
			if (InfilTemplate != none)
			{
				if (InfilTemplate.HoursAdded >= 0 && InfilTemplate.Deterrence <= 0)
				{
					return true;
				}
			}
			else
			{
				return true;
			}
		}
	}
	
	return false;
}

static function bool ActionHasAmbushRisk (XComGameState_CovertAction CovertAction)
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2CovertActionRiskTemplate RiskTemplate;
	local array<CovertActionRisk> Risks;
	local CovertActionRisk Risk;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Risks = CovertAction.Risks;

	foreach Risks(Risk)
	{
		RiskTemplate = X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(Risk.RiskTemplateName));

		// if an active uncountered ambush risk
		if (RiskTemplate != none
		 && Risk.RiskTemplateName == 'CovertActionRisk_Ambush'
		 && CovertAction.NegatedRisks.Find(Risk.RiskTemplateName) == INDEX_NONE
		 && Risk.ChanceToOccur + Risk.ChanceToOccurModifier > 0)
		{
			return true;
		}
	}

	return false;
}
