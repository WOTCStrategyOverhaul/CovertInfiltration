class XComGameState_Activity extends XComGameState_BaseObject;

enum EActivityCompletion
{
	// The player is still able to do the activity (or is doing it now)
	eActivityCompletion_NotCompleted,

	// The player failed to handle this activity in time limit
	eActivityCompletion_Expired,
	
	eActivityCompletion_Failure,
	eActivityCompletion_PartialSuccess,
	eActivityCompletion_Success
};

var protected name m_TemplateName;
var protected X2ActivityTemplate m_Template;

var StateObjectReference ChainRef;
var protectedwrite EActivityCompletion CompletionStatus;

// XCGS objects that this activity controls. For example, mission site, covert action, etc
var StateObjectReference PrimaryObjectRef;
var StateObjectReference SecondaryObjectRef;

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
	super.OnCreation(Template);

	m_Template = X2ActivityTemplate(Template);
	m_TemplateName = Template.DataName;
}

// Runs before the lifecycle callbacks on templates are called
function OnEarlySetup (XComGameState NewGameState);

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
	local XComGameState_ActivityChain ActivityChain;

	GetMyTemplate();

	if (m_Template.CleanupStage != none)
	{
		m_Template.CleanupStage(NewGameState, self);
	}

	ActivityChain = XComGameState_ActivityChain(NewGameState.ModifyStateObject(class'XComGameState_ActivityChain', ChainRef.ObjectID));
	ActivityChain.CurrentStageHasCompleted(NewGameState);
}

///////////////
/// Helpers ///
///////////////

function XComGameState_ActivityChain GetActivityChain ()
{
	return XComGameState_ActivityChain(`XCOMHISTORY.GetGameStateForObjectID(ChainRef.ObjectID));
}

function bool IsCurrentStage ()
{
	return GetActivityChain().GetCurrentActivity().ObjectID == ObjectID;
}

function bool IsCompleted ()
{
	return CompletionStatus != eActivityCompletion_NotCompleted;
}

protected function bool ValidateCanMarkCompletion ()
{
	if (!IsCurrentStage())
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