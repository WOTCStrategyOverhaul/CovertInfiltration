//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Template for an infiltration mission as an activity
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ActivityTemplate_Infiltration extends X2ActivityTemplate_Mission config(Infiltration);

var name CovertActionName;

var localized string ActionRewardDisplayName;
var localized string ActionRewardDetails;

// Expiry in hours
var config bool bExpires;
var config int ExpirationBaseTime;
var config int ExpirationVariance;
var config bool ExpirationNotBlocksCleanup; // Inverted, so that default is "block cleanup"

static function DefaultInfiltrationSetup (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	CreateCovertAction(NewGameState, ActivityState);
	CreateMission(NewGameState, ActivityState);
	AddExpiration(NewGameState, ActivityState);

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(ActivityState.SecondaryObjectRef, NewGameState);
}

static function CreateCovertAction (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local X2ActivityTemplate_Infiltration ActivityTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_ResistanceFaction FactionState;
	local X2CovertActionTemplate ActionTemplate;
	local XComGameState_CovertAction ActionState;

	FactionState = ActivityState.GetActivityChain().GetFaction();
	ActivityTemplate = X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate());
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(TemplateManager.FindStrategyElementTemplate(ActivityTemplate.CovertActionName));

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
	ActionState = ActionTemplate.CreateInstanceFromTemplate(NewGameState, FactionState.GetReference());
	ActivityState.SecondaryObjectRef = ActionState.GetReference(); // Needed here so that we can get reference to chain for region select inside Spawn
	
	ActionState.Spawn(NewGameState);
	ActionState.RequiredFactionInfluence = eFactionInfluence_Minimal;
	ActionState.bNewAction = true;

	FactionState.CovertActions.AddItem(ActionState.GetReference());

	XComGameState_Activity_Infiltration(ActivityState).RegisterForActionEvents();
}

static function AddExpiration (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local X2ActivityTemplate_Infiltration ActivityTemplate;
	local TDateTime Expiration;
	
	ActivityTemplate = X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate());
	
	if (ActivityTemplate.bExpires)
	{
		Expiration = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
		ActionExpirationManager = class'XComGameState_CovertActionExpirationManager'.static.GetExpirationManager();
		ActionExpirationManager = XComGameState_CovertActionExpirationManager(NewGameState.ModifyStateObject(class'XComGameState_CovertActionExpirationManager', ActionExpirationManager.ObjectID));

		class'X2StrategyGameRulesetDataStructures'.static.AddHours(Expiration, ActivityTemplate.ExpirationBaseTime + CreateExpirationVariance(ActivityTemplate));

		ActionExpirationManager.AddActionExpirationInfo(ActivityState.SecondaryObjectRef, Expiration, !ActivityTemplate.ExpirationNotBlocksCleanup);
	}
}

static function int CreateExpirationVariance (X2ActivityTemplate_Infiltration ActivityTemplate)
{
	local int Variance;
	local bool bNegVariance;

	Variance = `SYNC_RAND_STATIC(ActivityTemplate.ExpirationVariance);

	// roll chance for negative variance
	bNegVariance = `SYNC_RAND_STATIC(2) < 1;
	if (bNegVariance) Variance *= -1;

	return Variance;
}

static function CreateMission (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSiteInfiltration MissionState;

	MissionState = XComGameState_MissionSiteInfiltration(NewGameState.CreateNewStateObject(class'XComGameState_MissionSiteInfiltration'));
	ActivityState.PrimaryObjectRef = MissionState.GetReference();
	
	MissionState.InitializeFromActivity(NewGameState);
}

defaultproperties
{
	SetupStage = DefaultInfiltrationSetup
	StateClass = class'XComGameState_Activity_Infiltration'
	ScreenClass = class'UIMission_Infiltrated'
}