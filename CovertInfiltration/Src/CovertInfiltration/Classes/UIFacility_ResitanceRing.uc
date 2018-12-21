//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: New UI screen for Resistance Ring facility since it now deals with orders
//           instead of covert actions
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIFacility_ResitanceRing extends UIFacility;

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