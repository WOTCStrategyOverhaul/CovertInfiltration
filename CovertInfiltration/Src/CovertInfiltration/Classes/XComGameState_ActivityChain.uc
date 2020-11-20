//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Represents an activity chain and acts as the centerpiece for invoking all
//           callbacks and maintaing progress. Note that currently the finished chains
//           are not deleted
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_ActivityChain extends XComGameState_BaseObject config(Infiltration);

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

var array<StateObjectReference> UnclaimedChainRewardRefs;
var array<StateObjectReference> ClaimedChainRewardRefs;

// Chain Complications
var array<StateObjectReference> ComplicationRefs;

// The faction associated with this chain, if any
var StateObjectReference FactionRef;

// Region(s) where this chain is taking place
var StateObjectReference PrimaryRegionRef;
var StateObjectReference SecondaryRegionRef;

// Progress tracking
var protectedwrite int iCurrentStage;
var protectedwrite bool bEnded;
var protectedwrite EActivityChainEndReason EndReason;

var protectedwrite TDateTime StartedAt; // Only meaningful if iCurrentStage > -1
var protectedwrite TDateTime EndedAt; // Only meaningful if bEnded == true

// Cleanup logic
var config int NumMonthsToRetainAfterEnded;

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
	local ChainStage StageDef;
	local int i;

	`CI_Trace("Setting up chain" @ m_TemplateName);

	TemplateManager = GetMyTemplateManager();
	GetMyTemplate();

	// First, we choose the faction. Stages or regions may need this during setup
	if (m_Template.ChooseFaction != none)
	{
		FactionRef = m_Template.ChooseFaction(self, NewGameState);
	}

	// Next, choose the region(s). Stages may need this during setup
	if (m_Template.ChooseRegions != none)
	{
		m_Template.ChooseRegions(self, PrimaryRegionRef, SecondaryRegionRef);
	}
	
	`CI_Trace("Selected faction and regions, spawning stages");

	// Create the stages
	StageRefs.Length = m_Template.Stages.Length;

	foreach m_Template.Stages(StageDef, i)
	{
		ActivityTemplateName = GetActivityFromStage(StageDef);
		ActivityTemplate = X2ActivityTemplate(TemplateManager.FindStrategyElementTemplate(ActivityTemplateName));

		if (ActivityTemplate != none)
		{
			ActivityState = XComGameState_Activity(NewGameState.CreateNewStateObject(ActivityTemplate.StateClass, ActivityTemplate));
			ActivityState.ChainRef = GetReference();
			ActivityState.OnEarlySetup(NewGameState);

			StageRefs[i] = ActivityState.GetReference();
		}
		else
		{
			`CI_Warn("Stage definition is invalid! Cannot spawn activity: " $ ActivityTemplateName);
		}
	}

	`CI_Trace("Spawned stages, calling lifecycle callbacks");

	// First the chain callback
	if (m_Template.SetupChain != none)
	{
		m_Template.SetupChain(NewGameState, self);
	}

	// Then the callbacks on the stages
	foreach StageRefs(ActivityRef)
	{
		ActivityState = XComGameState_Activity(NewGameState.GetGameStateForObjectID(ActivityRef.ObjectID));
		ActivityState.OnSetupChain(NewGameState);
	}
	
	// Generate the chain-wide rewards if our template asks for them
	if (m_Template.GenerateChainRewards != none)
	{
		UnclaimedChainRewardRefs = m_Template.GenerateChainRewards(self, NewGameState);
	}

	SetupComplications(NewGameState);

	`CI_Trace("Chain setup complete");
	`XEVENTMGR.TriggerEvent('ActivityChainSetupComplete', self, self, NewGameState);
}

// Used by SpawnActivityChain command to force the chain to start at a particular stage
function HACK_SetCurrentStage (int CurrentStage)
{
	iCurrentStage = CurrentStage;
}

function HACK_SetStartedAt (TDateTime InStartedAt)
{
	//StartedAt = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
	StartedAt = InStartedAt;
}

////////////////
/// Progress ///
////////////////

function StartNextStage (XComGameState NewGameState)
{
	local XComGameState_Activity ActivityState;

	if (bEnded)
	{
		`RedScreen("StartNextStage called but the chain has ended already");
		return;
	}

	iCurrentStage++;

	`CI_Trace("Starting stage" @ iCurrentStage @ "of" @ m_TemplateName);

	if (iCurrentStage == 0)
	{
		StartedAt = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
	}

	ActivityState = GetCurrentActivity();
	ActivityState.SetupStage(NewGameState);

	GetMyTemplate();
	if (m_Template.PostStageSetup != none)
	{
		m_Template.PostStageSetup(NewGameState, ActivityState);
	}

	`XEVENTMGR.TriggerEvent('ActivityStarted', ActivityState, ActivityState, NewGameState);
}

function CurrentStageHasCompleted (XComGameState NewGameState)
{
	local XComGameState_Activity ActivityState;
	local StateObjectReference ActivityRef;
	local X2ComplicationTemplate ComplicationTemplate;
	local XComGameState_Complication ComplicationState;
	local XComGameStateHistory History;
	local int i;

	History = `XCOMHISTORY;

	`CI_Trace(m_TemplateName @ "current stage has reported completion, processing chain reaction");

	// Check if can progress
	if (iCurrentStage < StageRefs.Length - 1)
	{
		`CI_Trace("Still more stages avaliable");

		ActivityState = GetCurrentActivity();

		if (ActivityState.ShouldProgressChain())
		{
			`CI_Trace("Progression not blocked by stage template");
			StartNextStage(NewGameState);
		}
		else
		{
			`CI_Trace("Progression blocked by stage template");

			bEnded = true;
			EndReason = eACER_ProgressBlocked;
		}
	}
	else
	{
		`CI_Trace("No more stages avaliable");

		bEnded = true;
		EndReason = eACER_Complete;
		iCurrentStage++; // Do not get stuck on the last stage
	}

	if (bEnded)
	{
		`CI_Trace("Chain ended, calling lifecycle callbacks");

		EndedAt = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();

		// First call callbacks on the stages
		foreach StageRefs(ActivityRef)
		{
			ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityRef.ObjectID));
			ActivityState.OnCleanupChain(NewGameState);
		}

		// Then on the chain
		GetMyTemplate();
		if (m_Template.CleanupChain != none)
		{
			m_Template.CleanupChain(NewGameState, self);
		}

		`XEVENTMGR.TriggerEvent('ActivityChainEnded', self, self, NewGameState);
		
		// Fire off chain complications
		if (m_Template.bAllowComplications)
		{
			for (i = 0; i < ComplicationRefs.Length; i++)
			{
				ComplicationState = XComGameState_Complication(History.GetGameStateForObjectID(ComplicationRefs[i].ObjectID));

				if (ComplicationState.bTriggered)
				{
					ComplicationTemplate = ComplicationState.GetMyTemplate();

					if (EndReason == eACER_Complete && ComplicationTemplate.OnChainComplete != none)
						ComplicationTemplate.OnChainComplete(NewGameState, ComplicationState);
					if (EndReason == eACER_ProgressBlocked && ComplicationTemplate.OnChainBlocked != none)
						ComplicationTemplate.OnChainBlocked(NewGameState, ComplicationState);
				}
			}
		}
	}

	`CI_Trace("Finished handling stage completion");
}

function SetupComplications (XComGameState NewGameState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_Complication ComplicationState;
	local X2ComplicationTemplate ComplicationTemplate;
	local X2DataTemplate DataTemplate;
	local int AttachmentRoll, ActivationRoll;
	local bool bActivated;

	if (m_Template.bAllowComplications)
	{
		TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

		foreach TemplateManager.IterateTemplates(DataTemplate)
		{
			ComplicationTemplate = X2ComplicationTemplate(DataTemplate);

			if (ComplicationTemplate == none) continue;

			if (CanComplicationBeSelected(NewGameState, ComplicationTemplate))
			{
				AttachmentRoll = `SYNC_RAND_STATIC(100) + 1;

				if (AttachmentRoll < ComplicationTemplate.MinChance)
				{
					if (ComplicationTemplate.AlwaysSelect)
					{
						AttachmentRoll = ComplicationTemplate.MinChance;
					}
					else
					{
						AttachmentRoll = 0;
					}
				}
				else if (AttachmentRoll > ComplicationTemplate.MaxChance)
				{
					if (ComplicationTemplate.AlwaysSelect)
					{
						AttachmentRoll = ComplicationTemplate.MaxChance;
					}
					else
					{
						AttachmentRoll = 0;
					}
				}

				if (AttachmentRoll > 0)
				{
					`CI_Log("Adding Complication" @ ComplicationTemplate.DataName @ "at" @ AttachmentRoll $ "%");

					ActivationRoll = `SYNC_RAND_STATIC(100);
				
					`CI_Log("Complication Activation Roll: " $ ActivationRoll $ " < " $ AttachmentRoll);

					bActivated = ActivationRoll < AttachmentRoll;

					ComplicationState = ComplicationTemplate.CreateInstanceFromTemplate(NewGameState, self, AttachmentRoll, bActivated);
					ComplicationRefs.AddItem(ComplicationState.GetReference());
				}
				else
				{
					`CI_Log("Adding Complication" @ ComplicationTemplate.DataName @ "but roll failed");
				}
			}
		}
	}
}

protected function bool CanComplicationBeSelected (XComGameState NewGameState, X2ComplicationTemplate ComplicationTemplate)
{
	local XComGameState_ActivityChain OtherChainState;
	local XComGameStateHistory History;
	local array<int> ChainsIds;
	local int OtherObjectID;

	// Cannot select same complication multiple times
	if (HasComplication(ComplicationTemplate.DataName))
	{
		return false;
	}

	if (ComplicationTemplate.bExclusiveOnChain && ComplicationRefs.Length > 0)
	{
		return false;
	}

	if (ComplicationTemplate.bNoSimultaneous)
	{
		History = `XCOMHISTORY;

		// Get a list of chains from history
		foreach History.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
		{
			ChainsIds.AddItem(OtherChainState.ObjectID);
		}

		// Get a list of chains from NewGameState since History.IterateByClassType doesn't include things from pending states
		foreach NewGameState.IterateByClassType(class'XComGameState_ActivityChain', OtherChainState)
		{
			if (ChainsIds.Find(OtherChainState.ObjectID) == INDEX_NONE)
			{
				ChainsIds.AddItem(OtherChainState.ObjectID);
			}
		}

		// Now check all other chains if it has this complication
		// Here we use History.GetGameStateForObjectID as it does return things from pending gamestates
		foreach ChainsIds(OtherObjectID)
		{
			// ignore self
			if (OtherObjectID == ObjectID) continue;

			OtherChainState = XComGameState_ActivityChain(History.GetGameStateForObjectID(OtherObjectID));

			if (!OtherChainState.bEnded && OtherChainState.HasComplication(ComplicationTemplate.DataName))
			{
				return false;
			}
		}
	}

	if (ComplicationTemplate.CanBeChosen != none && !ComplicationTemplate.CanBeChosen(NewGameState, self))
	{
		`CI_Trace(ComplicationTemplate.FriendlyName $ " cannot be chosen");
		return false;
	}
	
	`CI_Trace(ComplicationTemplate.FriendlyName $ " is chosen");
	return true;
}

function bool HasComplication (name Complication)
{
	return FindComplication(Complication) != none;
}

function XComGameState_Complication FindComplication (name Complication)
{
	local XComGameState_Complication ComplicationState;
	local int x;

	for (x = 0; x < ComplicationRefs.Length; x++)
	{
		ComplicationState = XComGameState_Complication(`XCOMHISTORY.GetGameStateForObjectID(ComplicationRefs[x].ObjectID));

		if (ComplicationState.GetMyTemplateName() == Complication)
		{
			return ComplicationState;
		}
	}

	return none;
}

// See delegate for explanation
function OnEnlistStateIntoTactical (XComGameState StartGameState)
{
	GetMyTemplate();

	if (m_Template.OnEnlistStateIntoTactical != none)
	{
		m_Template.OnEnlistStateIntoTactical(StartGameState, self);
	}
}

/////////////////
// Dark Events //
/////////////////

function XComGameState_DarkEvent GetChainDarkEvent()
{
	local XComGameStateHistory History;
	local StateObjectReference DarkEventRef;
	local XComGameState_DarkEvent DarkEventState;
	
	History = `XCOMHISTORY;

	foreach ChainObjectRefs(DarkEventRef)
	{
		DarkEventState = XComGameState_DarkEvent(History.GetGameStateForObjectID(DarkEventRef.ObjectID));

		if (DarkEventState != none)
		{
			return DarkEventState;
		}
	}

	return none;
}

function PauseChainDarkEvent(XComGameState NewGameState)
{
	local XComGameState_DarkEvent DarkEventState;

	DarkEventState = GetChainDarkEvent();
	DarkEventState = XComGameState_DarkEvent(NewGameState.ModifyStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
	DarkEventState.PauseTimer();
}

function ResumeChainDarkEvent(XComGameState NewGameState)
{
	local XComGameState_DarkEvent DarkEventState;

	DarkEventState = GetChainDarkEvent();
	DarkEventState = XComGameState_DarkEvent(NewGameState.ModifyStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
	DarkEventState.ResumeTimer();
}

function TriggerChainDarkEvent(XComGameState NewGameState)
{
	local XComGameState_DarkEvent DarkEventState;

	DarkEventState = GetChainDarkEvent();
	DarkEventState = XComGameState_DarkEvent(NewGameState.ModifyStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
	DarkEventState.EndDateTime = `STRATEGYRULES.GameTime;
}

function CounterChainDarkEvent(XComGameState NewGameState)
{
	local XComGameState_DarkEvent DarkEventState;
	local XComGameState_HeadquartersAlien AlienHQ;
	
	DarkEventState = GetChainDarkEvent();
	AlienHQ = class'X2StrategyElement_DefaultMissionSources'.static.GetAndAddAlienHQ(NewGameState);

	AlienHQ.CancelDarkEvent(NewGameState, DarkEventState.GetReference());
}

function PreventChainDarkEventFromCompleting (XComGameState NewGameState)
{
	local XComGameState_DarkEvent DarkEventState;
	
	DarkEventState = GetChainDarkEvent();
	DarkEventState = XComGameState_DarkEvent(NewGameState.ModifyStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
	DarkEventState.bTemporarilyBlockActivation = true;
}

function RestoreChainDarkEventCompleting (XComGameState NewGameState)
{
	local XComGameState_DarkEvent DarkEventState;
	
	DarkEventState = GetChainDarkEvent();
	DarkEventState = XComGameState_DarkEvent(NewGameState.ModifyStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
	DarkEventState.bTemporarilyBlockActivation = false;
}

  ////////////////////
 /// Chain Reward ///
////////////////////

function XComGameState_Reward ClaimChainReward (XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local StateObjectReference RewardRef;
	local XComGameState_Reward RewardState;
	
	History = `XCOMHISTORY;

	foreach UnclaimedChainRewardRefs(RewardRef)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(RewardRef.ObjectID));

		if (RewardState != none)
		{
			`CI_Trace("Claiming chain reward: " $ RewardState.GetMyTemplateName());
			UnclaimedChainRewardRefs.RemoveItem(RewardRef);
			ClaimedChainRewardRefs.AddItem(RewardRef);
			return RewardState;
		}
	}

	`RedScreen(GetMyTemplateName() $ " has no chain rewards to return!");

	return none;
}

function ActivityRewardGenerated (XComGameState NewGameState, XComGameState_Activity ActivityState, XComGameState_Reward RewardState)
{
	GetMyTemplate();
	if (m_Template.OnActivityGeneratedReward != none)
	{
		m_Template.OnActivityGeneratedReward(NewGameState, ActivityState, RewardState);
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
	if (!HasStarted() || bEnded)
	{
		// Prevent warnings from GetActivityAtIndex()
		return none;
	}

	return GetActivityAtIndex(iCurrentStage);
}

function XComGameState_Activity GetLastActivity ()
{
	return GetActivityAtIndex(StageRefs.Length - 1);
}

function XComGameState_Activity GetActivityAtIndex (int i)
{
	if (i < 0 || i > StageRefs.Length - 1)
	{
		`CI_Warn("GetActivityAtIndex called with invalid index");
		ScriptTrace();
		return none;
	}

	return XComGameState_Activity(`XCOMHISTORY.GetGameStateForObjectID(StageRefs[i].ObjectID));
}

function XComGameState_ResistanceFaction GetFaction()
{
	return XComGameState_ResistanceFaction(`XCOMHISTORY.GetGameStateForObjectID(FactionRef.ObjectID));
}

function XComGameState_WorldRegion GetPrimaryRegion ()
{
	return XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(PrimaryRegionRef.ObjectID));
}

function XComGameState_WorldRegion GetSecondaryRegion ()
{
	return XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(SecondaryRegionRef.ObjectID));
}

static protected function name GetActivityFromStage(ChainStage StageDef)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityTemplate ActivityTemplate;
	local X2DataTemplate DataTemplate;
	local array<name> SelectedActivities;
	
	if (StageDef.PresetActivity != '')
	{
		`CI_Trace("Stage is preset");
		return StageDef.PresetActivity;
	}
	else
	{
		`CI_Trace("Stage is random");
	}

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	foreach TemplateManager.IterateTemplates(DataTemplate)
	{
		ActivityTemplate = X2ActivityTemplate(DataTemplate);

		if (ActivityTemplate != none
		 && StageDef.ActivityType == ActivityTemplate.ActivityType
		 && StageDef.ActivityTags.Find(ActivityTemplate.ActivityTag) != INDEX_NONE)
		{
			`CI_Trace("Activity Selection: " $ ActivityTemplate.DataName);
			SelectedActivities.AddItem(ActivityTemplate.DataName);
		}
	}
	
	if (SelectedActivities.Length == 0)
	{
		`Redscreen("Failed to find any activities for this stage");
		return '';
	}

	return SelectedActivities[`SYNC_RAND_STATIC(SelectedActivities.Length)];
}

///////////
/// Loc ///
///////////

function string GetOverviewTitle ()
{
	local string strReturn;

	strReturn = GetMyTemplate().strTitle;
	if (strReturn == "") strReturn = "(MISSING TITLE)";

	return strReturn;
}

function string GetOverviewDescription ()
{
	local string strReturn;

	strReturn = GetMyTemplate().GetOverviewDescription(self);
	if (strReturn == "") strReturn = "(MISSING DESCRIPTION)";

	return strReturn;
}

function string GetNarrativeObjective ()
{
	local string strReturn;

	strReturn = GetMyTemplate().GetNarrativeObjective(self);
	if (strReturn == "") strReturn = "(MISSING OBJECTIVE)";

	return strReturn;
}

/////////////////////////////
/// Cleanup of old chains ///
/////////////////////////////

static function RemoveEndedChains (optional bool bForceAll = false)
{
	local XComGameState_ActivityChain ChainState;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ActivityChain', ChainState)
	{
		if (!ChainState.bEnded) continue;

		if (bForceAll) ChainState.DoRemove();
		else ChainState.RemoveIfNeeded();
	}
}

protected function RemoveIfNeeded ()
{
	if (
		class'X2StrategyGameRulesetDataStructures'.static.DifferenceInMonths(
			class'XComGameState_GeoscapeEntity'.static.GetCurrentTime(),
			EndedAt
		) > default.NumMonthsToRetainAfterEnded
	)
	{
		DoRemove();
	}
}

protected function DoRemove ()
{
	local StateObjectReference ActivityRef, ComplicationRef;
	local XComGameState_Complication ComplicationState;
	local XComGameState_ActivityChain NewChainState;
	local XComGameState_Activity ActivityState;
	local XComGameState NewGameState;

	`CI_Trace("Starting removal of" @ m_TemplateName);

	GetMyTemplate();

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI Removing" @ m_TemplateName);
	NewChainState = XComGameState_ActivityChain(NewGameState.ModifyStateObject(class'XComGameState_ActivityChain', ObjectID));

	if (m_Template.RemoveChain != none) m_Template.RemoveChain(NewGameState, NewChainState);

	`CI_Trace("Removal of" @ m_TemplateName @ "- processing activities");
	foreach StageRefs(ActivityRef)
	{
		ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityRef.ObjectID));
		ActivityState.RemoveEntity(NewGameState);
	}

	`CI_Trace("Removal of" @ m_TemplateName @ "- processing complications");
	foreach ComplicationRefs(ComplicationRef)
	{
		ComplicationState = XComGameState_Complication(NewGameState.ModifyStateObject(class'XComGameState_Complication', ComplicationRef.ObjectID));
		ComplicationState.RemoveComplication(NewGameState);
	}

	if (m_Template.RemoveChainLate != none) m_Template.RemoveChainLate(NewGameState, NewChainState);

	NewGameState.RemoveStateObject(ObjectID);
	`SubmitGameState(NewGameState);

	`CI_Trace("Completed removal of" @ m_TemplateName);
}

defaultproperties
{
	iCurrentStage = -1;
}