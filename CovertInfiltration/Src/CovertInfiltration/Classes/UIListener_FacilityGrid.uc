class UIListener_FacilityGrid extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	TryDelayedWelcome(Screen);
}

event OnReceiveFocus (UIScreen Screen)
{
	TryDelayedWelcome(Screen);
}

protected function TryDelayedWelcome (UIScreen Screen)
{
	if (!IsGrid(Screen)) return;

	// This is stupid, but it's the easiest way to ensure that
	// we are not loading into the post-mission sequence or 
	// spawninig some alerts/popups
	Screen.SetTimer(0.3, false, nameof(AfterDelay), self);
}

protected function AfterDelay ()
{
	if (!IsGrid(`SCREENSTACK.GetCurrentScreen())) return;

	class'UIUtilities_InfiltrationTutorial'.static.Welcome();
}

static protected function bool IsGrid (UIScreen Screen)
{
	return Screen.IsA(class'UIFacilityGrid'.Name);
}
