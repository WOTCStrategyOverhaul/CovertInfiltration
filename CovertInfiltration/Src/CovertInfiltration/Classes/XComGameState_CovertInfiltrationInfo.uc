//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: A singleton container XCGS object to hold various mod-added properties so
//           that we don't need to override other XCGS classes
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CovertInfiltrationInfo extends XComGameState_BaseObject;

struct CharacterGroupKillCount
{
	var name CharacterGroup;
	var int KillCount;
};

// Encoding scheme: 00000000
//                  0        - beta (0) or workshop (1)
//                   00      - release number (eg. beta **2**)
//                     00000 - patch number
//
// This allows to easy compare the saved version with integer comparison, eg.
// if (CurrentVersion > CIInfo.ModVersion)
//
// See DLCInfo for the explanation of ModVersion vs StrategyModVersion
var int ModVersion;
var int StrategyModVersion;

const CURRENT_MOD_VERSION = 10000002; // 1.0 patch 2

/////////////////////
/// Strategy vars ///
/////////////////////

var bool bCompletedFirstOrdersAssignment; // If false (just built the ring) - allow player to assign orders at any time without waiting for supply drop
var bool bRingStaffReplacement; // True if we are replacing the staff assigned to resistance ring and no empty wildcard slots - do not un-grant/grant slot
var bool bPopupNewActionOnGeoscapeEntrance; // Used after completing P1s
var array<StateObjectReference> MissionsToShowAlertOnStrategyMap; // Used to highlight new missions after spawning one to avoid full screen popups
var array<StateObjectReference> CovertActionsToRemove; // Used to mark outdated CAs for removal when the player next enters the geoscape screen
var bool bBlackMarketLeadPurchased; // True when the player first puchases an actionable facility lead from the BM. Prevents it from spawning again

var array<name> TutorialStagesShown; // Template names of CI's tutorial stages that have been shown already
var bool bAlienFacilityBuiltTutorialPending; // Set when the first facility is built and we are waiting for Geoscape control to return to the player to show the tutorial

// Stores the references to soldiers that are coming back from an infiltration.
// This way we can upgrade their gear when exiting from post mission sequence, ensuring that soldiers don't have magically upgraded items when exiting the skyranger
var array<StateObjectReference> UnitsToConsiderUpgradingGearOnMissionExit;

/////////////////////
/// Tactical vars ///
/////////////////////

var bool bAirPatrolsTriggered;
var bool bCommsJammingTriggered;
var bool bSupplyExtractionRnfsStarted;

// Kill XP scaling system
var int NumEnemiesAtMissionStart;
var protected array<CharacterGroupKillCount> CharacterGroupsKillTracker;

/////////////////
/// Misc vars ///
/////////////////

// TODO: Description
var array<StateObjectReference> UnitsStartedMissionBelowReadyWill;

////////////////////////
/// Tactical helpers ///
////////////////////////

static function ResetPreMission (XComGameState StartGameState)
{
	local XComGameState_CovertInfiltrationInfo NewInfo;
	
	NewInfo = GetInfo();
	NewInfo = XComGameState_CovertInfiltrationInfo(StartGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', NewInfo.ObjectID));

	NewInfo.bAirPatrolsTriggered = false;
	NewInfo.bCommsJammingTriggered = false;
	NewInfo.bSupplyExtractionRnfsStarted = false;

	NewInfo.NumEnemiesAtMissionStart = default.NumEnemiesAtMissionStart;
	NewInfo.CharacterGroupsKillTracker.Length = 0;

	// It's supposed to be cleaned by this point, but make sure that's the case
	NewInfo.ResetUnitsStartedMissionBelowReadyWill();
}

////////////////////
/// Misc helpers ///
////////////////////

function ResetUnitsStartedMissionBelowReadyWill ()
{
	UnitsStartedMissionBelowReadyWill.Length = 0;
}

/////////////////
/// Accessors ///
/////////////////

static function XComGameState_CovertInfiltrationInfo GetInfo(optional bool AllowNull = false)
{
	return XComGameState_CovertInfiltrationInfo(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CovertInfiltrationInfo', AllowNull));
}

static function XComGameState_CovertInfiltrationInfo ChangeForGamestate(XComGameState NewGameState)
{
	local XComGameState_CovertInfiltrationInfo NewInfo;

	foreach NewGameState.IterateByClassType(class'XComGameState_CovertInfiltrationInfo', NewInfo)
	{
		break;
	}

	if (NewInfo == none)
	{
		NewInfo = GetInfo();
		NewInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', NewInfo.ObjectID));
	}

	return NewInfo;
}

// CharacterGroupsKillTracker

function int GetCharacterGroupsKills (name CharacterGroup)
{
	local int i;

	i = CharacterGroupsKillTracker.Find('CharacterGroup', CharacterGroup);

	return i == INDEX_NONE ? 0 : CharacterGroupsKillTracker[i].KillCount;
}

function RecordCharacterGroupsKill (name CharacterGroup, optional int Count = 1)
{
	Count = Max(Count, 0);
	SetCharacterGroupsKills(CharacterGroup, GetCharacterGroupsKills(CharacterGroup) + Count);
}

function SetCharacterGroupsKills (name CharacterGroup, int NewCount)
{
	local CharacterGroupKillCount CountStruct;
	local int i;

	i = CharacterGroupsKillTracker.Find('CharacterGroup', CharacterGroup);

	if (i == INDEX_NONE)
	{
		CountStruct.CharacterGroup = CharacterGroup;
		CountStruct.KillCount = NewCount;
		CharacterGroupsKillTracker.AddItem(CountStruct);
	}
	else
	{
		CharacterGroupsKillTracker[i].KillCount = NewCount;
	}
}

////////////////
/// Creation ///
////////////////

static function CreateInfo(optional XComGameState StartState)
{
	local XComGameState_CovertInfiltrationInfo Info;
	local XComGameState NewGameState;

	if (StartState != none)
	{
		Info = XComGameState_CovertInfiltrationInfo(StartState.CreateNewStateObject(class'XComGameState_CovertInfiltrationInfo'));
		Info.ModVersion = CURRENT_MOD_VERSION;
		return;
	}

	// Do not create if already exists
	if (GetInfo(true) != none) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating CI Info Singleton");
	
	Info = XComGameState_CovertInfiltrationInfo(NewGameState.CreateNewStateObject(class'XComGameState_CovertInfiltrationInfo'));
	Info.ModVersion = CURRENT_MOD_VERSION;
	Info.InitExistingCampaign();

	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}

protected function InitExistingCampaign()
{
	if (class'UIUtilities_Strategy'.static.GetResistanceHQ().NumMonths > 0)
	{
		bCompletedFirstOrdersAssignment = true;
	}
}

defaultproperties
{
	NumEnemiesAtMissionStart = -1;

	ModVersion = 0; // Loading from a save without ModVersion feature
	StrategyModVersion = 0; // Loading from a save without ModVersion feature
}