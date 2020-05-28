//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and statusNone
//  PURPOSE: Houses X2EventListenerTemplates that affect gameplay. Mostly CHL hooks
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2EventListener_Infiltration extends X2EventListener config(Infiltration);

// Unrealscript doesn't support nested arrays, so we place a struct inbetween
struct SitRepsArray
{
	var array<name> SitReps;
};

struct SitRepMissionPair
{
	var string MissionType; // Will be preffered if set
	var string MissionFamily;
	var name SitRep;
};

// Values from config represent a percentage to be removed from total will e.g.(25 = 25%, 50 = 50%)
var config int MIN_WILL_LOSS;
var config int MAX_WILL_LOSS;

var config(GameData) bool ALLOW_SQUAD_SIZE_SITREPS_ON_INFILS;
var config(GameData) array<SitRepsArray> SITREPS_EXCLUSIVE_BUCKETS;
var config(GameData) array<SitRepMissionPair> SITREPS_MISSION_BLACKLIST;

var config(GameBoard) array<name> CovertActionsPreventRandomSpawn;

var config(GameData) int NumDarkEventsFirstMonth;
var config(GameData) int NumDarkEventsSecondMonth;
var config(GameData) int NumDarkEventsThirdMonth;

var config(GameBoard) float RiskChancePercentMultiplier;
var config(GameBoard) float RiskChancePercentPerForceLevel;

var config array<StrategyCost> OneTimeMarketLeadCost;

var localized string strOneTimeMarketLeadDescription;

`include(CovertInfiltration/Src/CovertInfiltration/MCM_API_CfgHelpersStatic.uci)
`MCM_CH_VersionCheckerStatic(class'ModConfigMenu_Defaults'.default.iVERSION, class'UIListener_ModConfigMenu'.default.CONFIG_VERSION)

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateStrategyListeners());
	Templates.AddItem(CreateTacticalListeners());

	return Templates;
}

////////////////
/// Strategy ///
////////////////

static function CHEventListenerTemplate CreateStrategyListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_Strategy');
	Template.AddCHEvent('NumCovertActionsToAdd', NumCovertActionToAdd, ELD_Immediate, 99);
	Template.AddCHEvent('CovertActionCompleted', CovertActionCompleted, ELD_Immediate, 99);
	Template.AddCHEvent('AllowDarkEventRisk', AllowDarkEventRisk, ELD_Immediate, 99);
	Template.AddCHEvent('CovertActionRisk_AlterChanceModifier', AlterRiskChanceModifier, ELD_Immediate, 99);
	Template.AddCHEvent('CovertAction_PreventGiveRewards', PreventActionRewards, ELD_Immediate, 99);
	Template.AddCHEvent('CovertAction_RemoveEntity_ShouldEmptySlots', ShouldEmptySlotsOnActionRemoval, ELD_Immediate, 99);
	Template.AddCHEvent('ShouldCleanupCovertAction', ShouldCleanupCovertAction, ELD_Immediate, 99);
	Template.AddCHEvent('ResearchCompleted', CheckTechRushCovertActions, ELD_OnStateSubmitted, 99);
	Template.AddCHEvent('SitRepCheckAdditionalRequirements', SitRepCheckAdditionalRequirements, ELD_Immediate, 99);
	Template.AddCHEvent('CovertActionAllowCheckForProjectOverlap', CovertActionAllowCheckForProjectOverlap, ELD_Immediate, 99);
	Template.AddCHEvent('CovertAction_AllowResActivityRecord', CovertAction_AllowResActivityRecord, ELD_Immediate, 99);
	Template.AddCHEvent('AllowOnCoverActionCompleteAnalytics', AllowOnCoverActionCompleteAnalytics, ELD_Immediate, 99);
	Template.AddCHEvent('CovertActionStarted', CovertActionStarted, ELD_OnStateSubmitted, 99);
	Template.AddCHEvent('PostEndOfMonth', PostEndOfMonth, ELD_OnStateSubmitted, 99);
	Template.AddCHEvent('AllowActionToSpawnRandomly', AllowActionToSpawnRandomly, ELD_Immediate, 99);
	Template.AddCHEvent('AfterActionModifyRecoveredLoot', AfterActionModifyRecoveredLoot, ELD_Immediate, 99);
	Template.AddCHEvent('SoldierTacticalToStrategy', SoldierInfiltrationToStrategyUpgradeGear, ELD_Immediate, 99);
	Template.AddCHEvent('OverrideDarkEventCount', OverrideDarkEventCount, ELD_Immediate, 99);
	Template.AddCHEvent('LowSoldiersCovertAction', PreventLowSoldiersCovertActionNag, ELD_OnStateSubmitted, 99);
	Template.AddCHEvent('OverrideAddChosenTacticalTagsToMission', OverrideAddChosenTacticalTagsToMission, ELD_Immediate, 99);
	Template.AddCHEvent('PreCompleteStrategyFromTacticalTransfer', PreCompleteStrategyFromTacticalTransfer, ELD_Immediate, 99);
	Template.AddCHEvent('BlackMarketGoodsReset', BlackMarketGoodsReset, ELD_Immediate, 99);
	Template.AddCHEvent('BlackMarketPurchase', BlackMarketPurchase_OSS, ELD_OnStateSubmitted, 99);
	Template.AddCHEvent('AddResource', AddResource_OSS, ELD_OnStateSubmitted, 99);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn NumCovertActionToAdd(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_ResistanceFaction Faction;
	local XComLWTuple Tuple;

	Faction = XComGameState_ResistanceFaction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Faction == none || Tuple == none || Tuple.Id != 'NumCovertActionsToAdd') return ELR_NoInterrupt;

	// Force the same behaviour as with ring
	Tuple.Data[0].i = class'XComGameState_ResistanceFaction'.default.CovertActionsPerInfluence[Faction.Influence];

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CovertActionCompleted(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_MissionSiteInfiltration MissionState;
	local XComGameState_CovertAction CovertAction;
	local XComGameState_Activity Activity;

	CovertAction = XComGameState_CovertAction(EventSource);

	if (CovertAction == none)
	{
		return ELR_NoInterrupt;
	}

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(CovertAction))
	{
		`log(CovertAction.GetMyTemplateName() @ "finished, activating infiltration mission",, 'CI');

		Activity = class'XComGameState_Activity'.static.GetActivityFromSecondaryObject(CovertAction);
		MissionState = XComGameState_MissionSiteInfiltration(GameState.ModifyStateObject(class'XComGameState_MissionSiteInfiltration', Activity.PrimaryObjectRef.ObjectID));
		MissionState.OnActionCompleted(GameState);

		// Do not show the CA report, the mission will show its screen instead
		CovertAction.bNeedsActionCompletePopup = false;

		// Remove the CA, the mission takes over from here
		CovertAction.RemoveEntity(GameState);
	}
	else
	{
		`log(CovertAction.GetMyTemplateName() @ "finished, it was not an infiltration - applying fatigue",, 'CI');

		ApplyPostActionWillLoss(CovertAction, GameState);
	}
	
	return ELR_NoInterrupt;
}

static protected function ApplyPostActionWillLoss(XComGameState_CovertAction CovertAction, XComGameState NewGameState)
{
	local CovertActionStaffSlot CovertActionSlot;
	local XComGameState_StaffSlot SlotState;
	local XComGameState_Unit UnitState;
	
	foreach CovertAction.StaffSlots(CovertActionSlot)
	{
		SlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		if (SlotState.IsSlotFilled())
		{
			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SlotState.GetAssignedStaff().ObjectID));
			if (UnitState.UsesWillSystem() && !UnitState.IsInjured() && !UnitState.bCaptured)
			{
				UnitState.SetCurrentStat(eStat_Will, GetWillLoss(UnitState));
				UnitState.UpdateMentalState();

				class'X2Helper_Infiltration'.static.CreateWillRecoveryProject(NewGameState, UnitState);
			}
		}
	}
}

static protected function int GetWillLoss(XComGameState_Unit UnitState)
{
	local int WillToLose, LowestWill;

	WillToLose = default.MIN_WILL_LOSS + `SYNC_RAND_STATIC(default.MAX_WILL_LOSS - default.MIN_WILL_LOSS);
	WillToLose *= UnitState.GetMaxStat(eStat_Will) / 100;

	LowestWill = (UnitState.GetMaxStat(eStat_Will) * class'X2StrategyGameRulesetDataStructures'.default.MentalStatePercents[eMentalState_Shaken] / 100) + 1;
	//never put the soldier into shaken state from covert actions
	if (UnitState.GetMaxStat(eStat_Will) - WillToLose < LowestWill)
	{
		return LowestWill;
	}

	return UnitState.GetCurrentStat(eStat_Will) - WillToLose;
}

static protected function EventListenerReturn AllowDarkEventRisk(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Action == none || Tuple == none || Tuple.Id != 'AllowDarkEventRisk') return ELR_NoInterrupt;

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		// Infiltrations cannot get DE risks (at least for now)
		Tuple.Data[1].b = false;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn AlterRiskChanceModifier(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local array<StateObjectReference> ActionSquad;
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;
	local int ForceLevel;
	local float ModifierForceLevel;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Action == none || Tuple == none || Tuple.Id != 'CovertActionRisk_AlterChanceModifier') return ELR_NoInterrupt;
	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action)) return ELR_NoInterrupt;

	Tuple.Data[4].i += Tuple.Data[1].i * (default.RiskChancePercentMultiplier - 1);
	
	ForceLevel = class'UIUtilities_Strategy'.static.GetAlienHQ().GetForceLevel();
	ModifierForceLevel = default.RiskChancePercentPerForceLevel * ForceLevel;
	Tuple.Data[4].i += ModifierForceLevel;
	
	ActionSquad = class'X2Helper_Infiltration'.static.GetCovertActionSquad(Action);
	Tuple.Data[4].i -= class'X2Helper_Infiltration'.static.GetSquadRiskReduction(ActionSquad);
	
	`CI_Log("Risk modifier for" @ Tuple.Data[0].n @ "is" @ Tuple.Data[4].i $ ", base chance is" @ Tuple.Data[1].i);

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn PreventActionRewards(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Action == none || Tuple == none || Tuple.Id != 'CovertAction_PreventGiveRewards') return ELR_NoInterrupt;

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		// The reward is the mission, you greedy
		Tuple.Data[0].b = true;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn ShouldEmptySlotsOnActionRemoval(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Action == none || Tuple == none || Tuple.Id != 'CovertAction_RemoveEntity_ShouldEmptySlots') return ELR_NoInterrupt;

	if (Action.bStarted && class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		// do not kick people from finished infiltration - we will do it right before launching the mission
		Tuple.Data[0].b = false;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn ShouldCleanupCovertAction(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local ActionExpirationInfo ExpirationInfo;
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'ShouldCleanupCovertAction') return ELR_NoInterrupt;

	Action = XComGameState_CovertAction(Tuple.Data[0].o);

	if (class'XComGameState_CovertActionExpirationManager'.static.GetActionExpirationInfo(Action.GetReference(), ExpirationInfo))
	{
		if (ExpirationInfo.bBlockMonthlyCleanup)
		{
			Tuple.Data[1].b = false;
		}
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CheckTechRushCovertActions(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState_Tech TechState, AttachedTech;
	local XComGameState_CovertAction ActionState;
	local StateObjectReference RewardRef;
	local XComGameState_Reward RewardState;
	local bool RemovedAction;

	RemovedAction = false;
	History = `XCOMHISTORY;
	TechState = XComGameState_Tech(EventData);

	if(TechState == none) return ELR_NoInterrupt;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Clear TechRush Covert Actions");
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
	
	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if (ActionState.bCompleted == false && ActionState.GetMyTemplateName() == 'CovertAction_TechRush')
		{
			foreach ActionState.RewardRefs(RewardRef)
			{
				RewardState = XComGameState_Reward(History.GetGameStateForObjectID(RewardRef.ObjectID));
				AttachedTech = XComGameState_Tech(History.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));

				if (AttachedTech == TechState)
				{
					`CI_Trace("Flagged " $ ActionState.GetMyTemplateName $ " for removal on next update");
					CIInfo.CovertActionsToRemove.AddItem(ActionState.GetReference());
					RemovedAction = true;
				}
			}
		}
	}

	if (RemovedAction)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn SitRepCheckAdditionalRequirements (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;
	local InfilBonusMilestoneSelection InfilBonusSelection;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local SitRepMissionPair SitRepMissionExclusion;
	local X2SitRepEffect_SquadSize SquadSizeEffect;
	local XComGameState_MissionSite MissionState;
	local X2SitRepTemplate TestedSitRepTemplate;
	local SitRepsArray ExclusivityBucket;
	local array<name> CurrentSitReps;
	local bool bMissionMatched;
	local XComLWTuple Tuple;
	local name SitRepName;

	TestedSitRepTemplate = X2SitRepTemplate(EventSource);
	Tuple = XComLWTuple(EventData);

	if (TestedSitRepTemplate == none || Tuple == none || Tuple.Id != 'SitRepCheckAdditionalRequirements') return ELR_NoInterrupt;

	// Check if another listener already blocks this sitrep - in this case we don't need to do anything
	if (Tuple.Data[0].b == false) return ELR_NoInterrupt;

	MissionState = XComGameState_MissionSite(Tuple.Data[1].o);
	InfiltrationState = XComGameState_MissionSiteInfiltration(MissionState);

	// Block squad-size-modifying sitreps from infil

	if (InfiltrationState != none && !default.ALLOW_SQUAD_SIZE_SITREPS_ON_INFILS)
	{
		CurrentSitReps.Length = 1;
		CurrentSitReps[0] = TestedSitRepTemplate.DataName;

		foreach class'X2SitreptemplateManager'.static.IterateEffects(class'X2SitRepEffect_SquadSize', SquadSizeEffect, CurrentSitReps)
		{
			// If we reached this code then, there is at least one X2SitRepEffect_SquadSize attached to this sitrep
			// Block and exit early
			Tuple.Data[0].b = false;
			return ELR_NoInterrupt;
		}

		// If we didn't return above, then there are no X2SitRepEffect_SquadSize - keep going
		CurrentSitReps.Length = 0;
	}

	// Check mission blacklist

	foreach default.SITREPS_MISSION_BLACKLIST(SitRepMissionExclusion)
	{
		if (SitRepMissionExclusion.SitRep != TestedSitRepTemplate.DataName) continue;

		if (SitRepMissionExclusion.MissionType != "")
		{
			bMissionMatched = MissionState.GeneratedMission.Mission.sType == SitRepMissionExclusion.MissionType;
		}
		else if (SitRepMissionExclusion.MissionFamily != "")
		{
			bMissionMatched =
				MissionState.GeneratedMission.Mission.MissionFamily == SitRepMissionExclusion.MissionFamily ||
				(
					MissionState.GeneratedMission.Mission.MissionFamily == "" && // missions without families are their own family
					MissionState.GeneratedMission.Mission.sType == SitRepMissionExclusion.MissionFamily
				);
		}
		else
		{
			`RedScreen("SITREPS_MISSION_BLACKLIST entry encoutered without mission type or family");
			continue;
		}

		if (bMissionMatched)
		{
			// Found incompatibility - exit early
			Tuple.Data[0].b = false;
			return ELR_NoInterrupt;
		}
	}

	// Get the current sitreps, accounting for selected bonuses

	CurrentSitReps = MissionState.GeneratedMission.SitReps;

	if (InfiltrationState != none)
	{
		StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

		foreach InfiltrationState.SelectedInfiltartionBonuses(InfilBonusSelection)
		{
			if (InfilBonusSelection.BonusName == '') continue;

			BonusTemplate = X2OverInfiltrationBonusTemplate(StratMgr.FindStrategyElementTemplate(InfilBonusSelection.BonusName));

			if (BonusTemplate.bSitRep)
			{
				CurrentSitReps.AddItem(BonusTemplate.MetatdataName);
			}
		}
	}

	// Check for exclusivity with other sitreps

	foreach default.SITREPS_EXCLUSIVE_BUCKETS(ExclusivityBucket)
	{
		if (ExclusivityBucket.SitReps.Find(TestedSitRepTemplate.DataName) == INDEX_NONE) continue;

		// This bucket includes the tested sitrep, check if any other is already included
		foreach ExclusivityBucket.SitReps(SitRepName)
		{
			// Cannot be incompatible with itself
			if (SitRepName == TestedSitRepTemplate.DataName) continue;

			if (CurrentSitReps.Find(SitRepName) != INDEX_NONE)
			{
				// Found incompatibility - exit early
				Tuple.Data[0].b = false;
				return ELR_NoInterrupt;
			}
		}
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CovertActionAllowCheckForProjectOverlap (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);

	if (Action == none || Tuple == none || Tuple.Id != 'CovertActionAllowCheckForProjectOverlap') return ELR_NoInterrupt;

	// For now preserve the vanilla behaviour for non-infil CAs
	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		Tuple.Data[0].b = false;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CovertAction_AllowResActivityRecord (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);

	if (Action == none || Tuple == none) return ELR_NoInterrupt;

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		Tuple.Data[0].b = false;
	}

	return ELR_NoInterrupt;
}

// Yes, FXS misspelled it (AnalyticsManager::OnCoverActionComplete)
static protected function EventListenerReturn AllowOnCoverActionCompleteAnalytics (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none) return ELR_NoInterrupt;

	Action = XComGameState_CovertAction(Tuple.Data[2].o);
	if (Action == none) return ELR_NoInterrupt;

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		Tuple.Data[0].b = false;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn CovertActionStarted (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local array<StateObjectReference> CurrentSquad;
	local XComGameState_CovertAction ActionState;
	local StateObjectReference UnitRef;
	local XComGameState NewGameState;

	ActionState = XComGameState_CovertAction(EventSource);
	if (ActionState == none) return ELR_NoInterrupt;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Stop will recovery at action start");
	CurrentSquad = class'X2Helper_Infiltration'.static.GetCovertActionSquad(ActionState);

	foreach CurrentSquad(UnitRef)
	{
		//make sure soldier actually uses will system before we nuke it cuz reasons
		if (XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID)).UsesWillSystem())
		{
			class'X2Helper_Infiltration'.static.DestroyWillRecoveryProject(NewGameState, UnitRef);
		}
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn PostEndOfMonth (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Handling post end of month");
	class'XComGameState_ActivityChainSpawner'.static.SpawnCounterDarkEvents(NewGameState);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn AllowActionToSpawnRandomly (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local X2CovertActionTemplate ActionTemplate;
	local XComLWTuple Tuple;

	local X2ActivityTemplate_Infiltration InfiltrationActivityTemplate;
	local X2ActivityTemplate_CovertAction ActionActivityTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2DataTemplate DataTemplate;
	
	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'AllowActionToSpawnRandomly') return ELR_NoInterrupt;

	ActionTemplate = X2CovertActionTemplate(Tuple.Data[1].o);

	if (default.CovertActionsPreventRandomSpawn.Find(ActionTemplate.DataName) != INDEX_NONE)
	{
		Tuple.Data[0].b = false;
		return ELR_NoInterrupt;
	}

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	foreach TemplateManager.IterateTemplates(DataTemplate)
	{
		InfiltrationActivityTemplate = X2ActivityTemplate_Infiltration(DataTemplate);
		if (InfiltrationActivityTemplate != none && InfiltrationActivityTemplate.CovertActionName == ActionTemplate.DataName)
		{
			Tuple.Data[0].b = false;
			return ELR_NoInterrupt;
		}

		ActionActivityTemplate = X2ActivityTemplate_CovertAction(DataTemplate);
		if (ActionActivityTemplate != none && ActionActivityTemplate.CovertActionName == ActionTemplate.DataName)
		{
			Tuple.Data[0].b = false;
			return ELR_NoInterrupt;
		}
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn AfterActionModifyRecoveredLoot (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local UIInventory_LootRecovered LootRecoveredUI;
	
	local XComGameState_ActivityChain ChainState;
	local XComGameState_Activity ActivityState;
	
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local bool bDirty;

	local XComGameState_Complication_RewardInterception ComplicationState;
	local XComGameState_ResourceContainer ResContainer;
	local XComGameState_HeadquartersXCom XComHQ;
	local StateObjectReference ItemRef;
	local XComGameState_Item ItemState;
	local ResourcePackage Package;
	local int InterceptedQuantity;
	
	LootRecoveredUI = UIInventory_LootRecovered(EventSource);
	if (LootRecoveredUI == none) return ELR_NoInterrupt;

	XComHQ = `XCOMHQ;
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObjectID(XComHQ.MissionRef.ObjectID);
	if (ActivityState == none) return ELR_NoInterrupt;
	
	ChainState = ActivityState.GetActivityChain();
	if (ChainState.GetLastActivity().ObjectID != ActivityState.ObjectID) return ELR_NoInterrupt;
	
	ComplicationState = XComGameState_Complication_RewardInterception(ChainState.FindComplication('Complication_RewardInterception'));
	if (ComplicationState == none) return ELR_NoInterrupt;
	
	if (!ComplicationState.bTriggered) return ELR_NoInterrupt;

	// All checks have passed, we are good to do our magic
	`CI_Log("Processing Reward Interception");

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Apply reward interception");
	ResContainer = XComGameState_ResourceContainer(NewGameState.ModifyStateObject(class'XComGameState_ResourceContainer', ComplicationState.ResourceContainerRef.ObjectID));
	History = `XCOMHISTORY;

	// Loop through all of the recovered loot and see if we can't screw with it
	foreach XComHQ.LootRecovered(ItemRef)
	{
		ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
		if (ItemState == none) continue;

		if (!class'X2StrategyElement_DefaultComplications'.static.IsInterceptableItem(ItemState.GetMyTemplateName()))
		{
			`CI_Trace(ItemState.GetMyTemplateName() @ "is not interceptable - skipping");
			continue;
		}
		
		`CI_Trace(ItemState.GetMyTemplateName() @ "is intercepted");
		bDirty = true;
		
		// Reduce the quantity
		ItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
		InterceptedQuantity = ItemState.Quantity * class'X2StrategyElement_DefaultComplications'.default.REWARD_INTERCEPTION_TAKENLOOT;
		ItemState.Quantity -= InterceptedQuantity;

		// Store the quantity to give later
		Package.ItemType = ItemState.GetMyTemplateName();
		Package.ItemAmount = InterceptedQuantity;
		ResContainer.Packages.AddItem(Package);
	}
	
	// Save the changes, if there was any intercepted items
	if (bDirty)	
	{
		`SubmitGameState(NewGameState);
	}
	else 
	{
		if (!ComplicationState.RewardStateIntercepted)
		{
			`REDSCREEN("No interceptable loot for the complication - rescue mission will spawn empty!");
		}

		History.CleanupPendingGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}

// Note that we cannot use DLCInfo::OnPostMission as the gear of dead soldiers is stripped by that point
// This otoh is called right before the gear is stripped
static protected function EventListenerReturn SoldierInfiltrationToStrategyUpgradeGear (Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState_Unit UnitState;

	InfiltrationState = XComGameState_MissionSiteInfiltration(`XCOMHISTORY.GetGameStateForObjectID(`XCOMHQ.MissionRef.ObjectID));
	UnitState = XComGameState_Unit(EventSource);

	if (InfiltrationState == none || UnitState == none) return ELR_NoInterrupt;

	// This is required as EventData/EventSource inside ELD_Immediate are from last submitted state, not the pending one
	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(UnitState.ObjectID));

	// Captured soldiers are handeled when they are rescued - see #407 for more details
	if (UnitState.bCaptured) return ELR_NoInterrupt;

	if (!UnitState.IsDead())
	{
		// If we upgrade here, soldiers will have magically upgraded gear when exiting the skyranger, so defer it
		CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
		CIInfo.UnitsToConsiderUpgradingGearOnMissionExit.AddItem(UnitState.GetReference());
	}
	else
	{
		// Upgrade here so that it's stripped/added to hq inventory correctly
		class'X2StrategyElement_XpackStaffSlots'.static.CheckToUpgradeItems(NewGameState, UnitState);
	}
	
	return ELR_NoInterrupt;	
}

static protected function EventListenerReturn OverrideDarkEventCount(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;
	local XComGameState_HeadquartersResistance ResistanceHQ;
	
	Tuple = XComLWTuple(EventData);
	ResistanceHQ = XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	if (Tuple == none || Tuple.Id != 'OverrideDarkEventCount') return ELR_NoInterrupt;
	
	if (ResistanceHQ.NumMonths == 0)
	{
		Tuple.Data[0].i = default.NumDarkEventsFirstMonth;
	}
	else if (ResistanceHQ.NumMonths == 1)
	{
		Tuple.Data[0].i = default.NumDarkEventsSecondMonth;
	}
	else
	{
		Tuple.Data[0].i = default.NumDarkEventsThirdMonth;
	}
	
	if (Tuple.Data[1].b)
	{
		Tuple.Data[0].i += 1;
	}

	return ELR_NoInterrupt;
}
	
static protected function EventListenerReturn PreventLowSoldiersCovertActionNag(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (`MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.LOW_SOLDIERS_WARNING_DEFAULT, class'UIListener_ModConfigMenu'.default.LOW_SOLDIERS_WARNING))
	{
		return ELR_InterruptListeners;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OverrideAddChosenTacticalTagsToMission (Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComGameState_AdventChosen ChosenState, LocalChosenState;
	local array<XComGameState_AdventChosen> AllChosen;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_MissionSite MissionState;
	local bool bForce, bGuaranteed, bSpawn;
	local float AppearChanceScalar;
	local name ChosenSpawningTag;
	local int AppearanceChance;
	local XComLWTuple Tuple;

	MissionState = XComGameState_MissionSite(EventSource);
	Tuple = XComLWTuple(EventData);

	if (MissionState == none || Tuple == none || NewGameState == none) return ELR_NoInterrupt;
	
	AlienHQ = class'UIUtilities_Strategy'.static.GetAlienHQ();
	AllChosen = AlienHQ.GetAllChosen(NewGameState);

	// Get the actual pending mission state
	MissionState = XComGameState_MissionSite(NewGameState.GetGameStateForObjectID(MissionState.ObjectID));

	// If another mod already did something, skip our logic
	if (Tuple.Data[0].b) return ELR_NoInterrupt;

	// Do not mess with the golden path missions
	if (MissionState.GetMissionSource().bGoldenPath) return ELR_NoInterrupt;

	// Do not mess with missions that disallow chosen
	if (class'XComGameState_HeadquartersAlien'.default.ExcludeChosenMissionSources.Find(MissionState.Source) != INDEX_NONE) return ELR_NoInterrupt;

	// Do not mess with the chosen base defense
	if (MissionState.IsA(class'XComGameState_MissionSiteChosenAssault'.Name)) return ELR_NoInterrupt;

	// Do not mess with the chosen stronghold assault
	foreach AllChosen(ChosenState)
	{
		if (ChosenState.StrongholdMission.ObjectID == MissionState.ObjectID) return ELR_NoInterrupt;
	}

	// Infiltrations handle chosen internally
	if (MissionState.IsA(class'XComGameState_MissionSiteInfiltration'.Name))
	{
		Tuple.Data[0].b = true;
		return ELR_NoInterrupt;
	}

	// Ok, simple assault mission that allows chosen so we replace the logic
	Tuple.Data[0].b = true;	

	// First, remove tags of dead chosen and find the one that controls our region
	foreach AllChosen(ChosenState)
	{
		if (ChosenState.bDefeated)
		{
			ChosenState.PurgeMissionOfTags(MissionState);
		}
		else if (ChosenState.ChosenControlsRegion(MissionState.Region))
		{
			LocalChosenState = ChosenState;
		}
	}

	// Check if we found someone who can appear here
	if (LocalChosenState == none) return ELR_NoInterrupt;
	
	ChosenSpawningTag = LocalChosenState.GetMyTemplate().GetSpawningTag(LocalChosenState.Level);

	// Check if the chosen is already scheduled to spawn
	if (MissionState.TacticalGameplayTags.Find(ChosenSpawningTag) != INDEX_NONE) return ELR_NoInterrupt;

	// Then see if the chosen is forced to show up (used to spawn chosen on specific missions when the global active flag is disabled)
	// The current use case for this is the "introduction retaliation" - if we active the chosen when the retal spawns and then launch an infil, the chosen will appear on the infil
	// This could be expanded in future if we choose to completely override chosen spawning handling
	if (MissionState.Source == 'MissionSource_Retaliation' && class'XComGameState_HeadquartersXCom'.static.GetObjectiveStatus('CI_CompleteFirstRetal') == eObjectiveState_InProgress)
	{
		bForce = true;
	}

	// If chosen are not forced to showup and they are not active, bail
	if (!bForce && !AlienHQ.bChosenActive) return ELR_NoInterrupt;

	// Now check for the guranteed spawn
	if (bForce)
	{
		bGuaranteed = true;
	}
	else if (LocalChosenState.NumEncounters == 0)
	{
		bGuaranteed = true;
	}

	// If we are checking only for the guranteed spawns and there isn't one, bail
	if (!bGuaranteed && Tuple.Data[1].b) return ELR_NoInterrupt;

	// See if the chosen should actually spawn or not (either guranteed or by a roll)
	if (bGuaranteed)
	{
		bSpawn = true;
	}
	else if (CanChosenAppear(NewGameState))
	{
		AppearanceChance = ChosenState.GetChosenAppearChance();
		
		AppearChanceScalar = AlienHQ.ChosenAppearChanceScalar;
		if (AppearChanceScalar <= 0) AppearChanceScalar = 1.0f;

		if(ChosenState.CurrentAppearanceRoll < Round(float(AppearanceChance) * AppearChanceScalar))
		{
			bSpawn = true;
		}
	}

	// Add the tag to mission if the chosen is to show up
	if (bSpawn)
	{
		MissionState.TacticalGameplayTags.AddItem(ChosenSpawningTag);
	}

	// We are finally done
	return ELR_NoInterrupt;
}

// Copy paste from XComGameState_HeadquartersAlien
static protected function bool CanChosenAppear (XComGameState NewGameState)
{
	local array<XComGameState_AdventChosen> ActiveChosen;
	local XComGameState_HeadquartersAlien AlienHQ;
	local int MinNumMissions, NumActiveChosen;

	AlienHQ = class'UIUtilities_Strategy'.static.GetAlienHQ();
	ActiveChosen = AlienHQ.GetAllChosen(NewGameState);
	NumActiveChosen = ActiveChosen.Length; // Can't inline ActiveChosen cuz unrealscript

	if(NumActiveChosen < 0)
	{
		MinNumMissions = class'XComGameState_HeadquartersAlien'.default.MinMissionsBetweenChosenAppearances[0];
	}
	else if(NumActiveChosen >= class'XComGameState_HeadquartersAlien'.default.MinMissionsBetweenChosenAppearances.Length)
	{
		MinNumMissions = class'XComGameState_HeadquartersAlien'.default.MinMissionsBetweenChosenAppearances[class'XComGameState_HeadquartersAlien'.default.MinMissionsBetweenChosenAppearances.Length - 1];
	}
	else
	{
		MinNumMissions = class'XComGameState_HeadquartersAlien'.default.MinMissionsBetweenChosenAppearances[NumActiveChosen];
	}

	return AlienHQ.MissionsSinceChosen >= MinNumMissions;
}

static protected function EventListenerReturn PreCompleteStrategyFromTacticalTransfer (Object EventData, Object EventSource, XComGameState NullGameState, Name Event, Object CallbackData)
{
	local XComGameState_ActivityChain ChainState;
	local XComGameState_Activity ActivityState;
	
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local bool bDirty;

	local XComGameState_Complication_RewardInterception ComplicationState;
	local XComGameState_ResourceContainer ResContainer;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_MissionSite MissionState;
	local StateObjectReference RewardRef;
	local XComGameState_Reward RewardState;
	local ResourcePackage Package;
	local int InterceptedQuantity;
	
	XComHQ = `XCOMHQ;
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromPrimaryObjectID(XComHQ.MissionRef.ObjectID);
	if (ActivityState == none) return ELR_NoInterrupt;
	
	ChainState = ActivityState.GetActivityChain();
	if (ChainState.GetLastActivity().ObjectID != ActivityState.ObjectID) return ELR_NoInterrupt;
	
	ComplicationState = XComGameState_Complication_RewardInterception(ChainState.FindComplication('Complication_RewardInterception'));
	if (ComplicationState == none) return ELR_NoInterrupt;

	if (!ComplicationState.bTriggered) return ELR_NoInterrupt;

	// All checks have passed, we are good to do our magic
	`CI_Log("Processing Reward Interception");

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Apply reward interception");
	ResContainer = XComGameState_ResourceContainer(NewGameState.ModifyStateObject(class'XComGameState_ResourceContainer', ComplicationState.ResourceContainerRef.ObjectID));
	History = `XCOMHISTORY;
	
	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));

	foreach MissionState.Rewards(RewardRef)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(RewardRef.ObjectID));
		if (RewardState == none) continue;

		if (!class'X2StrategyElement_DefaultComplications'.static.IsInterceptableItem(RewardState.GetMyTemplate().rewardObjectTemplateName))
		{
			`CI_Trace(RewardState.GetMyTemplateName() @ "is not interceptable - skipping");
			continue;
		}
		
		`CI_Trace(RewardState.GetMyTemplateName() @ "is intercepted");
		bDirty = true;
		
		// Reduce the quantity
		RewardState = XComGameState_Reward(NewGameState.ModifyStateObject(class'XComGameState_Reward', RewardState.ObjectID));
		InterceptedQuantity = RewardState.Quantity * class'X2StrategyElement_DefaultComplications'.default.REWARD_INTERCEPTION_TAKENLOOT;
		RewardState.Quantity -= InterceptedQuantity;

		// Store the quantity to give later
		Package.ItemType = RewardState.GetMyTemplate().rewardObjectTemplateName;
		Package.ItemAmount = InterceptedQuantity;
		ResContainer.Packages.AddItem(Package);
	}

	// Save the changes, if there was any intercepted items
	if (bDirty)	
	{
		ComplicationState = XComGameState_Complication_RewardInterception(NewGameState.ModifyStateObject(class'XComGameState_Complication_RewardInterception', ComplicationState.ObjectID));
		ComplicationState.RewardStateIntercepted = true;
		`SubmitGameState(NewGameState);
	}
	else 
	{
		History.CleanupPendingGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn BlackMarketGoodsReset (Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2ItemTemplateManager ItemTemplateMgr;
	local XComGameState_BlackMarket MarketState;
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local Commodity ForSaleItem;

	MarketState = XComGameState_BlackMarket(EventData);
	if (MarketState == none) return ELR_NoInterrupt;

	// Check if the player bought the first lead already
	if (class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bBlackMarketLeadPurchased) return ELR_NoInterrupt;

	// Get the latest pending state
	MarketState = XComGameState_BlackMarket(NewGameState.ModifyStateObject(class'XComGameState_BlackMarket', MarketState.ObjectID));

	// Create the item
	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemTemplateMgr.FindItemTemplate('ActionableFacilityLead');
	ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
	ItemState.Quantity = 1;

	// Create the reward
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Item'));
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	RewardState.SetReward(ItemState.GetReference());

	// Fill out the commodity (default)
	ForSaleItem.RewardRef = RewardState.GetReference();
	ForSaleItem.Image = RewardState.GetRewardImage();
	ForSaleItem.CostScalars = MarketState.GoodsCostScalars;
	ForSaleItem.DiscountPercent = MarketState.GoodsCostPercentDiscount;

	// Fill out the commodity (custom)
	ForSaleItem.Title = ItemTemplate.GetItemFriendlyName(); // Get rid of the "1"
	ForSaleItem.Desc = default.strOneTimeMarketLeadDescription;
	ForSaleItem.Cost = default.OneTimeMarketLeadCost[`StrategyDifficultySetting];

	// Add to sale
	MarketState.ForSaleItems.AddItem(ForSaleItem);

	// We are done
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn BlackMarketPurchase_OSS (Object EventData, Object EventSource, XComGameState SubmittedGameState, Name Event, Object CallbackData)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState_Reward RewardState;
	local XComGameState_Item ItemState;
	local XComGameState NewGameState;

	RewardState = XComGameState_Reward(EventData);
	if (RewardState == none) return ELR_NoInterrupt;

	ItemState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	if (ItemState == none) return ELR_NoInterrupt;
	
	// Make sure we bought a lead and not something else
	if (ItemState.GetMyTemplateName() != 'ActionableFacilityLead') return ELR_NoInterrupt;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Handling BM Actionable Lead purchase");
	class'X2Helper_Infiltration'.static.UpdateFacilityMissionLocks(NewGameState);
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
	CIInfo.bBlackMarketLeadPurchased = true;
	`SubmitGameState(NewGameState);

	if (`HQPRES.StrategyMap2D != none) `HQPRES.StrategyMap2D.UpdateMissions();

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn AddResource_OSS (Object EventData, Object EventSource, XComGameState SubmittedGameState, Name Event, Object CallbackData)
{
	local XComGameState_Item ResourceItemState;

	ResourceItemState = XComGameState_Item(EventData);
	if (ResourceItemState == none) return ELR_NoInterrupt;

	if (ResourceItemState.GetMyTemplateName() == 'ActionableFacilityLead')
	{
		class'X2Helper_Infiltration'.static.UpdateFacilityMissionLocks();
		if (`HQPRES.StrategyMap2D != none) `HQPRES.StrategyMap2D.UpdateMissions();
	}

	 return ELR_NoInterrupt;
}

////////////////
/// Tactical ///
////////////////

static function CHEventListenerTemplate CreateTacticalListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_Tactical');
	Template.AddCHEvent('PostMissionObjectivesSpawned', AddCovertEscapeObjective, ELD_Immediate, 99);
	Template.AddCHEvent('SquadConcealmentBroken', CallReinforcementsOnSupplyExtraction, ELD_OnStateSubmitted, 99);
	Template.AddCHEvent('ScamperEnd', CallReinforcementsOnSupplyExtraction, ELD_OnStateSubmitted, 99);
	Template.AddCHEvent('OnTacticalBeginPlay', OnTacticalPlayBegun_VeryEarly, ELD_OnStateSubmitted, 99999);
	Template.AddCHEvent('OnTacticalBeginPlay', OnTacticalPlayBegun_VeryLate, ELD_OnStateSubmitted, -99999);
	Template.AddCHEvent('XpKillShot', XpKillShot, ELD_Immediate, 99);
	Template.AddCHEvent('PostAliensSpawned', PostAliensSpawned, ELD_Immediate, 99);
	Template.AddCHEvent('KismetGameStateMatinee', KismetGameStateMatinee_PreSupplyExtract, ELD_OnVisualizationBlockStarted, 99);
	Template.AddCHEvent('KismetGameStateMatinee', KismetGameStateMatinee_PostSupplyExtract, ELD_OnVisualizationBlockCompleted, 99);
	Template.RegisterInTactical = true;

	return Template;
}

static protected function EventListenerReturn AddCovertEscapeObjective(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComTacticalMissionManager MissionManager;
	local XComParcelManager ParcelManager;

	local XComGameStateContext_TacticalGameRule StateChangeContainer;
	local XComGameState_InteractiveObject InteractiveObject;
	local XComGameState_ObjectiveInfo ObjectiveState;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	local XComInteractiveLevelActor VisArchetype;
	local XComInteractiveLevelActor Visualizer;
	local vector ObjectiveLocation;
	local XComWorldData XComWorld;

	`log("AddCovertEscapeObjective hit",, 'CI');

	MissionManager = `TACTICALMISSIONMGR;
	ParcelManager = `PARCELMGR;
	History = `XCOMHISTORY;
	XComWorld = `XWORLD;

	if (MissionManager.ActiveMission.sType != "CovertEscape")
	{
		// DO NOT touch other missions
		`log("AddCovertEscapeObjective skip due to wrong mission type",, 'CI');
		return ELR_NoInterrupt;
	}

	// The following code is heavily "inspired" by XComTacticalMissionManager::CreateObjective_Interact
	// The idea is to just spawn a dummy objective at objective parcel so that LOP works correctly

	VisArchetype = XComInteractiveLevelActor(DynamicLoadObject("XComInteractiveLevelActor'Mission_Assets.Archetypes.ARC_IA_GenericObjectiveMarker'", class'XComInteractiveLevelActor'));
	ObjectiveLocation = ParcelManager.ObjectiveParcel.Location;

	NewGameState = History.GetStartState();
	if(NewGameState == none)
	{
		// the start state has already been locked, so we'll need to make our own
		StateChangeContainer = XComGameStateContext_TacticalGameRule(class'XComGameStateContext_TacticalGameRule'.static.CreateXComGameStateContext());
		StateChangeContainer.GameRuleType = eGameRule_UnitAdded;
		NewGameState = History.CreateNewGameState(true, StateChangeContainer);
	}

	// spawn the game object
	InteractiveObject = XComGameState_InteractiveObject(NewGameState.CreateNewStateObject(class'XComGameState_InteractiveObject'));
	XComWorld.GetFloorTileForPosition(ObjectiveLocation, InteractiveObject.TileLocation);
	InteractiveObject.ArchetypePath = PathName(VisArchetype);
	//InteractiveObject.InteractionBoundingBox = ... Let's hope this isn't needed

	ObjectiveState = XComGameState_ObjectiveInfo(NewGameState.CreateNewStateObject(class'XComGameState_ObjectiveInfo'));
	ObjectiveState.MissionType = "CovertEscape";
	InteractiveObject.AddComponentObject(ObjectiveState);

	// snap the loc to the spawned game object
	ObjectiveLocation = XComWorld.GetPositionFromTileCoordinates(InteractiveObject.TileLocation);
	ObjectiveLocation.Z = XComWorld.GetFloorZForPosition(ObjectiveLocation);

	// submit the new state
	if(NewGameState != History.GetStartState())
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}

	`log("Added dummy objective at objective parcel location",, 'CI');

	// spawn the visualizer object. 
	InteractiveObject.ActorId.Location = ObjectiveLocation; //Set the location on the state object so it can be found when the visualizer spawns. TODO: Is this writing to history after submission?
	Visualizer = `XCOMGAME.Spawn(VisArchetype.Class,,, ObjectiveLocation, rot(0,0,0), VisArchetype, true);
	Visualizer.SetObjectIDFromState(InteractiveObject);

	Visualizer.UpdateLootSparklesEnabled(false, InteractiveObject);

	// No need for this since we are spawning from scratch
	//UpdateObjectiveVisualizerFromSwapInfo(Visualizer, Spawn, SpawnInfo);

	History.SetVisualizer(InteractiveObject.ObjectID, Visualizer);
	InteractiveObject.SetInitialState(Visualizer);
	Visualizer.SetObjectIDFromState(InteractiveObject);

	return ELR_NoInterrupt;
}

static function EventListenerReturn CallReinforcementsOnSupplyExtraction(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_CIReinforcementsManager ManagerState;
	local DelayedReinforcementOrder DelayedReinforcementOrder;
	local XComGameState_CovertInfiltrationInfo CIInfo;

	if (`TACTICALMISSIONMGR.ActiveMission.sType != "SupplyExtraction")
	{
		return ELR_NoInterrupt;
	}

	// Check if we activated the system already
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	if (CIInfo.bSupplyExtractionRnfsStarted) return ELR_NoInterrupt;

	// Hold until the player squad is revealed
	if (
		Event == 'ScamperEnd' &&
		class'XComGameState_Player'.static.GetPlayerState(eTeam_XCom).bSquadIsConcealed
	)
	{
		return ELR_NoInterrupt;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: CallReinforcementsOnSupplyExtraction");
	ManagerState = class'XComGameState_CIReinforcementsManager'.static.GetReinforcementsManager();
	ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));

	DelayedReinforcementOrder.EncounterID = 'ADVx3_Standard';
	DelayedReinforcementOrder.TurnsUntilSpawn = 3;
	DelayedReinforcementOrder.Repeating = true;
	DelayedReinforcementOrder.RepeatTime = 2;

	ManagerState.DelayedReinforcementOrders.AddItem(DelayedReinforcementOrder);

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
	CIInfo.bSupplyExtractionRnfsStarted = true;

	`TACTICALRULES.SubmitGameState(NewGameState);

	// Fix for advent extraction never starting when starting mission without concealment
	if (Event == 'ScamperEnd') KismetStartSupplyExtract();

	return ELR_NoInterrupt;
}

// MUST BE CALLED
// 1) Inside gamestate submission "thread"
// 2) Without pending gamestate (inside ELD_OnStateSubmitted window)
static protected function KismetStartSupplyExtract ()
{
	local array<SequenceObject> Events;
	local SeqEvent_X2GameState Event;
	local WorldInfo WorldInfo;
	local Sequence GameSeq;
	local int Index;

	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	GameSeq = class'WorldInfo'.static.GetWorldInfo().GetGameSequence();

	GameSeq.FindSeqObjectsByClass(class'SeqEvent_X2GameState', true, Events);
	for (Index = 0; Index < Events.length; ++Index)
	{
		Event = SeqEvent_X2GameState(Events[Index]);

		if (Event == none) continue;
		if (Event.EventName != 'UMS_XCOMFirstLossOfConcealment') continue;
		if (Event.GetPackageName() != 'Obj_SupplyExtraction_CI') continue;

		// Correct node, FIRE
		Event.CheckActivate(WorldInfo, none);
	}
}

static function EventListenerReturn OnTacticalPlayBegun_VeryEarly (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	// Ensure that our singletons exist
	class'XComGameState_CovertInfiltrationInfo'.static.CreateInfo();
	class'XComGameState_CIReinforcementsManager'.static.CreateReinforcementsManager();

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnTacticalPlayBegun_VeryLate (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: OnTacticalPlayBegun_VeryLate");

	// We want to do this very late, since some mods spawn units in OnTacticalBeginPlay and we want to account for them
	class'X2Helper_Infiltration'.static.SetStartingEnemiesForXp(NewGameState);

	`SubmitGameState(NewGameState);
	
	// If supply extract, show tutorial
	if (`TACTICALMISSIONMGR.ActiveMission.sType == "SupplyExtraction")
	{
		class'UIUtilities_InfiltrationTutorial'.static.SupplyExtractMission();
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn XpKillShot (Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit KillerState, VictimState, UnitState;
	local float XpMult, OriginalKillXp, OriginalBonusKillXP;
	local XComGameState_HeadquartersXCom XComHQ;
	local XpEventData XpEventData;

	XpEventData = XpEventData(EventData);
	if (XpEventData == none) return ELR_NoInterrupt;

	KillerState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(XpEventData.XpEarner.ObjectID));
	VictimState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(XpEventData.EventTarget.ObjectID));
	if (KillerState == none || VictimState == none) return ELR_NoInterrupt;

	`CI_Trace("Processing kill XP granted by" @ VictimState.GetFullName() @ "to" @ KillerState.GetFullName());

	// First record the kill - it's needed for GetKillContributionMultiplerForKill
	class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState)
		.RecordCharacterGroupsKill(VictimState.GetMyTemplate().CharacterGroupName);

	XpMult = class'X2Helper_Infiltration'.static.GetKillContributionMultiplerForKill(VictimState.GetMyTemplate().CharacterGroupName);
	XComHQ = `XCOMHQ;

	// Save the original values, we will need them quite a bit
	OriginalKillXp = VictimState.GetMyTemplate().KillContribution;
	OriginalBonusKillXP = XComHQ != none ? XComHQ.BonusKillXP : 0.0;

	`CI_Trace("XpMult=" $ XpMult $ ", OriginalKillXp=" $ OriginalKillXp $ ", OriginalBonusKillXP=" $ OriginalBonusKillXP);

	// Undo the original values
	KillerState.KillCount -= OriginalKillXp;
	KillerState.BonusKills -= OriginalBonusKillXP;

	// Apply the new (scaled) values
	KillerState.KillCount += OriginalKillXp * XpMult;
	KillerState.BonusKills += OriginalBonusKillXP * XpMult;

	// Special handling for Wet Work GTS bonus
	// In theory, this code should never be reached as this was removed in WOTC
	// However, the code is still there, and can very easily reenabled by a mod
	// As such, we would like to handle this case as well
	if (XComHQ != none && XComHQ.SoldierUnlockTemplates.Find('WetWorkUnlock') != INDEX_NONE)
	{
		// Unapply the wetwork kill
		KillerState.WetWorkKills--;

		// Apply the bonus as BonusKills (WOTC's replacement for WetWorkKills)
		KillerState.BonusKills += class'X2ExperienceConfig'.default.NumKillsBonus * XpMult;
	}

	// Adjust kill assists as well
	foreach NewGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if (UnitState != KillerState && UnitState.ControllingPlayer.ObjectID == KillerState.ControllingPlayer.ObjectID && UnitState.CanEarnXp() && UnitState.IsAlive())
		{
			UnitState.KillAssistsCount -= OriginalKillXp;
			UnitState.KillAssistsCount += OriginalKillXp * XpMult;

			`CI_Trace("Adjusted kill assist for" @ UnitState.GetFullName());
		}
	}

	`CI_Trace("Finished processing kill XP");

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn PostAliensSpawned (Object EventData, Object EventSource, XComGameState StartGameState, Name Event, Object CallbackData)
{
	if (`TACTICALMISSIONMGR.ActiveMission.sType == "CovertEscape")
	{
		`CI_Log("CovertEscape PostAliensSpawned ClearPendingLootFromAllUnits");
		ClearPendingLootFromAllUnits(StartGameState);
	}

	return ELR_NoInterrupt;
}

static protected function ClearPendingLootFromAllUnits (XComGameState StartGameState)
{
	local XComGameState_Unit UnitState;
	local LootResults EmptyLootResults;
	local StateObjectReference ItemRef;
	local bool bHasLoot;

	EmptyLootResults.bRolledForLoot = true;

	foreach StartGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		bHasLoot = false;

		if (UnitState.PendingLoot.LootToBeCreated.Length > 0)
		{
			bHasLoot = true;
		}
		
		if (UnitState.PendingLoot.AvailableLoot.Length > 0)
		{
			bHasLoot = true;

			foreach UnitState.PendingLoot.AvailableLoot(ItemRef)
			{
				// Let's hope this is actually a fresh item and not something else...
				StartGameState.RemoveStateObject(ItemRef.ObjectID);

				`CI_Trace("Removed loot" @ ItemRef.ObjectID @ "carried by" @ UnitState.ObjectID @ UnitState.GetMyTemplateName() @ UnitState.GetFullName());
			}
		}

		if (bHasLoot)
		{
			UnitState.SetLoot(EmptyLootResults);

			`CI_Trace("Cleared pending loot from" @ UnitState.ObjectID @ UnitState.GetMyTemplateName() @ UnitState.GetFullName());
		}
	}
}

static protected function EventListenerReturn KismetGameStateMatinee_PreSupplyExtract (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	TrySetSupplyExtractorATTVisibility(true, GameState);
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn KismetGameStateMatinee_PostSupplyExtract (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	TrySetSupplyExtractorATTVisibility(false, GameState);
	return ELR_NoInterrupt;
}

static protected function TrySetSupplyExtractorATTVisibility (bool bNewVisible, XComGameState GameState)
{
	local XComGameStateContext_Kismet KismetContext;
	local SeqAct_PlayGameStateMatinee Trigger;
	local SkeletalMeshActor MeshActor;

	// Check that we are in the correct mission type
	if (`TACTICALMISSIONMGR.ActiveMission.sType != "SupplyExtraction") return;

	KismetContext = XComGameStateContext_Kismet(GameState.GetContext());
	if (KismetContext == none) return;

	Trigger = SeqAct_PlayGameStateMatinee(KismetContext.FindSequenceOp());
	if (Trigger == none) return;

	// Check that it's the correct matinee
	if (Trigger.MatineeComment != "CIN_SupplyExtraction_ATTArrives") return;

	// Find the ATT actor
	foreach `XWORLDINFO.AllActors(class'SkeletalMeshActor', MeshActor)
	{
		if (
			MeshActor.GetPackageName() == 'CIN_XP_SupplyExtractionATTArrival' &&
			PathName(MeshActor.SkeletalMeshComponent.SkeletalMesh) == "TroopTransport_ANIM.Meshes.SM_TroopTransport"
		)
		{
			MeshActor.SetHidden(!bNewVisible);
			break;
		}
	}
}
