//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and statusNone
//  PURPOSE: Handles various template changes. Split from DLCInfo to prevent poluting it
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Helper_Infiltration_TemplateMod extends Object config(Game);

struct RegionScoringPair
{
	var XComGameState_WorldRegion RegionState;
	var int Score;
};

var config(GameData) array<name> arrRemoveFactionCard;
var config(GameData) int LiveFireTrainingRanksIncrease;
var config(GameData) array<name> arrSabotagesToRemove;
var config(GameData) array<name> arrPointsOfInterestToRemove;
var config(GameData) array<name> arrAllowPromotionReward;
var config(GameData) array<string> arrFirstRetalExcludedMissionFamilies;
var config(GameData) int FacilityLeadResearchPointsToComplete;
var config(GameData) int FacilityLeadResearchRepeatPointsIncrease;
var config(Infiltration) float FacilityLeadPOINeededProgressThreshold;
var config(Infiltration) int FacilityLeadPOINeededLeadsCap;

var config(UI) bool SHOW_INFILTRATION_STATS;
var config(UI) bool SHOW_DETERRENCE_STATS;

var localized string strSoldiers;
var localized string strReady;
var localized string strTired;
var localized string strWounded;
var localized string strInfiltrating;
var localized string strOnCovertAction;
var localized string strUnavailable;

var localized string strInfilLabel;
var localized string strDeterLabel;

var localized string strAcademyProjectStatusGTS;

/////////////
/// Items ///
/////////////

static function PatchItemStats()
{
	local X2DataTemplate                   DataTemplate;
	local array<X2DataTemplate>            DiffTemplates;
	local X2InfiltrationModTemplateManager InfilTemplateManager;
	local X2InfiltrationModTemplate        InfilTemplate;
	local X2ItemTemplateManager            ItemTemplateManager;
	local X2EquipmentTemplate              ItemTemplate;
	local array<X2EquipmentTemplate>       EditTemplates;
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	InfilTemplateManager = class'X2InfiltrationModTemplateManager'.static.GetInfilTemplateManager();
	
	foreach InfilTemplateManager.IterateTemplates(DataTemplate)
	{
		InfilTemplate = X2InfiltrationModTemplate(DataTemplate);
		
		if (InfilTemplate != none)
		{
			if (InfilTemplate.ModifyType == eIMT_Item)
			{
				ItemTemplateManager.FindDataTemplateAllDifficulties(InfilTemplate.ElementName, DiffTemplates);

				foreach DiffTemplates(DataTemplate)
				{
					ItemTemplate = X2EquipmentTemplate(DataTemplate);

					if (ItemTemplate != none)
					{
						if (default.SHOW_INFILTRATION_STATS)
						{
							ItemTemplate.SetUIStatMarkup(default.strInfilLabel, , InfilTemplate.HoursAdded);
						}
						if (default.SHOW_DETERRENCE_STATS)
						{
							ItemTemplate.SetUIStatMarkup(default.strDeterLabel, , InfilTemplate.Deterrence);
						}

						EditTemplates.AddItem(ItemTemplate);
					}
				}
			}
		}
	}

	foreach InfilTemplateManager.IterateTemplates(DataTemplate)
	{
		InfilTemplate = X2InfiltrationModTemplate(DataTemplate);
		
		if (InfilTemplate != none)
		{
			if (InfilTemplate.ModifyType == eIMT_Category)
			{
				foreach ItemTemplateManager.IterateTemplates(DataTemplate)
				{
					ItemTemplate = X2EquipmentTemplate(DataTemplate);
					
					if (ItemTemplate != none)
					{
						ItemTemplateManager.FindDataTemplateAllDifficulties(ItemTemplate.DataName, DiffTemplates);

						foreach DiffTemplates(DataTemplate)
						{
							ItemTemplate = X2EquipmentTemplate(DataTemplate);

							if (ItemTemplate != none && ItemTemplate.ItemCat == InfilTemplate.ElementName && EditTemplates.Find(ItemTemplate) == INDEX_NONE)
							{
								if (default.SHOW_INFILTRATION_STATS)
								{
									ItemTemplate.SetUIStatMarkup(default.strInfilLabel, , InfilTemplate.HoursAdded);
								}
								if (default.SHOW_DETERRENCE_STATS)
								{
									ItemTemplate.SetUIStatMarkup(default.strDeterLabel, , InfilTemplate.Deterrence);
								}
							}
						}
					}
				}
			}
		}
	}
}

static function PatchFacilityLeadItem ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemTemplateManager.FindItemTemplate('FacilityLeadItem');

	ItemTemplate.strImage = "img:///UILibrary_CovertInfiltration.Inv_Facility_Lead_Locked";
	
	// Needed to gate the hack reward
	// (see X2HackRewardTemplate::IsHackRewardCurrentlyPossible)
	ItemTemplate.Requirements.SpecialRequirementsFn = IsFacilityLeadItemAvailable; 
}

static protected function bool IsFacilityLeadItemAvailable ()
{
	// Check if we reached the relevant part of the game
	if (!class'X2Helper_Infiltration'.static.IsLeadsSystemEngaged()) return false;

	// Check if it's ok to spawn new leads
	if (!class'X2Helper_Infiltration'.static.ShouldAllowCasualLeadGain()) return false;

	return true;
}

static function PatchFacilityLeadReward ()
{
	local array<X2DataTemplate> DifficulityVariants;
	local X2StrategyElementTemplateManager Manager;
	local X2RewardTemplate RewardTemplate;
	local X2DataTemplate DataTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Manager.FindDataTemplateAllDifficulties('Reward_FacilityLead', DifficulityVariants);
	foreach DifficulityVariants(DataTemplate)
	{
		RewardTemplate = X2RewardTemplate(DataTemplate);
		if (RewardTemplate == none) continue;

		RewardTemplate.IsRewardAvailableFn = IsFacilityLeadRewardAvailable;
	}
}

static protected function bool IsFacilityLeadRewardAvailable (optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	return IsFacilityLeadItemAvailable();
}

////////////////
/// Research ///
////////////////

static protected function PatchGoldenPathTechs ()
{
	local X2StrategyElementTemplateManager Manager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;
	local int i;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	// ResistanceCommunications
	Manager.FindDataTemplateAllDifficulties('ResistanceCommunications', DifficulityVariants);
	foreach DifficulityVariants(DataTemplate)
	{
		TechTemplate = X2TechTemplate(DataTemplate);

		if (TechTemplate != none)
		{
			// Replace T2_M0_CompleteGuerillaOps with the blacksite reveal
			i = TechTemplate.Requirements.RequiredObjectives.Find('T2_M0_CompleteGuerillaOps');

			if (i != INDEX_NONE) TechTemplate.Requirements.RequiredObjectives[i] = 'T2_M0_L0_BlacksiteReveal';
			else TechTemplate.Requirements.RequiredObjectives.AddItem('T2_M0_L0_BlacksiteReveal');
		}
	}
}

static function PatchFacilityLeadResearch ()
{
	local X2StrategyElementTemplateManager Manager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;
	local int i;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	Manager.FindDataTemplateAllDifficulties('Tech_AlienFacilityLead', DifficulityVariants);
	foreach DifficulityVariants(DataTemplate)
	{
		TechTemplate = X2TechTemplate(DataTemplate);
		if (TechTemplate == none) continue;

		TechTemplate.PointsToComplete = default.FacilityLeadResearchPointsToComplete;
		TechTemplate.RepeatPointsIncrease = default.FacilityLeadResearchRepeatPointsIncrease;

		//TechTemplate.Requirements.SpecialRequirementsFn = HasSeenAlienFacility;
		TechTemplate.Requirements.SpecialRequirementsFn = none; // If we got a lead somehow, then we can research it
		TechTemplate.ResearchCompletedFn = FacilityLeadCompleted;

		// Remove intel cost, it's hard enough already to get leads
		i = TechTemplate.Cost.ResourceCosts.Find('ItemTemplateName', 'Intel');
		if (i != INDEX_NONE) TechTemplate.Cost.ResourceCosts.Remove(i, 1);
	}
}

static protected function bool HasSeenAlienFacility ()
{
	return class'UIUtilities_Strategy'.static.GetAlienHQ().bHasSeenFacility;
}

static protected function FacilityLeadCompleted (XComGameState NewGameState, XComGameState_Tech TechState)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
	XComHQ.AddResource(NewGameState, 'ActionableFacilityLead', 1);
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
		MissionSource.GetSitrepsFn = class'X2Helper_Infiltration'.static.GetSitrepsForRetaliationMission;
		MissionSource.GetMissionRegionFn = GetRetaliationRegion;

		MissionSource.DifficultyValue = 3;
		MissionSource.GetMissionDifficultyFn = GetMissionDifficultyFromMonthPlusTemplate;
	}
}

static protected function SpawnRetaliationMission(XComGameState NewGameState, int MissionMonthIndex)
{
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
	local string Family;

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

	// Changed: If first one (this used to check for non-narrative, but narrative is forbidden now)
	if(!CalendarState.HasCreatedMissionOfSource('MissionSource_Retaliation'))
	{
		foreach default.arrFirstRetalExcludedMissionFamilies(Family)
		{
			MissionState.ExcludeMissionFamilies.AddItem(Family);
		}
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

static protected function array<XComGameState_WorldRegion> GetRetaliationRegion (XComGameState NewGameState)
{
	local array<XComGameState_WorldRegion> CandidateRegionStates;
	local X2RetalPlacementModifierTemplateManager ModManager;
	local int i, MinScore, Adjustment, TotalScore, Roll;
	local array<RegionScoringPair> RegionScores;

	ModManager = class'X2RetalPlacementModifierTemplateManager'.static.GetRetalPlacementModifierTemplateManager();
	CandidateRegionStates = class'X2StrategyElement_DefaultMissionSources'.static.GetAllContactedRegions();

	RegionScores.Length = CandidateRegionStates.Length;
	for (i = 0; i < CandidateRegionStates.Length; i++)
	{
		RegionScores[i].RegionState = CandidateRegionStates[i];
		RegionScores[i].Score = ModManager.ScoreRegion(NewGameState, CandidateRegionStates[i]);

		if (
			i == 0 ||
			RegionScores[i].Score < MinScore
		)
		{
			MinScore = RegionScores[i].Score;
		}
	}

	// Move the values so they are [0; max]
	Adjustment = Max(-MinScore, 0);
	`CI_Trace("GetRetaliationRegions Adjustment" @ Adjustment);

	for (i = 0; i < RegionScores.Length; i++)
	{
		RegionScores[i].Score += Adjustment;
		TotalScore += RegionScores[i].Score;

		`CI_Trace("Region:" @ RegionScores[i].RegionState.GetMyTemplateName() $ "; Score:" @ RegionScores[i].Score $ "; TotalScore:" @ TotalScore);
	}

	Roll = `SYNC_RAND_STATIC(TotalScore + 1);
	`CI_Trace("GetRetaliationRegions Roll" @ Roll);

	TotalScore = 0;
	for (i = 0; i < RegionScores.Length; i++)
	{
		TotalScore += RegionScores[i].Score;

		if (TotalScore >= Roll)
		{
			CandidateRegionStates.Length = 0;
			CandidateRegionStates.AddItem(RegionScores[i].RegionState);
			
			return CandidateRegionStates;
		}
	}

	`RedScreen("CI: GetRetaliationRegions: Roll outside of total score, returning random contacted region");
	
	CandidateRegionStates.Length = 1;
	return CandidateRegionStates;
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

static function PatchQuestItems ()
{
	local array<X2DataTemplate> DifficulityVariants;
	local X2ItemTemplateManager TemplateManager;
	local X2QuestItemTemplate QuestItemTemplate;
	local X2DataTemplate DataTemplate;
	local array<name> TemplateNames;
	local name TemplateName;

	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	TemplateManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(TemplateName)
	{
		DifficulityVariants.Length = 0;
		TemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			QuestItemTemplate = X2QuestItemTemplate(DataTemplate);
			if (QuestItemTemplate == none) break; // All variants will be of same type, so just skip to next entry in TemplateNames

			if (QuestItemTemplate.DataName == 'FlightDevice')
			{
				 // This will prevent FlightDevice from being selected for missions other than the tutorial one
				QuestItemTemplate.MissionSource.AddItem('MissionSource_RecoverFlightDevice');
			}

			if (QuestItemTemplate.RewardType.Length > 0)
			{
				QuestItemTemplate.RewardType.AddItem('Reward_Rumor');
			}
		}
	}
}

static protected function int GetMissionDifficultyFromMonthPlusTemplate (XComGameState_MissionSite MissionState)
{
	local TDateTime StartDate;
	local array<int> MonthlyDifficultyAdd;
	local int Difficulty, MonthDiff;

	class'X2StrategyGameRulesetDataStructures'.static.SetTime(StartDate, 0, 0, 0, class'X2StrategyGameRulesetDataStructures'.default.START_MONTH,
		class'X2StrategyGameRulesetDataStructures'.default.START_DAY, class'X2StrategyGameRulesetDataStructures'.default.START_YEAR);

	Difficulty = MissionState.GetMissionSource().DifficultyValue;
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

static function PatchAlienNetworkMissionSource ()
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<X2DataTemplate> DifficultyVariants;
	local X2DataTemplate DataTemplate;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	StratMgr.FindDataTemplateAllDifficulties('MissionSource_AlienNetwork', DifficultyVariants);

	foreach DifficultyVariants(DataTemplate)
	{
		MissionSource = X2MissionSourceTemplate(DataTemplate);
		MissionSource.OnFailureFn = none; // The default one only disconnects the region
	}
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

static function PatchGoldenPath ()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ObjectiveTemplate ObjectiveTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	ObjectiveTemplate = X2ObjectiveTemplate(TemplateManager.FindStrategyElementTemplate('T2_M0_L0_BlacksiteReveal'));
	if (ObjectiveTemplate == none)
	{
		`REDSCREEN("CI: Failed to find T2_M0_L0_BlacksiteReveal template");
	}
	else
	{
		ObjectiveTemplate.CompletionEvent = 'NonFactionMissionExit';
		ObjectiveTemplate.NextObjectives.AddItem('T2_M1_ContactBlacksiteRegion');
	}

	// Get rid of T2_M0_CompleteGuerillaOps (it's forced complete at the start of the campaign, should do nothing)
	ObjectiveTemplate = X2ObjectiveTemplate(TemplateManager.FindStrategyElementTemplate('T2_M0_CompleteGuerillaOps'));
	if (ObjectiveTemplate == none)
	{
		`REDSCREEN("CI: Failed to find T2_M0_CompleteGuerillaOps template");
	}
	else
	{
		ObjectiveTemplate.CompletionEvent = '_______';
		ObjectiveTemplate.NextObjectives.Length = 0;
	}

	// Get rid of MissionExpired listener for T2_M1_L1_RevealBlacksiteObjective, it's fine to skip missions in CI
	ObjectiveTemplate = X2ObjectiveTemplate(TemplateManager.FindStrategyElementTemplate('T2_M1_L1_RevealBlacksiteObjective'));
	if (ObjectiveTemplate == none)
	{
		`REDSCREEN("CI: Failed to find T2_M1_L1_RevealBlacksiteObjective template");
	}
	else
	{
		RemoveNarrativeTriggerByEvent(ObjectiveTemplate, 'MissionExpired');
		RemoveNarrativeTriggerByEvent(ObjectiveTemplate, 'WelcomeToResistanceComplete');
	}

	// Edit the associated researches
	PatchGoldenPathTechs();
}

static protected function RemoveNarrativeTriggerByEvent (X2ObjectiveTemplate ObjectiveTemplate, name EventName)
{
	local int i;

	for (i = 0; i < ObjectiveTemplate.NarrativeTriggers.Length; i++)
	{
		if (ObjectiveTemplate.NarrativeTriggers[i].TriggeringEvent == EventName)
		{
			ObjectiveTemplate.NarrativeTriggers.Remove(i, 1);
			i--;
		}
	}
}

static function PatchChosenObjectives ()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ObjectiveTemplate ObjectiveTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	ObjectiveTemplate = X2ObjectiveTemplate(TemplateManager.FindStrategyElementTemplate('XP3_M0_NonLostAndAbandoned'));
	if (ObjectiveTemplate == none)
	{
		`REDSCREEN("CI: Failed to find XP3_M0_NonLostAndAbandoned template");
	}
	else
	{
		ObjectiveTemplate.NextObjectives.RemoveItem('XP1_M0_ActivateChosen');
	}
}

///////////////////////
/// XCOM Facilities ///
///////////////////////

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
	
	GTSTemplate.IsFacilityProjectActiveFn = IsAcademyProjectActive;
	GTSTemplate.GetQueueMessageFn = GetAcademyQueueMessage;

	// Add 2nd training slot
	StaffSlotDef.StaffSlotTemplateName = 'OTSStaffSlot';
	GTSTemplate.StaffSlotDefs.AddItem(StaffSlotDef);
	
	// Remove squad size upgrades
	GTSTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIUnlock');
	GTSTemplate.SoldierUnlockTemplates.RemoveItem('SquadSizeIIUnlock');

	// Add infiltration size upgrades
	GTSTemplate.SoldierUnlockTemplates.AddItem('InfiltrationSize1');
	GTSTemplate.SoldierUnlockTemplates.AddItem('InfiltrationSize2');

	// Add training target rank unlock
	GTSTemplate.SoldierUnlockTemplates.AddItem('AcademyTrainingRankUnlock');
}

static function bool IsAcademyProjectActive(StateObjectReference FacilityRef)
{
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState_StaffSlot StaffSlot;
	local XComGameState_HeadquartersProjectTrainAcademy AcademyProject;
	local int idx;

	FacilityState = XComGameState_FacilityXCom(`XCOMHISTORY.GetGameStateForObjectID(FacilityRef.ObjectID));

	for (idx = 0; idx < FacilityState.StaffSlots.Length; idx++)
	{
		StaffSlot = FacilityState.GetStaffSlot(idx);
		if (StaffSlot.IsSlotFilled())
		{
			AcademyProject = class'X2Helper_Infiltration'.static.GetAcademyProjectForUnit(StaffSlot.GetAssignedStaffRef());
			if (AcademyProject != none)
			{
				return true;
			}
		}
	}
	return false;
}

static function string GetAcademyQueueMessage(StateObjectReference FacilityRef)
{
	local XComGameState_HeadquartersProjectTrainAcademy AcademyProject;
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState_StaffSlot StaffSlot;
	local string strSoldierClass, Message;
	local int i, iCurrentHoursRemaining, iLowestHoursRemaining;
	local bool bProjectFound;

	FacilityState = XComGameState_FacilityXCom(`XCOMHISTORY.GetGameStateForObjectID(FacilityRef.ObjectID));
	iLowestHoursRemaining = 0;

	for (i = 0; i < FacilityState.StaffSlots.Length; i++)
	{
		StaffSlot = FacilityState.GetStaffSlot(i);
		if (StaffSlot.IsSlotFilled())
		{
			AcademyProject = class'X2Helper_Infiltration'.static.GetAcademyProjectForUnit(StaffSlot.GetAssignedStaffRef());
			if (AcademyProject != none)
			{
				bProjectFound = true;
				iCurrentHoursRemaining = AcademyProject.GetCurrentNumHoursRemaining();
				if (iCurrentHoursRemaining < 0)
				{
					Message = class'UIUtilities_Text'.static.GetColoredText(class'UIFacility_Powercore'.default.m_strStalledResearch, eUIState_Warning);
					strSoldierClass = StaffSlot.GetBonusDisplayString();
					break;
				}
				else if (iLowestHoursRemaining == 0 || iCurrentHoursRemaining < iLowestHoursRemaining)
				{
					iLowestHoursRemaining = iCurrentHoursRemaining;
					strSoldierClass = StaffSlot.GetBonusDisplayString();
					Message = class'UIUtilities_Text'.static.GetTimeRemainingString(iLowestHoursRemaining);
				}
			}
		}
	}

	return bProjectFound ? (strSoldierClass $ ":" @ Message) : "";
}

static function PatchLivingQuarters()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate FacilityTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	FacilityTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('LivingQuarters'));
	
	// add crew size limit upgrades
	FacilityTemplate.Upgrades.AddItem('LivingQuarters_CrewSizeI');
	FacilityTemplate.Upgrades.AddItem('LivingQuarters_CrewSizeII');
}

static function PatchHangar()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate HangarTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	HangarTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('Hangar'));

	HangarTemplate.GetQueueMessageFn = GetPatchedHangarQueueMessage;
}

static function string GetPatchedHangarQueueMessage(StateObjectReference FacilityRef)
{
	local BarracksStatusReport CurrentBarracksStatus;
	local string strStatus;

	CurrentBarracksStatus = class'X2Helper_Infiltration'.static.GetBarracksStatusReport();

	strStatus = default.strSoldiers $ ": ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strReady $ ":" @ CurrentBarracksStatus.Ready, "53b45e") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strTired $ ":" @ CurrentBarracksStatus.Tired, "fdce2b") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strWounded $ ":" @ CurrentBarracksStatus.Wounded, "bf1e2e") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strInfiltrating $ ":" @ CurrentBarracksStatus.Infiltrating, "2ed1b6") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strOnCovertAction $ ":" @ CurrentBarracksStatus.OnCovertAction, "219481") $ ", ";
	strStatus $= class'UIUtilities_Infiltration'.static.ColourText(default.strUnavailable $ ":" @ CurrentBarracksStatus.Unavailable, "828282");

	return strStatus;
}

///////////////////
/// Staff Slots ///
///////////////////

static function PatchAcademyStaffSlot ()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2StaffSlotTemplate SlotTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	SlotTemplate = X2StaffSlotTemplate(TemplateManager.FindStrategyElementTemplate('OTSStaffSlot'));

	SlotTemplate.UIStaffSlotClass = class'UIFacility_AcademySlot_CI';
	SlotTemplate.FillFn = FillAcademySlot;
	SlotTemplate.EmptyStopProjectFn = EmptyStopProjectAcademySlot;
	SlotTemplate.IsUnitValidForSlotFn = IsUnitValidForAcademySlot;
	SlotTemplate.GetBonusDisplayStringFn = GetAcademySlotBonusDisplayString;
}

static protected function FillAcademySlot (XComGameState NewGameState, StateObjectReference SlotRef, StaffUnitInfo UnitInfo, optional bool bTemporary = false)
{
	local XComGameState_Unit NewUnitState;
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_HeadquartersXCom NewXComHQ;
	local XComGameState_HeadquartersProjectTrainAcademy ProjectState;
	local StateObjectReference EmptyRef;
	local int SquadIndex;

	local UIChooseClass ChooseClassScreen;
	local UIScreenStack ScreenStack;

	class'X2StrategyElement_DefaultStaffSlots'.static.FillSlot(NewGameState, SlotRef, UnitInfo, NewSlotState, NewUnitState);
	NewXComHQ = class'X2StrategyElement_DefaultStaffSlots'.static.GetNewXComHQState(NewGameState);
	
	ProjectState = XComGameState_HeadquartersProjectTrainAcademy(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectTrainAcademy'));
	ProjectState.SetProjectFocus(UnitInfo.UnitRef, NewGameState, NewSlotState.Facility);

	NewUnitState.SetStatus(eStatus_Training);
	NewXComHQ.Projects.AddItem(ProjectState.GetReference());

	// Remove their gear
	NewUnitState.MakeItemsAvailable(NewGameState, false);
	
	// If the unit undergoing training is in the squad, remove them
	SquadIndex = NewXComHQ.Squad.Find('ObjectID', UnitInfo.UnitRef.ObjectID);
	if (SquadIndex != INDEX_NONE) NewXComHQ.Squad[SquadIndex] = EmptyRef;

	// Assaign the new soldier class if rookie (if coming from UIChooseClass)
	ScreenStack = `SCREENSTACK;
	ChooseClassScreen = UIChooseClass(ScreenStack.GetCurrentScreen());

	if (ChooseClassScreen != none)
	{
		ProjectState.NewClassName = ChooseClassScreen.m_arrClasses[ChooseClassScreen.iSelectedItem].DataName;
	}
}

static protected function EmptyStopProjectAcademySlot (StateObjectReference SlotRef)
{
	local XComGameState_HeadquartersProjectTrainAcademy ProjectState;
	local HeadquartersOrderInputContext OrderInput;
	local XComGameState_StaffSlot SlotState;
	
	SlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(SlotRef.ObjectID));
	ProjectState = class'X2Helper_Infiltration'.static.GetAcademyProjectForUnit(SlotState.GetAssignedStaffRef());

	if (ProjectState != none)
	{
		// This will just cancel any project given to it, kick the unit out of the slot and set the status back to active
		// No need to write a custom implementation
		OrderInput.OrderType = eHeadquartersOrderType_CancelTrainRookie;
		OrderInput.AcquireObjectReference = ProjectState.GetReference();

		class'XComGameStateContext_HeadquartersOrder'.static.IssueHeadquartersOrder(OrderInput);
	}
	else
	{
		`RedScreen("CI: Failed to find XComGameState_HeadquartersProjectTrainAcademy for slot" @ SlotRef.ObjectID @ "with unit" @ SlotState.GetAssignedStaffRef().ObjectID);
	}
}

static protected function bool IsUnitValidForAcademySlot (XComGameState_StaffSlot SlotState, StaffUnitInfo UnitInfo)
{
	local XComGameState_Unit Unit;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));
	
	return Unit.CanBeStaffed()
		&& Unit.IsSoldier()
		&& Unit.IsActive()
		&& Unit.GetRank() < class'X2Helper_Infiltration'.static.GetAcademyTrainingTargetRank()
		&& !Unit.CanRankUpSoldier()
		&& SlotState.GetMyTemplate().ExcludeClasses.Find(Unit.GetSoldierClassTemplateName()) == INDEX_NONE;
}

static protected function string GetAcademySlotBonusDisplayString (XComGameState_StaffSlot SlotState, optional bool bPreview)
{
	local XComGameState_HeadquartersProjectTrainAcademy AcademyProject;
	local string Contribution;

	if (SlotState.IsSlotFilled())
	{
		AcademyProject = class'X2Helper_Infiltration'.static.GetAcademyProjectForUnit(SlotState.GetAssignedStaffRef());

		if (AcademyProject.PromotingFromRookie())
		{
			Contribution = Caps(AcademyProject.GetNewClassTemplate().DisplayName);
		}
		else
		{
			Contribution = default.strAcademyProjectStatusGTS;
		}
	}

	return class'X2StrategyElement_DefaultStaffSlots'.static.GetBonusDisplayString(SlotState, "%SKILL", Contribution);
}

static function PatchCovertActionPromotionRewards()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2DataTemplate DataTemplate;
	local X2CovertActionTemplate ActionTemplate;
	local int index;
	
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	foreach TemplateManager.IterateTemplates(DataTemplate)
	{
		ActionTemplate = X2CovertActionTemplate(DataTemplate);

		if (ActionTemplate != none)
		{
			if (default.arrAllowPromotionReward.Find(ActionTemplate.DataName) == INDEX_NONE)
			{
				// Must be a for loop because a foreach loop is passed a copy of the array
				for (index = 0; index < ActionTemplate.Slots.Length; index++)
				{
					ActionTemplate.Slots[index].Rewards.RemoveItem('Reward_RankUp');
				}
			}
		}
	}
}

static function PatchDoomRemovalCovertAction()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2CovertActionTemplate ActionTemplate;
	
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	ActionTemplate = X2CovertActionTemplate(TemplateManager.FindStrategyElementTemplate('CovertAction_RemoveDoom'));

	ActionTemplate.bMultiplesAllowed = false;
}

/////////////////////
/// Faction Cards ///
/////////////////////

static function RemoveFactionCards()
{
	local X2StrategyElementTemplateManager Manager;
	local X2StrategyCardTemplate CardTemplate;
	local name TemplateName;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	`CI_Log("Suffocating Faction Cards");

	foreach default.arrRemoveFactionCard(TemplateName)
	{
		CardTemplate = X2StrategyCardTemplate(Manager.FindStrategyElementTemplate(TemplateName));
		CardTemplate.Category = "__REMOVED__";
	}
}

static function PatchLiveFireTraining ()
{
	local X2StrategyElementTemplateManager Manager;
	local X2StrategyCardTemplate CardTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CardTemplate = X2StrategyCardTemplate(Manager.FindStrategyElementTemplate('ResCard_LiveFireTraining'));

	CardTemplate.OnActivatedFn = ActivateLiveFireTraining;
	CardTemplate.OnDeactivatedFn = DeactivateLiveFireTraining;
	CardTemplate.GetMutatorValueFn = GetLiveFireTrainingRanksIncrease;
	CardTemplate.GetSummaryTextFn = class'X2StrategyElement_XpackResistanceActions'.static.GetSummaryTextReplaceInt;
}

static function int GetLiveFireTrainingRanksIncrease ()
{
	return default.LiveFireTrainingRanksIncrease;
}

static protected function ActivateLiveFireTraining(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'X2StrategyElement_XpackResistanceActions'.static.GetNewXComHQState(NewGameState);
	XComHQ.BonusTrainingRanks += GetLiveFireTrainingRanksIncrease();
}

static protected function DeactivateLiveFireTraining(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'X2StrategyElement_XpackResistanceActions'.static.GetNewXComHQState(NewGameState);
	XComHQ.BonusTrainingRanks -= GetLiveFireTrainingRanksIncrease();
}

//////////////
/// Chosen ///
//////////////

static function RemoveSabotages ()
{
	local X2StrategyElementTemplateManager Manager;
	local X2SabotageTemplate SabotageTemplate;
	local name TemplateName;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	`CI_Log("Disabling Chosen sabotages");

	foreach default.arrSabotagesToRemove(TemplateName)
	{
		SabotageTemplate = X2SabotageTemplate(Manager.FindStrategyElementTemplate(TemplateName));
		SabotageTemplate.CanActivateDelegate = class'X2Helper_Infiltration'.static.ReturnFalse;
	}
}

//////////////////////////
/// Points of Interest ///
//////////////////////////

static function RemovePointsOfInterest ()
{
	local X2StrategyElementTemplateManager Manager;
	local X2PointOfInterestTemplate POITemplate;
	local name TemplateName;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	`CI_Log("Disabling Points of Interest");

	foreach default.arrPointsOfInterestToRemove(TemplateName)
	{
		POITemplate = X2PointOfInterestTemplate(Manager.FindStrategyElementTemplate(TemplateName));

		if(POITemplate != none)
		{
			POITemplate.CanAppearFn = NeverAppear;
		}
		else
		{
			`CI_Warn(TemplateName $ " is not a POI template, cannot disable!");
		}
	}
}

static function bool NeverAppear(XComGameState_PointOfInterest POIState)
{
	return false;
}

static function PatchFacilityLeadPOI ()
{
	local array<X2DataTemplate> DifficulityVariants;
	local X2StrategyElementTemplateManager Manager;
	local X2PointOfInterestTemplate POITemplate;
	local X2DataTemplate DataTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Manager.FindDataTemplateAllDifficulties('POI_FacilityLead', DifficulityVariants);
	foreach DifficulityVariants(DataTemplate)
	{
		POITemplate = X2PointOfInterestTemplate(DataTemplate);
		if (POITemplate == none) continue;

		POITemplate.CanAppearFn = CanFacilityLeadPOIAppear;
		POITemplate.IsRewardNeededFn = IsFacilityLeadPOINeeded;
	}
}

static protected function bool CanFacilityLeadPOIAppear (XComGameState_PointOfInterest POIState)
{
	return class'X2Helper_Infiltration'.static.IsLeadsSystemEngaged();
}

static protected function bool IsFacilityLeadPOINeeded (XComGameState_PointOfInterest POIState)
{
	local XComGameState_HeadquartersAlien AlienHQ;
	local float fDoomPercent;

	AlienHQ = class'UIUtilities_Strategy'.static.GetAlienHQ();
	fDoomPercent = (1.0 * AlienHQ.GetCurrentDoom()) / AlienHQ.GetMaxDoom();

	return
		fDoomPercent >= default.FacilityLeadPOINeededProgressThreshold &&
		class'X2Helper_Infiltration'.static.GetCountOfAnyLeads() <= default.FacilityLeadPOINeededLeadsCap;
}

/////////////////
/// Abilities ///
/////////////////

static function PatchEvacAbility ()
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local X2Condition_GameplayTag SitrepCondition;

	SitrepCondition = new class'X2Condition_GameplayTag';
	SitrepCondition.DisallowGameplayTag = 'CI_DisablePlaceEvac';
	
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('PlaceEvacZone');
	AbilityTemplate.AbilityShooterConditions.AddItem(SitrepCondition);
}
