//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Represents an activity that currently exists in the world. Note that the
//           activity states are created when the chain is started and as such the
//           existance of this object doesn't mean that the activity is currently
//           underway - care needs to be taken
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_Activity extends XComGameState_GeoscapeEntity;

var protected name m_TemplateName;
var protected X2ActivityTemplate m_Template;

var StateObjectReference ChainRef;
var protectedwrite EActivityCompletion CompletionStatus;

// XCGS objects that this activity controls. For example, mission site, covert action, etc
var StateObjectReference PrimaryObjectRef;
var StateObjectReference SecondaryObjectRef;

var protectedwrite bool bChainNeedsCompletionNotification;

////////////////
/// Template ///
////////////////

static function X2StrategyElementTemplateManager GetMyTemplateManager()
{
	return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

simulated function name GetMyTemplateName()
{
	return m_TemplateName;
}

simulated function X2ActivityTemplate GetMyTemplate()
{
	if (m_Template == none)
	{
		m_Template = X2ActivityTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_TemplateName));
	}

	return m_Template;
}

////////////////
/// Creation ///
////////////////

event OnCreation (optional X2DataTemplate Template)
{
	local X2EventManager EventManager;
	local Object SelfObj;

	super.OnCreation(Template);

	m_Template = X2ActivityTemplate(Template);
	m_TemplateName = Template.DataName;

	EventManager = `XEVENTMGR;
	SelfObj = self;
	
	EventManager.RegisterForEvent(SelfObj, 'ActivitySetupComplete', OnSetupCompleteSubmitted, ELD_OnStateSubmitted,, SelfObj, true);
}

/////////////////
/// Lifecycle ///
/////////////////
// These are separated into specific functions for 2 reasons:
// (1) Prettify the calling code
// (2) Allow for additional extension point in the state classes

function OnEarlySetup (XComGameState NewGameState)
{
	if (GetMyTemplate().SetupChainEarly != none)
	{
		GetMyTemplate().SetupChainEarly(NewGameState, self);
	}
}

function OnSetupChain (XComGameState NewGameState)
{
	if (GetMyTemplate().SetupChain != none)
	{
		GetMyTemplate().SetupChain(NewGameState, self);
	}
}

function SetupStage (XComGameState NewGameState)
{
	local XComGameState_Activity NewActivityState;

	NewActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ObjectID));
	NewActivityState.CompletionStatus = eActivityCompletion_NotCompleted;

	if (GetMyTemplate().SetupStage != none)
	{
		GetMyTemplate().SetupStage(NewGameState, NewActivityState);
	}

	`XEVENTMGR.TriggerEvent('ActivitySetupComplete', NewActivityState, NewActivityState, NewGameState);
}

protected function EventListenerReturn OnSetupCompleteSubmitted (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (GetMyTemplate().SetupStageSubmitted != none)
	{
		GetMyTemplate().SetupStageSubmitted(self);
	}

	return ELR_NoInterrupt;
}

function CleanupStage (XComGameState NewGameState)
{
	if (GetMyTemplate().CleanupStage != none)
	{
		GetMyTemplate().CleanupStage(NewGameState, self);
	}
}

function CleanupStageDeffered (XComGameState NewGameState)
{
	if (GetMyTemplate().CleanupStageDeffered != none)
	{
		GetMyTemplate().CleanupStageDeffered(NewGameState, self);
	}
}

function OnCleanupChain (XComGameState NewGameState)
{
	if (GetMyTemplate().CleanupChain != none)
	{
		GetMyTemplate().CleanupChain(NewGameState, self);
	}
}

function bool ShouldProgressChain ()
{
	if (GetMyTemplate().ShouldProgressChain != none)
	{
		return GetMyTemplate().ShouldProgressChain(self);
	}

	return true;
}

//////////////////
/// Completion ///
//////////////////

function MarkExpired (XComGameState NewGameState)
{
	if (!ValidateCanMarkCompletion()) return;

	CompletionStatus = eActivityCompletion_Expired;
	PostMarkCompleted(NewGameState);
}

function MarkFailed (XComGameState NewGameState)
{
	if (!ValidateCanMarkCompletion()) return;

	CompletionStatus = eActivityCompletion_Failure;
	PostMarkCompleted(NewGameState);
}

function MarkPartialSuccess (XComGameState NewGameState)
{
	if (!ValidateCanMarkCompletion()) return;

	CompletionStatus = eActivityCompletion_PartialSuccess;
	PostMarkCompleted(NewGameState);
}

function MarkSuccess (XComGameState NewGameState)
{
	if (!ValidateCanMarkCompletion()) return;

	CompletionStatus = eActivityCompletion_Success;
	PostMarkCompleted(NewGameState);
}

protected function PostMarkCompleted (XComGameState NewGameState)
{
	`CI_Trace(m_TemplateName @ "marked completed as" @ CompletionStatus);

	CleanupStage(NewGameState);
	bChainNeedsCompletionNotification = true;

	`XEVENTMGR.TriggerEvent('ActivityMarkedComplete', self, self, NewGameState);
}

function UpdateGameBoard ()
{
	local XComGameState_ActivityChain NewChainState;
	local XComGameState_Activity NewActivityState;
	local XComGameState NewGameState;

	if (bChainNeedsCompletionNotification && class'X2Helper_Infiltration'.static.GeoscapeReadyForUpdate())
	{
		`CI_Trace(m_TemplateName @ "notifiying chain of completion");
		
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI:" @ m_TemplateName @ "notifiying chain of completion");
		NewChainState = XComGameState_ActivityChain(NewGameState.ModifyStateObject(class'XComGameState_ActivityChain', ChainRef.ObjectID));
		NewActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ObjectID));

		NewActivityState.CleanupStageDeffered(NewGameState);
		NewActivityState.bChainNeedsCompletionNotification = false;

		NewChainState.CurrentStageHasCompleted(NewGameState);
		`XEVENTMGR.TriggerEvent('ActivityCompleted', self, self, NewGameState);

		`SubmitGamestate(NewGameState);
	}

	if (IsOngoing()) UpdateActivity();
}

protected function UpdateActivity ();

///////////////
/// Helpers ///
///////////////

function XComGameState_ActivityChain GetActivityChain ()
{
	return XComGameState_ActivityChain(`XCOMHISTORY.GetGameStateForObjectID(ChainRef.ObjectID));
}

function bool IsCompleted ()
{
	return CompletionStatus != eActivityCompletion_NotCompleted;
}

function int GetStageIndex ()
{
	return GetActivityChain().StageRefs.Find('ObjectID', ObjectID);
}

function bool IsOngoing ()
{
	return CompletionStatus == eActivityCompletion_NotCompleted;
}

function bool IsSuccessfullAtLeastPartially ()
{
	return CompletionStatus == eActivityCompletion_Success || CompletionStatus == eActivityCompletion_PartialSuccess;
}

protected function bool ValidateCanMarkCompletion ()
{
	if (!IsOngoing())
	{
		`RedScreen("Cannot change activity completion status - not current stage");
		return false;
	}

	if (IsCompleted())
	{
		`RedScreen("Cannot change activity completion status - already completed");
		return false;
	}

	return true;
}

///////////
/// Loc ///
///////////

function string GetOverviewHeader ()
{
	local string strReturn;

	strReturn = GetMyTemplate().strOverviewHeader;
	if (strReturn == "") strReturn = "(MISSING HEADER)";

	return strReturn;
}

function string GetOverviewDescription ()
{
	local string strReturn;

	strReturn = GetMyTemplate().GetOverviewDescription(self);
	if (strReturn == "") strReturn = "(MISSING DESCRIPTION)";

	return strReturn;
}

/////////////////////////
/// XCGS_GE interface ///
/////////////////////////

protected function bool CanInteract ()
{
	return false;
}

function bool ShouldBeVisible ()
{
	return false;
}

///////////////
/// Removal ///
///////////////

function RemoveEntity (XComGameState NewGameState)
{
	`CI_Trace("Removing" @ m_TemplateName);

	GetMyTemplate();
	if (m_Template.RemoveStage != none) m_Template.RemoveStage(NewGameState, self);

	NewGameState.RemoveStateObject(ObjectID);
}

//////////////////////
/// Static helpers ///
//////////////////////

static function XComGameState_Activity GetActivityFromPrimaryObject (XComGameState_BaseObject StateObject)
{
	local XComGameState GameState;

	GameState = StateObject.GetParentGameState();
	if (GameState.HistoryIndex != -1) GameState = none;

	return GetActivityFromPrimaryObjectID(StateObject.ObjectID, GameState);
}

static function XComGameState_Activity GetActivityFromPrimaryObjectID (int StateObjectID, optional XComGameState NewGameState)
{
	local XComGameState_Activity Activity;

	// If we have a pending state, search it first
	if (NewGameState != none)
	{
		foreach NewGameState.IterateByClassType(class'XComGameState_Activity', Activity)
		{
			if (Activity.PrimaryObjectRef.ObjectID == StateObjectID)
			{
				return Activity;
			}
		}
	}

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Activity', Activity)
	{
		if (Activity.PrimaryObjectRef.ObjectID == StateObjectID)
		{
			return Activity;
		}
	}

	return none;
}

static function XComGameState_Activity GetActivityFromSecondaryObject (XComGameState_BaseObject StateObject)
{
	local XComGameState GameState;

	GameState = StateObject.GetParentGameState();
	if (GameState.HistoryIndex != -1) GameState = none;

	return GetActivityFromSecondaryObjectID(StateObject.ObjectID, GameState);
}

static function XComGameState_Activity GetActivityFromSecondaryObjectID (int StateObjectID, optional XComGameState NewGameState)
{
	local XComGameState_Activity Activity;

	// If we have a pending state, search it first
	if (NewGameState != none)
	{
		foreach NewGameState.IterateByClassType(class'XComGameState_Activity', Activity)
		{
			if (Activity.SecondaryObjectRef.ObjectID == StateObjectID)
			{
				return Activity;
			}
		}
	}

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Activity', Activity)
	{
		if (Activity.SecondaryObjectRef.ObjectID == StateObjectID)
		{
			return Activity;
		}
	}

	return none;
}

static function XComGameState_Activity GetActivityFromObject (XComGameState_BaseObject StateObject)
{
	local XComGameState GameState;

	GameState = StateObject.GetParentGameState();
	if (GameState.HistoryIndex != -1) GameState = none;

	return GetActivityFromObjectID(StateObject.ObjectID, GameState);
}

static function XComGameState_Activity GetActivityFromObjectID (int StateObjectID, optional XComGameState NewGameState)
{
	local XComGameState_Activity Activity;

	Activity = GetActivityFromPrimaryObjectID(StateObjectID);
	if (Activity != none) return Activity;

	return GetActivityFromSecondaryObjectID(StateObjectID);
}