//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class contains the special logic used for
//           infiltration missions, such as autoselecting the
//           mission squad from the infiltration Covert Action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_MissionSiteInfiltration extends XComGameState_MissionSite config(Infiltration);

// Since spawner action will get erased from history when player launches a mission
// we need to duplicate any info that is used after the mission site is initialized
var array<name> AppliedFlatRisks;
var float SecondsForOnePercent;
var int MaxAllowedInfil;

var array<name> AppliedSitRepTags;
var array<StateObjectReference> SoldiersOnMission;
var array<InfilBonusMilestoneSelection> SelectedInfiltartionBonuses;

// Chosen tracking
var int ChosenRollLastDoneAt;
var bool bChosenPresent;
var int ChosenLevel;

var config array<InfilChosenModifer> ChosenAppearenceMods;
var config float ChosenRollInfilInterval;

var localized string strBannerBonusGained;

`include(CovertInfiltration/Src/CovertInfiltration/MCM_API_CfgHelpersStatic.uci)
`MCM_CH_VersionCheckerStatic(class'ModConfigMenu_Defaults'.default.iVERSION, class'UIListener_ModConfigMenu'.default.CONFIG_VERSION)

/////////////
/// Setup ///
/////////////

function InitializeFromActivity (XComGameState NewGameState)
{
	local X2ActivityTemplate_Infiltration ActivityTemplate;
	local XComGameState_Activity ActivityState;

	ActivityState = GetActivity();
	ActivityTemplate = X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate());
	
	SetRegionFromAction();
	Source = class'X2ActivityTemplate_Mission'.const.MISSION_SOURCE_NAME;
	class'X2Helper_Infiltration'.static.SetFactionOnMissionSite(NewGameState, ActivityState);

	if (ActivityTemplate.PreMissionSetup != none)
	{
		ActivityTemplate.PreMissionSetup(NewGameState, ActivityState);
	}

	if (ActivityTemplate.InitializeMissionRewards != none)
	{
		Rewards = ActivityTemplate.InitializeMissionRewards(NewGameState, ActivityState);
	}

	if (Rewards.Length == 0)
	{
		Rewards.AddItem(class'X2Helper_Infiltration'.static.CreateRewardNone(NewGameState));
	}

	class'X2Helper_Infiltration'.static.InitalizeGeneratedMissionFromActivity(NewGameState, GetActivity()); // This also selects sitreps from plot type
	SelectPlotAndBiome(); // Need to do this here so that we have plot type display on the loadout. This also selects sitreps from plot type
	class'X2Helper_Infiltration'.static.SelectEnviromentalSitreps(self);

	// Invoke the CHL sitrep hook here, before we do any of our own sitrep messing
	// This should ensure compatibility with mods like LSC
	PostSitRepCreationHook();

	InitRegisterEvents();
}

protected function SetRegionFromAction ()
{
	local XComGameState_CovertAction Action;

	Action = GetSpawningAction();

	Continent  = Action.Continent;
	Region = Action.Region;

	// We cannot copy over the exact location here as it is (0, 0, 0) at this moment and will be updated next tick
	// However, we can copy the region and continent to show on the event queue popup
}

protected function EventListenerReturn OnActionStarted (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_MissionSiteInfiltration NewInfiltration;

	NewInfiltration = XComGameState_MissionSiteInfiltration(GameState.ModifyStateObject(class'XComGameState_MissionSiteInfiltration', ObjectID));

	NewInfiltration.SetSoldiersFromAction();
	NewInfiltration.MaxAllowedInfil = class'X2Helper_Infiltration'.static.GetMaxAllowedInfil(NewInfiltration.SoldiersOnMission, GetSpawningAction());

	return ELR_NoInterrupt;
}

// This is called from X2EventListener_Infiltration::CovertActionCompleted.
// We could subscribe to the event here, but eh, we already have a catch-all listener there
function OnActionCompleted (XComGameState NewGameState)
{
	CopyDataFromAction();
	
	ApplyFlatRisks();
	UpdateSitrepTags();
	SelectOverInfiltrationBonuses();
	Available = true;

	`XEVENTMGR.TriggerEvent('InfiltrationMissionSiteAvaliable', self, self, NewGameState);

	// The event and geoscape scan stop are in X2EventListener_Infiltration_UI::CovertActionCompleted
}

protected function CopyDataFromAction ()
{
	local ActionFlatRiskSitRep FlatRiskSitRep;
	local XComGameState_CovertAction Action;
	local CovertActionRisk Risk;
	local int ActionDuration;

	Action = GetSpawningAction();

	// Copy over the exact location
	Location.x = Action.Location.x;
	Location.y = Action.Location.y;

	// Copy over the applied risks
	AppliedFlatRisks.Length = 0;

	foreach Action.Risks(Risk)
	{
		if (Risk.bOccurs)
		{
			foreach class'X2Helper_Infiltration'.default.FlatRiskSitReps(FlatRiskSitRep)
			{
				if (FlatRiskSitRep.FlatRiskName == Risk.RiskTemplateName)
				{
					AppliedFlatRisks.AddItem(Risk.RiskTemplateName);
				}
			}
		}
	}

	// The mission phase starts once the action finishes (100%)
	TimerStartDateTime = Action.EndDateTime;

	// Calculate the infiltration speed (this allows for arbitrary max infil %)
	ActionDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(Action.EndDateTime, Action.StartDateTime);
	SecondsForOnePercent = ActionDuration / 100;
}

protected function SelectPlotAndBiome()
{
	local PlotTypeDefinition PlotTypeDef;
	local XComParcelManager ParcelMgr;
	local name SitRepName;
	local string Biome;

	ParcelMgr = `PARCELMGR;

	// Find a plot that supports the biome and the mission
	// Note that here we only support sitrep plot filters for forced sitreps
	// As we cannot change the plot as sitreps are added/removed
	SelectBiomeAndPlotDefinition(GeneratedMission.Mission, Biome, GeneratedMission.Plot, GeneratedMission.SitReps);

	// Add SitReps forced by Plot Type
	PlotTypeDef = ParcelMgr.GetPlotTypeDefinition(GeneratedMission.Plot.strType);

	foreach PlotTypeDef.ForcedSitReps(SitRepName)
	{
		if (
			GeneratedMission.SitReps.Find(SitRepName) == INDEX_NONE &&
			(SitRepName != 'TheLost' || GeneratedMission.SitReps.Find('TheHorde') == INDEX_NONE)
		)
		{
			GeneratedMission.SitReps.AddItem(SitRepName);
		}
	}

	// the plot we find should either have no defined biomes, or the requested biome type
	if (GeneratedMission.Plot.ValidBiomes.Length > 0)
	{
		GeneratedMission.Biome = ParcelMgr.GetBiomeDefinition(Biome);
	}
}

protected function PostSitRepCreationHook ()
{
	local array<X2DownloadableContentInfo> DLCInfos; 
	local int i; 

	DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);

	for(i = 0; i < DLCInfos.Length; ++i)
	{
		DLCInfos[i].PostSitRepCreation(GeneratedMission, self);
	}

	// CHL issue #157. See OnActionCompleted for explanation
}

protected function ApplyFlatRisks()
{
	local name SitRepName;
	local name RiskName;
	local int i;

	foreach AppliedFlatRisks(RiskName)
	{
		i = class'X2Helper_Infiltration'.default.FlatRiskSitReps.Find('FlatRiskName', RiskName);
		SitRepName = class'X2Helper_Infiltration'.default.FlatRiskSitReps[i].SitRepName;

		if (GeneratedMission.SitReps.Find(SitRepName) == INDEX_NONE)
		{
			GeneratedMission.SitReps.AddItem(SitRepName);
		}
	}
}

protected function SelectOverInfiltrationBonuses()
{
	local array<X2InfiltrationBonusMilestoneTemplate> Milestones;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local X2CardManager CardManager;
	local array<string> CardLabels;
	local string Card;
	local int i;

	Milestones = class'X2InfiltrationBonusMilestoneTemplateManager'.static.GetMilestoneTemplateManager().GetSortedBonusMilestones();
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CardManager = class'X2CardManager'.static.GetCardManager();

	// Build the decks
	BuildBonusesDeck();

	// Reset the bonuses just in case
	SelectedInfiltartionBonuses.Length = 0;
	SelectedInfiltartionBonuses.Length = Milestones.Length;

	for (i = 0; i < Milestones.Length; i++)
	{
		SelectedInfiltartionBonuses[i].MilestoneName = Milestones[i].DataName;

		// Need to do this every time to get freshly sorted array
		CardLabels.Length = 0;
		CardManager.GetAllCardsInDeck('OverInfiltrationBonuses', CardLabels);

		foreach CardLabels(Card)
		{
			BonusTemplate = X2OverInfiltrationBonusTemplate(TemplateManager.FindStrategyElementTemplate(name(Card)));

			if (BonusTemplate == none || BonusTemplate.Milestone != Milestones[i].DataName)
			{
				// Something changed or a different tier
				continue;
			}

			if (BonusTemplate.IsAvaliableFn != none && !BonusTemplate.IsAvaliableFn(BonusTemplate, self))
			{
				// Bonus doesn't qualify
				continue;
			}

			// All good, use the bonus
			SelectedInfiltartionBonuses[i].BonusName = BonusTemplate.DataName;

			if (!BonusTemplate.DoNotMarkUsed)
			{
				CardManager.MarkCardUsed('OverInfiltrationBonuses', Card);
			}

			// We are done for this milestone
			break;
		}

		// In case we didn't manage to pick anything for this tier
		// Just leave it empty ('') and the code later will handle it
	}
}

static function BuildBonusesDeck ()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local X2CardManager CardManager;
	local X2DataTemplate Template;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CardManager = class'X2CardManager'.static.GetCardManager();

	foreach TemplateManager.IterateTemplates(Template, none)
	{
		BonusTemplate = X2OverInfiltrationBonusTemplate(Template);
		if (BonusTemplate == none) continue;

		CardManager.AddCardToDeck(
			'OverInfiltrationBonuses',
			string(BonusTemplate.DataName),
			BonusTemplate.Weight > 0 ? BonusTemplate.Weight : 1
		);
	}
}

protected function SetSoldiersFromAction ()
{
	SoldiersOnMission = class'X2Helper_Infiltration'.static.GetCovertActionSquad(GetSpawningAction());
}

function UpdateSitrepTags()
{
	// Reworked this function to remove tac tags if sitreps are removed

	local X2SitRepTemplateManager SitRepMgr;
	local X2SitRepTemplate SitRepTemplate;
	local name SitRepTemplateName, GameplayTag;
	local array<name> RequiredTags;
	local int i;

	SitRepMgr = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();

	// Collect needed tags
	foreach GeneratedMission.SitReps(SitRepTemplateName)
	{
		SitRepTemplate = SitRepMgr.FindSitRepTemplate(SitRepTemplateName);

		foreach SitRepTemplate.TacticalGameplayTags(GameplayTag)
		{
			RequiredTags.AddItem(GameplayTag);
		}
	}

	// Remove obsolete tags
	for (i = 0; i < TacticalGameplayTags.Length; ++i) {
		if (AppliedSitRepTags.Find(TacticalGameplayTags[i]) != INDEX_NONE && RequiredTags.Find(TacticalGameplayTags[i]) == INDEX_NONE) {
			TacticalGameplayTags.Remove(i, 1);
			i--;
		}
	}

	// Add missing tags
	foreach RequiredTags(GameplayTag)
	{
		if (TacticalGameplayTags.Find(GameplayTag) == INDEX_NONE)
		{
			TacticalGameplayTags.AddItem(GameplayTag);
		}
	}

	// Store which tags we applied
	AppliedSitRepTags = RequiredTags;
}

/////////////////////////
/// Progress tracking ///
/////////////////////////

function UpdateGameBoard()
{
	local XComGameState NewGameState;
	local XComGameState_Activity ActivityState;
	local XComGameState_MissionSiteInfiltration NewMissionState;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local XComHQPresentationLayer HQPres;

	// Do not do anything if we didn't transition to the mission stage yet
	if (!Available) return;

	// Check if we should give an overinfil bonus
	// Do this before showing the screen to support max infil rewards

	BonusTemplate = GetNextOverInfiltrationBonus();
	
	if (BonusTemplate != none && GetCurrentInfilInt() >= GetNextThreshold())
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Give over infiltartion bonus");
		NewMissionState = XComGameState_MissionSiteInfiltration(NewGameState.ModifyStateObject(class'XComGameState_MissionSiteInfiltration', ObjectID));

		BonusTemplate.ApplyFn(NewGameState, BonusTemplate, NewMissionState);
		NewMissionState.SelectedInfiltartionBonuses[NewMissionState.GetBonusMilestoneSelectionIndexByMilestone(BonusTemplate.Milestone)].bGranted = true;

		`SubmitGamestate(NewGameState);
		
		ActivityState = class'XComGameState_Activity'.static.GetActivityFromObject(NewMissionState);

		HQPres = `HQPRES;
		HQPres.NotifyBanner(strBannerBonusGained, GetUIButtonIcon(), NewMissionState.GetMissionObjectiveText(), BonusTemplate.GetBonusName(), eUIState_Good);
		`XSTRATEGYSOUNDMGR.PlaySoundEvent(X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate()).MilestoneSound);

		`CI_Log("Checking if should pause at: " $ BonusTemplate.Milestone);
		if (ShouldPauseGeoscapeAtMilestone(BonusTemplate.Milestone))
		{
			`HQPRES.StrategyMap2D.ToggleScan();
		}
	}

	if (MustLaunch())
	{
		EnablePreventTick();
		MissionSelected();
	}
}

function float GetCurrentOverInfil()
{
	local int SecondsSinceMission;

	SecondsSinceMission = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(GetCurrentTime(), TimerStartDateTime);

	return SecondsSinceMission / SecondsForOnePercent / 100;
}

function float GetCurrentInfil()
{
	return 1 + GetCurrentOverInfil();
}

function int GetCurrentInfilInt()
{
	// Truncate, not round on purpose 
	// We want the percentage to go up only when a percent is fully accumulated
	return int(GetCurrentInfil() * 100);
}

function bool MustLaunch()
{
	return GetCurrentInfilInt() >= MaxAllowedInfil;
}

protected function EventListenerReturn OnPreventGeoscapeTick(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComHQPresentationLayer HQPres;
	local UIStrategyMap StrategyMap;
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'PreventGeoscapeTick') return ELR_NoInterrupt;

	HQPres = `HQPRES;
	StrategyMap = HQPres.StrategyMap2D;
	
	// Don't popup anything while the Avenger or Skyranger are flying
	if (StrategyMap != none && StrategyMap.m_eUIState != eSMS_Flight)
	{
		MissionSelected();

		Tuple.Data[0].b = true;
		return ELR_InterruptListeners;
	}

	return ELR_NoInterrupt;
}

/////////////////////
/// Infil bonuses ///
/////////////////////

function X2OverInfiltrationBonusTemplate GetNextOverInfiltrationBonus()
{
	local X2InfiltrationBonusMilestoneTemplate MilestoneTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local InfilBonusMilestoneSelection Selection;

	MilestoneTemplate = GetNextValidBonusMilestoneTemplate();

	// None left
	if (MilestoneTemplate == none) return none;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	GetBonusMilestoneSelectionByMilestone(MilestoneTemplate.DataName, Selection);

	return X2OverInfiltrationBonusTemplate(TemplateManager.FindStrategyElementTemplate(Selection.BonusName));
}

function int GetNextThreshold()
{
	local X2InfiltrationBonusMilestoneTemplate MilestoneTemplate;

	MilestoneTemplate = GetNextValidBonusMilestoneTemplate();

	// Return something absurdly highly
	// Do not return -1 as (GetCurrentInfilInt() > GetNextThreshold()) checks will pass
	if (MilestoneTemplate == none) return 99999;

	return MilestoneTemplate.ActivateAtProgress;
}

function name GetNextValidBonusMilestoneName ()
{
	local array<InfilBonusMilestoneSelection> SortedSelectedBonuses;
	local InfilBonusMilestoneSelection Selection;

	SortedSelectedBonuses = GetSortedBonusSelection();

	foreach SortedSelectedBonuses(Selection)
	{
		if (Selection.BonusName != '' && !Selection.bGranted)
		{
			return Selection.MilestoneName;
		}
	}

	return '';
}

function X2InfiltrationBonusMilestoneTemplate GetNextValidBonusMilestoneTemplate ()
{
	local name MilestoneName;

	MilestoneName = GetNextValidBonusMilestoneName();
	if (MilestoneName == '') return none;

	return class'X2InfiltrationBonusMilestoneTemplateManager'.static.GetMilestoneTemplateManager()
		.GetMilestoneTemplate(MilestoneName);
}

function PostSitRepsChanged (XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local int MissionDataIndex;

	UpdateSitrepTags();

	// Need to update XComHQ.arrGeneratedMissionData cache
	XComHQ = `XCOMHQ;
	MissionDataIndex = XComHQ.arrGeneratedMissionData.Find('MissionID', ObjectID);

	if (MissionDataIndex != INDEX_NONE)
	{
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		XComHQ.arrGeneratedMissionData.Remove(MissionDataIndex, 1);
	}

	// Reset the schedule so that the change in tactial tags is applied
	SelectedMissionData.SelectedMissionScheduleName = '';

	`XEVENTMGR.TriggerEvent('InfiltrationSitRepsChanged', self, self, NewGameState);
}

/////////////////////////////
/// Infil bonuses helpers ///
/////////////////////////////

function int GetBonusMilestoneSelectionIndexByMilestone (name Milestone, optional bool ErrorOtherwise = true)
{
	local int i;

	i = SelectedInfiltartionBonuses.Find('MilestoneName', Milestone);

	if (i == INDEX_NONE && ErrorOtherwise)
	{
		`RedScreen("CI: GetBonusMilestoneSelectionIndexByMilestone failed to find milestone" @ string(Milestone));
		ScriptTrace();
	}

	return i;
}

function bool GetBonusMilestoneSelectionByMilestone (name Milestone, out InfilBonusMilestoneSelection OutMilestoneSelection, optional bool ErrorOtherwise = true)
{
	local int i;

	i = GetBonusMilestoneSelectionIndexByMilestone(Milestone, ErrorOtherwise);

	if (i != INDEX_NONE)
	{
		OutMilestoneSelection = SelectedInfiltartionBonuses[i];
		return true;
	}

	return false;
}

function array<InfilBonusMilestoneSelection> GetSortedBonusSelection ()
{
	local array<InfilBonusMilestoneSelection> SortedSelections;

	SortedSelections = SelectedInfiltartionBonuses;
	SortedSelections.Sort(CompareBonusSelections);

	return SortedSelections;
}

protected static function int CompareBonusSelections (InfilBonusMilestoneSelection A, InfilBonusMilestoneSelection B)
{
	local X2InfiltrationBonusMilestoneTemplateManager TemplateManager;
	local X2InfiltrationBonusMilestoneTemplate MilestoneTemplate;
	local int ProgressA, ProgressB;

	TemplateManager = class'X2InfiltrationBonusMilestoneTemplateManager'.static.GetMilestoneTemplateManager();
	
	MilestoneTemplate = TemplateManager.GetMilestoneTemplate(A.MilestoneName);
	if (MilestoneTemplate != none) ProgressA = MilestoneTemplate.ActivateAtProgress;
	else return 0; // GetMilestoneTemplate will redscreen

	MilestoneTemplate = TemplateManager.GetMilestoneTemplate(B.MilestoneName);
	if (MilestoneTemplate != none) ProgressB = MilestoneTemplate.ActivateAtProgress;
	else return 0; // GetMilestoneTemplate will redscreen

	if (ProgressA == ProgressB) return 0;

	return ProgressA < ProgressB ? 1 : -1;
}

//////////////
/// Chosen ///
//////////////

function XComGameState_AdventChosen GetCurrentChosen()
{
	local array<XComGameState_AdventChosen> AliveChosen;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_AdventChosen ChosenState;
	
	AlienHQ = class'UIUtilities_Strategy'.static.GetAlienHQ();
	AliveChosen = AlienHQ.GetAllChosen(, true);

	foreach AliveChosen(ChosenState)
	{
		if (ChosenState.ChosenControlsRegion(Region)) 
		{
			return ChosenState;
		}
	}

	return none;
}

function int GetChosenAppereanceChance()
{
	local float OverInfilScalar, AlienHQScalar;
	local XComGameState_AdventChosen CurrentChosen;
	local XComGameState_HeadquartersAlien AlienHQ;
	local int BaseChance;

	AlienHQ = class'UIUtilities_Strategy'.static.GetAlienHQ();
	CurrentChosen = GetCurrentChosen();

	if (CurrentChosen == none || !AlienHQ.bChosenActive) {
		return -1;
	}

	BaseChance = CurrentChosen.GetChosenAppearChance();
	if (BaseChance == 0) return 0;

	OverInfilScalar = class'X2Helper_Infiltration'.static.ExecuteMultiStepLerp(GetCurrentInfilInt(), GetChosenOverinfilLerpConfig());
	if (OverInfilScalar <= 0)
	{
		`RedScreen("CI: GetChosenAppereanceChance: OverInfilScalar was calculated to be 0 or less. This is invalid and overinfil will be ignored for chosen appearence chance calculation");
		OverInfilScalar = 1;
	}

	AlienHQScalar = AlienHQ.ChosenAppearChanceScalar;
	if (AlienHQScalar <= 0) AlienHQScalar = 1;

	`CI_Trace("ChosenAppereanceChance: BaseChance=" $ BaseChance $ ", OverInfilScalar=" $ OverInfilScalar $ ", AlienHQScalar=" $ AlienHQScalar);

	return Round(BaseChance * OverInfilScalar * AlienHQScalar);
}

static protected function MultiStepLerpConfig GetChosenOverinfilLerpConfig ()
{
	local MultiStepLerpConfig AlgoConfig;
	local int i;

	AlgoConfig.Steps.Length = default.ChosenAppearenceMods.Length;

	for (i = 0; i < default.ChosenAppearenceMods.Length; i++)
	{
		AlgoConfig.Steps[i].X = default.ChosenAppearenceMods[i].Progress;
		AlgoConfig.Steps[i].Y = default.ChosenAppearenceMods[i].Multiplier;
	}

	return AlgoConfig;
}

function bool ShouldPreformChosenRoll ()
{
	local XComGameState_AdventChosen CurrentChosen;

	CurrentChosen = GetCurrentChosen();

	if (ChosenRollLastDoneAt < 0)
	{
		`CI_Log("Chosen roll not performed yet or reset after another mission was done");
		return true;
	}

	if (Abs(ChosenRollLastDoneAt - GetCurrentInfilInt()) >= ChosenRollInfilInterval)
	{
		`CI_Log("Infiltration progressed further than chosen roll interval");
		return true;
	}

	if (CurrentChosen != none && CurrentChosen.Level != ChosenLevel)
	{
		`CI_Log("Chosen level has changed");
		return true;
	}

	`CI_Log("No reason found to reroll the chosen");
	return false;
}

function PreformChosenRoll ()
{
	local XComGameState_AdventChosen CurrentChosen;
	local bool bNewShouldSpawn;
	local int AppearenceChance;

	CurrentChosen = GetCurrentChosen();

	if (CurrentChosen == none)
	{
		`CI_Log("No chosen active for this infiltration");
		bNewShouldSpawn = false;
	}
	else
	{
		AppearenceChance = GetChosenAppereanceChance();
		bNewShouldSpawn = CurrentChosen.CurrentAppearanceRoll < AppearenceChance;
	
		`CI_Log("Chosen roll chance" @ AppearenceChance @ (bNewShouldSpawn ? "- success" : "- failed"));
	}

	if (bNewShouldSpawn != bChosenPresent || ChosenLevel != CurrentChosen.Level)
	{
		bChosenPresent = bNewShouldSpawn;
		ChosenLevel = CurrentChosen.Level;

		// Reset the schedule so that we regenerate the preplaced encounters to account for the chosen presence/lack
		SelectedMissionData.SelectedMissionScheduleName = '';

		// Remove all chosen tags even if the chosen is present as the chosen might have leveled up
		RemoveChosenTags();

		// Add the tag for the current level, if present
		if (bChosenPresent)
		{
			TacticalGameplayTags.AddItem(CurrentChosen.GetMyTemplate().GetSpawningTag(CurrentChosen.Level));
		}
	}

	// Save the infil percentage in any case, even if nothing was changed
	// As we don't want to reroll if the screen is opened and closed again
	ChosenRollLastDoneAt = GetCurrentInfilInt();
}

protected function RemoveChosenTags ()
{
	local XComGameState_AdventChosen ChosenState;
	local XComGameState_MissionSite MissionState;

	// Because PurgeMissionOfTags's argument is marked as "out" �\_(?)_/�
	MissionState = self;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AdventChosen', ChosenState)
	{
		ChosenState.PurgeMissionOfTags(MissionState);
	}
}

function ResetChosenRollAfterAnotherMission ()
{
	ChosenRollLastDoneAt = default.ChosenRollLastDoneAt;
}

//////////////
/// Launch ///
//////////////

function bool RequiresAvenger()
{
	// Does not require the Avenger at the mission site
	return false;
}

function SelectSquad()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_StaffSlot SlotState;
	local StateObjectReference SoldierRef;
	local XComGameState_Unit Soldier;
	
	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Set up infiltrating squad");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	
	// Soldiers are no longer on covert action
	foreach SoldiersOnMission(SoldierRef)
	{
		Soldier = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SoldierRef.ObjectID));
		SlotState = XComGameState_StaffSlot(NewGameState.ModifyStateObject(class'XComGameState_StaffSlot', Soldier.StaffingSlot.ObjectID));
		SlotState.EmptySlot(NewGameState);
	}

	// Replace the squad with the soldiers who were on the Covert Action
	XComHQ.Squad = SoldiersOnMission;

	// This isn't needed to properly spawn units into battle, but without this
	// the transition screen shows last selection in streategy, not people on this mission
	XComHQ.AllSquads.Length = 1;
	XComHQ.AllSquads[0].SquadMembers = SoldiersOnMission;
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

function StartMission()
{
	local XGStrategy StrategyGame;
	
	BeginInteraction();
	
	StrategyGame = `GAME;
	StrategyGame.PrepareTacticalBattle(ObjectID);
	
	// Transfer directly to the mission, no squad select. Squad is set up based on the covert action soldiers.
	ConfirmMission();
}

////////////
/// Misc ///
////////////

function RemoveEntity(XComGameState NewGameState)
{
	super.RemoveEntity(NewGameState);
	UnRegisterFromEvents();
}

///////////////
/// Helpers ///
///////////////

function XComGameState_Activity GetActivity ()
{
	return class'XComGameState_Activity'.static.GetActivityFromPrimaryObject(self);
}

// Note that this might fail if we already had a mission since the CA->overinfil transition
function XComGameState_CovertAction GetSpawningAction ()
{
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(GetActivity().SecondaryObjectRef.ObjectID));
}

static function bool ShouldPauseGeoscapeAtMilestone (name MilestoneReached)
{
	if (!`GAME.GetGeoscape().IsScanning()) return false;
	
	switch (MilestoneReached)
	{
		case 'MissionReady':
			return `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_100_DEFAULT, class'UIListener_ModConfigMenu'.default.PAUSE_ON_MILESTONE_100);
			break;
		case 'GenericBuff1':
			return `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_125_DEFAULT, class'UIListener_ModConfigMenu'.default.PAUSE_ON_MILESTONE_125);
			break;
		case 'SitRep1':
			return `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_150_DEFAULT, class'UIListener_ModConfigMenu'.default.PAUSE_ON_MILESTONE_150);
			break;
		case 'RiskRemoval':
			return `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_175_DEFAULT, class'UIListener_ModConfigMenu'.default.PAUSE_ON_MILESTONE_175);
			break;
		case 'SitRep2':
			return `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_200_DEFAULT, class'UIListener_ModConfigMenu'.default.PAUSE_ON_MILESTONE_200);
			break;
		case 'GenericBuff2':
			return `MCM_CH_GetValueStatic(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_225_DEFAULT, class'UIListener_ModConfigMenu'.default.PAUSE_ON_MILESTONE_225);
			break;
		default:
			`RedScreen("XCGS_MissionSiteInfiltration::ShouldPauseGeoscapeAtMilestone was passed an invalid milestone name!");
			return true;
	}
}

////////////////////////
/// Event management ///
////////////////////////

protected function InitRegisterEvents ()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
	ThisObj = self;

	EventManager.RegisterForEvent(ThisObj, 'CovertActionStarted', OnActionStarted,, 99, GetSpawningAction(), true);
}

protected function EnablePreventTick()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
	ThisObj = self;

	// Give this a very high priority to make sure it trumps any other "on-before-tick" behaviour
	EventManager.RegisterForEvent(ThisObj, 'PreventGeoscapeTick', OnPreventGeoscapeTick, ELD_Immediate, 500);
}

protected function UnRegisterFromEvents()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
	ThisObj = self;

	EventManager.UnRegisterFromAllEvents(ThisObj);
}

//////////////////
/// Validation ///
//////////////////

static function ValidateConfig ()
{
	if (default.ChosenAppearenceMods.Length < 2)
	{
		`RedScreen("XCGS_MissionSiteInfiltration::ChosenAppearenceMods needs at least 2 elements");
	}
}

///////////////////////////////
/// Disabled base functions ///
///////////////////////////////

function BuildMission(X2MissionSourceTemplate MissionSource, Vector2D v2Loc, StateObjectReference RegionRef, array<XComGameState_Reward> MissionRewards, optional bool bAvailable=true, optional bool bExpiring=false, optional int iHours=-1, optional int iSeconds=-1, optional bool bUseSpecifiedLevelSeed=false, optional int LevelSeedOverride=0, optional bool bSetMissionData=true)
{
	FunctionNotSupported("BuildMission");
}

private function FunctionNotSupported(string CalledFunction)
{
	`RedScreen("XComGameState_MissionSiteInfiltration doesn't support" @ CalledFunction);
}

/////////////////////////////////
/// Private stuff from parent ///
/////////////////////////////////

private function SelectBiomeAndPlotDefinition(MissionDefinition MissionDef, out string Biome, out PlotDefinition SelectedDef, optional array<name> SitRepNames)
{
	local XComParcelManager ParcelMgr;
	local string PrevBiome;
	local array<string> ExcludeBiomes;

	ParcelMgr = `PARCELMGR;
	ExcludeBiomes.Length = 0;
	
	Biome = SelectBiome(MissionDef, ExcludeBiomes);
	PrevBiome = Biome;

	while(!SelectPlotDefinition(MissionDef, Biome, SelectedDef, ExcludeBiomes, SitRepNames))
	{
		Biome = SelectBiome(MissionDef, ExcludeBiomes);

		if(Biome == PrevBiome)
		{
			`Redscreen("Could not find valid plot for mission!\n" $ " MissionType: " $ MissionDef.MissionName);
			SelectedDef = ParcelMgr.arrPlots[0];
			return;
		}
	}
}

//---------------------------------------------------------------------------------------
private function string SelectBiome(MissionDefinition MissionDef, out array<string> ExcludeBiomes)
{
	local string Biome;
	local int TotalValue, RollValue, CurrentValue, idx, BiomeIndex;
	local array<BiomeChance> BiomeChances;
	local string TestBiome;

	if(MissionDef.ForcedBiome != "")
	{
		return MissionDef.ForcedBiome;
	}

	// Grab Biome from location
	Biome = class'X2StrategyGameRulesetDataStructures'.static.GetBiome(Get2DLocation());

	if(ExcludeBiomes.Find(Biome) != INDEX_NONE)
	{
		Biome = "";
	}

	// Grab "extra" biomes which we could potentially swap too (used for Xenoform)
	BiomeChances = class'X2StrategyGameRulesetDataStructures'.default.m_arrBiomeChances;

	// Not all plots support these "extra" biomes, check if excluded
	foreach ExcludeBiomes(TestBiome)
	{
		BiomeIndex = BiomeChances.Find('BiomeName', TestBiome);

		if(BiomeIndex != INDEX_NONE)
		{
			BiomeChances.Remove(BiomeIndex, 1);
		}
	}

	// If no "extra" biomes just return the world map biome
	if(BiomeChances.Length == 0)
	{
		return Biome;
	}

	// Calculate total value of roll to see if we want to swap to another biome
	TotalValue = 0;

	for(idx = 0; idx < BiomeChances.Length; idx++)
	{
		TotalValue += BiomeChances[idx].Chance;
	}

	// Chance to use location biome is remainder of 100
	if(TotalValue < 100)
	{
		TotalValue = 100;
	}

	// Do the roll
	RollValue = `SYNC_RAND(TotalValue);
	CurrentValue = 0;

	for(idx = 0; idx < BiomeChances.Length; idx++)
	{
		CurrentValue += BiomeChances[idx].Chance;

		if(RollValue < CurrentValue)
		{
			Biome = BiomeChances[idx].BiomeName;
			break;
		}
	}

	return Biome;
}

//---------------------------------------------------------------------------------------
private function bool SelectPlotDefinition(MissionDefinition MissionDef, string Biome, out PlotDefinition SelectedDef, out array<string> ExcludeBiomes, optional array<name> SitRepNames)
{
	local XComParcelManager ParcelMgr;
	local array<PlotDefinition> ValidPlots;
	local X2SitRepTemplateManager SitRepMgr;
	local name SitRepName;
	local X2SitRepTemplate SitRep;

	ParcelMgr = `PARCELMGR;
	ParcelMgr.GetValidPlotsForMission(ValidPlots, MissionDef, Biome);
	SitRepMgr = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();

	// pull the first one that isn't excluded from strategy, they are already in order by weight
	foreach ValidPlots(SelectedDef)
	{
		foreach SitRepNames(SitRepName)
		{
			SitRep = SitRepMgr.FindSitRepTemplate(SitRepName);

			if(SitRep != none && SitRep.ExcludePlotTypes.Find(SelectedDef.strType) != INDEX_NONE)
			{
				continue;
			}
		}

		if(!SelectedDef.ExcludeFromStrategy)
		{
			return true;
		}
	}

	ExcludeBiomes.AddItem(Biome);
	return false;
}

defaultproperties
{
	Available = false;
	Expiring = false;

	ChosenRollLastDoneAt = -1
	ChosenLevel = -1
}