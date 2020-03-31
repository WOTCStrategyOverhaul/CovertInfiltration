// Used to handle eAlert_CrewOverflow, now that's a seperate mod
// The class/infrastructure was left here in case we will need it in future

class UIAlert_CovertInfiltration extends UIAlert;

simulated function BuildAlert ()
{
	BindLibraryItem();

	switch (eAlertName)
	{
		default:
			AddBG(MakeRect(0, 0, 1000, 500), eUIState_Normal).SetAlpha(0.75f);
		break;
	}

	// Set up the navigation *after* the alert is built, so that the button visibility can be used. 
	RefreshNavigation();
}

simulated function name GetLibraryID ()
{
	switch (eAlertName)
	{
		default:
			return '';
	}
}

simulated function PresentUIEffects ()
{
	super.PresentUIEffects();
}
