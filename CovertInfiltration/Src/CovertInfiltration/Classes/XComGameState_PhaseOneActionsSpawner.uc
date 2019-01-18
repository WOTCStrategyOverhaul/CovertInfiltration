class XComGameState_PhaseOneActionsSpawner extends XComGameState_BaseObject config(Infiltration);

var protectedwrite float PreviousWork;
var protectedwrite TDateTime PreviousWorkSubmittedAt;

// Work rate is meaured in hours
var protectedwrite int CurrentWorkRate;
var protectedwrite int NextSpawnAt; // In work units

var const config array<int> GameStartWork; // How much work to add when the campaign starts

var const config array<int> WorkRateXcom;
var const config array<int> WorkRatePerContact;
var const config array<int> WorkRatePerRelay;
var const config bool bStaringRegionContributesToWork;

var const config array<int> WorkRequiredForP1;
var const config array<int> WorkRequiredForP1Variance;

var const config array<name> ActionsToSpawn;

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

	// STEP 1: we check if we are due spawning an action at CurrentWorkRate
	if (Spawner.ShouldSpawnAction())
	{
		bDirty = true;
		Spawner.SpawnAction(NewGameState);
		Spawner.ResetProgress();
		Spawner.SetNextSpawnAt();
	}

	// STEP 2: See if we need to adjust current work rate
	if (Spawner.CurrentWorkRate != GetCurrentWorkRate())
	{
		bDirty = true;
		Spawner.SubmitWorkDone();
		Spawner.SetCurrentWorkRate();
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

function bool ShouldSpawnAction()
{
	local float WorkDone;

	WorkDone = PreviousWork + GetWorkDoneInCurrentPeriod();

	return WorkDone >= NextSpawnAt;
}

function SpawnAction(XComGameState NewGameState)
{
	// TODO: Spawn
	// TODO: Popup
}

function ResetProgress()
{
	PreviousWork = 0;
	PreviousWorkSubmittedAt = `STRATEGYRULES.GameTime;
}

function SubmitWorkDone()
{
	PreviousWork += GetWorkDoneInCurrentPeriod();
	PreviousWorkSubmittedAt = `STRATEGYRULES.GameTime;
}

function float GetWorkDoneInCurrentPeriod()
{
	local int MinutesSinceLastSubmission;
	local float HoursSinceLastSubmission;

	MinutesSinceLastSubmission = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInMinutes(`STRATEGYRULES.GameTime, PreviousWorkSubmittedAt);
	HoursSinceLastSubmission = MinutesSinceLastSubmission / 60;
	
	return CurrentWorkRate * HoursSinceLastSubmission;
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

function SetCurrentWorkRate()
{
	CurrentWorkRate = GetCurrentWorkRate();
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
		Spawner.SetCurrentWorkRate();
		Spawner.SetNextSpawnAt();
	}
	// Do not create if already exists
	else if (GetSpawner(true) != none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating P1 Spawner singleton");
	
		Spawner = XComGameState_PhaseOneActionsSpawner(NewGameState.CreateNewStateObject(class'XComGameState_PhaseOneActionsSpawner'));
		Spawner.PreviousWorkSubmittedAt = GetGameTimeFromHistory();
		Spawner.SetCurrentWorkRate();
		Spawner.SetNextSpawnAt();
		
		`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	}
}

static protected function TDateTime GetGameTimeFromHistory()
{
	return XComGameState_GameTime(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_GameTime')).CurrentTime;
}