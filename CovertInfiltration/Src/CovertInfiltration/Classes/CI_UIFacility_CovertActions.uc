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
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	m_kCovertOpsStatus.Hide();
}