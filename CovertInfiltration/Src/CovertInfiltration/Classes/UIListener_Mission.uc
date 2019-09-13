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
}

simulated protected function OnViewChainButtonRealized (UIViewChainButton Button)
{
	Button.SetX(-Button.Width / 2);
}