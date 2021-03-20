class UIListener_MCM extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local CI_MCMScreen MCMScreen;

	if (ScreenClass==none)
	{
		if (MCM_API(Screen) != none)
			ScreenClass=Screen.Class;
		else return;
	}

	MCMScreen = new class'CI_MCMScreen';
	MCMScreen.OnInit(Screen);
}

defaultproperties
{
    ScreenClass = none;
}
