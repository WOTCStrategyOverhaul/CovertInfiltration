//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to adjust the "Next covert op" alert
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_NextCovertAction extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIAlert Alert;

	Alert = UIAlert(Screen);
	if (Alert == none) return;
	if (Alert.eAlertName != 'eAlert_NextCovertAction') return;

	// First, we check if there are still active CAs and if yes, drop the alert
	if (AnyOngoingActions())
	{
		Alert.CloseScreen();
		return;
	}

	// Then, we replace the confirm callback with our own screen
	Alert.DisplayPropertySet.CallbackFunction = AlertCallback;
}

static function bool AnyOngoingActions()
{
	local XComGameState_CovertAction ActionState;
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if (ActionState.bStarted && !ActionState.bCompleted)
		{
			return true;
		}
	}

	return false;
}

static protected function AlertCallback(Name eAction, out DynamicPropertySet AlertData, optional bool bInstant = false)
{
	if (eAction == 'eUIAction_Accept')
	{
		class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape();
	}
	else
	{
		`HQPRES.CAMRestoreSavedLocation();
	}
}