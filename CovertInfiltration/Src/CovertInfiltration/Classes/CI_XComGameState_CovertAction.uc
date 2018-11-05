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

function CompleteCovertAction(XComGameState NewGameState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState_ResistanceFaction FactionState;
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2RewardTemplate RewardTemplate;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local int index;

	ResHQ = XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	// Save the Action as completed by its faction
	FactionState = GetFaction();
	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
	FactionState.CompletedCovertActions.AddItem(GetMyTemplateName());

	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();

	if (InfilMgr.GetCovertMissionInfoTemplateFromCA(GetMyTemplateName()) != none)
	{
		// It's an infiltration! No rewards for you until mission completion!
		//GiveRewards(NewGameState);

		// Commence mission spawning as defined by the X2CovertMissionInfo template
		RegionState = GetWorldRegion();

		MissionRewards.Length = 0;
		for (index = 0; index < InfilMgr.GetCovertMissionInfoTemplateFromCA(GetMyTemplateName()).MissionRewards.length; index++)
		{
			RewardTemplate = InfilMgr.GetCovertMissionInfoTemplateFromCA(GetMyTemplateName()).MissionRewards[index];
			RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
			MissionRewards.AddItem(RewardState);
		}

		MissionSource = InfilMgr.GetCovertMissionInfoTemplateFromCA(GetMyTemplateName()).MissionSource;

		MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));
		//MissionState.CovertActionRef = GetReference();
		MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true);

		MissionState.ResistanceFaction = Faction;
	}
	else
	{
		GiveRewards(NewGameState);

		// Check to ensure a Rookie Action is available
		if (ResHQ.RookieCovertActions.Find(GetMyTemplateName()) != INDEX_NONE)
		{
			// This is a Rookie Action, so check to see if another one exists
			if (!ResHQ.IsRookieCovertActionAvailable(NewGameState))
			{
				ResHQ = XComGameState_HeadquartersResistance(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersResistance', ResHQ.ObjectID));
				ResHQ.CreateRookieCovertAction(NewGameState);
			}
		}
	}

	// Flag the completion popup and trigger appropriate events
	bNeedsActionCompletePopup = true;
	`XEVENTMGR.TriggerEvent('CovertActionCompleted', , , NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_ActionsCompleted');
}
