class XComGameState_PhaseOneActionsSpawner extends XComGameState_BaseObject;

var float PreviousWork;
var TDateTime PreviousWorkSubmittedAt;

// Work rate is meaured in hours
var int CurrentWorkRate;

var const config array<int> GameStartWork; // How much work to add when the campaign starts
var const config array<int> WorkRatePerContact;
var const config array<int> WorkRatePerRelay;
var const config array<int> WorkRequiredForP1;
var const config array<int> WorkRequiredForP1Variance;
var const config array<name> ActionsToSpawn;

static function Update();

static function GetNumContactsAndRelays(out int Contacts, out int Relays, optional XComGameState StartState);

////////////////
/// Creation ///
////////////////

static function CreateSpawner(optional XComGameState StartState)
{
	local XComGameState_PhaseOneActionsSpawner Spawner;
	local XComGameState NewGameState;

	if (StartState != none)
	{
		Spawner = XComGameState_PhaseOneActionsSpawner(StartState.CreateNewStateObject(class'XComGameState_PhaseOneActionsSpawner'));
		Spawner.PreviousWork = `ScaleStrategyArrayInt(GameStartWork);
		// TODO: Start time
		return;
	}

	// Do not create if already exists
	if (GetInfo(true) != none) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating CI Info Singleton");
	
	Info = XComGameState_CovertInfiltrationInfo(NewGameState.CreateNewStateObject(class'XComGameState_CovertInfiltrationInfo'));
	Info.InitExistingCampaign();
		
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}