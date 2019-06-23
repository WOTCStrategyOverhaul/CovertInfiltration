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

var array<StateObjectReference> SoldiersOnMission;

var config array<int> OverInfiltartionThresholds;
var config float ChosenAppearenceModAt100;
var config float ChosenAppearenceModAt200;

var array<name> SelectedOverInfiltartionBonuses;
var int OverInfiltartionBonusesGranted;

var localized string strBannerBonusGained;

/////////////
/// Setup ///
/////////////

function InitializeFromActivity (XComGameState NewGameState)
{
	local X2ActivityTemplate_Infiltration ActivityTemplate;
	local XComGameState_Activity ActivityState;

	ActivityState = GetActivity();
	ActivityTemplate = X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate());
	
	Source = class'X2ActivityTemplate_Mission'.const.MISSION_SOURCE_NAME;

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

	class'X2Helper_Infiltration'.static.InitalizeGeneratedMissionFromActivity(GetActivity());
	SelectPlotAndBiome(); // Need to do this here so that we have plot type display on the loadout
}

// This is called from X2EventListener_Infiltration::CovertActionCompleted.
// We could subscribe to the event here, but eh, we already have a catch-all listener there
function OnActionCompleted (XComGameState NewGameState)
{
	CopyDataFromAction();
	
	ApplyFlatRisks();
	UpdateSitrepTags();
	SelectOverInfiltrationBonuses();

	SetSoldiersFromAction();
	Available = true;

	// The event and geoscape scan stop are in X2EventListener_Infiltration_UI::CovertActionCompleted
}

protected function CopyDataFromAction ()
{
	local ActionFlatRiskSitRep FlatRiskSitRep;
	local XComGameState_CovertAction Action;
	local CovertActionRisk Risk;

	Action = GetSpawningAction();

	// Copy over the location data
	Location.x = Action.Location.x;
	Location.y = Action.Location.y;
	Continent  = Action.Continent;
	Region = Action.Region;

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
	ExpirationDateTime = Action.EndDateTime;

	// And ends at 200%
	class'X2StrategyGameRulesetDataStructures'.static.AddHours(ExpirationDateTime, Action.HoursToComplete);
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

	// At this point normally the CHL calls DLCInfo::PostSitRepCreation hook
	// TODO: decide what to do with that hook since we change sitreps later

	// the plot we find should either have no defined biomes, or the requested biome type
	if (GeneratedMission.Plot.ValidBiomes.Length > 0)
	{
		GeneratedMission.Biome = ParcelMgr.GetBiomeDefinition(Biome);
	}
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
	local X2StrategyElementTemplateManager TemplateManager;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local X2CardManager CardManager;
	local array<string> CardLabels;
	local X2DataTemplate Template;
	local name DeckName;
	local string Card;
	local int i;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CardManager = class'X2CardManager'.static.GetCardManager();

	// Build the decks
	foreach TemplateManager.IterateTemplates(Template, none)
	{
		BonusTemplate = X2OverInfiltrationBonusTemplate(Template);
		if (BonusTemplate == none) continue;

		CardManager.AddCardToDeck(
			GetBonusDeckName(BonusTemplate.Tier),
			string(BonusTemplate.DataName),
			BonusTemplate.Weight > 0 ? BonusTemplate.Weight : 1
		);
	}

	// Reset the bonuses just in case
	SelectedOverInfiltartionBonuses.Length = 0;
	SelectedOverInfiltartionBonuses.Length = OverInfiltartionThresholds.Length;

	for (i = 0; i < OverInfiltartionThresholds.Length; i++)
	{
		DeckName = GetBonusDeckName(i);

		CardLabels.Length = 0;
		CardManager.GetAllCardsInDeck(DeckName, CardLabels);

		foreach CardLabels(Card)
		{
			BonusTemplate = X2OverInfiltrationBonusTemplate(TemplateManager.FindStrategyElementTemplate(name(Card)));

			if (BonusTemplate == none || BonusTemplate.Tier != i)
			{
				// Something changed, just remove the card from deck
				CardManager.RemoveCardFromDeck(DeckName, Card);
				continue;
			}

			if (BonusTemplate.IsAvaliableFn != none && !BonusTemplate.IsAvaliableFn(BonusTemplate, self))
			{
				// Bonus doesn't qualify
				continue;
			}

			// All good, use the bonus
			SelectedOverInfiltartionBonuses[i] = name(Card);

			if (!BonusTemplate.DoNotMarkUsed)
			{
				CardManager.MarkCardUsed(DeckName, Card);
			}

			// Do not attempt to check 
			break;
		}

		// In case we didn't manage to pick anything for this tier
		// Just leave it empty ('') and the code later will handle it
	}
}

static function name GetBonusDeckName(int Tier)
{
	return name('OverInfiltrationBonusesT' $ Tier);
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
	// TODO: This will break if there are non-sitreps tags. Introduce some sort of "applied sitreps" tracking system?
	for (i = 0; i < TacticalGameplayTags.Length; ++i) {
		if (RequiredTags.Find(TacticalGameplayTags[i]) == INDEX_NONE) {
			TacticalGameplayTags.Remove(i, 1);
			i--;
		}
	}

	// Add missing tags
	foreach RequiredTags(GameplayTag)
	{
		if(TacticalGameplayTags.Find(GameplayTag) == INDEX_NONE)
		{
			TacticalGameplayTags.AddItem(GameplayTag);
		}
	}
}

/////////////////
/// Overinfil ///
/////////////////

function UpdateGameBoard()
{
	local XComGameState NewGameState;
	local XComGameState_MissionSiteInfiltration NewMissionState;
	local X2OverInfiltrationBonusTemplate BonusTemplate;
	local XComHQPresentationLayer HQPres;

	// Do not do anything if we didn't transition to the mission stage yet
	if (!Available) return;

	// Check if we should give an overinfil bonus
	// Do this before showing the screen to support 200% rewards

	BonusTemplate = GetNextOverInfiltrationBonus();

	if (BonusTemplate != none && GetCurrentInfilInt() >= GetNextThreshold())
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Give over infiltartion bonus");
		NewMissionState = XComGameState_MissionSiteInfiltration(NewGameState.ModifyStateObject(class'XComGameState_MissionSiteInfiltration', ObjectID));

		BonusTemplate.ApplyFn(NewGameState, BonusTemplate, NewMissionState);
		NewMissionState.OverInfiltartionBonusesGranted++;

		`SubmitGamestate(NewGameState);

		HQPres = `HQPRES;
		HQPres.NotifyBanner(strBannerBonusGained, GetUIButtonIcon(), NewMissionState.GetMissionObjectiveText(), BonusTemplate.GetBonusName(), eUIState_Good);
		HQPres.PlayUISound(eSUISound_SoldierPromotion);

		if (`GAME.GetGeoscape().IsScanning())
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
	local float FullDurationDiff, CurrentDiff;

	// Use seconds so that we support 200% tiers
	FullDurationDiff = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(ExpirationDateTime, TimerStartDateTime);
	CurrentDiff = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(ExpirationDateTime, GetCurrentTime());

	return 1 - CurrentDiff / FullDurationDiff;
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

protected function int CompareThresholds (int A, int B)
{
	if (A == B) return 0;

	return A < B ? 1 : -1;
}

function X2OverInfiltrationBonusTemplate GetNextOverInfiltrationBonus()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local int NextBonusIndex;

	NextBonusIndex = GetNextValidBonusIndex();

	// None left
	if (NextBonusIndex < 0) return none;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	return X2OverInfiltrationBonusTemplate(TemplateManager.FindStrategyElementTemplate(SelectedOverInfiltartionBonuses[OverInfiltartionBonusesGranted]));
}

function int GetNextThreshold()
{
	local array<int> SortedThresholds;
	local int NextBonusIndex;

	NextBonusIndex = GetNextValidBonusIndex();

	// Return something absurdly highly
	// Do not return -1 as (GetCurrentInfilInt() > GetNextThreshold()) checks will pass
	if (NextBonusIndex < 0) return 99999;

	SortedThresholds = OverInfiltartionThresholds;
	SortedThresholds.Sort(CompareThresholds);

	return SortedThresholds[OverInfiltartionBonusesGranted];
}

function int GetNextValidBonusIndex()
{
	local int i;

	for (i = OverInfiltartionBonusesGranted; i < OverInfiltartionThresholds.Length; i++)
	{
		if (SelectedOverInfiltartionBonuses[i] != '')
		{
			return i;
		}
	}

	return -1;
}

function bool MustLaunch()
{
	return class'X2StrategyGameRulesetDataStructures'.static.LessThan(ExpirationDateTime, GetCurrentTime());
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

function PostSitRepsChanged(XComGameState NewGameState)
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

function int GetChosenAppereanceChange()
{
	local float OverInfilProgress, OverInfilScalar, AlienHQScalar;
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

	OverInfilProgress = GetCurrentOverInfil() / 100;
	OverInfilScalar = Lerp(ChosenAppearenceModAt100, ChosenAppearenceModAt200, OverInfilProgress);

	AlienHQScalar = AlienHQ.ChosenAppearChanceScalar;
	if (AlienHQScalar <= 0) AlienHQScalar = 1;

	return Round(BaseChance * OverInfilScalar * AlienHQScalar);
}

function ApplyChosenBeforeLaunch()
{
	local XComGameState_MissionSiteInfiltration NewMissionState;
	local XComGameState_AdventChosen CurrentChosen;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState NewGameState;
	local int AppearenceChance;

	AppearenceChance = GetChosenAppereanceChange();
	CurrentChosen = GetCurrentChosen();

	`CI_Log("Infiltration launch - chosen chance" @ AppearenceChance);

	if (CurrentChosen.CurrentAppearanceRoll < AppearenceChance)
	{
		`CI_Log("Infiltration launch - chosen roll success, adding");
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Infiltration - adding chosen to mission");

		// Add chosen to the mission
		NewMissionState = XComGameState_MissionSiteInfiltration(NewGameState.ModifyStateObject(class'XComGameState_MissionSiteInfiltration', ObjectID));
		NewMissionState.TacticalGameplayTags.AddItem(CurrentChosen.GetMyTemplate().GetSpawningTag(CurrentChosen.Level));

		// Update the tactical tags cache
		XComHQ = `XCOMHQ;
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		XComHQ.AddMissionTacticalTags(NewMissionState);

		`SubmitGamestate(NewGameState);
	}
	else
	{
		`CI_Log("Infiltration launch - chosen roll failed, skipping");
	}
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
	
	ApplyChosenBeforeLaunch();
	BeginInteraction();
	
	StrategyGame = `GAME;
	StrategyGame.PrepareTacticalBattle(ObjectID);
	
	// Transfer directly to the mission, no squad select. Squad is set up based on the covert action soldiers.
	ConfirmMission();
}

////////////
/// Misc ///
////////////

function class<UIStrategyMapItem> GetUIClass()
{
	return class'CI_UIStrategyMapItem_CovertAction';
}

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

////////////////////////
/// Event management ///
////////////////////////

protected function EnablePreventTick()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
	ThisObj = self;

	EventManager.RegisterForEvent(ThisObj, 'PreventGeoscapeTick', OnPreventGeoscapeTick);
}

protected function UnRegisterFromEvents()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
	ThisObj = self;

	EventManager.UnRegisterFromAllEvents(ThisObj);
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
}