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
	//local XComNarrativeMoment ActionNarrative;
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
				ApplyRisks(NewGameState);
				ApplyInfiltration(NewGameState);
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
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState_ResistanceFaction FactionState;
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local XComGameState_MissionSiteInfiltration MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2RewardTemplate RewardTemplate;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local X2CovertMissionInfoTemplate CovertMission;
	local int index;

	ResHQ = XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	CovertMission = InfilMgr.GetCovertMissionInfoTemplateFromCA(GetMyTemplateName());

	if (CovertMission != none)
	{
		`LOG("COVERT INFILTRATION TRIGGERED");

		bInfiltrated = true;
		bNeedsInfiltratedPopup = true;

		// It's an infiltration! Commence mission spawning as defined by the X2CovertMissionInfo template

		RegionState = GetWorldRegion();

		MissionRewards.Length = 0;
		for (index = 0; index < CovertMission.MissionRewards.length; index++)
		{
			RewardTemplate = CovertMission.MissionRewards[index];
			RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
			MissionRewards.AddItem(RewardState);
		}

		MissionSource = CovertMission.MissionSource;

		MissionState = XComGameState_MissionSiteInfiltration(NewGameState.CreateNewStateObject(class'XComGameState_MissionSiteInfiltration'));

		// Note to self: Make the RegionState return the same location as the CA
		MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true);
		//MissionState.SetMissionData(CovertMission.MissionRewards[0], false, 1);
		MissionState.ResistanceFaction = Faction;
	}
	else
	{
		`LOG("WAS NOT AN INFILTRATION ACTION");
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
	local TDialogueBoxData DialogData;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Toggle Action Complete Popup");
	ActionState = CI_XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', self.ObjectID));
	ActionState.bNeedsInfiltratedPopup = false;
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	
	DialogData.eType = eDialog_Normal;
	DialogData.strTitle = "Covert Infiltration Complete";
	DialogData.strText = "Our troopers have successfully infiltrated the enemy and have informed us they are ready to strike.";
	DialogData.strAccept = "Launch Mission";
	DialogData.strCancel = "Return to Avenger";
	DialogData.fnCallback = LaunchInfiltration;
	`HQPRES.UIRaiseDialog(DialogData);
	
	`GAME.GetGeoscape().Pause();
}

function LaunchInfiltration(name eAction)
{
	local XComGameState_MissionSiteInfiltration MissionSite;
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local X2CovertMissionInfoTemplate CovertMission;
	local TDialogueBoxData DialogData;
	
	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	CovertMission = InfilMgr.GetCovertMissionInfoTemplateFromCA(GetMyTemplateName());
	MissionSite = XComGameState_MissionSiteInfiltration(GetMission(CovertMission.MissionSource.DataName));

	if(eAction == 'eUIAction_Accept')
	{
		MissionSite.SelectSquad();
		MissionSite.StartMission();
	}
	else
	{
		
	}
}