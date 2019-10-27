//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Queues tutorial popup when eAlert_AlienFacility is shown
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_AlienFacilityBuilt extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	local UIAlert Alert;

	Alert = UIAlert(Screen);
	if (Alert == none) return;
	if (Alert.eAlertName != 'eAlert_AlienFacility') return;

	class'UIUtilities_InfiltrationTutorial'.static.QueueAlienFacilityBuilt();
}

