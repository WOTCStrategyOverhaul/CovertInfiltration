//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Hides the default infromation provided by UISitRepInformation and
//           instantiates UIBetterSitRepDetails to show the information
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_SitRepInformation extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIBetterSitRepDetails Details;
	local UISitRepInformation InfoScreen;
	local int i;

	InfoScreen = UISitRepInformation(Screen);
	if (InfoScreen.MissionData.SitReps.Length == 0) return;
	
	// Clear out the default information

	Screen.MC.BeginFunctionOp("SetSitRepRow");
	Screen.MC.QueueNumber(0);
	Screen.MC.QueueString("");
	Screen.MC.QueueString("");
	Screen.MC.QueueString("");
	Screen.MC.EndOp();

	for (i = 0; i < 4; i++)
	{
		Screen.MC.BeginFunctionOp("SetAdjustmentRow");
		Screen.MC.QueueNumber(i);
		Screen.MC.QueueString("");
		Screen.MC.QueueString("");
		Screen.MC.QueueString("");
		Screen.MC.EndOp();
	}

	Screen.MC.BeginFunctionOp("SetDarkEventData");
	Screen.MC.QueueString("");
	Screen.MC.QueueString("");
	Screen.MC.EndOp();

	// Spawn our own info
	Details = Screen.Spawn(class'UIBetterSitRepDetails', Screen);
	Details.CastedScreen = InfoScreen;
	Details.InitPanel();
}

defaultproperties
{
	// Not accounting for MCOs since our changes are effectively a MCO
	ScreenClass = class'UISitRepInformation';
}