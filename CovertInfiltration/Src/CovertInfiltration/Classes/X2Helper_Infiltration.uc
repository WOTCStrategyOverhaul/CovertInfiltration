//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf, Xymanek, statusNone and ArcaneData
//  PURPOSE: Houses various common functionality used in various places by this mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Helper_Infiltration extends Object config(Infiltration);

var config int PERSONNEL_INFIL;
var config int PERSONNEL_DETER;

var config int EXFIL_INTEL_COST_BASEAMOUNT;
var config int EXFIL_INTEL_COST_MULTIPLIER;

var config array<float> OVERLOADED_MULT;

var config array<int> RANKS_DETER;

var config array<ActionFlatRiskSitRep> FlatRiskSitReps;
var config(MissionSources) array<ActivityMissionFamilyMapping> ActivityMissionFamily;

var config int ASSAULT_MISSION_SITREPS_CHANCE;
var config int ASSAULT_MISSION_POSITIVE_SITREP_TIER;

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

static function int GetSoldierInfiltration(StateObjectReference UnitRef)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		UnitState;
	local array<XComGameState_Item>	CurrentInventory;
	local XComGameState_Item		InventoryItem;
	local X2InfiltrationModTemplate Template;
	local float						UnitInfiltration; // using float until value is returned to prevent casting inaccuracy

	local X2InfiltrationModTemplateManager InfilMgr;
	InfilMgr = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();

	History = `XCOMHISTORY;

	if(UnitRef.ObjectID <= 0)
		return 0;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));

	if(!UnitState.IsSoldier())
		return default.PERSONNEL_INFIL;

	UnitInfiltration = 0;

	CurrentInventory = UnitState.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		Template = InfilMgr.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName());

		if (Template == none)
			continue;

		UnitInfiltration += (float(Template.HoursAdded) * GetUnitInfiltrationMultiplierForCategory(UnitState, InventoryItem.GetMyTemplate().ItemCat));
	}

	return int(UnitInfiltration);
}

static function float GetUnitInfiltrationMultiplierForCategory(XComGameState_Unit Unit, name category)
{
	local float InfiltrationMultiplier;
	local array<XComGameState_Item>	CurrentInventory;
	local XComGameState_Item InventoryItem;
	local X2InfiltrationModTemplate Template;
	local X2InfiltrationModTemplateManager InfiltrationManager;

	InfiltrationManager = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();

	InfiltrationMultiplier = 1.0;

	CurrentInventory = Unit.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		Template = InfiltrationManager.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName());

		if (Template == none)
			continue;

		if (Template.MultCategory == category)
			InfiltrationMultiplier *= Template.InfilMultiplier;
	}

	return InfiltrationMultiplier;
}

static function int GetSquadDeterrence(array<StateObjectReference> Soldiers)
{
	local StateObjectReference	UnitRef;
	local int					TotalDeterrence;

	TotalDeterrence = 0;
	foreach Soldiers(UnitRef)
	{
		TotalDeterrence += GetSoldierDeterrence(Soldiers, UnitRef);
	}

	return TotalDeterrence;
}

static function int GetSoldierDeterrence(array<StateObjectReference> Soldiers, StateObjectReference UnitRef)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		UnitState;
	local array<XComGameState_Item>	CurrentInventory;
	local XComGameState_Item		InventoryItem;
	local int						UnitDeterrence;

	local X2InfiltrationModTemplateManager InfilMgr;
	InfilMgr = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();

	History = `XCOMHISTORY;

	if(UnitRef.ObjectID <= 0)
		return 0;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));

	if(!UnitState.IsSoldier())
		return default.PERSONNEL_DETER;

	UnitDeterrence = 0;

	CurrentInventory = UnitState.GetAllInventoryItems();
	foreach CurrentInventory(InventoryItem)
	{
		if(InfilMgr.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName()) != none)
		{
			UnitDeterrence += InfilMgr.GetInfilTemplateFromItem(InventoryItem.GetMyTemplateName()).Deterrence;
		}
	}

	UnitDeterrence += default.RANKS_DETER[UnitState.GetSoldierRank()];

	return UnitDeterrence;
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

static function StrategyCost GetExfiltrationCost(XComGameState_CovertAction CovertAction)
{
	local StrategyCost ExfiltrateCost;
	local ArtifactCost IntelCost;
	local TDateTime CurrentTime;
	local float Days;

	CurrentTime = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
	Days = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInHours(CurrentTime, CovertAction.StartDateTime) / 24;

	IntelCost.Quantity = default.EXFIL_INTEL_COST_BASEAMOUNT + Round(Days * default.EXFIL_INTEL_COST_MULTIPLIER);
	IntelCost.ItemTemplateName = 'Intel';

	ExfiltrateCost.ResourceCosts.AddItem(IntelCost);

	return ExfiltrateCost;
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
	local int Result;
	
	Result = GetSquadInfilWithoutPenalty(Soldiers);
	Result += GetSquadOverloadPenalty(Soldiers, CovertAction, Result);

	return Result;
}

static function int GetSquadInfilWithoutPenalty(array<StateObjectReference> Soldiers)
{
	local StateObjectReference UnitRef;
	local int                  TotalInfiltration;

	TotalInfiltration = 0;

	foreach Soldiers(UnitRef)
	{
		TotalInfiltration += GetSoldierInfiltration(UnitRef);
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

static function int GetSquadOverloadPenalty(array<StateObjectReference> Soldiers, XComGameState_CovertAction CovertAction, int TotalInfiltration)
{
	local int                            SquadSize, MaxSize, CurrentSlot, OverloadSlot;
	local XComGameState_HeadquartersXCom XComHQ;
	local float                          Multiplier;

	XComHQ = `XCOMHQ;

	MaxSize = GetRequiredStaffSlots(CovertAction);
	MaxSize += (XComHQ.HasSoldierUnlockTemplate('InfiltrationSize1') ? 1 : 0) + (XComHQ.HasSoldierUnlockTemplate('InfiltrationSize2') ? 1 : 0);
	
	SquadSize = GetSquadSize(Soldiers);

	if (MaxSize < 1 || SquadSize < 1) 
		return 0;

	Multiplier = 0.0;
	OverloadSlot = 0;

	for (CurrentSlot = MaxSize + 1; CurrentSlot <= SquadSize; CurrentSlot++)
	{
		Multiplier += default.OVERLOADED_MULT[OverloadSlot];
		OverloadSlot++;
	}

	return TotalInfiltration * Multiplier;
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

static function InitalizeGeneratedMissionFromActivity (XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSite MissionState;
	local XComTacticalMissionManager MissionMgr;
	local X2RewardTemplate MissionReward;
	local GeneratedMissionData EmptyData;
	local string AdditionalTag;

	MissionState = GetMissionStateFromActivity(ActivityState);
	MissionReward = XComGameState_Reward(`XCOMHISTORY.GetGameStateForObjectID(MissionState.Rewards[0].ObjectID)).GetMyTemplate();
	MissionMgr = `TACTICALMISSIONMGR;
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

	MissionState.GeneratedMission.MissionQuestItemTemplate = MissionMgr.ChooseQuestItemTemplate(MissionState.Source, MissionReward, MissionState.GeneratedMission.Mission, MissionState.DarkEvent.ObjectID > 0);

	// Cosmetic stuff

	MissionState.GeneratedMission.BattleOpName = class'XGMission'.static.GenerateOpName(false);
	MissionState.GenerateMissionFlavorText();
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

	if (!class'X2StrategyGameRulesetDataStructures'.static.Roll(default.ASSAULT_MISSION_SITREPS_CHANCE))
	{
		// Failed the roll, no sitreps
		return EmptyArray;
	}

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
			BonusTemplate.Tier != default.ASSAULT_MISSION_POSITIVE_SITREP_TIER || // Different tier
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
		// We add directly instead of returning the array so that the MeetsRequirements call later accounts for this sitrep
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

	return EmptyArray;

	// Prevent compiler warning
	EmptyArray.Length = 0;
}