//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: A singleton container XCGS object to hold various mod-added properties so
//           that we don't need to override other XCGS classes
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_CovertInfiltrationInfo extends XComGameState_BaseObject config(Infiltration);

/////////////////////
/// Strategy vars ///
/////////////////////

var bool bCompletedFirstOrdersAssignment; // If false (just built the ring) - allow player to assign orders at any time without waiting for supply drop
var bool bRingStaffReplacement; // True if we are replacing the staff assigned to resistance ring and no empty wildcard slots - do not un-grant/grant slot
var bool bPopupNewActionOnGeoscapeEntrance; // Used after completing P1s
var array<StateObjectReference> MissionsToShowAlertOnStrategyMap; // Used to highlight new missions after spawning one to avoid full screen popups
var array<name> TutorialStagesShown; // Template names of CI's tutorial stages that have been shown already

var int CurrentBarracksLimit;

var config int StartingBarracksLimit;
var config int BarracksLimitIncreaseI;
var config int BarracksLimitIncreaseII;

/////////////////////
/// Tactical vars ///
/////////////////////

var bool bAirPatrolsTriggered;

////////////////////////
/// Tactical helpers ///
////////////////////////

static function ResetForBeginTacticalPlay ()
{
	local XComGameState_CovertInfiltrationInfo NewInfo;
	local XComGameState NewGameState;
	
	// Make sure info already exists - required for tql/skirmish
	CreateInfo();

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Resetting XCGS_CovertInfiltrationInfo for begin play");
	NewInfo = GetInfo();
	NewInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', NewInfo.ObjectID));

	NewInfo.bAirPatrolsTriggered = false;

	`SubmitGameState(NewGameState);
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
		Info.CurrentBarracksLimit = default.StartingBarracksLimit;
		return;
	}

	// Do not create if already exists
	if (GetInfo(true) != none) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating CI Info Singleton");
	
	Info = XComGameState_CovertInfiltrationInfo(NewGameState.CreateNewStateObject(class'XComGameState_CovertInfiltrationInfo'));
	Info.InitExistingCampaign();
		
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}

protected function InitExistingCampaign()
{
	if (class'UIUtilities_Strategy'.static.GetResistanceHQ().NumMonths > 0)
	{
		bCompletedFirstOrdersAssignment = true;
	}

	CurrentBarracksLimit = default.StartingBarracksLimit;
}

/////////////////////
/// Barracks Size ///
/////////////////////

function IncreaseBarracksSizeI(XComGameState UpdateState)
{
	local XComGameState_CovertInfiltrationInfo UpdatedInfo;

	UpdatedInfo = ChangeForGamestate(UpdateState);

	UpdatedInfo.CurrentBarracksLimit += default.BarracksLimitIncreaseI;
}

function IncreaseBarracksSizeII(XComGameState UpdateState)
{	
	local XComGameState_CovertInfiltrationInfo UpdatedInfo;

	UpdatedInfo = ChangeForGamestate(UpdateState);

	UpdatedInfo.CurrentBarracksLimit += default.BarracksLimitIncreaseII;
}