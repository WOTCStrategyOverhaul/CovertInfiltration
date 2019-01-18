class XComGameState_PhaseOneActionsSpawner extends XComGameState_BaseObject;

var float PreviousWork;
var TDateTime PreviousWorkSubmittedAt;

// Work rate is meaured in hours
var int CurrentWorkRate;
var int NextSpawnAt; // In work units

var const config array<int> GameStartWork; // How much work to add when the campaign starts
var const config array<int> WorkRateXcom;
var const config array<int> WorkRatePerContact;
var const config array<int> WorkRatePerRelay;
var const config array<int> WorkRequiredForP1;
var const config array<int> WorkRequiredForP1Variance;
var const config array<name> ActionsToSpawn;

static function Update();

static function int GetCurrentWorkRate()
{
	local int Contacts, Relays, WorkRate;

	GetNumContactsAndRelays(Contacts, Relays);

	WorkRate = `ScaleStrategyArrayInt(WorkRateXcom);
	Workrate += Contacts * `ScaleStrategyArrayInt(WorkRatePerContact);
	Workrate += Relays * `ScaleStrategyArrayInt(WorkRatePerRelay);

	return WorkRate;
}

function SetCurrentWorkRate()
{
	CurrentWorkRate = GetCurrentWorkRate();
}

static function GetNumContactsAndRelays(out int Contacts, out int Relays)
{
	local XComGameState_WorldRegion Region;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	Contacts = 0;
	Relays = 0;

	foreach History.IterateByClassType(class'XComGameState_WorldRegion', Region)
	{
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

	bVarianceHigher = `SYNC_RAND(2) > 1;
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
		Spawner.PreviousWork = `ScaleStrategyArrayInt(GameStartWork);
		Spawner.PreviousWorkSubmittedAt = GetGameTimeFromHistory();
		Spawner.SetCurrentWorkRate();
		Spawner.SetNextSpawnAt();
	}
	// Do not create if already exists
	else if (GetSpawner(true) != none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating CI P1 Spawner singleton");
	
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