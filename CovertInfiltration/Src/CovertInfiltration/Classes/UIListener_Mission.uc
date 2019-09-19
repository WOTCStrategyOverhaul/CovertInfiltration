class UIListener_Mission extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	local UIMission MissionScreen;

	MissionScreen = UIMission(Screen);
	if (MissionScreen == none) return;

	SpawnViewChainButton(MissionScreen);
	CleanUpStrategyHudAlert(MissionScreen);
}

simulated protected function SpawnViewChainButton (UIMission MissionScreen)
{
	local XComGameState_Activity ActivityState;
	local UIViewChainButton Button;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromObjectID(MissionScreen.MissionRef.ObjectID);
	if (ActivityState == none) return;

	Button = MissionScreen.Spawn(class'UIViewChainButton', MissionScreen);
	Button.bAnimateOnInit = false;
	Button.ChainRef = ActivityState.ChainRef;
	Button.bRestoreCamEarthViewOnOverviewClose = true;
	Button.OnLayoutRealized = OnViewChainButtonRealized;
	Button.InitViewChainButton('ViewChainButton');
	Button.AnchorTopCenter();
	Button.SetPosition(0, 40);

	Button.AnimateIn(0);

	MissionScreen.Movie.Stack.SubscribeToOnInputForScreen(MissionScreen, OnMissionScreenInput);

	// Tutorial
	class'UIUtilities_InfiltrationTutorial'.static.ActivityChains();
}

simulated protected function OnViewChainButtonRealized (UIViewChainButton Button)
{
	Button.SetX(-Button.Width / 2);
}

simulated protected function bool OnMissionScreenInput (UIScreen Screen, int iInput, int ActionMask)
{
	local UIViewChainButton ViewChainButton;

	if (!Screen.CheckInputIsReleaseOrDirectionRepeat(iInput, ActionMask))
	{
		return false;
	}

	ViewChainButton = UIViewChainButton(Screen.GetChildByName('ViewChainButton'));
	if (ViewChainButton == none)
	{
		`Redscreen("Handling input for UIMission but unable to find ViewChainButton");
		return false;
	}

	switch (iInput)
	{
	case class'UIUtilities_Input'.const.FXS_BUTTON_RTRIGGER:
		if (ViewChainButton.bIsVisible)
		{
			ViewChainButton.OpenScreen();
			return true;
		}
		break;
	}

	return false;
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
