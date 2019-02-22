//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf and Xymanek
//  PURPOSE: This class is used for various hooks and to add commands to game's
//           debug console
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_CovertInfiltration extends X2DownloadableContentInfo;

var config MissionIntroDefinition InfiltrationMissionIntroDefinition;
var config(Plots) array<string> arrAdditionalPlotsForCovertEscape;

static event UpdateDLC()
{
	class'XComGameState_PhaseOneActionsSpawner'.static.Update();
	class'XComGameState_CovertActionExpirationManager'.static.Update();
}

static event OnLoadedSavedGameToStrategy()
{
	class'XComGameState_PhaseOneActionsSpawner'.static.PrintDebugInfo();
}

///////////////////////
/// Loaded/new game ///
///////////////////////

static event InstallNewCampaign(XComGameState StartState)
{
	class'XComGameState_CovertInfiltrationInfo'.static.CreateInfo(StartState);
	class'XComGameState_PhaseOneActionsSpawner'.static.CreateSpawner(StartState);
	class'XComGameState_CovertActionExpirationManager'.static.CreateExpirationManager(StartState);
	CreateGoldenPathActions(StartState);
	CompleteTutorial(StartState);
	ForceLockAndLoad(StartState);
}

static event OnLoadedSavedGame()
{
	class'XComGameState_CovertInfiltrationInfo'.static.CreateInfo();
	class'XComGameState_PhaseOneActionsSpawner'.static.CreateSpawner();
	class'XComGameState_CovertActionExpirationManager'.static.CreateExpirationManager();
	CreateGoldenPathActions(none);
	CompleteTutorial(none);
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

static function CompleteTutorial(XComGameState NewGameState)
{
	local bool bSubmitLocally;

	if (NewGameState == none)
	{
		bSubmitLocally = true;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Disabling Covert Action Tutorial");
	}

	class'XComGameState_Objective'.static.CompleteObjectiveByName(NewGameState, 'XP2_M0_FirstCovertActionTutorial');
	class'XComGameState_Objective'.static.CompleteObjectiveByName(NewGameState, 'XP2_M1_SecondCovertActionTutorial');
	
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
// TODO: Move everything to X2Helper_Infiltration_TemplateMod

static function OnPreCreateTemplates()
{
	class'X2Helper_Infiltration_TemplateMod'.static.ForceDifficultyVariants();
}

static event OnPostTemplatesCreated()
{
	PatchResistanceRing();
	RemoveNoCovertActionNags();
	RemoveSquadSizeUpgrades();
	MarkPlotsForCovertEscape();

	class'X2Helper_Infiltration_TemplateMod'.static.MakeItemsBuildable();
	class'X2Helper_Infiltration_TemplateMod'.static.ApplyTradingPostModifiers();
	class'X2Helper_Infiltration_TemplateMod'.static.KillItems();
	class'X2Helper_Infiltration_TemplateMod'.static.DisableLockAndBreakthrough();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchRetailationMissionSource();
	class'X2Helper_Infiltration_TemplateMod'.static.PatchGuerillaTacticsSchool();

	PatchUIWeaponUpgradeItem();
}

static protected function PatchUIWeaponUpgradeItem()
{
	local UIArmory_WeaponUpgradeItem ItemCDO;

	ItemCDO = UIArmory_WeaponUpgradeItem(class'XComEngine'.static.GetClassDefaultObject(class'UIArmory_WeaponUpgradeItem'));
	ItemCDO.bProcessesMouseEvents = false;

	 // UIArmory_WeaponUpgradeItem doesn't need to process input - the BG does it
	 // However, it that flag is set then we don't get mouse events for children
	 // which breaks the "drop item" button
}

static protected function PatchResistanceRing()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate RingTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RingTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('ResistanceRing'));

	if (RingTemplate == none)
	{
		`REDSCREEN("CI: Failed to find resistance ring template");
		return;
	}

	RingTemplate.OnFacilityBuiltFn = OnResistanceRingBuilt;
	RingTemplate.GetQueueMessageFn = GetRingQueueMessage;
	RingTemplate.NeedsAttentionFn = ResistanceRingNeedsAttention;
	RingTemplate.UIFacilityClass = class'UIFacility_ResitanceRing';
}

static protected function OnResistanceRingBuilt(StateObjectReference FacilityRef)
{
	// Removed action-generating things since the ring is now about orders

	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("On Resistance Ring Built");
	FacilityState = XComGameState_FacilityXCom(NewGameState.ModifyStateObject(class'XComGameState_FacilityXCom', FacilityRef.ObjectID));

	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionState.bMetXCom)
		{
			// Turn on the Faction plaque in the Ring if they have already been met
			if (!FacilityState.ActivateUpgrade(NewGameState, FactionState.GetRingPlaqueUpgradeName()))
			{
				`RedScreen("@jweinhoffer Tried to activate Faction Plaque in the Ring, but failed.");
			}
		}
	}
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

static protected function string GetRingQueueMessage(StateObjectReference FacilityRef)
{
	if (ResistanceRingNeedsAttention(FacilityRef))
	{
		return class'UIUtilities_Text'.static.GetColoredText(class'UIFacility_ResitanceRing'.default.strAssingOrdersOverlay, eUIState_Bad);
	}

	return "";
}

static protected function bool ResistanceRingNeedsAttention(StateObjectReference FacilityRef)
{	
	// Highlight the ring if it was just built and the player needs to assign orders
	return !class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bCompletedFirstOrdersAssignment;
}

static protected function RemoveNoCovertActionNags()
{
	// Remove the warning about no covert action running since those refernce the ring

	local X2StrategyElementTemplateManager TemplateManager;
	local X2ObjectiveTemplate Template;
	local int i;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Template = X2ObjectiveTemplate(TemplateManager.FindStrategyElementTemplate('CEN_ToDoWarnings'));

	if (Template == none)
	{
		`REDSCREEN("CI: Failed to find CEN_ToDoWarnings template - cannot remove no covert action nags");
		return;
	}

	for (i = 0; i < Template.NarrativeTriggers.Length; i++)
	{
		if (Template.NarrativeTriggers[i].NarrativeDeck == 'CentralCovertActionNags')
		{
			Template.NarrativeTriggers.Remove(i, 1);
			i--; // The array is shifted, so we need to account for that
		}
	}
}

static protected function RemoveSquadSizeUpgrades()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate FacilityTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	FacilityTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('OfficerTrainingSchool'));

	FacilityTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIUnlock');
	FacilityTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIIUnlock');
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

/// /////// ///
/// HELPERS ///
/// /////// ///

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

exec function PrintP1SpawnerDebugInfo()
{
	class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ConsoleCommand("UnSuppress CI_P1Spawner");
	class'XComGameState_PhaseOneActionsSpawner'.static.PrintDebugInfo();
}