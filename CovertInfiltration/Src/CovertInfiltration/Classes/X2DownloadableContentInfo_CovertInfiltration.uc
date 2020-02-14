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

// Cheats

var name ForcedNextEnviromentalSitrep;

//////////////////////////////////
/// Vanilla DLCInfo misc hooks ///
//////////////////////////////////

static event UpdateDLC ()
{
	class'XComGameState_ActivityChainSpawner'.static.Update();
	class'XComGameState_CovertActionExpirationManager'.static.Update();
	UpdateRemoveCovertActions();
	UpdateShowTutorial();
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
	GrantBonusStartUpStaff(StartState);
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

static function GrantBonusStartUpStaff (XComGameState StartState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit EngineerState, ScientistState;

	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	
	if (XComHQ == none)
	{
		return;
	}

	EngineerState = `CHARACTERPOOLMGR.CreateCharacter(StartState, eCPSM_Mixed, 'Engineer');
	ScientistState = `CHARACTERPOOLMGR.CreateCharacter(StartState, eCPSM_Mixed, 'Scientist');

	XComHQ = XComGameState_HeadquartersXCom(StartState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	XComHQ.AddToCrew(StartState, EngineerState);
	XComHQ.AddToCrew(StartState, ScientistState);

	XComHQ.HandlePowerOrStaffingChange(StartState);
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
	class'X2Helper_Infiltration_TemplateMod'.static.PatchUtilityItems();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchItemStats();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchGuerillaTacticsSchool();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchAcademyStaffSlot();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchTLPArmorsets();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchTLPWeapons();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchWeaponTechs();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchGoldenPath();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchChosenObjectives();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchLivingQuarters();
	class'X2Helper_Infiltration_TemplateMod'.static.RemoveSabotages();
	class'X2Helper_Infiltration_TemplateMod'.static.RemovePointsOfInterest();
	class'X2Helper_Infiltration_TemplateMod'.static.RemoveFactionCards();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchLiveFireTraining();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchHangar();

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

static event OnExitPostMissionSequence ()
{
	PostMissionUpgradeItems();
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

exec function ForceNextEnviromentalSitrep(name SitRep)
{
	ForcedNextEnviromentalSitrep = SitRep;
}

///////////////
/// Helpers ///
///////////////

static function X2DownloadableContentInfo_CovertInfiltration GetCDO()
{
	return X2DownloadableContentInfo_CovertInfiltration(class'XComEngine'.static.GetClassDefaultObjectByName(default.Class.Name));
}
