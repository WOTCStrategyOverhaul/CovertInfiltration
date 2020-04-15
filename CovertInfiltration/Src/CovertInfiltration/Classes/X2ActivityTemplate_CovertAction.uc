//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Template for a Covert Action as an activity
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ActivityTemplate_CovertAction extends X2ActivityTemplate;

var name CovertActionName;

// Expiry in hours
var config bool bExpires;
var config int ExpirationBaseTime;
var config int ExpirationVariance;
var config bool ExpirationNotBlocksCleanup; // Inverted, so that default is "block cleanup"

static function DefaultCovertActionSetup (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_Activity_CovertAction CAActivity;

	CreateCovertAction(NewGameState, ActivityState);
	AddExpiration(NewGameState, ActivityState);

	CAActivity = XComGameState_Activity_CovertAction(ActivityState);
	CAActivity.RegisterForActionEvents();
}

static function CreateCovertAction (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local X2ActivityTemplate_CovertAction ActivityTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_ResistanceFaction FactionState;
	local X2CovertActionTemplate ActionTemplate;
	local XComGameState_CovertAction ActionState;

	FactionState = ActivityState.GetActivityChain().GetFaction();
	ActivityTemplate = X2ActivityTemplate_CovertAction(ActivityState.GetMyTemplate());
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(TemplateManager.FindStrategyElementTemplate(ActivityTemplate.CovertActionName));

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
	ActionState = ActionTemplate.CreateInstanceFromTemplate(NewGameState, FactionState.GetReference());
	ActivityState.PrimaryObjectRef = ActionState.GetReference(); // Needed here so that we can get reference to chain for region select inside Spawn
	
	ActionState.Spawn(NewGameState);
	ActionState.RequiredFactionInfluence = eFactionInfluence_Minimal;
	ActionState.bNewAction = true;

	FactionState.CovertActions.AddItem(ActionState.GetReference());
}

static function AddExpiration (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local X2ActivityTemplate_CovertAction ActivityTemplate;
	local TDateTime Expiration;
	
	ActivityTemplate = X2ActivityTemplate_CovertAction(ActivityState.GetMyTemplate());
	
	if (ActivityTemplate.bExpires)
	{
		Expiration = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
		ActionExpirationManager = class'XComGameState_CovertActionExpirationManager'.static.GetExpirationManager();
		ActionExpirationManager = XComGameState_CovertActionExpirationManager(NewGameState.ModifyStateObject(class'XComGameState_CovertActionExpirationManager', ActionExpirationManager.ObjectID));

		class'X2StrategyGameRulesetDataStructures'.static.AddHours(Expiration, ActivityTemplate.ExpirationBaseTime + CreateExpirationVariance(ActivityTemplate));

		ActionExpirationManager.AddActionExpirationInfo(ActivityState.PrimaryObjectRef, Expiration, !ActivityTemplate.ExpirationNotBlocksCleanup);
	}
}

static function int CreateExpirationVariance (X2ActivityTemplate_CovertAction ActivityTemplate)
{
	local int Variance;
	local bool bNegVariance;

	Variance = `SYNC_RAND_STATIC(ActivityTemplate.ExpirationVariance);

	// roll chance for negative variance
	bNegVariance = `SYNC_RAND_STATIC(2) < 1;
	if (bNegVariance) Variance *= -1;

	return Variance;
}

static function DefaultSetupStageSubmitted (XComGameState_Activity ActivityState)
{
	class'UIUtilities_Infiltration'.static.CovertActionAvaliable(
		XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectId(ActivityState.PrimaryObjectRef.ObjectID))
	);
}

static function bool DefaultShouldProgressChain (XComGameState_Activity ActivityState)
{
	// Do not progress if the CA expired
	return ActivityState.CompletionStatus == eActivityCompletion_Success;
}

static function string DefaultGetOverviewStatusCovertAction (XComGameState_Activity ActivityState)
{
	if (ActivityState.IsOngoing())
	{
		if (XComGameState_Activity_CovertAction(ActivityState).GetAction().bStarted)
		{
			return class'UIUtilities_Infiltration'.default.strCompletionStatusLabel_Ongoing;
		}
		else
		{
			return class'UIUtilities_Infiltration'.default.strCompletionStatusLabel_Available;
		}
	}

	return DefaultGetOverviewStatus(ActivityState);
}

defaultproperties
{
	SetupStage = DefaultCovertActionSetup
	SetupStageSubmitted = DefaultSetupStageSubmitted
	ShouldProgressChain = DefaultShouldProgressChain
	StateClass = class'XComGameState_Activity_CovertAction'
	ActivityType = eActivityType_Action

	GetOverviewStatus = DefaultGetOverviewStatusCovertAction
}