class UIListener_Mission extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	local XComGameState_Activity ActivityState;
	local UIViewChainButton Button;
	local UIMission MissionScreen;

	MissionScreen = UIMission(Screen);
	if (MissionScreen == none) return;

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