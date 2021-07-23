//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf and Xymanek
//  PURPOSE: This class is used for various hooks and to add commands to game's
//           debug console
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_CovertInfiltration extends X2DownloadableContentInfo;

struct ArmorUtilitySlotsModifier
{
	var name ArmorTemplate;
	var int Mod;
};

var config(Engine) bool SuppressTraceLogs;

var config MissionIntroDefinition InfiltrationMissionIntroDefinition;
var config(GameCore) array<ArmorUtilitySlotsModifier> ArmorUtilitySlotsMods;

// Cheats

var name ForcedNextEnviromentalSitrep;

// Internal "config"

var const array<name> HQInventoryStatesToEnlistIntoTactical;

`include(CovertInfiltration\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

//////////////////////////////////
/// Vanilla DLCInfo misc hooks ///
//////////////////////////////////

static event UpdateDLC ()
{
	class'XComGameState_ActivityChainSpawner'.static.Update();
	class'XComGameState_CovertActionExpirationManager'.static.Update();
	UpdateRemoveCovertActions();
	UpdateShowTutorial();
	TryClearRulerOnCurrentMission();
}

static function UpdateRemoveCovertActions ()
{
	local XComGameState NewGameState;
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState_CovertAction ActionState;
	local StateObjectReference ActionRef;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();

	if (CIInfo == none) return;
	
	if (CIInfo.CovertActionsToRemove.Length <= 0  || class'X2Helper_Infiltration'.static.GeoscapeReadyForUpdate() == false) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Removing Flagged Covert Actions");
	CIInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', CIInfo.ObjectID));

	foreach CIInfo.CovertActionsToRemove(ActionRef)
	{
		ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionRef.ObjectID));
		if (ActionState != none && ActionState.bCompleted == false)
		{
			if (ActionState.bStarted)
			{
				ActionState.bCompleted = true;
				ActionState.CompleteCovertAction(NewGameState);
			}
			else
			{
				ActionState.RemoveEntity(NewGameState);
			}
		}
	}
	
	CIInfo.CovertActionsToRemove.Length = 0;

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

static protected function UpdateShowTutorial ()
{
	local XComHQPresentationLayer HQPres;
	local XComGameState NewGameState;

	HQPres = `HQPRES;
	
	if (HQPres.StrategyMap2D != none && HQPres.StrategyMap2D.m_eUIState != eSMS_Flight && HQPres.ScreenStack.GetCurrentScreen() == HQPres.StrategyMap2D)
	{
		class'UIUtilities_InfiltrationTutorial'.static.GeoscapeEntry();
	}

	if (
		class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bAlienFacilityBuiltTutorialPending &&
		
		// Do the same check again, as the previous tutorial could have been shown
		(HQPres.StrategyMap2D != none && HQPres.StrategyMap2D.m_eUIState != eSMS_Flight && HQPres.ScreenStack.GetCurrentScreen() == HQPres.StrategyMap2D)
	)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Turn off bAlienFacilityBuiltTutorialPending");
		class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState).bAlienFacilityBuiltTutorialPending = false;
		`SubmitGameState(NewGameState);

		class'UIUtilities_InfiltrationTutorial'.static.AlienFacilityBuilt();
	}
}

static protected function TryClearRulerOnCurrentMission ()
{
	// DLC2's ruler tracking system assumes that the flow of the game is
	// mission generated -> player goes on mission -> mission generated -> player goes -> etc.
	// While there are a few safeguards that prevent complete mess on missions such as strongholds,
	// these are not enough to gurantee reliable behaviour when there are multiple missions in progress
	// or there are multiple assault missions (**which can have rulers**) avaliable at the same time.
	// As such, we simply clear the tracker when the player returns to the geoscape (not flying to a mission)
	// Note that the call is no-op if no RulerOnCurrentMission is set, so it's safe to call every frame
	if (class'X2Helper_Infiltration'.static.IsDLCLoaded('DLC_2') && class'X2Helper_Infiltration'.static.GeoscapeReadyForUpdate())
	{
		class'X2Helper_Infiltration_DLC2'.static.ClearRulerOnCurrentMission();
	}
}

static function bool ShouldUpdateMissionSpawningInfo (StateObjectReference MissionRef)
{
	// This is a very ugly hack, but it helps with many issues that arise due to difference in behaviour
	// between having the shadow chamber and not (WHY FXS?????). Particularly related to DLC2
	return true;
}

///////////////////////
/// Loaded/new game ///
///////////////////////

static event InstallNewCampaign(XComGameState StartState)
{
	class'XComGameState_CovertInfiltrationInfo'.static.CreateInfo(StartState);
	class'XComGameState_ActivityChainSpawner'.static.CreateSpawner(StartState);
	class'XComGameState_CovertActionExpirationManager'.static.CreateExpirationManager(StartState);
	
	CreateGoldenPathActions(StartState);
	ForceObjectivesCompleted(StartState);
	CreateActionableLeadResourceState(StartState);
	AddGatecrasherRewards(StartState);
	ForceCloseBlackMarket(StartState);

	PatchDebugStart(StartState);
}

static event OnLoadedSavedGame()
{
	class'XComGameState_CovertInfiltrationInfo'.static.CreateInfo();
	class'XComGameState_ActivityChainSpawner'.static.CreateSpawner();
	class'XComGameState_CovertActionExpirationManager'.static.CreateExpirationManager();

	CreateGoldenPathActions(none);
	ForceObjectivesCompleted(none);
	CreateActionableLeadResourceState(none);
}

static protected function CreateGoldenPathActions(XComGameState NewGameState)
{
	local XComGameState_ResistanceFaction FactionState;
	local bool bSubmitLocally;

	if (NewGameState == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating Golden Path actions");
		bSubmitLocally = true;

		// Add all factions to the new state
		foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
		{
			NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID);
		}
	}

	foreach NewGameState.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		FactionState.CreateGoldenPathActions(NewGameState);
	}

	if (bSubmitLocally)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

static function ForceObjectivesCompleted (XComGameState NewGameState)
{
	local bool bSubmitLocally;

	if (NewGameState == none)
	{
		bSubmitLocally = true;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Disabling Covert Action Tutorial");
	}

	class'XComGameState_Objective'.static.CompleteObjectiveByName(NewGameState, 'XP2_M0_FirstCovertActionTutorial');
	class'XComGameState_Objective'.static.CompleteObjectiveByName(NewGameState, 'XP2_M1_SecondCovertActionTutorial');
	class'XComGameState_Objective'.static.CompleteObjectiveByName(NewGameState, 'T2_M0_CompleteGuerillaOps');
	
	if(bSubmitLocally)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

static function AddGatecrasherRewards (XComGameState StartState)
{
	local X2StrategyElementTemplateManager StratMgr;
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;

	`CI_Trace("Adjusting Gatecrasher");

	foreach StartState.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if (MissionState.Source == 'MissionSource_Start')
		{
			break;
		}
	}

	if (MissionState == none)
	{
		`RedScreen("Failed to find existing Gatecrasher");
		return;
	}
	
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RegionState = MissionState.GetWorldRegion();

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Engineer'));
	RewardState = RewardTemplate.CreateInstanceFromTemplate(StartState);
	RewardState.GenerateReward(StartState, 1.0, RegionState.GetReference());
	AddTacticalTagToRewardUnit(StartState, RewardState, 'Prisoner_00');
	MissionState.Rewards.AddItem(RewardState.GetReference());
	
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Scientist'));
	RewardState = RewardTemplate.CreateInstanceFromTemplate(StartState);
	RewardState.GenerateReward(StartState, 1.0, RegionState.GetReference());
	AddTacticalTagToRewardUnit(StartState, RewardState, 'Prisoner_01');
	MissionState.Rewards.AddItem(RewardState.GetReference());

	PopulatePureTacticalRewardDeck();

	`CI_Trace("Gatecrasher adjusted!");
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

static function PopulatePureTacticalRewardDeck ()
{
	local X2CardManager CardManager;
	local X2DataTemplate DataTemplate;
	local X2HackRewardTemplateManager HackRewardTemplateManager;
	local X2HackRewardTemplate HackRewardTemplate;

	CardManager = class'X2CardManager'.static.GetCardManager();

	HackRewardTemplateManager = class'X2HackRewardTemplateManager'.static.GetHackRewardTemplateManager();

	foreach HackRewardTemplateManager.IterateTemplates(DataTemplate, None)
	{
		HackRewardTemplate = X2HackRewardTemplate(DataTemplate);

		if( HackRewardTemplate.bIsNegativeTacticalReward && !HackRewardTemplate.bIsNegativeStrategyReward )
		{
			CardManager.AddCardToDeck('NegativePureTacticalHackRewards', string(HackRewardTemplate.DataName));
		}

		if( HackRewardTemplate.bIsTier1Reward || HackRewardTemplate.bIsTier2Reward )
		{
			if( HackRewardTemplate.bIsTacticalReward && !HackRewardTemplate.bIsStrategyReward )
			{
				CardManager.AddCardToDeck('PureTacticalHackRewards', string(HackRewardTemplate.DataName));
			}
		}
	}
}

static protected function CreateActionableLeadResourceState (XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateMgr;
	local XComGameState_Item NewItemState;
	local X2ItemTemplate ItemTemplate;
	local bool bSubmitLocally;

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemTemplateMgr.FindItemTemplate('ActionableFacilityLead');

	if (NewGameState == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating Actionable Leads resource state");
		bSubmitLocally = true;
	}

	NewItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
	NewItemState.Quantity = 0;

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
	XComHQ.AddItemToHQInventory(NewItemState);

	if (bSubmitLocally)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

static protected function ForceCloseBlackMarket (XComGameState StartState)
{
	local XComGameState_BlackMarket BlackMarketState;
	BlackMarketState = XComGameState_BlackMarket(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BlackMarket'));
	BlackMarketState = XComGameState_BlackMarket(StartState.ModifyStateObject(class'XComGameState_BlackMarket', BlackMarketState.ObjectID));
	BlackMarketState.ForceCloseBlackMarket(StartState);
}

static protected function PatchDebugStart (XComGameState StartState)
{
	local UIShellStrategy DevStrategyShell;

	// Avoid warnings when creating state for the shell
	if (`SCREENSTACK == none) return;

	// We can't check XComGameState_CampaignSettings as we are called before the values there are set
	DevStrategyShell = UIShellStrategy(`SCREENSTACK.GetFirstInstanceOf(class'UIShellStrategy'));
	if (DevStrategyShell == none) return;

	if (DevStrategyShell.m_bCheatStart)
	{
		ForceAllFactionsMet(StartState);
	}
}

static protected function ForceAllFactionsMet (XComGameState StartState)
{
	local XComGameState_ResistanceFaction FactionState;
	
	foreach StartState.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (!FactionState.bMetXCom)
		{
			FactionState.MeetXCom(StartState);
			FactionState.bSeenFactionHQReveal = true;
		}
	}
}

static function OnLoadedSavedGameWithDLCExisting ()
{
	ModVersion_OnLoadedSavedGameWithDLCExisting();
}

static event OnLoadedSavedGameToStrategy ()
{
	ModVersion_FinalizeStrategy();
}

///////////////////
/// Mod version ///
///////////////////

// This is called right after the history is deserialized so it's the perfect place to adjust the state.
// However, we might be in tactical so not all state objects will be visible in the history - fix
// those in later events/hooks (referencing CIInfo.StrategyModVersion instead) and
// ModVersion_OnPostMission will record the new strategy/final version
static protected function ModVersion_OnLoadedSavedGameWithDLCExisting ()
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();

	// Do nothing if we are adding the mod to an existing campaign (why is this called???) or if we already updated the state
	if (CIInfo == none || CIInfo.ModVersion >= class'XComGameState_CovertInfiltrationInfo'.const.CURRENT_MOD_VERSION) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating CI state from" @ CIInfo.ModVersion @ "to" @ class'XComGameState_CovertInfiltrationInfo'.const.CURRENT_MOD_VERSION);

	// State fix-up changes go here
	`CI_Log("ModVersion_OnLoadedSavedGameWithDLCExisting running");

	// Save that the state was updated.
	// Do this last, so that the state update code can access the previous version
	CIInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', CIInfo.ObjectID));
	CIInfo.ModVersion = class'XComGameState_CovertInfiltrationInfo'.const.CURRENT_MOD_VERSION;

	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}

// Any fixes that reference CIInfo.StrategyModVersion should also be called here to account for cases when 
// the update was while the save was in strategy
static protected function ModVersion_FinalizeStrategy ()
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();

	// Do nothing if we already updated the state
	if (CIInfo.StrategyModVersion >= class'XComGameState_CovertInfiltrationInfo'.const.CURRENT_MOD_VERSION) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Finalizing CI strategy state update from" @ CIInfo.StrategyModVersion @ "to" @ class'XComGameState_CovertInfiltrationInfo'.const.CURRENT_MOD_VERSION);

	// Final state fix-up changes go here
	`CI_Log("ModVersion_FinalizeStrategy running");

	// Save that the state was updated.
	// Do this last, so that the state update code can access the previous version
	CIInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', CIInfo.ObjectID));
	CIInfo.StrategyModVersion = class'XComGameState_CovertInfiltrationInfo'.const.CURRENT_MOD_VERSION;

	`SubmitGameState(NewGameState);
}

/////////////////
/// Templates ///
/////////////////

static function OnPreCreateTemplates()
{
	// This must be the very first thing called in the mod code
	class'UIListener_ModConfigMenu'.static.TryTransfer();

	if (`GETMCMVAR(ENABLE_TRACE_STARTUP))
	{
		GetCDO().SuppressTraceLogs = false;
	}

	class'XComGameState_MissionSiteInfiltration'.static.ValidateConfig();
	class'X2Helper_Infiltration'.static.ValidateXpMultiplers();
}

static event OnPostTemplatesCreated()
{
	class'X2Helper_Infiltration_TemplateMod'.static.PatchResistanceRing();
	class'X2Helper_Infiltration_TemplateMod'.static.RemoveNoCovertActionNags();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchRetailationMissionSource();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchNewRetaliationNarrative();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchQuestItems();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchStartMissionSource();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchAlienNetworkMissionSource();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchSabotageMonumentMissionSchedules();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchMissionDefinitions();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchSabotageMissionNarrative();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchItemStats();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchFacilityLeadPOI();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchFacilityLeadItem();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchFacilityLeadReward();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchFacilityLeadResearch();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchGuerillaTacticsSchool();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchAcademyStaffSlot();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchCovertActionPromotionRewards();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchDoomRemovalCovertAction();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchUniqueCovertActions();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchResourceGatheringCovertActions();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchGoldenPath();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchChosenObjectives();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchLivingQuarters();
	class'X2Helper_Infiltration_TemplateMod'.static.RemoveSabotages();
	class'X2Helper_Infiltration_TemplateMod'.static.RemovePointsOfInterest();
	class'X2Helper_Infiltration_TemplateMod'.static.RemoveFactionCards();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchLiveFireTraining();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchHangar();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchEvacAbility();
}

///////////
/// Loc ///
///////////

static function bool AbilityTagExpandHandler (string InString, out string OutString)
{
	if (InString == "MENTAL_READINESS_VALUE")
	{
		OutString = string(class'X2Ability_SitRepAbilitySet_CI'.default.MENTAL_READINESS_VALUE);
		return true;
	}

	if (InString == "UPDATED_FIREWALLS_HACK_DEFENSE_BONUS")
	{
		OutString = string(class'X2Ability_SitRepAbilitySet_CI'.default.UPDATED_FIREWALLS_HACK_DEFENSE_BONUS);
		return true;
	}

	if (InString == "FOXHOLES_MOBILITY")
	{
		OutString = string(class'X2Ability_SitRepAbilitySet_CI'.default.FOXHOLES_MOBILITY);
		return true;
	}

	if (InString == "FOXHOLES_DEFENSE")
	{
		OutString = string(class'X2Ability_SitRepAbilitySet_CI'.default.FOXHOLES_DEFENSE);
		return true;
	}
	
	if (InString == "LIGHTNINGSTRIKEDURATIONACTUAL")
	{
		OutString = string(class'X2Ability_OfficerTrainingSchool'.default.LIGHTNING_STRIKE_NUM_TURNS);
		return true;
	}

	if (InString == "OPPORTUNE_MOMENT_1_CRIT_BONUS")
	{
		OutString = string(class'X2Ability_SitRepAbilitySet_CI'.default.OPPORTUNE_MOMENT_1_CRIT_BONUS);
		return true;
	}

	if (InString == "OPPORTUNE_MOMENT_1_DETECTION_MODIFIER")
	{
		OutString = string(int(class'X2Ability_SitRepAbilitySet_CI'.default.OPPORTUNE_MOMENT_1_DETECTION_MODIFIER * 100));
		return true;
	}

	if (InString == "OPPORTUNE_MOMENT_2_CRIT_BONUS")
	{
		OutString = string(class'X2Ability_SitRepAbilitySet_CI'.default.OPPORTUNE_MOMENT_2_CRIT_BONUS);
		return true;
	}

	if (InString == "OPPORTUNE_MOMENT_2_DETECTION_MODIFIER")
	{
		OutString = string(int(class'X2Ability_SitRepAbilitySet_CI'.default.OPPORTUNE_MOMENT_2_DETECTION_MODIFIER * 100));
		return true;
	}

	if (InString == "MESSYINSERTION_WILLLOSS")
	{
		OutString = string(int(class'X2SitRep_InfiltrationSitRepEffects'.default.MESSYINSERTION_WILLLOSS * 100));
		return true;
	}

	if (InString == "MESSYINSERTION_HEALTHLOSS")
	{
		OutString = string(int(class'X2SitRep_InfiltrationSitRepEffects'.default.MESSYINSERTION_HEALTHLOSS * 100));
		return true;
	}
	
	if (InString == "EXPERIMENTALROLLOUT_CRITMODIFIER")
	{
		OutString = string(class'X2Ability_SitRepAbilitySet_CI'.default.EXPERIMENTALROLLOUT_CRITMODIFIER * -1);
		return true;
	}

	if (InString == "EXPERIMENTALROLLOUT_EXPLOSIVEDAMAGE")
	{
		OutString = string(int(class'X2Ability_SitRepAbilitySet_CI'.default.EXPERIMENTALROLLOUT_EXPLOSIVEDAMAGE * 100));
		return true;
	}

	return false;
}

////////////////////////////
/// Mission start/finish ///
////////////////////////////

static event OnPreMission (XComGameState StartGameState, XComGameState_MissionSite MissionState)
{
	TryEnlistChainStateIntoTactical(StartGameState, MissionState);
	EnlistHQInventoryStatesToEnlistIntoTactical(StartGameState);
	class'XComGameState_CovertInfiltrationInfo'.static.ResetPreMission(StartGameState);

	OnPreMission_Activity(StartGameState, MissionState);
}

// Small explanation: the strategy states are archived before the tactical start state and are normally inaccesible in tactical.
// However, there are cases when we do need the current chain/activity in tactical.
// In particular Pyrrhic Victories mod calls the WasMissionSuccessfulFn on the mission source while in tactical, which is
// proxied to the activity template in our case. However, the proxying relies on the activity state (which is normally missing in tactical).
// Additionally, the chain/activity logic often looks at other "parts" of the chain, so we copy over all the "parts"
// in order to avoid accidentally introducing subtle bugs.
static protected function TryEnlistChainStateIntoTactical (XComGameState StartGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_Complication ComplicationState;
	local XComGameState_ActivityChain ChainState;
	local XComGameState_Activity ActivityState;
	local StateObjectReference StateRef;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromObject(MissionState);
	
	if (ActivityState == none)
	{
		`CI_Trace("Mission not associated with an activity, skipping enlisting states into tactical");
		return;
	}

	`CI_Trace("Enlisting chain (and related states) into tactical start state");

	// Chain itself
	ChainState = XComGameState_ActivityChain(StartGameState.ModifyStateObject(class'XComGameState_ActivityChain', ActivityState.ChainRef.ObjectID));

	// Activities
	foreach ChainState.StageRefs(StateRef)
	{
		StartGameState.ModifyStateObject(class'XComGameState_Activity', StateRef.ObjectID);
	}

	// Complications
	foreach ChainState.ComplicationRefs(StateRef)
	{
		StartGameState.ModifyStateObject(class'XComGameState_Complication', StateRef.ObjectID);
	}

	// Now that the states are enlisted, allow templates to enlist other states as they need

	ChainState.OnEnlistStateIntoTactical(StartGameState);

	foreach ChainState.StageRefs(StateRef)
	{
		ActivityState = XComGameState_Activity(StartGameState.GetGameStateForObjectID(StateRef.ObjectID));
		ActivityState.OnEnlistStateIntoTactical(StartGameState);
	}

	foreach ChainState.ComplicationRefs(StateRef)
	{
		ComplicationState = XComGameState_Complication(StartGameState.GetGameStateForObjectID(StateRef.ObjectID));
		ComplicationState.OnEnlistStateIntoTactical(StartGameState);
	}
}

// Similar thing as the previous method.
// See defaultproperties for specific examples.
static protected function EnlistHQInventoryStatesToEnlistIntoTactical (XComGameState StartGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;
    local XComGameState_Item ItemState;
	local StateObjectReference ItemRef;
    local XComGameStateHistory History;

	History = `XCOMHISTORY;

	foreach StartGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	foreach XComHQ.Inventory(ItemRef)
	{
		 ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));

		 if (ItemState != none && default.HQInventoryStatesToEnlistIntoTactical.Find(ItemState.GetMyTemplateName()) != INDEX_NONE)
		 {
			StartGameState.ModifyStateObject(class'XComGameState_Item', ItemRef.ObjectID);
		 }
	}
}

static protected function OnPreMission_Activity (XComGameState StartGameState, XComGameState_MissionSite MissionState)
{
	local X2ActivityTemplate_Mission MissionActivityTemplate;
	local XComGameState_Activity ActivityState;

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromObject(MissionState);
	if (ActivityState == none) return;

	MissionActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	if (MissionActivityTemplate == none)
	{
		`CI_Log("ERROR: Launching into an activity-associated mission, but the activity doesn't use X2ActivityTemplate_Mission???");
		return;
	}

	if (MissionActivityTemplate.OnPreMission != none)
	{
		MissionActivityTemplate.OnPreMission(StartGameState, ActivityState);
	}
}

static event OnPostMission ()
{
	ResetInfiltrationChosenRoll();
	TriggerMissionExitEvents();
	HandleFacilityMissionExit();
	PostChosenStronghold();
	ResetUnitsStartedMissionBelowReadyWill();

	class'XComGameState_ActivityChain'.static.RemoveEndedChains();

	ModVersion_FinalizeStrategy();
}

static protected function ResetInfiltrationChosenRoll ()
{
	local XComGameState_MissionSiteInfiltration Infiltration;
	local XComGameState_BattleData BattleData;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: ResetInfiltrationChosenRoll");
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	foreach History.IterateByClassType(class'XComGameState_MissionSiteInfiltration', Infiltration)
	{
		// Do not touch the mission on which we just went
		if (Infiltration.ObjectID == BattleData.m_iMissionID) continue;
		
		Infiltration = XComGameState_MissionSiteInfiltration(NewGameState.ModifyStateObject(class'XComGameState_MissionSiteInfiltration', Infiltration.ObjectID));
		Infiltration.ResetChosenRollAfterAnotherMission();
	}

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

static protected function TriggerMissionExitEvents ()
{
	local XComGameState_MissionSite MissionState;
	local XComGameState_BattleData BattleData;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local bool bSubmit;

	History = `XCOMHISTORY;
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Trigger mission exit events");
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));

	if (MissionState.ResistanceFaction.ObjectID == 0)
	{
		`XEVENTMGR.TriggerEvent('NonFactionMissionExit', , , NewGameState);
		bSubmit = true;
	}

	if (bSubmit)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

static protected function HandleFacilityMissionExit ()
{
	local XComGameState_MissionSite MissionState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_BattleData BattleData;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local string strEffect;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));

	// Do nothing if we came back from some other mission
	if (MissionState.Source != 'MissionSource_AlienNetwork') return;

	// Do nothing is this was attempt did not use a lead
	if (!class'X2Helper_Infiltration'.static.DoesFacilityRequireLead(MissionState)) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: HandleFacilityMissionExit");

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
	XComHQ.AddResource(NewGameState, 'ActionableFacilityLead', -1);
	// No need to call X2Helper_Infiltration::UpdateFacilityMissionLocks() here - it will be called by the AddResource event

	// Save our changes cuz otherwise XComHQ.GetResourceAmount will return the old value
	`SubmitGameState(NewGameState);
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: HandleFacilityMissionExit 2");

	strEffect = XComHQ.GetResourceAmount('ActionableFacilityLead') > 0
		? class'UIUtilities_Infiltration'.default.strActionableLeadUsed
		: class'UIUtilities_Infiltration'.default.strLastActionableLeadUsed;

	class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, strEffect, true);

	`SubmitGameState(NewGameState);
}

static protected function PostChosenStronghold ()
{
	local XComGameStateHistory History;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionState;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));

	`CI_Trace("DisableChosenSurveillance called");

	// Do nothing if we came back from some other mission
	if (MissionState.Source != 'MissionSource_ChosenStronghold') return;
	
	DisableChosenSurveillance();
}

static protected function ResetUnitsStartedMissionBelowReadyWill ()
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: ResetUnitsStartedMissionBelowReadyWill");
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
	
	CIInfo.ResetUnitsStartedMissionBelowReadyWill();

	`SubmitGameState(NewGameState);
}

static event OnExitPostMissionSequence ()
{
	PostMissionUpgradeItems();

	OnExitPostMissionSequence_Complications();
	OnExitPostMissionSequence_Activity();
}

static function PostMissionUpgradeItems ()
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState_Unit UnitState;
	local StateObjectReference UnitRef;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	if (CIInfo.UnitsToConsiderUpgradingGearOnMissionExit.Length == 0) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: PostMissionUpgradeItems");
	History = `XCOMHISTORY;
	
	CIInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', CIInfo.ObjectID));

	foreach CIInfo.UnitsToConsiderUpgradingGearOnMissionExit(UnitRef)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
		if (UnitState == none) continue;

		class'X2StrategyElement_XpackStaffSlots'.static.CheckToUpgradeItems(NewGameState, UnitState);
	}

	CIInfo.UnitsToConsiderUpgradingGearOnMissionExit.Length = 0;
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

static protected function OnExitPostMissionSequence_Complications ()
{
	local XComGameState_Complication ComplicationState;
	local XComGameState_ActivityChain ChainState;
	local XComGameState_Activity ActivityState;
	local XComGameState_BattleData BattleData;
	local StateObjectReference StateRef;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromObjectID(BattleData.m_iMissionID);
	if (ActivityState == none) return;

	ChainState = ActivityState.GetActivityChain();
	foreach ChainState.ComplicationRefs(StateRef)
	{
		ComplicationState = XComGameState_Complication(History.GetGameStateForObjectID(StateRef.ObjectID));
		ComplicationState.OnExitPostMissionSequence();
	}
}

static protected function OnExitPostMissionSequence_Activity ()
{
	local X2ActivityTemplate_Mission MissionActivityTemplate;
	local XComGameState_Activity ActivityState;
	local XComGameState_BattleData BattleData;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	ActivityState = class'XComGameState_Activity'.static.GetActivityFromObjectID(BattleData.m_iMissionID);
	if (ActivityState == none) return;

	MissionActivityTemplate = X2ActivityTemplate_Mission(ActivityState.GetMyTemplate());
	if (MissionActivityTemplate == none)
	{
		`CI_Log("ERROR: OnExitPostMissionSequence_Activity: the activity doesn't use X2ActivityTemplate_Mission???");
		return;
	}

	if (MissionActivityTemplate.OnExitPostMissionSequence != none)
	{
		MissionActivityTemplate.OnExitPostMissionSequence(ActivityState);
	}
}

static function bool DisplayQueuedDynamicPopup (DynamicPropertySet PropertySet)
{
	if (PropertySet.PrimaryRoutingKey == 'UIAlert_CovertInfiltration')
	{
		CallUIAlert_CovertInfiltration(PropertySet);
		return true;
	}

	return false;
}

static protected function CallUIAlert_CovertInfiltration (const out DynamicPropertySet PropertySet)
{
	local UIAlert_CovertInfiltration Alert;
	local XComPresentationLayerBase Pres;

	Pres = `PRESBASE;

	Alert = Pres.Spawn(class'UIAlert_CovertInfiltration', Pres);
	Alert.DisplayPropertySet = PropertySet;
	Alert.eAlertName = PropertySet.SecondaryRoutingKey;

	Pres.ScreenStack.Push(Alert);
}

/// ////////////// ///
/// DLC (HL) HOOKS ///
/// ////////////// ///

/// <summary>
/// Called from X2TacticalGameRuleset:state'CreateTacticalGame':UpdateTransitionMap / 
/// XComPlayerController:SetupDropshipMatinee for both PreMission/PostMission.
/// You may fill out the `OverrideMapName` parameter to override the transition map.
/// If `UnitState != none`, return whether this unit should have cosmetic attachments (gear) on the transition map.
/// </summary>
static function bool LoadingScreenOverrideTransitionMap(optional out string OverrideMapName, optional XComGameState_Unit UnitState)
{
	local XComGameStateHistory History;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionSiteState;

	// Code adapted from LW2
	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	MissionSiteState = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));

	if (XComGameState_MissionSiteInfiltration(MissionSiteState) != none)
	{
		if (`TACTICALRULES != none)
		{
			switch (MissionSiteState.GeneratedMission.Plot.strType)
			{
				case "CityCenter":
				case "Rooftops":
				case "Facility":
					OverrideMapName = "CIN_Loading_Infiltration_CityCenter";
					break;
				case "Shanty":
				case "Slums":
					OverrideMapName = "CIN_Loading_Infiltration_Slums";
					break;
				case "SmallTown":
					OverrideMapName = "CIN_Loading_Infiltration_SmallTown";
					break;
				case "Wilderness":
					OverrideMapName = "CIN_Loading_Infiltration_Wilderness";
					break;
				case "Tunnels_Sewer":
					OverrideMapName = "CIN_Loading_Infiltration_Tunnels_Sewer";
					break;
				case "Tunnels_Subway":
					OverrideMapName = "CIN_Loading_Infiltration_Tunnels_Subway";
					break;
				case "Abandoned":
					OverrideMapName = "CIN_Loading_Infiltration_Abandoned";
					break;
				case "Stronghold":
				default:
					OverrideMapName = "CIN_Loading_Infiltration_CityCenter";
					break;
			}

			// We want cosmetic attachments!
			return true;
		}
	}

	return false; 
}

/// <summary>
/// Called from XComTacticalMissionManager:GetActiveMissionIntroDefinition before it returns the Default.
/// Notable changes from LW2: Called even if the mission/plot/plot type has an override.
/// OverrideType is -1 for default, 0 for Mission override, 1 for Plot override, 2 for Plot Type override.
/// OverrideTag contains the Mission name / Plot name / Plot type, respectively
/// Return true to use.
/// </summary>
static function bool UseAlternateMissionIntroDefinition(MissionDefinition ActiveMission, int OverrideType, string OverrideTag, out MissionIntroDefinition MissionIntro)
{
	local XComGameStateHistory History;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionSiteState;

	// Code adapted from LW2
	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	MissionSiteState = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));

	// We assume that any Infiltration mission doesn't need a special intro. In particular, we assume important
	// story missions like the Network Tower, Final Mission, Chosen Base Assaults, Avenger Defense etc. can't be infiltrated.
	// This wasn't true in LW2, and needs to be changed here when we get more things to infiltrate.
	if (XComGameState_MissionSiteInfiltration(MissionSiteState) != none)
	{
		MissionIntro = default.InfiltrationMissionIntroDefinition;
		return true;
	}
	return false;
}

static function GetNumUtilitySlotsOverride (out int NumUtilitySlots, XComGameState_Item EquippedArmor, XComGameState_Unit UnitState, XComGameState CheckGameState)
{
	local int i;

	if (EquippedArmor != none)
	{
		i = default.ArmorUtilitySlotsMods.Find('ArmorTemplate', EquippedArmor.GetMyTemplateName());

		if (i != INDEX_NONE)
		{
			NumUtilitySlots += default.ArmorUtilitySlotsMods[i].Mod;
		}
	}
}

static function bool GetDLCEventInfo (out array<HQEvent> arrEvents)
{
	local bool bFound;

	bFound = GetProjectEvents(arrEvents);

	return bFound;
}

static protected function bool GetProjectEvents (out array<HQEvent> arrEvents)
{
	local XComGameState_HeadquartersProject ProjectState;
	local XComGameState_HeadquartersXCom XComHQ;
	local StateObjectReference ProjectRef;
	local XComGameStateHistory History;
	local HQEvent kEvent, kEventBlank;
	local bool bFound;

	History = `XCOMHISTORY;
	XComHQ = `XCOMHQ;

	foreach XComHQ.Projects(ProjectRef)
	{
		ProjectState = XComGameState_HeadquartersProject(History.GetGameStateForObjectID(ProjectRef.ObjectID));
		if (ProjectState == none) continue;

		// Academy training
		if (ProcessEventAcademy(ProjectState, kEvent))
		{
			bFound = true;
			arrEvents.AddItem(kEvent);
		}
		kEvent = kEventBlank;
	}

	return bFound;
}

static protected function bool ProcessEventAcademy (XComGameState_HeadquartersProject ProjectState, out HQEvent kEvent)
{
	local XComGameState_HeadquartersProjectTrainAcademy AcademyProject;
	local XComGameState_Unit UnitState;
	local string ClassName;

	AcademyProject = XComGameState_HeadquartersProjectTrainAcademy(ProjectState);
	if (AcademyProject == none) return false;

	if (!AcademyProject.PromotingFromRookie())
	{
		ClassName = class'X2Helper_Infiltration_TemplateMod'.default.strAcademyProjectStatusGTS;
	}
	else
	{
		ClassName = Caps(AcademyProject.GetNewClassTemplate().DisplayName); 
	}

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AcademyProject.ProjectFocus.ObjectID));
	kEvent.Data =  Repl(class'XComGameState_HeadquartersXCom'.default.TrainRookieEventLabel @ UnitState.GetName(eNameType_RankFull), "%CLASSNAME", ClassName);
	kEvent.Hours = AcademyProject.GetCurrentNumHoursRemaining();
	kEvent.ImagePath = class'UIUtilities_Image'.const.EventQueue_Staff;
			
	if (kEvent.Hours < 0)
	{
		kEvent.Data = class'XComGameState_HeadquartersXCom'.default.ProjectPausedLabel @ kEvent.Data;
	}

	return true;
}

static function PostEncounterCreation (out name EncounterName, out PodSpawnInfo Encounter, int ForceLevel, int AlertLevel, optional XComGameState_BaseObject SourceObject)
{
	local X2SitRepEffect_ModifyEncounter SitRepEffect;
	local XComGameState_MissionSite MissionState;

	MissionState = XComGameState_MissionSite(SourceObject);
	if (MissionState == none)
	{
		`CI_Warn("PostEncounterCreation recived SourceObject which is not instance of XComGameState_MissionSite");
		return;
	}

	foreach class'X2SitreptemplateManager'.static.IterateEffects(class'X2SitRepEffect_ModifyEncounter', SitRepEffect, MissionState.GeneratedMission.SitReps)
	{
		if (SitRepEffect.bApplyToPreplaced && SitRepEffect.ProcessEncounter != none)
		{
			SitRepEffect.ProcessEncounter(
				EncounterName, Encounter,
				ForceLevel, AlertLevel,
				MissionState, none
			);
		}
	}
}

static function PostReinforcementCreation (out name EncounterName, out PodSpawnInfo Encounter, int ForceLevel, int AlertLevel, optional XComGameState_BaseObject SourceObject, optional XComGameState_BaseObject ReinforcementState)
{
	local X2SitRepEffect_ModifyEncounter SitRepEffect;
	local XComGameState_MissionSite MissionState;
	local XComGameState_BattleData BattleData;

	BattleData = XComGameState_BattleData(SourceObject);
	MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(BattleData.m_iMissionID));

	foreach class'X2SitreptemplateManager'.static.IterateEffects(class'X2SitRepEffect_ModifyEncounter', SitRepEffect, BattleData.ActiveSitReps)
	{
		if (SitRepEffect.bApplyToReinforcement && SitRepEffect.ProcessEncounter != none)
		{
			SitRepEffect.ProcessEncounter(
				EncounterName, Encounter,
				ForceLevel, AlertLevel,
				MissionState, ReinforcementState
			);
		}
	}
}

/// //////// ///
/// COMMANDS ///
/// //////// ///

exec function GetRingModifier()
{
	local TDialogueBoxData DialogData;
	DialogData.eType = eDialog_Normal;
	DialogData.strTitle = "Resistance Ring Info:";
	DialogData.strText = "Modifier:" @ class'UIUtilities_Strategy'.static.GetResistanceHQ().CovertActionDurationModifier;
	`HQPRES.UIRaiseDialog(DialogData);
}

exec function RemoveEmptyWildcardSlot()
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersResistance NewResHQ;
	local int iEmptySlot;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Removing empty wildcard slot");
	NewResHQ = class'X2StrategyElement_StaffSlots_Infiltration'.static.GetNewResHQState(NewGameState);
	iEmptySlot = class'X2StrategyElement_StaffSlots_Infiltration'.static.FindEmptyWildcardSlot(NewResHQ);

	if (iEmptySlot > -1)
	{
		NewResHQ.WildCardSlots.Remove(iEmptySlot, 1);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		`RedScreen("Cannot remove wildcard slot - no empty slots found");
		`XCOMHISTORY.CleanupPendingGamestate(NewGameState);
	}
}

exec function SpawnCovertAction(name TemplateName, optional name FactionTemplateName = '')
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	local XComGameState_ResistanceFaction FactionState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2CovertActionTemplate ActionTemplate;
	local array<name> ActionExclusionList;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(StratMgr.FindStrategyElementTemplate(TemplateName));

	if (ActionTemplate == none)
	{
		`REDSCREEN("Cannot execute SpawnCovertAction cheat - invalid template name");
		return;
	}

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: CreateCovertAction" @ TemplateName);

	// Find first faction
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionTemplateName == '' || FactionState.GetMyTemplateName() == FactionTemplateName)
		{
			FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
			break;
		}
	}

	if (FactionState == none)
	{
		`REDSCREEN("Cannot execute SpawnCovertAction cheat - invalid faction template name");
		History.CleanupPendingGameState(NewGameState);
	}
	else
	{
		FactionState.AddCovertAction(NewGameState, ActionTemplate, ActionExclusionList);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

exec function PrintChainSpawnerDebugInfo()
{
	class'XComGameState_ActivityChainSpawner'.static.PrintDebugInfo();
}

exec function SpawnNextActivityChain ()
{
	local XComGameState_ActivityChainSpawner Spawner;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: SpawnNextActivityChain");
	Spawner = class'XComGameState_ActivityChainSpawner'.static.GetSpawner();
	Spawner = XComGameState_ActivityChainSpawner(NewGameState.ModifyStateObject(class'XComGameState_ActivityChainSpawner', Spawner.ObjectID));

	Spawner.SpawnActivityChain(NewGameState);
	Spawner.ResetProgress();
	Spawner.SetNextSpawnAt();

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

exec function ClearOverInfiltrationBonusesDeck()
{
	local X2CardManager CardManager;
	local array<string> CardLabels;
	local string Card;

	CardManager = class'X2CardManager'.static.GetCardManager();
	CardManager.GetAllCardsInDeck('OverInfiltrationBonuses', CardLabels);

	foreach CardLabels(Card)
	{
		CardManager.RemoveCardFromDeck('OverInfiltrationBonuses', Card);
	}
}

exec function SpawnActivityChain (name ChainTemplateName, int StartAtStage = 0)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_ActivityChain ChainState;
	local X2ActivityChainTemplate ChainTemplate;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: SpawnActivityChain" @ ChainTemplateName);
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate(ChainTemplateName));

	`CI_Trace("Starting cheat: SpawnActivityChain" @ ChainTemplateName);

	ChainState = ChainTemplate.CreateInstanceFromTemplate(NewGameState);
	ChainState.HACK_SetCurrentStage(StartAtStage - 1);
	ChainState.HACK_SetStartedAt(class'XComGameState_GeoscapeEntity'.static.GetCurrentTime());
	ChainState.StartNextStage(NewGameState);

	`SubmitGameState(NewGameState);
}

exec function EnableCITrace (bool Enabled)
{
	SuppressTraceLogs = !Enabled;
}

exec function CompleteCurrentCovertActionImproved (optional bool bCompleted = true)
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_CovertAction ActionState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: CompleteCurrentCovertAction");
	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if (ActionState.bStarted)
		{
			ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionState.ObjectID));
			ActionState.bCompleted = bCompleted;
			ActionState.CompleteCovertAction(NewGameState);
		}
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

exec function SetNumKillsOfCharacterGroup (name CharacterGroup, int NewKills)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: SetNumKillsOfCharacterGroup" @ CharacterGroup);
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
	CIInfo.SetCharacterGroupsKills(CharacterGroup, NewKills);

	`SubmitGameState(NewGameState);

	`CI_Log("Set kill count for" @ CharacterGroup @ "to" @ CIInfo.GetCharacterGroupsKills(CharacterGroup));
}

exec function SpawnResistanceCardAction (name CardName)
{
	local XComGameState_StrategyCard DesiredCardState, CardState;
	local XComGameState_ResistanceFaction FactionState;
	local X2StrategyElementTemplateManager StratMgr;
	local XComGameState_CovertAction ActionState;
	local X2CovertActionTemplate ActionTemplate;
	local StateObjectReference ActionRef;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_StrategyCard', CardState)
	{
		if (CardState.GetMyTemplateName() == CardName)
		{
			DesiredCardState = CardState;
			break;
		}
	}

	if (DesiredCardState == none)
	{
		`CI_Log("SpawnResistanceCardAction: Failed to find" @ CardName @ "card");
		return;
	}

	if (DesiredCardState.bDrawn)
	{
		`CI_Log("SpawnResistanceCardAction: Card" @ CardName @ "is already drawn, cannot spawn CA for it");
		return;
	}

	FactionState = DesiredCardState.GetAssociatedFaction();
	if (FactionState == none)
	{
		`CI_Log("SpawnResistanceCardAction: Card" @ CardName @ "does not belong to a faction, cannot spawn CA for it");
		return;		
	}

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(StratMgr.FindStrategyElementTemplate('CovertAction_ResistanceCard'));

	if (ActionTemplate == none)
	{
		`CI_Log("SpawnResistanceCardAction: Failed to find CA template, cannot spawn CA");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: SpawnResistanceCardAction" @ CardName);
	DesiredCardState = XComGameState_StrategyCard(NewGameState.ModifyStateObject(class'XComGameState_StrategyCard', DesiredCardState.ObjectID));
	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));

	ActionRef = FactionState.CreateCovertAction(NewGameState, ActionTemplate, eFactionInfluence_Minimal);
	ActionState = XComGameState_CovertAction(NewGameState.GetGameStateForObjectID(ActionRef.ObjectID));
	FactionState.CovertActions.AddItem(ActionRef);

	// Unlink the randomly selected card
	CardState = XComGameState_StrategyCard(NewGameState.GetGameStateForObjectID(ActionState.StoredRewardRef.ObjectID));
	if (CardState != none) CardState.bDrawn = false;

	// Set the desired card
	ActionState.StoredRewardRef = DesiredCardState.GetReference();
	DesiredCardState.bDrawn = true;

	`SubmitGameState(NewGameState);
}

exec function SetBonusForInfiltrationMilestone (name Milestone, name Bonus)
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local UIMission_Infiltrated MissionScreen;
	local XComGameState NewGameState;
	local int i;

	MissionScreen = UIMission_Infiltrated(`SCREENSTACK.GetCurrentScreen());
	if (MissionScreen == none)
	{
		`CI_Log("SetBonusForInfiltrationMilestone failed - not looking at infiltration mission blades");
		return;
	}

	InfiltrationState = MissionScreen.GetInfiltration();
	i = InfiltrationState.SelectedInfiltartionBonuses.Find('MilestoneName', Milestone);

	if (i == INDEX_NONE)
	{
		`CI_Log("SetBonusForInfiltrationMilestone failed - invalid milestone");
		return;
	}

	if (InfiltrationState.SelectedInfiltartionBonuses[i].bGranted)
	{
		`CI_Log("SetBonusForInfiltrationMilestone failed - milestone already granted");
		return;
	}
	
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	BonusTemplate = X2OverInfiltrationBonusTemplate(TemplateManager.FindStrategyElementTemplate(Bonus));

	if (BonusTemplate == none)
	{
		`CI_Log("SetBonusForInfiltrationMilestone failed - invalid bonus");
		return;
	}

	if (BonusTemplate.Milestone != Milestone)
	{
		`CI_Log("SetBonusForInfiltrationMilestone failed - bonus milestone mismatch");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: SetBonusForInfiltrationMilestone");
	InfiltrationState = XComGameState_MissionSiteInfiltration(NewGameState.ModifyStateObject(class'XComGameState_MissionSiteInfiltration', InfiltrationState.ObjectID));
	InfiltrationState.SelectedInfiltartionBonuses[i].BonusName = BonusTemplate.DataName;
	`SubmitGameState(NewGameState);

	// Recreate the screen
	MissionScreen.CloseScreenOnly();
	InfiltrationState.AttemptSelectionCheckInterruption();
}

exec function SetFlatRisk (name FlatRiskName)
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2CovertActionRiskTemplate RiskTemplate;
	local XComGameState_CovertAction ActionState;
	local UICovertActionsGeoscape ActionsScreen;
	local XComGameState NewGameState;

	if (class'X2Helper_Infiltration'.default.FlatRiskSitReps.Find('FlatRiskName', FlatRiskName) == INDEX_NONE)
	{
		`CI_Log("SetFlatRisk failed - invalid FlatRiskName");
		return;
	}

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RiskTemplate = X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(FlatRiskName));

	if (RiskTemplate == none)
	{
		`CI_Log("SetFlatRisk failed - risk template not found");
		return;
	}

	ActionsScreen = UICovertActionsGeoscape(`SCREENSTACK.GetCurrentScreen());
	if (ActionsScreen == none)
	{
		`CI_Log("SetFlatRisk failed - not looking at covert actions screen");
		return;
	}

	ActionState = ActionsScreen.GetAction();

	if (ActionState.bStarted)
	{
		`CI_Log("SetFlatRisk failed - action already started");
		return;
	}

	if (!class'X2Helper_Infiltration'.static.IsInfiltrationAction(ActionState))
	{
		`CI_Log("SetFlatRisk failed - not looking at an infiltration action");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: SetFlatRisk");
	ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionState.ObjectID));
	
	// Clear existing risks
	ActionState.Risks.Length = 0;
	ActionState.NegatedRisks.Length = 0;

	// Add the new one
	class'X2Helper_Infiltration'.static.AddRiskToAction(RiskTemplate, ActionState);
	ActionState.RecalculateRiskChanceToOccurModifiers();
	`SubmitGameState(NewGameState);

	// Refresh the UI
	ActionsScreen.UpdateData();
}

exec function SetRiskOccurance (name RiskName, bool bOccurs)
{
	local XComGameState_CovertAction ActionState;
	local UICovertActionsGeoscape ActionsScreen;
	local XComGameState NewGameState;
	local int i;

	ActionsScreen = UICovertActionsGeoscape(`SCREENSTACK.GetCurrentScreen());
	if (ActionsScreen == none)
	{
		`CI_Log("SetRiskActivation failed - not looking at covert actions screen");
		return;
	}

	ActionState = ActionsScreen.GetAction();
	if (!ActionState.bStarted || ActionState.bCompleted)
	{
		`CI_Log("SetRiskActivation failed - action is not ongoing");
		return;
	}

	if (ActionState.NegatedRisks.Find(RiskName) != INDEX_NONE)
	{
		`CI_Log("SetRiskActivation failed - risk is nagated");
		return;
	}

	i = ActionState.Risks.Find('RiskTemplateName', RiskName);
	if (i == INDEX_NONE)
	{
		`CI_Log("SetRiskActivation failed - risk does not exist on the action");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: SetRiskActivation");
	ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionState.ObjectID));
	ActionState.Risks[i].bOccurs = bOccurs;
	`SubmitGameState(NewGameState);
}

exec function ForceAbortSelectedInfil ()
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;
	local XComGameState_Activity_Infiltration ActivityState;
	local UIMission_Infiltrated MissionScreen;
	local XComGameState NewGameState;

	MissionScreen = UIMission_Infiltrated(`SCREENSTACK.GetCurrentScreen());
	if (MissionScreen == none)
	{
		`CI_Log("ForceAbortSelectedInfil failed - not looking at infiltration mission blades");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: ForceAbortSelectedInfil");
	
	InfiltrationState = XComGameState_MissionSiteInfiltration(NewGameState.ModifyStateObject(class'XComGameState_MissionSiteInfiltration', MissionScreen.MissionRef.ObjectID));
	ActivityState = XComGameState_Activity_Infiltration(class'XComGameState_Activity'.static.GetActivityFromObject(InfiltrationState));
	ActivityState = XComGameState_Activity_Infiltration(NewGameState.ModifyStateObject(class'XComGameState_Activity_Infiltration', ActivityState.ObjectID));
	
	ClearUnitsFromInfil(NewGameState, InfiltrationState);

	// Not really intended to be used this way (once launchable, infils are not supposed to be aborted)
	// but it's the best we can do
	X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate()).OnAborted(NewGameState, ActivityState);

	`SubmitGameState(NewGameState);

	MissionScreen.CloseScreenOnly();
}

simulated function ClearUnitsFromInfil (XComGameState NewGameState, XComGameState_MissionSiteInfiltration InfiltrationState)
{
	local XComGameState_StaffSlot SlotState;
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;
	local StateObjectReference UnitRef;

	History = `XCOMHISTORY;

	foreach InfiltrationState.SoldiersOnMission(UnitRef)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
		if (UnitState == none) continue;

		SlotState = UnitState.GetStaffSlot();
		SlotState.EmptySlot(NewGameState);

		// Refresh the will recovery project
		if (UnitState.IsSoldier() && UnitState.UsesWillSystem())
		{
			class'X2Helper_Infiltration'.static.DestroyWillRecoveryProject(NewGameState, UnitRef);
			class'X2Helper_Infiltration'.static.CreateWillRecoveryProject(NewGameState, UnitState);
		}
	}
}

exec function ForceNextEnviromentalSitrep(name SitRep)
{
	ForcedNextEnviromentalSitrep = SitRep;
}

exec function ForceRemoveEndedChains ()
{
	class'XComGameState_ActivityChain'.static.RemoveEndedChains();
}

exec function ForceRemoveEndedChainsAll ()
{
	class'XComGameState_ActivityChain'.static.RemoveEndedChains(true);
}

exec function ListAllMissionTypesWithQuestItems ()
{
	local X2QuestItemTemplate QuestItemDataTemplate;
	local array<string> ResultMissionTypes;
	local X2DataTemplate DataTemplate;
	local string MissionType;

	foreach class'X2ItemTemplateManager'.static.GetItemTemplateManager().IterateTemplates(DataTemplate, none)
	{
		QuestItemDataTemplate = X2QuestItemTemplate(DataTemplate);
		if (QuestItemDataTemplate == none) continue;

		foreach QuestItemDataTemplate.MissionType(MissionType)
		{
			if (ResultMissionTypes.Find(MissionType) == INDEX_NONE)
			{
				ResultMissionTypes.AddItem(MissionType);
			}
		}
	}

	`CI_Log("===============================");
	`CI_Log("Missions with quest items:");
	foreach ResultMissionTypes(MissionType)
	{
		`CI_Log("  " $ MissionType);
	}
	`CI_Log("===============================");
}

exec function RefreshFacilityMissionsLocks ()
{
	local XComGameState NewGameState;

	// Give UpdateFacilityMissionLocks an explicit gamestate, so that if it does nothing,
	// we will see the empty gamestate in the X2DebugHistory
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: RefreshFacilityLocks");
	class'X2Helper_Infiltration'.static.UpdateFacilityMissionLocks(NewGameState);
	`SubmitGameState(NewGameState);
}

exec function CIRecordAnalyticsMission (bool bMissionSuccess)
{
	local XComGameState NewGameState;
	local XComGameState_Analytics Analytics;
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: RecordAnalyticsMission");

	Analytics = XComGameState_Analytics(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_Analytics'));
	Analytics = XComGameState_Analytics(NewGameState.ModifyStateObject(class'XComGameState_Analytics', Analytics.ObjectID));

	if (bMissionSuccess)
	{
		Analytics.AddValue("BATTLES_WON", 1);
	}
	else
	{
		Analytics.AddValue("BATTLES_LOST", 1);
	}
	
	`SubmitGameState(NewGameState);
}

exec function AttachComplicationToFocusedChain (name ComplicationName, optional bool bActivated = true, optional int TriggerChance = 0)
{
	local UIListItemString ChainListItem;
	local UIChainsOverview ChainsScreen;

	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_Complication ComplicationState;
	local X2ComplicationTemplate ComplicationTemplate;
	local XComGameState_ActivityChain ChainState;
	local XComGameState NewGameState;

	ChainsScreen = UIChainsOverview(`SCREENSTACK.GetCurrentScreen());
	if (ChainsScreen == none)
	{
		`CI_Log("AttachComplicationToFocusedChain failed - not looking at chains overview screen");
		return;
	}

	ChainListItem = UIListItemString(ChainsScreen.ChainsList.GetItem(ChainsScreen.ChainsList.SelectedIndex));
	if (ChainListItem == none)
	{
		`CI_Log("AttachComplicationToFocusedChain failed - no chain selected");
		return;
	}

	ChainState = XComGameState_ActivityChain(`XCOMHISTORY.GetGameStateForObjectID(ChainListItem.metadataInt));
	if (ChainState == none) 
	{
		`CI_Log("AttachComplicationToFocusedChain failed - failed to fetch chain state");
		return;
	}

	if (!ChainState.GetMyTemplate().bAllowComplications)
	{
		`CI_Log("AttachComplicationToFocusedChain failed - chain forbids complications");
		return;
	}

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ComplicationTemplate = X2ComplicationTemplate(TemplateManager.FindStrategyElementTemplate(ComplicationName));
	if (ComplicationTemplate == none)
	{
		`CI_Log("AttachComplicationToFocusedChain failed - complication not found");
		return;
	}

	// Ready to work

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: AttachComplicationToFocusedChain");
	ChainState = XComGameState_ActivityChain(NewGameState.ModifyStateObject(class'XComGameState_ActivityChain', ChainState.ObjectID));

	ComplicationState = ComplicationTemplate.CreateInstanceFromTemplate(NewGameState, ChainState, TriggerChance, bActivated);
	ChainState.ComplicationRefs.AddItem(ComplicationState.GetReference());

	`SubmitGameState(NewGameState);

	// Refresh UI
	ChainsScreen.ChainsList.SetSelectedIndex(ChainsScreen.ChainsList.SelectedIndex, true);
}

exec function DefeatAllChosen()
{
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_AdventChosen ChosenState;
	local StateObjectReference ChosenRef;
	local XComGameState NewGameState;
	
	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: DefeatAllChosen");

	if (AlienHQ.bChosenActive)
	{
		foreach AlienHQ.AdventChosen(ChosenRef)
		{
			ChosenState = XComGameState_AdventChosen(`XCOMHISTORY.GetGameStateForObjectID(ChosenRef.ObjectID));
			ChosenState = XComGameState_AdventChosen(NewGameState.ModifyStateObject(class'XComGameState_AdventChosen', ChosenState.ObjectID));
			ChosenState.bDefeated = true;
			ChosenState.OnDefeated(NewGameState);
		}
	}
	
	`SubmitGameState(NewGameState);
}

exec function DisableChosenSurveillanceDebug ()
{
	`CI_Trace("DisableChosenSurveillance activated from console command");

	DisableChosenSurveillance();
}

exec function CI_DumpCurrentArmoryFullName ()
{
	local UIScreenStack ScreenStack;
	local UIArmory Screen;

	ScreenStack = `SCREENSTACK;
	Screen = UIArmory(ScreenStack.GetCurrentScreen());

	`CI_Log(nameof(CI_DumpCurrentArmoryFullName) @ Screen.GetUnit().GetFullName());
}

// ... stupid XComHeadquartersCheatManager::SetSoldierWill and its full name arg

exec function CI_SetCurrentArmorySoldierWill (float NewStat)
{
	local UIScreenStack ScreenStack;
	local UIArmory Screen;

	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersProjectRecoverWill WillProject;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;

	ScreenStack = `SCREENSTACK;
	Screen = UIArmory(ScreenStack.GetCurrentScreen());
	UnitState = Screen.GetUnit();
	
	if (UnitState == none)
	{
		`CI_Log(nameof(CI_DumpCurrentArmoryFullName) @ "failed to fetch unit state, aborting");
		return;
	}

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Cheat: CI_SetCurrentArmorySoldierWill");

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
	UnitState.SetCurrentStat(eStat_Will, NewStat);

	UnitState.UpdateMentalState();

	if(UnitState.NeedsWillRecovery())
	{
		// First remove existing recover will project if there is one.
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		foreach History.IterateByClassType(class'XComGameState_HeadquartersProjectRecoverWill', WillProject)
		{
			if(WillProject.ProjectFocus == UnitState.GetReference())
			{
				XComHQ.Projects.RemoveItem(WillProject.GetReference());
				NewGameState.RemoveStateObject(WillProject.ObjectID);
				break;
			}
		}

		// Add new will recover project
		WillProject = XComGameState_HeadquartersProjectRecoverWill(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectRecoverWill'));
		WillProject.SetProjectFocus(UnitState.GetReference(), NewGameState);
		XComHQ.Projects.AddItem(WillProject.GetReference());
	}

	if(NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

exec function CI_GivePendingTrait (Name TraitTemplateName)
{
	local XComGameState_Unit Unit;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: CI_GivePendingTrait" @ TraitTemplateName);

	Unit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', XComTacticalController(`LOCALPLAYERCONTROLLER).GetActiveUnit().GetVisualizedStateReference().ObjectID));
	Unit.AcquireTrait(NewGameState, TraitTemplateName, false);

	`TACTICALRULES.SubmitGameState(NewGameState);
}

exec function CI_TestWaterworldAchievements ()
{
	class'X2AchievementTracker'.static.FinalMissionOnSuccess();
}

///////////////
/// Helpers ///
///////////////

static function DisableChosenSurveillance ()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_AdventChosen ChosenState;
	local StateObjectReference ChosenRef;
	
	local XComGameState NewGameState;
	local XComGameState_ActivityChain ChainState;
	local XComGameState_Complication ComplicationState;
	
	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	
	`CI_Trace("DisableChosenSurveillance called");

	// Do nothing if any chosen is still alive and kicking
	foreach AlienHQ.AdventChosen(ChosenRef)
	{
		ChosenState = XComGameState_AdventChosen(`XCOMHISTORY.GetGameStateForObjectID(ChosenRef.ObjectID));
			
		if (!ChosenState.bDefeated)
		{
			return;
		}
	}
	
	`CI_Trace("DisableChosenSurveillance passed");

	foreach History.IterateByClassType(class'XComGameState_ActivityChain', ChainState)
	{
		if (ChainState.bEnded) continue;
		if (ChainState.ComplicationRefs.Length == 0) continue;

		ComplicationState = ChainState.FindComplication('Complication_ChosenSurveillance');

		if (ComplicationState == none) continue;
		
		`CI_Trace("DisableChosenSurveillance on chain" @ ChainState.GetMyTemplateName());

		if (NewGameState == none) 
		{
			`CI_Trace("DisableChosenSurveillance creating gamestate");
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: PostMissionDisableSurviellance");
		}

		ChainState = XComGameState_ActivityChain(NewGameState.ModifyStateObject(class'XComGameState_ActivityChain', ChainState.ObjectID));
		ChainState.ComplicationRefs.RemoveItem(ComplicationState.GetReference());
		ComplicationState.RemoveComplication(NewGameState);
	}
	
	if (NewGameState != none)
	{
		`CI_Trace("DisableChosenSurveillance submitting gamestate");
		`SubmitGameState(NewGameState);
	}
}

static function X2DownloadableContentInfo_CovertInfiltration GetCDO()
{
	return X2DownloadableContentInfo_CovertInfiltration(class'XComEngine'.static.GetClassDefaultObjectByName(default.Class.Name));
}

/////////////////////////
/// defaultproperties ///
/////////////////////////

defaultproperties
{
	// These are needed to be able to call X2Helper_Infiltration::GetCountOfAnyLeads
	// E.g. a mec is dropped as part of RNFs and we check whether facility lead can be used a hack reward
	HQInventoryStatesToEnlistIntoTactical.Add("FacilityLeadItem")
	HQInventoryStatesToEnlistIntoTactical.Add("ActionableFacilityLead")
}
