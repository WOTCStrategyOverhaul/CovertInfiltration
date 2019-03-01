//---------------------------------------------------------------------------------------
// THIS IS A DEVELOPMENT-ONLY CLASS. It will be converted to CHL hooks or other 
// mechanisms to avoid using ModClassOverwrite
//---------------------------------------------------------------------------------------

class CI_XComGameState_CovertAction extends XComGameState_CovertAction;

function bool ShouldBeVisible()
{
	return class'UIUtilities_Infiltration'.static.ShouldShowCovertAction(self);
}

protected function bool CanInteract()
{
	return true;
}

// On attempted selection, if an additional prompt is required before action, displays that prompt and returns true; 
// otherwise returns false.
protected function bool DisplaySelectionPrompt()
{
	class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape(GetReference());	
	return true;
}

function GiveRewards(XComGameState NewGameState)
{
	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(self))
	{
		// The reward is the mission, you greedy
		return;
	}

	super.GiveRewards(NewGameState);
}

function RemoveEntity(XComGameState NewGameState)
{
	local XComGameState_ResistanceFaction FactionState;
	local bool SubmitLocally;

	if (NewGameState == None)
	{
		SubmitLocally = true;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Covert Action Despawned");
	}

	// The only change: do not kick people from finished infiltration
	if (bStarted && class'X2Helper_Infiltration'.static.IsInfiltrationAction(self))
	{
		// Do not remove people from slots - we will do it right before launching the mission
	}
	else
	{
		EmptyAllStaffSlots(NewGameState);
	}
	
	// clean up the rewards for this action if it wasn't started
	if (!bStarted)
	{
		CleanUpRewards(NewGameState);
	}

	// Remove the action from the list stored by the Faction, so it can't be modified after it has been completed
	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', Faction.ObjectID));
	FactionState.RemoveCovertAction(GetReference());

	// remove this action from the history
	NewGameState.RemoveStateObject(ObjectID);

	if (!bNeedsLocationUpdate && `HQPRES != none && `HQPRES.StrategyMap2D != none)
	{
		// Only remove map pin if it was generated
		bAvailable = false;
		RemoveMapPin(NewGameState);
	}

	if (SubmitLocally)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

function string GetNarrative()
{
	local XComGameState_ResistanceFaction FactionState;
	local XGParamTag kTag;

	FactionState = GetFaction();

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	kTag.StrValue0 = FactionState.GetFactionName();
	kTag.StrValue1 = FactionState.GetRivalChosen().GetChosenName();
	kTag.StrValue2 = FactionState.GetRivalChosen().GetChosenClassName();
	kTag.StrValue3 = GetContinent().GetMyTemplate().DisplayName;
	kTag.StrValue4 = GetDarkEventString();

	return `XEXPAND.ExpandString(GetMyNarrativeTemplate().ActionPreNarrative);
}

function string GetDarkEventString()
{
	local XComGameState_Reward RewardState;
	local XComGameState_DarkEvent DarkEventState;

	RewardState = XComGameState_Reward(`XCOMHISTORY.GetGameStateForObjectID(RewardRefs[0].ObjectID));
	DarkEventState = XComGameState_DarkEvent(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));

	if(DarkEventState == none) return "<Missing DE>";

	return DarkEventState.GetMyTemplate().DisplayName;
}