class XComGameState_ActivityChain extends XComGameState_BaseObject;

enum EActivityChainEndReason
{	
	eACER_Complete, // The activity has run out of stages to throw at the player
	eACER_ProgressBlocked, // X2ActivityTemplate::ShouldProgressChain returned false. Check current stage for why that happened
};

var protected name m_TemplateName;
var protected X2ActivityChainTemplate m_Template;

// Matches 1:1 with X2ActivityChainTemplate::Stages
// Note that all stages are created when the chain is created
var array<StateObjectReference> StageRefs;

// References to objects that this chain is about
// For example: reward units, dark event, etc
var array<StateObjectReference> ChainObjectRefs;

// Progress tracking
var protectedwrite int iCurrentStage;
var protectedwrite bool bEnded;
var protectedwrite EActivityChainEndReason EndReason;

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

simulated function X2ActivityChainTemplate GetMyTemplate()
{
	if (m_Template == none)
	{
		m_Template = X2ActivityChainTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_TemplateName));
	}

	return m_Template;
}

////////////////
/// Creation ///
////////////////

event OnCreation (optional X2DataTemplate Template)
{
	super.OnCreation(Template);

	m_Template = X2ActivityChainTemplate(Template);
	m_TemplateName = Template.DataName;
}

function SetupChain (XComGameState NewGameState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_Activity ActivityState;
	local X2ActivityTemplate ActivityTemplate;
	local StateObjectReference ActivityRef;
	local name ActivityTemplateName;
	local int i;

	TemplateManager = GetMyTemplateManager();
	GetMyTemplate();

	StageRefs.Length = m_Template.Stages.Length;

	foreach m_Template.Stages(ActivityTemplateName, i)
	{
		ActivityTemplate = X2ActivityTemplate(TemplateManager.FindStrategyElementTemplate(ActivityTemplateName));

		if (ActivityTemplate != none)
		{
			ActivityState = XComGameState_Activity(NewGameState.CreateNewStateObject(ActivityTemplate.StateClass, ActivityTemplate));
			ActivityState.ChainRef = GetReference();
			ActivityState.OnEarlySetup(NewGameState);

			StageRefs[i] = ActivityState.GetReference();
		}
	}

	// First the chain callback
	if (m_Template.SetupChain != none)
	{
		m_Template.SetupChain(NewGameState, self);
	}

	// Then the callbacks on the stages
	foreach StageRefs(ActivityRef)
	{
		ActivityState = XComGameState_Activity(NewGameState.GetGameStateForObjectID(ActivityRef.ObjectID));
		ActivityTemplate = ActivityState.GetMyTemplate();

		if (ActivityTemplate.SetupChain != none)
		{
			ActivityTemplate.SetupChain(NewGameState, ActivityState);
		}
	}
}

////////////////
/// Progress ///
////////////////

function StartNextStage (XComGameState NewGameState)
{
	local XComGameState_Activity ActivityState;
	local X2ActivityTemplate ActivityTemplate;

	if (bEnded)
	{
		`RedScreen("StartNextStage called but the chain has ended already");
		return;
	}

	iCurrentStage++;

	ActivityState = GetCurrentActivity();
	ActivityTemplate = ActivityState.GetMyTemplate();

	if (ActivityTemplate.SetupStage != none)
	{
		ActivityTemplate.SetupStage(NewGameState, ActivityState);
	}
}

function CurrentStageHasCompleted (XComGameState NewGameState)
{
	local XComGameState_Activity ActivityState;
	local X2ActivityTemplate ActivityTemplate;
	local StateObjectReference ActivityRef;

	// Check if can progress
	if (iCurrentStage < StageRefs.Length - 1)
	{
		ActivityState = GetCurrentActivity();
		ActivityTemplate = ActivityState.GetMyTemplate();

		if (ActivityTemplate.ShouldProgressChain == none || ActivityTemplate.ShouldProgressChain(ActivityState))
		{
			StartNextStage(NewGameState);
		}
		else
		{
			bEnded = true;
			EndReason = eACER_ProgressBlocked;
		}
	}
	else
	{
		bEnded = true;
		EndReason = eACER_Complete;
		iCurrentStage++; // Do not get stuck on the last stage
	}

	if (bEnded)
	{
		// First call callbacks on the stages
		foreach StageRefs(ActivityRef)
		{
			ActivityState = XComGameState_Activity(NewGameState.GetGameStateForObjectID(ActivityRef.ObjectID));
			ActivityTemplate = ActivityState.GetMyTemplate();

			if (ActivityTemplate.CleanupChain != none)
			{
				ActivityTemplate.CleanupChain(NewGameState, ActivityState);
			}
		}

		// Then on the chain
		GetMyTemplate();
		if (m_Template.CleanupChain != none)
		{
			m_Template.CleanupChain(NewGameState, self);
		}
	}
}

///////////////
/// Helpers ///
///////////////

function bool HasStarted ()
{
	return iCurrentStage > -1;
}

function bool IsCompleted ()
{
	return bEnded && EndReason == eACER_Complete;
}

function XComGameState_Activity GetCurrentActivity ()
{
	return XComGameState_Activity(`XCOMHISTORY.GetGameStateForObjectID(StageRefs[iCurrentStage].ObjectID));
}

defaultproperties
{
	iCurrentStage = -1;
}