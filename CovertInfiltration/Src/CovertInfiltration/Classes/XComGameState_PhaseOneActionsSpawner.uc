//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Replacement for base game MissionCalendar which instead spawns CAs based on
///          "work" done by XCom (base) and contacted regions and relays built (bonus)
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_PhaseOneActionsSpawner extends XComGameState_BaseObject config(Infiltration);

var protectedwrite float PreviousWork;
var protectedwrite TDateTime PreviousWorkSubmittedAt;

// Work rate is meaured in hours
var protectedwrite int CachedWorkRate;
var protectedwrite int NextSpawnAt; // In work units

var name LastActionSpawned;

var const config array<int> WorkRateXcom;
var const config array<int> WorkRatePerContact;
var const config array<int> WorkRatePerRelay;
var const config bool bStaringRegionContributesToWork;

var const config array<int> GameStartWork; // How much work to add when the campaign starts
var const config array<int> WorkRequiredForP1;
var const config array<int> WorkRequiredForP1Variance;

var const config array<name> ActionsToSpawn;

var config int MinSupplies;
var config int MinIntel;

var config int EXPIRATION_BASE_TIME;
var config int EXPIRATION_VARIANCE;

static function Update()
{
	local XComGameState_PhaseOneActionsSpawner Spawner;
	local XComGameState NewGameState;
	local bool bDirty;

	Spawner = GetSpawner(false); // Do not spam redscreens every tick
	if (Spawner == none)
	{
		`RedScreenOnce("CI: Failed to fetch XComGameState_PhaseOneActionsSpawner for ticking");
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: XComGameState_PhaseOneActionsSpawner update");
	Spawner = XComGameState_PhaseOneActionsSpawner(NewGameState.ModifyStateObject(class'XComGameState_PhaseOneActionsSpawner', Spawner.ObjectID));

	// STEP 1: we check if we are due spawning an action at CachedWorkRate
	if (Spawner.ShouldSpawnAction())
	{
		`log("Enough work for P1, staring spawning",, 'CI_P1Spawner');
		bDirty = true;
		
		Spawner.LastActionSpawned = Spawner.SpawnAction(NewGameState);
		Spawner.ResetProgress();
		Spawner.SetNextSpawnAt();
	}

	// STEP 2: See if we need to adjust current work rate
	if (Spawner.CachedWorkRate != GetCurrentWorkRate())
	{
		`log("Cached work rate (" $ Spawner.CachedWorkRate $ ") doesn't match current, submitting work done and caching new work rate",, 'CI_P1Spawner');
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

function bool ShouldSpawnAction()
{
	local float WorkDone;

	WorkDone = PreviousWork + GetWorkDoneInCurrentPeriod();

	return WorkDone >= NextSpawnAt;
}

function ResetProgress()
{
	`log("Reset progress for P1",, 'CI_P1Spawner');

	PreviousWork = 0;
	PreviousWorkSubmittedAt = `STRATEGYRULES.GameTime;
}

function SubmitWorkDone()
{
	PreviousWork += GetWorkDoneInCurrentPeriod();
	PreviousWorkSubmittedAt = `STRATEGYRULES.GameTime;

	`log("Submitted work done, now" $ PreviousWork,, 'CI_P1Spawner');
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
	`log("New cached work rate - " $ CachedWorkRate,, 'CI_P1Spawner');
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

	WorkRequired = `ScaleStrategyArrayInt(WorkRequiredForP1);
	Variance = `SYNC_RAND(`ScaleStrategyArrayInt(WorkRequiredForP1Variance));

	bVarianceHigher = `SYNC_RAND(2) < 1;
	if (!bVarianceHigher) Variance *= -1;

	NextSpawnAt = WorkRequired + Variance;

	`log("Next P1 at" @ NextSpawnAt @ "work",, 'CI_P1Spawner');
}

////////////////
/// Spawning ///
////////////////

function name SpawnAction(XComGameState NewGameState)
{
	local X2CovertActionTemplate ActionTemplate;
	local XComGameState_ResistanceFaction Faction;
	local StateObjectReference NewActionRef;

	// TODO: Better logic for picking location/faction of action:
	// 1) Get a random contacted region that has the least infiltrations right now
	// 2) Get a faction that controls that region
	// 3) If said faction isn't met pick one that has the least infiltrations currently

	ActionTemplate = PickActionToSpawn();
	Faction = GetFactionForNewAction();

	if (ActionTemplate == none)
	{
		`RedScreen("CI: Cannot spawn P1 actions - the template is none");
		return '';
	}
	if (Faction == none)
	{
		`RedScreen("CI: Cannot spawn P1 actions - no faction that met XCom");
		return '';
	}

	`log("All inputs ok, spawning action",, 'CI_P1Spawner');

	// Spawn
	Faction = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', Faction.ObjectID));
	NewActionRef = Faction.CreateCovertAction(NewGameState, ActionTemplate, eFactionInfluence_Minimal);
	Faction.CovertActions.AddItem(NewActionRef);
	AddExpiration(NewGameState, NewActionRef);

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(NewActionRef, NewGameState);
	class'X2EventManager'.static.GetEventManager().TriggerEvent('P1ActionSpawned', NewGameState.GetGameStateForObjectID(NewActionRef.ObjectID), self, NewGameState);

	return ActionTemplate.DataName;
}

function X2CovertActionTemplate PickActionToSpawn()
{
	local X2StrategyElementTemplateManager Manager;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateManager;
	local name PickedActionName;
	local array<StateObjectReference> DarkEvents;

	DarkEvents = class'X2StrategyElement_InfiltrationRewards'.static.GetRandomDarkEvents(4);
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	if (default.ActionsToSpawn.Length == 0)
	{
		`RedScreen("CI: Cannot spawn P1 actions - ActionsToSpawn is empty");
		return none;
	}

	//`LOG(LastActionSpawned);

	if((
		class'X2StrategyElement_DefaultRewards'.static.IsEngineerRewardNeeded() ||
		class'X2StrategyElement_DefaultRewards'.static.IsScientistRewardNeeded()) &&
		LastActionSpawned != 'CovertAction_P1Jailbreak')
	{
		PickedActionName = 'CovertAction_P1Jailbreak';
		//`LOG("PERSONNEL NEEDED");
	}
	else if(DarkEvents.Length > 1 && LastActionSpawned != 'CovertAction_P1DarkEvent')
	{
		PickedActionName = 'CovertAction_P1DarkEvent';
		//`LOG("ACTIVITY NEEDED");
	}
	else if((
		!XComHQ.HasItem(ItemTemplateManager.FindItemTemplate('Supplies'), default.MinSupplies) || 
		!XComHQ.HasItem(ItemTemplateManager.FindItemTemplate('Intel'), default.MinIntel)) &&
		LastActionSpawned != 'CovertAction_P1SupplyRaid')
	{
		PickedActionName = 'CovertAction_P1SupplyRaid';
		//`LOG("RESOURCES NEEDED");
	}
	else
	{
		//`LOG("RANDOM SPAWN");
		if(DarkEvents.Length == 0)
		{
			PickedActionName = ExclusionRoll(LastActionSpawned, true);
		}
		else
		{
			PickedActionName = ExclusionRoll(LastActionSpawned, false);
		}
	}
	
	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	return X2CovertActionTemplate(Manager.FindStrategyElementTemplate(PickedActionName));
}

static function name ExclusionRoll(name Exclude, bool NoDarkEvent)
{
	local array<name> RefinedList;

	RefinedList = default.ActionsToSpawn;
	RefinedList.RemoveItem(Exclude);

	if(NoDarkEvent && Exclude != 'CovertAction_P1DarkEvent')
	{
		RefinedList.RemoveItem('CovertAction_P1DarkEvent');
	}

	return RefinedList[`SYNC_RAND_STATIC(RefinedList.Length)];
}

static function XComGameState_ResistanceFaction GetFactionForNewAction()
{
	local XComGameState_ResistanceFaction Faction;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', Faction)
	{
		if (Faction.bMetXCom)
		{
			return Faction;
		}
	}

	return none;
}

///////////////////////////
/// Creation and access ///
///////////////////////////

static function XComGameState_PhaseOneActionsSpawner GetSpawner(optional bool AllowNull = false)
{
	return XComGameState_PhaseOneActionsSpawner(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_PhaseOneActionsSpawner', AllowNull));
}

static function CreateSpawner(optional XComGameState StartState)
{
	local XComGameState_PhaseOneActionsSpawner Spawner;
	local XComGameState NewGameState;

	if (StartState != none)
	{
		Spawner = XComGameState_PhaseOneActionsSpawner(StartState.CreateNewStateObject(class'XComGameState_PhaseOneActionsSpawner'));
		Spawner.PreviousWork = `ScaleStrategyArrayInt(default.GameStartWork);
		Spawner.PreviousWorkSubmittedAt = GetGameTimeFromHistory();
		Spawner.SetCachedWorkRate();
		Spawner.SetNextSpawnAt();
	}
	// Do not create if already exists
	else if (GetSpawner(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating P1 Spawner singleton");
		Spawner = XComGameState_PhaseOneActionsSpawner(NewGameState.CreateNewStateObject(class'XComGameState_PhaseOneActionsSpawner'));
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

simulated function AddExpiration(XComGameState NewGameState, StateObjectReference ActionRef)
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local TDateTime Expiration;

	Expiration = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
	ActionExpirationManager = class'XComGameState_CovertActionExpirationManager'.static.GetExpirationManager();
	ActionExpirationManager = XComGameState_CovertActionExpirationManager(NewGameState.ModifyStateObject(class'XComGameState_CovertActionExpirationManager', ActionExpirationManager.ObjectID));

	class'X2StrategyGameRulesetDataStructures'.static.AddHours(Expiration, EXPIRATION_BASE_TIME*24 + CreateExpirationVariance());

	ActionExpirationManager.AddActionExpirationInfo(ActionRef, Expiration);
}

simulated function int CreateExpirationVariance()
{
	local int Variance;
	local bool bNegVariance;

	Variance = `SYNC_RAND(EXPIRATION_VARIANCE);

	// roll chance for negative variance
	bNegVariance = `SYNC_RAND(2) < 1;
	if (bNegVariance) Variance *= -1;

	return Variance;
}

/////////////////////
/// Debug helpers ///
/////////////////////

static function PrintDebugInfo()
{
	local XComGameState_PhaseOneActionsSpawner Spawner;
	Spawner = GetSpawner(true);

	if (Spawner == none)
	{
		`log("PrintDebugInfo - no spawner found in history",, 'CI_P1Spawner');
		return;
	}

	`log("Submitted work - " $ Spawner.PreviousWork,, 'CI_P1Spawner'); // TODO: Figure out how to concatenate TDateTime
	`log("Next spawn at" @ Spawner.NextSpawnAt,, 'CI_P1Spawner');
	`log("Cached work rate - " $ Spawner.CachedWorkRate,, 'CI_P1Spawner');
	`log("Current work rate - " $ Spawner.GetCurrentWorkRate(),, 'CI_P1Spawner');
}