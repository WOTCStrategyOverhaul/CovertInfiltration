class UIAlert_CovertInfiltration extends UIAlert;

simulated function BuildAlert ()
{
	BindLibraryItem();

	switch (eAlertName)
	{
		case 'eAlert_CrewOverflow':
			BuildCrewOverflow();
		break;
				
		default:
			AddBG(MakeRect(0, 0, 1000, 500), eUIState_Normal).SetAlpha(0.75f);
		break;
	}

	// Set  up the navigation *after* the alert is built, so that the button visibility can be used. 
	RefreshNavigation();
}

simulated function name GetLibraryID ()
{
	switch (eAlertName)
	{
		case 'eAlert_CrewOverflow':	return 'Alert_Warning';
		
		default:
			return '';
	}
}

simulated function PresentUIEffects ()
{
	super.PresentUIEffects();

	if (eAlertName == 'eAlert_CrewOverflow')
	{
		CrewOverflowShowLivingRoom();
	}
}

simulated protected function BuildCrewOverflow ()
{
	local TAlertHelpInfo Info;

	Info.strTitle = "Crew overflow title";
	Info.strHeader = "Crew overflow header";
	Info.strDescription = "Crew overflow description";
	Info.strImage = m_strLowScientistsImage;
	Info.strConfirm = m_strOK;

	BuildHelpAlert(Info);
}

simulated protected function CrewOverflowShowLivingRoom ()
{
	`HQPRES.CAMLookAtRoom(`XCOMHQ.GetRoom(16), bInstantInterp ? float(0) : `HQINTERPTIME);
}