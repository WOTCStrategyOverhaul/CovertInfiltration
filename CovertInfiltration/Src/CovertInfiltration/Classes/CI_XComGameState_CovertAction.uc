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

function bool Update(XComGameState NewGameState)
{
	local XComGameState_MissionSiteInfiltration MissionState;
	local XComGameState_HeadquartersXCom XComHQ;
	local UIStrategyMap StrategyMap;
	local bool bModified;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	StrategyMap = `HQPRES.StrategyMap2D;
	bModified = false;

	// Do not trigger anything while the Avenger or Skyranger are flying, or if another popup is already being presented
	if (StrategyMap != none && StrategyMap.m_eUIState != eSMS_Flight && !`HQPRES.ScreenStack.IsCurrentClass(class'UIAlert'))
	{
		if (!bCompleted)
		{
			// If the end date time has passed, this action has completed
			if (bStarted && class'X2StrategyGameRulesetDataStructures'.static.LessThan(EndDateTime, GetCurrentTime()))
			{
				if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(self))
				{
					`log("Spawning infiltration mission for" @ m_TemplateName,, 'CI');

					MissionState = XComGameState_MissionSiteInfiltration(NewGameState.CreateNewStateObject(class'XComGameState_MissionSiteInfiltration'));
					MissionState.SetupFromAction(NewGameState, self);
				}
				else
				{
					`log(m_TemplateName @ "finished, it was not an infiltration",, 'CI');

					// Note: infiltrations cannot have risks, period
					ApplyRisks(NewGameState);
				}
				
				if (bAmbushed)
				{
					// Flag XComHQ as expecting an ambush, so we can ensure the Covert Action rewards are only granted after it is completed
					XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
					XComHQ.bWaitingForChosenAmbush = true;
				}
				else
				{
					CompleteCovertAction(NewGameState);

					if (MissionState != none)
					{
						// Do not show the CA report, the mission will show its screen instead
						bNeedsActionCompletePopup = false;

						// Remove the CA, the mission takes over from here
						RemoveEntity(NewGameState);

						// We need to be sure that the player still cannot access those soldiers in armory, or use them in any way
						MissionState.SetSoldiersAsOnAction(NewGameState);
					}
				}

				bCompleted = true;
				bModified = true;
			}
		}
		else if (bAmbushed && !XComHQ.bWaitingForChosenAmbush)
		{
			bAmbushed = false; // Turn off Ambush flag so we don't hit this code block more than once
			
			// If the mission was ambushed, rewards were not granted before the tactical battle, so give them here
			CompleteCovertAction(NewGameState);
			bModified = true;
		}
	}

	return bModified;
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
		// Do not remove people from slots - we will do it later
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