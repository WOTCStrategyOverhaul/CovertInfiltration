//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to adjust the UI of Resistance Ring for it's new purpose
//           (orders instead of (somewhat) CAs)
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class CI_UIFacility_CovertActions extends UIFacility_CovertActions;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	m_kCovertOpsStatus.Hide();
}

simulated function CreateFacilityButtons()
{
	AddFacilityButton(class'UIStrategyMap'.default.m_srResistanceOrders, OnViewOrders);
}

simulated function OnViewOrders()
{
	`HQPRES.UIStrategyPolicy(false, true);

	// Even though the listener will redirect the camera, we do it here to prevent the small jump
	class'UIUtilities_Infiltration'.static.ForceRingViewIfPossible(0);
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	m_kCovertOpsStatus.Hide();
}