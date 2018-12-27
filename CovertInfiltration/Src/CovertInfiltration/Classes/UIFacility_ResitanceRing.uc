//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: New UI screen for Resistance Ring facility since it now deals with orders
//           instead of covert actions
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIFacility_ResitanceRing extends UIFacility;

var localized string strAssingOrdersOverlay;

simulated function CreateFacilityButtons()
{
	AddFacilityButton(class'UIStrategyMap'.default.m_srResistanceOrders, OnViewOrders);
}

simulated function OnInit()
{
	super.OnInit();

	if (!class'UIUtilities_Strategy'.static.GetXComHQ().bHasSeenResistanceOrdersIntroPopup)
	{
		`HQPRES.UIResistanceOrdersIntro();
	}
}

simulated function OnViewOrders()
{
	`HQPRES.UIStrategyPolicy(false, true);
}