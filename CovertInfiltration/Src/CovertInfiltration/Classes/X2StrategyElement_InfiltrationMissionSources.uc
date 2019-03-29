//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains all the MissionSource templates
//           required for the mod's infiltrations
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationMissionSources extends X2StrategyElement_DefaultMissionSources;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> MissionSources;
	
	MissionSources.AddItem(CreateGatherLeadTemplate());
	MissionSources.AddItem(CreateDarkEventTemplate());
	MissionSources.AddItem(CreateEngineerTemplate());
	MissionSources.AddItem(CreateScientistTemplate());
	MissionSources.AddItem(CreateDarkVIPTemplate());
	
	return MissionSources;
}

static function X2DataTemplate CreateGatherLeadTemplate()
{
	local X2MissionSourceTemplate Template;
	//local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_GatherLead');
	Template.bIncreasesForceLevel = false;
	Template.bShowRewardOnPin = true;
	Template.OnSuccessFn = GatherLeadOnSuccess;
	Template.OnFailureFn = GatherLeadOnFailure;
	//Template.OnExpireFn = GuerillaOpOnExpire;
	Template.DifficultyValue = 1;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps";
	Template.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Guerrilla_Ops";
	Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonth;
	//Template.SpawnMissionsFn = SpawnGuerillaOpsMissions;
	//Template.MissionPopupFn = GuerillaOpsPopup;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;
	Template.GetSitRepsFn = GetSitRepsFromRisk;

	/*DeckEntry.RewardName = 'Reward_Supplies';
	DeckEntry.Quantity = 1;
	Template.RewardDeck.AddItem(DeckEntry);
	DeckEntry.RewardName = 'Reward_Soldier';
	DeckEntry.Quantity = 1;
	Template.RewardDeck.AddItem(DeckEntry);
	DeckEntry.RewardName = 'Reward_Intel';
	DeckEntry.Quantity = 2;
	Template.RewardDeck.AddItem(DeckEntry);*/

	return Template;
}

// in p1s add spawning p2 on strategic success (if strat objectives were completed)
// also queue the ca alert so that the player is notified to go to covert ops screen when entering geoscape
static function GatherLeadOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	GiveRewards(NewGameState, MissionState);
	//SpawnPointOfInterest(NewGameState, MissionState); // No POIs here
	//CleanUpGuerillaOps(NewGameState, MissionState.ObjectID);
	
	MissionState.RemoveEntity(NewGameState);
	`XEVENTMGR.TriggerEvent('GuerillaOpComplete', , , NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsCompleted');
}

static function GatherLeadOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	MissionState.RemoveEntity(NewGameState);
	`XEVENTMGR.TriggerEvent('GuerillaOpComplete', , , NewGameState);
	
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsFailed');
}

static function X2DataTemplate CreateDarkEventTemplate()
{
	local X2MissionSourceTemplate Template;
	local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_DarkEvent');
	Template.bIncreasesForceLevel = false;
	Template.bShowRewardOnPin = true;
	Template.OnSuccessFn = DarkEventOnSuccess;
	//Template.OnFailureFn = GuerillaOpOnFailure;
	//Template.OnExpireFn = GuerillaOpOnExpire;
	Template.DifficultyValue = 1;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps";
	Template.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Guerrilla_Ops";
	Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonth;
	//Template.SpawnMissionsFn = SpawnGuerillaOpsMissions;
	//Template.MissionPopupFn = GuerillaOpsPopup;
	Template.WasMissionSuccessfulFn = StrategyObjectivePlusSweepCompleted;
	Template.GetMissionRegionFn = GetGuerillaOpRegions;
	Template.GetSitRepsFn = GetSitRepsFromRisk;

	DeckEntry.RewardName = 'Reward_Supplies';
	DeckEntry.Quantity = 2;
	Template.RewardDeck.AddItem(DeckEntry);
	DeckEntry.RewardName = 'Reward_Soldier';
	DeckEntry.Quantity = 1;
	Template.RewardDeck.AddItem(DeckEntry);
	DeckEntry.RewardName = 'Reward_Intel';
	DeckEntry.Quantity = 1;
	Template.RewardDeck.AddItem(DeckEntry);

	return Template;
}

static function DarkEventOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	if(MissionState.HasDarkEvent())
	{
		StopMissionDarkEvent(NewGameState, MissionState);
	}

	GiveRewards(NewGameState, MissionState);
	
	MissionState.RemoveEntity(NewGameState);
	`XEVENTMGR.TriggerEvent('GuerillaOpComplete', , , NewGameState);

	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsCompleted');
}

static function X2DataTemplate CreateEngineerTemplate()
{
	local X2MissionSourceTemplate Template;
	local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_Engineer');
	Template.bIncreasesForceLevel = false;
	//Template.bDisconnectRegionOnFail = true;
	Template.OnSuccessFn = Phase2OnSuccess;
	//Template.OnFailureFn = CouncilOnFailure;
	//Template.OnExpireFn = CouncilOnExpire;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.Council_VIP";
	Template.MissionImage = "img://UILibrary_Common.Councilman_small";
	Template.GetMissionDifficultyFn = GetCouncilMissionDifficulty;
	//Template.SpawnMissionsFn = SpawnCouncilMission;
	//Template.MissionPopupFn = CouncilPopup;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;
	//Template.RequireLaunchMissionPopupFn = CouncilRequireLaunchMissionPopup;
	Template.GetMissionRegionFn = GetCalendarMissionRegion;
	Template.GetSitRepsFn = GetSitRepsFromRisk;

	DeckEntry.RewardName = 'Reward_Engineer';
	DeckEntry.Quantity = 1;
	Template.RewardDeck.AddItem(DeckEntry);

	return Template;
}

static function X2DataTemplate CreateScientistTemplate()
{
	local X2MissionSourceTemplate Template;
	local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_Scientist');
	Template.bIncreasesForceLevel = false;
	//Template.bDisconnectRegionOnFail = true;
	Template.OnSuccessFn = Phase2OnSuccess;
	//Template.OnFailureFn = CouncilOnFailure;
	//Template.OnExpireFn = CouncilOnExpire;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.Council_VIP";
	Template.MissionImage = "img://UILibrary_Common.Councilman_small";
	Template.GetMissionDifficultyFn = GetCouncilMissionDifficulty;
	//Template.SpawnMissionsFn = SpawnCouncilMission;
	//Template.MissionPopupFn = CouncilPopup;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;
	//Template.RequireLaunchMissionPopupFn = CouncilRequireLaunchMissionPopup;
	Template.GetMissionRegionFn = GetCalendarMissionRegion;
	Template.GetSitRepsFn = GetSitRepsFromRisk;

	DeckEntry.RewardName = 'Reward_Scientist';
	DeckEntry.Quantity = 1;
	Template.RewardDeck.AddItem(DeckEntry);

	return Template;
}

static function X2DataTemplate CreateDarkVIPTemplate()
{
	local X2MissionSourceTemplate Template;
	local RewardDeckEntry DeckEntry;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_DarkVIP');
	Template.bIncreasesForceLevel = false;
	//Template.bDisconnectRegionOnFail = true;
	Template.OnSuccessFn = Phase2OnSuccess;
	//Template.OnFailureFn = CouncilOnFailure;
	//Template.OnExpireFn = CouncilOnExpire;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.Council_VIP";
	Template.MissionImage = "img://UILibrary_Common.Councilman_small";
	Template.GetMissionDifficultyFn = GetCouncilMissionDifficulty;
	//Template.SpawnMissionsFn = SpawnCouncilMission;
	//Template.MissionPopupFn = CouncilPopup;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;
	//Template.RequireLaunchMissionPopupFn = CouncilRequireLaunchMissionPopup;
	Template.GetMissionRegionFn = GetCalendarMissionRegion;
	Template.GetSitRepsFn = GetSitRepsFromRisk;

	DeckEntry.RewardName = 'Reward_Intel';
	DeckEntry.Quantity = 1;
	Template.RewardDeck.AddItem(DeckEntry);

	return Template;
}

static function Phase2OnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local array<int> ExcludeIndices;

	ExcludeIndices = GetCouncilExcludeRewards(MissionState);
	MissionState.bUsePartialSuccessText = (ExcludeIndices.Length > 0);
	GiveRewards(NewGameState, MissionState, ExcludeIndices);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_CouncilMissionsCompleted');
}

static function array<name> GetSitRepsFromRisk(XComGameState_MissionSite MissionState)
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;
	local XComGameState_CovertAction ActionState;
	local ActionFlatRiskSitRep FlatRiskSitRep;
	local array<name> ActiveSitReps;
	local CovertActionRisk Risk;

	InfiltrationState = XComGameState_MissionSiteInfiltration(MissionState);

	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(InfiltrationState.CorrespondingActionRef.ObjectID));
	
	if (ActionState != none)
	{
		foreach ActionState.Risks(Risk)
		{
			if (Risk.bOccurs)
			{
				foreach class'X2Helper_Infiltration'.default.FlatRiskSitReps(FlatRiskSitRep)
				{
					if (FlatRiskSitRep.FlatRiskName == Risk.RiskTemplateName)
					{
						ActiveSitReps.AddItem(FlatRiskSitRep.SitRepName);
						break;
					}
				}
			}
		}
	}

	return ActiveSitReps;
}