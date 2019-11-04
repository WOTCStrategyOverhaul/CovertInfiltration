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
var config(Plots) array<string> arrAdditionalPlotsForCovertEscape;
var config(GameCore) array<ArmorUtilitySlotsModifier> ArmorUtilitySlotsMods;

//////////////////////////////////
/// Vanilla DLCInfo misc hooks ///
//////////////////////////////////

static event UpdateDLC ()
{
	class'XComGameState_ActivityChainSpawner'.static.Update();
	class'XComGameState_CovertActionExpirationManager'.static.Update();
	UpdateShowTutorial();
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
	ForceLockAndLoad(StartState);
}

static event OnLoadedSavedGame()
{
	class'XComGameState_CovertInfiltrationInfo'.static.CreateInfo();
	class'XComGameState_ActivityChainSpawner'.static.CreateSpawner();
	class'XComGameState_CovertActionExpirationManager'.static.CreateExpirationManager();

	CreateGoldenPathActions(none);
	ForceObjectivesCompleted(none);
	ForceLockAndLoad(none);
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

static protected function ForceLockAndLoad(XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local bool bSubmitLocally;

	if (NewGameState == none)
	{
		bSubmitLocally = true;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Forcing Lock And Load");
	}

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
	XComHQ.bReuseUpgrades = true;

	if(bSubmitLocally)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

/////////////////
/// Templates ///
/////////////////

static function OnPreCreateTemplates()
{
	class'X2Helper_Infiltration_TemplateMod'.static.ForceDifficultyVariants();

	class'XComGameState_MissionSiteInfiltration'.static.ValidateConfig();
	class'X2Helper_Infiltration'.static.ValidateXpMultiplers();
}

static event OnPostTemplatesCreated()
{
	class'X2Helper_Infiltration_TemplateMod'.static.PatchResistanceRing();
	class'X2Helper_Infiltration_TemplateMod'.static.RemoveNoCovertActionNags();
	class'X2Helper_Infiltration_TemplateMod'.static.MakeItemsBuildable();
	class'X2Helper_Infiltration_TemplateMod'.static.ApplyTradingPostModifiers();
	class'X2Helper_Infiltration_TemplateMod'.static.KillItems();
	class'X2Helper_Infiltration_TemplateMod'.static.DisableLockAndBreakthrough();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchRetailationMissionSource();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchNewRetaliationNarrative();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchGatecrasher();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchQuestItems();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchGuerillaTacticsSchool();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchAcademyStaffSlot();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchTLPArmorsets();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchTLPWeapons();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchWeaponTechs();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchGoldenPath();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchLivingQuarters();
	class'X2Helper_Infiltration_TemplateMod'.static.RemoveSabotages();

	// These aren't actually template changes, but's this is still a convenient place to do it - before the game fully loads
	MarkPlotsForCovertEscape();
	PatchUIWeaponUpgradeItem();
}

static protected function PatchUIWeaponUpgradeItem()
{
	local UIArmory_WeaponUpgradeItem ItemCDO;

	ItemCDO = UIArmory_WeaponUpgradeItem(class'XComEngine'.static.GetClassDefaultObject(class'UIArmory_WeaponUpgradeItem'));
	ItemCDO.bProcessesMouseEvents = false;

	 // UIArmory_WeaponUpgradeItem doesn't need to process input - the BG does it
	 // However, if that flag is set then we don't get mouse events for children
	 // which breaks the "drop item" button
}

static protected function MarkPlotsForCovertEscape()
{
	local XComParcelManager ParcelManager;
	local int i;

	ParcelManager = `PARCELMGR;

	for (i = 0; i < ParcelManager.arrPlots.Length; i++)
	{
		if (default.arrAdditionalPlotsForCovertEscape.Find(ParcelManager.arrPlots[i].MapName) != INDEX_NONE)
		{
			ParcelManager.arrPlots[i].ObjectiveTags.AddItem("CovertEscape");
		}
	}
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

	return false;
}

////////////////////////////
/// Mission start/finish ///
////////////////////////////

static event OnPreMission (XComGameState StartGameState, XComGameState_MissionSite MissionState)
{
	class'XComGameState_CovertInfiltrationInfo'.static.ResetPreMission(StartGameState);
}

static event OnPostMission ()
{
	ResetInfiltrationChosenRoll();
	TriggerMissionExitEvents();
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
				case "Slums":
				case "Facility":
					OverrideMapName = "CIN_Loading_Infiltration_CityCenter";
					break;
				case "Shanty":
				case "SmallTown":
				case "Wilderness":
					OverrideMapName = "CIN_Loading_Infiltration_SmallTown";
					break;
				// FIXME: Evalutate, create an Abandoned intro?
				case "Abandoned":
				case "Tunnels_Sewer":
				case "Stronghold":
				case "Tunnels_Subway":
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
		ClassName = "GTS"; // TODO: Loc
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