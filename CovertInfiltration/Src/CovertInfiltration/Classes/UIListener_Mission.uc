class UIListener_Mission extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	local UIMission MissionScreen;

	MissionScreen = UIMission(Screen);
	if (MissionScreen == none) return;

	SpawnViewChainButton(MissionScreen);
	CleanUpStrategyHudAlert(MissionScreen);

	if (MissionScreen.IsA(class'UIMission_AlienFacility'.Name))
	{
		class'UIUtilities_InfiltrationTutorial'.static.QueueAlienFacilityBuilt();
	}
}

// TODO: Rename
simulated protected function SpawnViewChainButton (UIMission MissionScreen)
{
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromObjectID(MissionScreen.MissionRef.ObjectID);
	if (ActivityState == none) return;

	MissionScreen.SetTimer(1, false, nameof(DoSpawnViewChainButton), self);

	// Don't trigger this tutorial on single stage chains
	if (ActivityState.GetActivityChain().GetMyTemplate().Stages.Length > 1)
	{
		class'UIUtilities_InfiltrationTutorial'.static.ActivityChains();
	}
}

simulated protected function DoSpawnViewChainButton ()
{
	local UIMission MissionScreen;
	local UIChainPreview ChainPreview;

	MissionScreen = UIMission(`SCREENSTACK.GetFirstInstanceOf(class'UIMission'));
	if (MissionScreen == none) return;

	ChainPreview = MissionScreen.Spawn(class'UIChainPreview', MissionScreen);
	ChainPreview.bRestoreCamEarthViewOnOverviewClose = true;
	ChainPreview.InitChainPreview('ChainPreview');
	ChainPreview.SetFocusedActivity(class'XComGameState_Activity'.static.GetActivityFromObjectID(MissionScreen.MissionRef.ObjectID).GetReference());
	ChainPreview.RegisterInputHandler();
}

simulated protected function CleanUpStrategyHudAlert (UIMission MissionScreen)
{
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;
	local int i;
	
	local UIStrategyMap_MissionIcon MissionIcon;
	local UIStrategyMap StrategyMap;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	i = CIInfo.MissionsToShowAlertOnStrategyMap.Find('ObjectID', MissionScreen.MissionRef.ObjectID);
	
	if (i != INDEX_NONE)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Removing strategy map alert icon for mission");
		CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
		CIInfo.MissionsToShowAlertOnStrategyMap.Remove(i, 1);

		`SubmitGameState(NewGameState);

		// Undo the alert on the map
		StrategyMap = `HQPRES.StrategyMap2D;
		foreach StrategyMap.MissionItemUI.MissionIcons(MissionIcon)
		{
			if (MissionIcon.MissionSite != none && MissionIcon.MissionSite.ObjectID == MissionScreen.MissionRef.ObjectID)
			{
				MissionIcon.AS_SetAlert(false);
			}
		}
	}
}
