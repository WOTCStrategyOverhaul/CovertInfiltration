//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Replacement for base game MissionCalendar which instead spawns CAs based on
///          "work" done by XCom (base) and contacted regions and relays built (bonus)
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_ActivityChainSpawner extends XComGameState_BaseObject config(Infiltration);

var protectedwrite float PreviousWork;
var protectedwrite TDateTime PreviousWorkSubmittedAt;

// Work rate is meaured in hours
var protectedwrite int CachedWorkRate;
var protectedwrite int NextSpawnAt; // In work units

var array<ChainDeckEntry> ChainDeck;

var const config array<int> WorkRateXcom;
var const config array<int> WorkRatePerContact;
var const config array<int> WorkRatePerRelay;
var const config bool bStaringRegionContributesToWork;

var const config array<int> GameStartWork; // How much work to add when the campaign starts
var const config array<int> WorkRequiredForSpawn;
var const config array<int> WorkRequiredForSpawnVariance;

var config int MinSupplies;
var config int MinIntel;

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
		`log("Enough work for P1, starting spawning",, 'CI_ACSpawner');
		bDirty = true;
		
		Spawner.SpawnActivityChain(NewGameState);
		Spawner.ResetProgress();
		Spawner.SetNextSpawnAt();
	}

	// STEP 2: See if we need to adjust current work rate
	if (Spawner.CachedWorkRate != GetCurrentWorkRate())
	{
		`log("Cached work rate (" $ Spawner.CachedWorkRate $ ") doesn't match current, submitting work done and caching new work rate",, 'CI_ACSpawner');
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
	`log("Reset progress for P1",, 'CI_ACSpawner');

	PreviousWork = 0;
	PreviousWorkSubmittedAt = `STRATEGYRULES.GameTime;
}

function SubmitWorkDone()
{
	PreviousWork += GetWorkDoneInCurrentPeriod();
	PreviousWorkSubmittedAt = `STRATEGYRULES.GameTime;

	`log("Submitted work done, now" $ PreviousWork,, 'CI_ACSpawner');
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
	`log("New cached work rate - " $ CachedWorkRate,, 'CI_ACSpawner');
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

function SetNextSpawnAt()
{
	local int WorkRequired, Variance;
	local bool bVarianceHigher;

	WorkRequired = `ScaleStrategyArrayInt(WorkRequiredForSpawn);
	Variance = `SYNC_RAND(`ScaleStrategyArrayInt(WorkRequiredForSpawnVariance));

	bVarianceHigher = `SYNC_RAND(2) < 1;
	if (!bVarianceHigher) Variance *= -1;

	NextSpawnAt = WorkRequired + Variance;

	`log("Next chain at" @ NextSpawnAt @ "work",, 'CI_ACSpawner');
}

////////////////
/// Spawning ///
////////////////
/*
function SpawnAction(XComGameState NewGameState)
{
	local X2CovertActionTemplate ActionTemplate;
	local XComGameState_ResistanceFaction Faction;
	local StateObjectReference NewActionRef;

	ActionTemplate = PickActionToSpawn();
	Faction = GetFactionForNewAction();

	if (ActionTemplate == none)
	{
		`RedScreen("CI: Cannot spawn P1 actions - the template is none");
		return;
	}
	if (Faction == none)
	{
		`RedScreen("CI: Cannot spawn P1 actions - no faction that met XCom");
		return;
	}

	`log("All inputs ok, spawning action",, 'CI_ACSpawner');

	// Spawn
	Faction = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', Faction.ObjectID));
	NewActionRef = Faction.CreateCovertAction(NewGameState, ActionTemplate, eFactionInfluence_Minimal);
	Faction.CovertActions.AddItem(NewActionRef);
	AddExpiration(NewGameState, NewActionRef);

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(NewActionRef, NewGameState);
	class'X2EventManager'.static.GetEventManager().TriggerEvent('P1ActionSpawned', NewGameState.GetGameStateForObjectID(NewActionRef.ObjectID), self, NewGameState);

	LastChainSpawned = ActionTemplate.DataName;
}
*/

function SpawnActivityChain (XComGameState NewGameState)
{
	local XComGameState_ActivityChain ChainState;
	local X2ActivityChainTemplate ChainTemplate;

	ChainTemplate = PickChainToSpawn(NewGameState);
	
	if (ChainTemplate == none)
	{
		`RedScreen("CI: Cannot spawn chain - the template is none");
		return;
	}

	`log("All inputs ok, spawning chain",, 'CI_ACSpawner');

	ChainState = ChainTemplate.CreateInstanceFromTemplate(NewGameState);
	ChainState.StartNextStage(NewGameState);
}

function X2ActivityChainTemplate PickChainToSpawn(XComGameState NewGameState)
{
	local X2StrategyElementTemplateManager Manager;
	local XComGameState_HeadquartersXCom XComHQ;
	local name PickedChainName;
	
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	if (ChainDeck.Length == 0)
	{
		RegenerateChainDeck(NewGameState);
	}

	PickedChainName = PickFromChainDeck();
	
	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	return X2ActivityChainTemplate(Manager.FindStrategyElementTemplate(PickedChainName));
}

function RegenerateChainDeck(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local X2ActivityChainTemplate ChainTemplate;
	local ChainDeckEntry DeckEntry;

	History = `XCOMHISTORY;

	ChainDeck.Length = 0;
	
	foreach History.IterateByClassType(class'X2ActivityChainTemplate', ChainTemplate)
	{
		if (ChainTemplate.SpawnInDeck)
		{
			if (ChainTemplate.DeckReq == none || ChainTemplate.DeckReq(NewGameState))
			{
				DeckEntry.ChainName = ChainTemplate.DataName;
				DeckEntry.ChainTemplate = ChainTemplate;
				DeckEntry.NumInDeck = ChainTemplate.NumInDeck;
				ChainDeck.AddItem(DeckEntry);

				// TODO: add in support for bonus deck entries based on another condition as defined in chain template
			}
		}
	}
}

function name PickFromChainDeck()
{
	// TODO: turn the deck entries into a regular array and random draw from that
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
		Spawner.SetNextSpawnAt();
	}
	// Do not create if already exists
	else if (GetSpawner(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating Activity Chain Spawner singleton");
		Spawner = XComGameState_ActivityChainSpawner(NewGameState.CreateNewStateObject(class'XComGameState_ActivityChainSpawner'));
		Spawner.PreviousWorkSubmittedAt = GetGameTimeFromHistory();
		Spawner.SetCachedWorkRate();
		Spawner.SetNextSpawnAt();
		
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

	`log("Submitted work - " $ Spawner.PreviousWork,, 'CI_ACSpawner'); // TODO: Figure out how to concatenate TDateTime
	`log("Next spawn at" @ Spawner.NextSpawnAt,, 'CI_ACSpawner');
	`log("Cached work rate - " $ Spawner.CachedWorkRate,, 'CI_ACSpawner');
	`log("Current work rate - " $ Spawner.GetCurrentWorkRate(),, 'CI_ACSpawner');
}

defaultproperties
{

}
