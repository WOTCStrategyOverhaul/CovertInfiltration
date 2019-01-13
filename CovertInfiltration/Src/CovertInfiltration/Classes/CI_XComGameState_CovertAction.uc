//---------------------------------------------------------------------------------------
// THIS IS A DEVELOPMENT-ONLY CLASS. It will be converted to CHL hooks or other 
// mechanisms to avoid using ModClassOverwrite
//---------------------------------------------------------------------------------------

class CI_XComGameState_CovertAction extends XComGameState_CovertAction;

var() bool bInfiltrated;
var() bool bNeedsInfiltratedPopup;

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
	local XComGameState_HeadquartersXCom XComHQ;
	local bool bModified;
	local UIStrategyMap StrategyMap;

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
				ApplyInfiltration(NewGameState);
				
				if (!bInfiltrated)
				{
					// Infiltrations cannot have risks, period
					ApplyRisks(NewGameState);
				} 
				
				if (bAmbushed || bInfiltrated)
				{
					// Flag XComHQ as expecting an ambush, so we can ensure the Covert Action rewards are only granted after it is completed
					XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
					XComHQ.bWaitingForChosenAmbush = true;
				}
				else
				{
					CompleteCovertAction(NewGameState);
				}

				bCompleted = true;
				bModified = true;
			}
		}
		else if (bAmbushed && !XComHQ.bWaitingForChosenAmbush)
		{
			bAmbushed = false; // Turn off Ambush flag so we don't hit this code block more than once
			bInfiltrated = false;
			// If the mission was ambushed, rewards were not granted before the tactical battle, so give them here
			CompleteCovertAction(NewGameState);
			bModified = true;
		}
	}

	return bModified;
}

function ApplyInfiltration(XComGameState NewGameState)
{
	local XComGameState_MissionSiteInfiltration MissionState;

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(self))
	{
		`log("Spawning infiltration mission for" @ m_TemplateName,, 'CI');

		bInfiltrated = true;
		bNeedsInfiltratedPopup = true;

		// It's an infiltration! Commence mission spawning as defined by the X2CovertMissionInfo template

		MissionState = XComGameState_MissionSiteInfiltration(NewGameState.CreateNewStateObject(class'XComGameState_MissionSiteInfiltration'));
		MissionState.SetupFromAction(self, NewGameState);
	}
	else
	{
		`log(m_TemplateName @ "finished, it was not an infiltration",, 'CI');
	}
}

function UpdateGameBoard()
{
	local XComGameState NewGameState;
	local XComGameState_CovertAction NewActionState;
	local UIStrategyMap StrategyMap;
	local bool bUpdated;
	
	if (ShouldUpdate())
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Update Covert Action");

		NewActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ObjectID));

		bUpdated = NewActionState.Update(NewGameState);
		`assert(bUpdated); // why did Update & ShouldUpdate return different bools?

		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		`HQPRES.StrategyMap2D.UpdateMissions();
	}

	StrategyMap = `HQPRES.StrategyMap2D;
	if (StrategyMap != none && StrategyMap.m_eUIState != eSMS_Flight)
	{
		// Flags indicate the covert action has been completed
		if (bNeedsInfiltratedPopup || bNeedsAmbushPopup || bNeedsActionCompletePopup)
		{
			StartActionCompleteSequence();
		}
	}
}

simulated public function ShowActionCompletePopups()
{
	if (bNeedsInfiltratedPopup)
	{
		InfiltratedPopup();
	}
	else if (bNeedsAmbushPopup)
	{
		AmbushPopup();
	}
	else if (bNeedsActionCompletePopup)
	{
		ActionCompletePopup();
	}
}

// Going to have to create a new popup window from scratch, using this existing stuff is not working
simulated public function InfiltratedPopup()
{
	local XComGameState NewGameState;
	local CI_XComGameState_CovertAction ActionState;
	local X2CovertMissionInfoTemplate CovertMission;
	local XComHQPresentationLayer HQPres;
	local UIMission_Infiltrated MissionUI;
	local X2CovertMissionInfoTemplateManager InfilMgr;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Toggle Action Complete Popup");
	ActionState = CI_XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', self.ObjectID));
	ActionState.bNeedsInfiltratedPopup = false;
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	
	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	CovertMission = InfilMgr.GetCovertMissionInfoTemplateFromCA(GetMyTemplateName());
	
	HQPres = `HQPRES;
	
	MissionUI = HQPres.Spawn(class'UIMission_Infiltrated', HQPres);
	MissionUI.MissionRef = GetMission(CovertMission.MissionSource).GetReference();
	HQPres.ScreenStack.Push(MissionUI);

	`GAME.GetGeoscape().Pause();
}