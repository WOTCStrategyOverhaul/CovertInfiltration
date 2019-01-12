//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf and Xymanek
//  PURPOSE: This class is used for various hooks and to add commands to game's
//           debug console
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_CovertInfiltration extends X2DownloadableContentInfo;

///////////////////////
/// Loaded/new game ///
///////////////////////

static event InstallNewCampaign(XComGameState StartState)
{
	class'XComGameState_CovertInfiltrationInfo'.static.CreateInfo(StartState);
	CreateGoldenPathActions(StartState);
}

static event OnLoadedSavedGame()
{
	class'XComGameState_CovertInfiltrationInfo'.static.CreateInfo();
	CreateGoldenPathActions(none);
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

/////////////////
/// Templates ///
/////////////////

static event OnPostTemplatesCreated()
{
	PatchResistanceRing();
	RemoveNoCovertActionNags();
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