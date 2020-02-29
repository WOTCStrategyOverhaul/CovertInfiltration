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

simulated protected function SpawnViewChainButton (UIMission MissionScreen)
{
	local XComGameState_Activity ActivityState;
	
	ActivityState = class'XComGameState_Activity'.static.GetActivityFromObjectID(MissionScreen.MissionRef.ObjectID);
	if (ActivityState == none) return;

	MissionScreen.SetTimer(1, false, nameof(DoSpawnViewChainButton), self);

	// Tutorial
	class'UIUtilities_InfiltrationTutorial'.static.ActivityChains();
}

simulated protected function DoSpawnViewChainButton ()
{
	local UIViewChainButton Button;
	local UIMission MissionScreen;

	MissionScreen = UIMission(`SCREENSTACK.GetFirstInstanceOf(class'UIMission'));
	if (MissionScreen == none) return;

	Button = MissionScreen.Spawn(class'UIViewChainButton', MissionScreen);
	Button.bAnimateOnInit = false;
	Button.ChainRef = class'XComGameState_Activity'.static.GetActivityFromObjectID(MissionScreen.MissionRef.ObjectID).ChainRef;
	Button.bRestoreCamEarthViewOnOverviewClose = true;
	Button.OnLayoutRealized = OnViewChainButtonRealized;
	Button.InitViewChainButton('ViewChainButton');
	Button.AnchorTopCenter();
	Button.SetPosition(0, 40);

	Button.RealizeContent();
	Button.AnimateIn(0);

	MissionScreen.Movie.Stack.SubscribeToOnInputForScreen(MissionScreen, OnMissionScreenInput);
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

event OnRemoved (UIScreen Screen)
{
	local UIMission MissionScreen;

	MissionScreen = UIMission(Screen);
	if (MissionScreen == none) return;

	// DLC2's ruler tracking system assumes that the flow of the game is
	// mission generated -> player goes on mission -> mission generated -> player goes -> etc.
	// While there are a few safeguards that prevent complete mess on missions such as strongholds,
	// these are not enough to gurantee reliable behaviour when there are multiple missions in progress
	// or there are multiple assault missions (**which can have rulers**) avaliable at the same time.
	// As such, we simply clear the tracker when existing mission blades
	// TODO: How does this behave with assualt missions?
	if (class'X2Helper_Infiltration'.static.IsDLCLoaded('DLC_2'))
	{
		class'X2Helper_Infiltration_DLC2'.static.ClearRulerOnCurrentMission();
	}
}