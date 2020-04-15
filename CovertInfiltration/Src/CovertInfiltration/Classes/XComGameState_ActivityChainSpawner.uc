//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and NotSoLoneWolf
//  PURPOSE: Replacement for base game MissionCalendar which instead spawns activity 
//           chains based on "work" done by XCom (base) and contacted regions
//           and relays built (bonus)
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_ActivityChainSpawner extends XComGameState_BaseObject config(Infiltration);

var protectedwrite float PreviousWork;
var protectedwrite TDateTime PreviousWorkSubmittedAt;

// Work rate is meaured in hours
var protectedwrite int CachedWorkRate;
var protectedwrite int NextSpawnAt; // In work units

var const config array<int> WorkRateXcom;
var const config array<int> WorkRatePerContact;
var const config array<int> WorkRatePerRelay;
var const config bool bStaringRegionContributesToWork;

var const config array<int> GameStartWork; // How much work to add when the campaign starts
var const config array<int> WorkRequiredForSpawn;
var const config array<int> WorkRequiredForSpawnVariance;

static function Update()
{
	local XComGameState_ActivityChainSpawner Spawner;
	local XComGameState NewGameState;
	local UIStrategyMap StrategyMap;
	local bool bDirty;

	Spawner = GetSpawner(false); // Do not spam redscreens every tick
	if (Spawner == none)
	{
		`RedScreenOnce("CI: Failed to fetch XComGameState_ActivityChainSpawner for ticking");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: XComGameState_ActivityChainSpawner update");
	Spawner = XComGameState_ActivityChainSpawner(NewGameState.ModifyStateObject(class'XComGameState_ActivityChainSpawner', Spawner.ObjectID));
	
	StrategyMap = `HQPRES.StrategyMap2D;

	// STEP 1: we check if we are due spawning an action at CachedWorkRate
	if (Spawner.ShouldSpawnChain() && StrategyMap != none && StrategyMap.m_eUIState != eSMS_Flight)
	{
		`CI_Trace("Enough work for activity chain, starting spawning");
		bDirty = true;
		
		Spawner.SpawnActivityChain(NewGameState);
		Spawner.ResetProgress();
		Spawner.SetNextSpawnAt();
	}

	// STEP 2: See if we need to adjust current work rate
	if (Spawner.CachedWorkRate != GetCurrentWorkRate())
	{
		`CI_Trace("Cached work rate (" $ Spawner.CachedWorkRate $ ") doesn't match current, submitting work done and caching new work rate");
		bDirty = true;
		
		Spawner.SubmitWorkDone();
		Spawner.SetCachedWorkRate();
	}

	if (bDirty)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
	}
}

///////////////////
/// Bookkeeping ///
///////////////////

function bool ShouldSpawnChain()
{
	local float WorkDone;

	WorkDone = PreviousWork + GetWorkDoneInCurrentPeriod();

	return WorkDone >= NextSpawnAt;
}

function ResetProgress()
{
	`CI_Trace("Reset progress for next chain");

	PreviousWork = 0;
	PreviousWorkSubmittedAt = `STRATEGYRULES.GameTime;
}

function SubmitWorkDone()
{
	PreviousWork += GetWorkDoneInCurrentPeriod();
	PreviousWorkSubmittedAt = `STRATEGYRULES.GameTime;

	`CI_Trace("Submitted work done, now" $ PreviousWork);
}

function float GetWorkDoneInCurrentPeriod()
{
	local int MinutesSinceLastSubmission;
	local float HoursSinceLastSubmission;

	MinutesSinceLastSubmission = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInMinutes(`STRATEGYRULES.GameTime, PreviousWorkSubmittedAt);
	HoursSinceLastSubmission = MinutesSinceLastSubmission / 60;
	
	return fmax(CachedWorkRate * HoursSinceLastSubmission, 0);
}

static function int GetCurrentWorkRate()
{
	local int Contacts, Relays, WorkRate;

	GetNumContactsAndRelays(Contacts, Relays);

	WorkRate = `ScaleStrategyArrayInt(default.WorkRateXcom);
	Workrate += Contacts * `ScaleStrategyArrayInt(default.WorkRatePerContact);
	Workrate += Relays * `ScaleStrategyArrayInt(default.WorkRatePerRelay);

	return WorkRate;
}

function SetCachedWorkRate()
{
	CachedWorkRate = GetCurrentWorkRate();
	`CI_Trace("New cached work rate - " $ CachedWorkRate);
}

static function GetNumContactsAndRelays(out int Contacts, out int Relays)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_WorldRegion Region;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	XComHQ = `XCOMHQ;
	Contacts = 0;
	Relays = 0;

	foreach History.IterateByClassType(class'XComGameState_WorldRegion', Region)
	{
		if (!default.bStaringRegionContributesToWork && XComHQ.StartingRegion.ObjectID == Region.ObjectID)
		{
			continue;
		}

		if (Region.ResistanceLevel == eResLevel_Contact)
		{
			Contacts++;
		}

		if (Region.ResistanceLevel == eResLevel_Outpost)
		{
			Contacts++;
			Relays++;
		}
	}
}

function SetNextSpawnAt(optional bool StartingChain = false)
{
	local int WorkRequired, Variance;
	local bool bVarianceHigher;

	WorkRequired = `ScaleStrategyArrayInt(WorkRequiredForSpawn);
	NextSpawnAt = WorkRequired;

	if (StartingChain == false)
	{
		Variance = `SYNC_RAND(`ScaleStrategyArrayInt(WorkRequiredForSpawnVariance));

		bVarianceHigher = `SYNC_RAND(2) < 1;
		if (!bVarianceHigher) Variance *= -1;

		NextSpawnAt = WorkRequired + Variance;
	}

	`CI_Trace("Next chain at" @ NextSpawnAt @ "work");
}

////////////////
/// Spawning ///
////////////////

function SpawnActivityChain (XComGameState NewGameState)
{
	local XComGameState_ActivityChain ChainState;
	local X2ActivityChainTemplate ChainTemplate;

	BuildChainDeck();
	ChainTemplate = PickChainToSpawn(NewGameState);

	if (ChainTemplate == none)
	{
		`RedScreen("CI: Cannot spawn chain - failed to pick a chain");
		return;
	}

	`CI_Trace("All inputs ok, spawning chain");

	ChainState = ChainTemplate.CreateInstanceFromTemplate(NewGameState);
	ChainState.StartNextStage(NewGameState);
}

static protected function BuildChainDeck ()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityChainTemplate ChainTemplate;
	local X2DataTemplate DataTemplate;
	local X2CardManager CardManager;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CardManager = class'X2CardManager'.static.GetCardManager();

	foreach TemplateManager.IterateTemplates(DataTemplate)
	{
		ChainTemplate = X2ActivityChainTemplate(DataTemplate);
		if (ChainTemplate == none) continue;

		if (ChainTemplate.SpawnInDeck)
		{
			CardManager.AddCardToDeck('ActivityChainSpawner', string(ChainTemplate.DataName), ChainTemplate.NumInDeck);
		}
	}
}

protected function X2ActivityChainTemplate PickChainToSpawn (XComGameState NewGameState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityChainTemplate ChainTemplate;
	local X2CardManager CardManager;
	local array<string> CardLabels;
	local string Card;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CardManager = class'X2CardManager'.static.GetCardManager();
	
	CardManager.GetAllCardsInDeck('ActivityChainSpawner', CardLabels);
	foreach CardLabels(Card)
	{
		ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate(name(Card)));
		if (ChainTemplate == none) continue;
		
		if (!ChainTemplate.SpawnInDeck) continue;
		if (!ChainTemplate.DeckReq(NewGameState)) continue;

		CardManager.MarkCardUsed('ActivityChainSpawner', Card);

		return ChainTemplate;
	}

	return none;
}

///////////////////
/// Dark events ///
///////////////////

// Called from X2EventListener_Infiltration::PostEndOfMonth
static function SpawnCounterDarkEvents (XComGameState NewGameState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_HeadquartersAlien AlienHQ;
	
	local array<StateObjectReference> ChainObjectRefs;
	local XComGameState_DarkEvent DarkEventState;
	local StateObjectReference DarkEventRef, SelectedRegion;
	local array<StateObjectReference> DarkEventRefs, RegionRefs;
	
	local XComGameState_ActivityChain ChainState;
	local X2ActivityChainTemplate ChainTemplate;

	local int i;

	AlienHQ = class'UIUtilities_Strategy'.static.GetAlienHQ();
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ChainTemplate = X2ActivityChainTemplate(TemplateManager.FindStrategyElementTemplate('ActivityChain_CounterDarkEvent'));

	// Step 1: spawn the chains

	RegionRefs = GetContactedRegions();
	DarkEventRefs = AlienHQ.ChosenDarkEvents;

	for (i = 0; i < DarkEventRefs.Length; i++)
	{
		// No regions left to assign DEs, skip the rest of them
		if (RegionRefs.Length == 0) break;
		
		if (DarkEventRefs.Length == 0)
		{
			`RedScreen("CI: Dark Events array empty when it should be filled");
			break;
		}

		DarkEventRef = DarkEventRefs[`SYNC_RAND_STATIC(DarkEventRefs.Length)];
		DarkEventRefs.RemoveItem(DarkEventRef);

		DarkEventState = XComGameState_DarkEvent(`XCOMHISTORY.GetGameStateForObjectID(DarkEventRef.ObjectID));
		if (DarkEventState == none) continue;

		// Chosen-initiated DEs cannot be countered
		if (DarkEventState.bChosenActionEvent) continue;

		ChainObjectRefs.Length = 0;
		ChainObjectRefs.AddItem(DarkEventRef);

		SelectedRegion = RegionRefs[`SYNC_RAND_STATIC(RegionRefs.Length)];
		RegionRefs.RemoveItem(SelectedRegion);

		ChainState = ChainTemplate.CreateInstanceFromTemplate(NewGameState, ChainObjectRefs);
		ChainState.PrimaryRegionRef = SelectedRegion;
		ChainState.SecondaryRegionRef = SelectedRegion;
		ChainState.StartNextStage(NewGameState);
	}
}

static protected function array<XComGameState_ActivityChain> SortChainsRandomly (array<XComGameState_ActivityChain> Chains)
{
	local array<XComGameState_ActivityChain> Result;
	local XComGameState_ActivityChain Chain;

	while (Chains.Length > 0)
	{
		Chain = Chains[`SYNC_RAND_STATIC(Chains.Length)];

		Chains.RemoveItem(Chain);
		Result.AddItem(Chain);
	}

	return Result;
}

///////////////////////////
/// Creation and access ///
///////////////////////////

static function XComGameState_ActivityChainSpawner GetSpawner(optional bool AllowNull = false)
{
	return XComGameState_ActivityChainSpawner(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_ActivityChainSpawner', AllowNull));
}

static function CreateSpawner(optional XComGameState StartState)
{
	local XComGameState_ActivityChainSpawner Spawner;
	local XComGameState NewGameState;

	if (StartState != none)
	{
		Spawner = XComGameState_ActivityChainSpawner(StartState.CreateNewStateObject(class'XComGameState_ActivityChainSpawner'));
		Spawner.PreviousWork = `ScaleStrategyArrayInt(default.GameStartWork);
		Spawner.PreviousWorkSubmittedAt = GetGameTimeFromHistory();
		Spawner.SetCachedWorkRate();
		Spawner.SetNextSpawnAt(true);
	}
	// Do not create if already exists
	else if (GetSpawner(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating Activity Chain Spawner singleton");
		Spawner = XComGameState_ActivityChainSpawner(NewGameState.CreateNewStateObject(class'XComGameState_ActivityChainSpawner'));
		Spawner.PreviousWorkSubmittedAt = GetGameTimeFromHistory();
		Spawner.SetCachedWorkRate();
		Spawner.SetNextSpawnAt(true);
		
		`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	}
}

static protected function TDateTime GetGameTimeFromHistory()
{
	return XComGameState_GameTime(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_GameTime')).CurrentTime;
}

/////////////////////
/// Debug helpers ///
/////////////////////

static function PrintDebugInfo()
{
	local XComGameState_ActivityChainSpawner Spawner;
	Spawner = GetSpawner(true);

	if (Spawner == none)
	{
		`log("PrintDebugInfo - no spawner found in history",, 'CI_ACSpawner');
		return;
	}

	`CI_Trace("Submitted work - " $ Spawner.PreviousWork); // TODO: Figure out how to concatenate TDateTime
	`CI_Trace("Next spawn at" @ Spawner.NextSpawnAt);
	`CI_Trace("Cached work rate - " $ Spawner.CachedWorkRate);
	`CI_Trace("Current work rate - " $ Spawner.GetCurrentWorkRate());
}

//////////////////////
/// Region Helpers ///
//////////////////////

static function array<StateObjectReference> GetContactedRegions ()
{
	local array<StateObjectReference> RegionRefs;
	local XComGameState_WorldRegion RegionState;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
		if (RegionState.HaveMadeContact())
		{
			RegionRefs.AddItem(RegionState.GetReference());
		}
	}
	
	return RegionRefs;
}
