//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and statusNone
//  PURPOSE: Handles various template changes. Split from DLCInfo to prevent poluting it
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Helper_Infiltration_TemplateMod extends Object config(Game);

struct TradingPostValueModifier
{
	var name ItemName;
	var int NewValue;
};

var config array<name> arrDataSetsToForceVariants;
var config(StrategyTuning) array<name> arrMakeItemBuildable;
var config(StrategyTuning) array<name> arrKillItems;
var config(StrategyTuning) array<TradingPostValueModifier> arrTradingPostModifiers;

/////////////
/// Items ///
/////////////

static function ForceDifficultyVariants()
{
	local name DataSetToPatch;
	local X2DataSet DataSetCDO;

	foreach default.arrDataSetsToForceVariants(DataSetToPatch)
	{
		DataSetCDO = X2DataSet(class'XComEngine'.static.GetClassDefaultObjectByName(DataSetToPatch));

		if (DataSetCDO == none)
		{
			`CI_Warn(DataSetToPatch @ "is not a valid X2DataSet class");
		}
		else
		{
			DataSetCDO.bShouldCreateDifficultyVariants = true;
		}
	}
}

static function MakeItemsBuildable()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local name TemplateName;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`CI_Log("Making items buildable");

	foreach default.arrMakeItemBuildable(TemplateName)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate == none)
			{
				`CI_Warn(DataTemplate.Name @ "is not an X2ItemTemplate");
				continue;
			}

			ItemTemplate.CanBeBuilt = true;
			ItemTemplate.bInfiniteItem = false;
			ItemTemplate.CreatorTemplateName = '';

			`CI_Trace(ItemTemplate.Name @ "was made single-buildable" @ `showvar(ItemTemplate.Requirements.RequiredTechs.Length));
		}
	}
}

static function ApplyTradingPostModifiers()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;
	local TradingPostValueModifier ValueModifier;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach default.arrTradingPostModifiers(ValueModifier)
	{
		ItemTemplate = ItemTemplateManager.FindItemTemplate(ValueModifier.ItemName);

		ItemTemplate.TradingPostValue = ValueModifier.NewValue;
	}
}

static function KillItems()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local name TemplateName;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`CI_Log("Killing items");

	foreach default.arrKillItems(TemplateName)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate == none)
			{
				`CI_Warn(DataTemplate.Name @ "is not an X2ItemTemplate");
				continue;
			}

			// "Killing" inspired by LW2
			ItemTemplate.CanBeBuilt = false;
			ItemTemplate.PointsToComplete = 999999;
			ItemTemplate.Requirements.RequiredEngineeringScore = 999999;
			ItemTemplate.Requirements.bVisibleifPersonnelGatesNotMet = false;
			ItemTemplate.OnBuiltFn = none;
			ItemTemplate.Cost.ResourceCosts.Length = 0;
			ItemTemplate.Cost.ArtifactCosts.Length = 0;

			`CI_Trace(ItemTemplate.Name @ "was killed");
		}
	}
}

////////////////
/// Research ///
////////////////

static function DisableLockAndBreakthrough()
{
	local X2StrategyElementTemplateManager Manager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Manager.FindDataTemplateAllDifficulties('BreakthroughReuseWeaponUpgrades', DifficulityVariants);
	
	foreach DifficulityVariants(DataTemplate)
	{
		TechTemplate = X2TechTemplate(DataTemplate);

		if (TechTemplate != none)
		{
			TechTemplate.bBreakthrough = false;
			TechTemplate.Requirements.RequiredScienceScore = 999999;
			TechTemplate.Requirements.bVisibleifPersonnelGatesNotMet = false;
			TechTemplate.Requirements.SpecialRequirementsFn = class'X2Helper_Infiltration'.static.ReturnFalse;
		}
	}
}

////////////////
/// Missions ///
////////////////

static function PatchRetailationMissionSource()
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<X2DataTemplate> DifficultyVariants;
	local X2DataTemplate DataTemplate;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	StratMgr.FindDataTemplateAllDifficulties('MissionSource_Retaliation', DifficultyVariants);

	foreach DifficultyVariants(DataTemplate)
	{
		MissionSource = X2MissionSourceTemplate(DataTemplate);
		MissionSource.SpawnMissionsFn = SpawnRetaliationMission;
	}
}

static protected function SpawnRetaliationMission(XComGameState NewGameState, int MissionMonthIndex)
{
	local XComGameState_Objective ObjectiveState; // Added
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local array<XComGameState_WorldRegion> PossibleRegions;
	local float MissionDuration;
	local int iReward;
	local XComGameState_MissionCalendar CalendarState;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState_HeadquartersXCom XComHQ;

	CalendarState = class'X2StrategyElement_DefaultMissionSources'.static.GetMissionCalendar(NewGameState);

	// Set Popup flag
	CalendarState.MissionPopupSources.AddItem('MissionSource_Retaliation');

	// Calculate Mission Expiration timer
	MissionDuration = float((class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + `SYNC_RAND_STATIC(class'X2StrategyElement_DefaultMissionSources'.default.MissionMaxDuration - class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + 1)) * 3600);

	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', CalendarState.CurrentMissionMonth[MissionMonthIndex].Missions[0].ObjectID));
	MissionState.Available = true;
	MissionState.Expiring = true;
	MissionState.TimeUntilDespawn = MissionDuration;
	MissionState.TimerStartDateTime = `STRATEGYRULES.GameTime;
	MissionState.SetProjectedExpirationDateTime(MissionState.TimerStartDateTime);
	PossibleRegions = MissionState.GetMissionSource().GetMissionRegionFn(NewGameState);
	RegionState = PossibleRegions[0];
	MissionState.Region = RegionState.GetReference();
	MissionState.Location = RegionState.GetRandomLocationInRegion();

	// Generate Rewards
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	for(iReward = 0; iReward < MissionState.Rewards.Length; iReward++)
	{
		RewardState = XComGameState_Reward(NewGameState.ModifyStateObject(class'XComGameState_Reward', MissionState.Rewards[iReward].ObjectID));
		RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), MissionState.Region);
	}

	// Changed: If first on non-narrative
	if(!(XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings')).bXPackNarrativeEnabled) &&
	   !CalendarState.HasCreatedMissionOfSource('MissionSource_Retaliation'))
	{
		// Change 1: force chosen even if no ResistanceOps were completed yet
		ObjectiveState = class'XComGameState_HeadquartersXCom'.static.GetObjective('XP1_M0_ActivateChosen');
		if (ObjectiveState != none && ObjectiveState.GetStateOfObjective() == eObjectiveState_InProgress)
		{
			ObjectiveState.CompleteObjective(NewGameState);
		}

		// Change 2: force the xpack retal instead of vanilla one
		// xymanek - I want the first retal not to be so penalizing (first chosen is very hard)
		// TODO: Remove the intro voiceline ("One of chosen is leading an assault")
		MissionState.ExcludeMissionFamilies.AddItem("Terror");
	}

	// Set Mission Data
	MissionState.SetMissionData(MissionState.GetRewardType(), false, 0);

	MissionState.PickPOI(NewGameState);

	// Flag AlienHQ as having spawned a Retaliation mission
	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersAlien', AlienHQ)
	{
		break;
	}

	if (AlienHQ == none)
	{
		AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
		AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
	}

	AlienHQ.bHasSeenRetaliation = true;
	CalendarState.CreatedMissionSources.AddItem('MissionSource_Retaliation');

	// Add tactical tags to upgrade the civilian militia if the force level has been met and the tags have not been previously added
	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	if (AlienHQ.ForceLevel >= 14 && XComHQ.TacticalGameplayTags.Find('UseTier3Militia') == INDEX_NONE)
	{
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		XComHQ.TacticalGameplayTags.AddItem('UseTier3Militia');
	}
	else if (AlienHQ.ForceLevel >= 8 && XComHQ.TacticalGameplayTags.Find('UseTier2Militia') == INDEX_NONE)
	{
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		XComHQ.TacticalGameplayTags.AddItem('UseTier2Militia');
	}

	`XEVENTMGR.TriggerEvent('RetaliationMissionSpawned', MissionState, MissionState, NewGameState);
}

static function PatchNewRetaliationNarrative()
{
	local X2MissionNarrativeTemplateManager TemplateManager;
	local X2MissionNarrativeTemplate Template;

	TemplateManager = class'X2MissionNarrativeTemplateManager'.static.GetMissionNarrativeTemplateManager();
	Template = TemplateManager.FindMissionNarrativeTemplate("ChosenRetaliation");

	// This is the intro VO which refers to "chosen leading the assault". We don't want that since
	// (1) it will be played before player meets the first chosen
	// (2) it plays if there is no chosen on this mission
	// (3) it plays even after all chosen are defated
	Template.NarrativeMoments[10] = "";
}

//////////////////
/// Objectives ///
//////////////////

static function RemoveNoCovertActionNags()
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

//////////////////
/// Facilities ///
//////////////////

static function PatchResistanceRing()
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

static function PatchGuerillaTacticsSchool()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate GTSTemplate;
	local StaffSlotDefinition StaffSlotDef;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	GTSTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('OfficerTrainingSchool'));

	if (GTSTemplate == none)
	{
		`REDSCREEN("CI: Failed to find GTS template");
		return;
	}
	
	// Add 2nd training slot
	StaffSlotDef.StaffSlotTemplateName = 'OTSStaffSlot';
	GTSTemplate.StaffSlotDefs.AddItem(StaffSlotDef);
	
	// Remove squad size upgrades
	GTSTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIUnlock');
	GTSTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIIUnlock');

	// Add infiltration size upgrades
	GTSTemplate.SoldierUnlockTemplates.AddItem('InfiltrationSize1');
	GTSTemplate.SoldierUnlockTemplates.AddItem('InfiltrationSize2');
}
