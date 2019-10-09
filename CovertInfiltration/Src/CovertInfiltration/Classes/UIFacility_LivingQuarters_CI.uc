//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Overrides UIFacility_LivingQuarters to add upgrades button
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIFacility_LivingQuarters_CI extends UIFacility_LivingQuarters;

simulated function CreateFacilityButtons()
{
	AddFacilityButton(m_strPersonnel, OnShowPersonnel);
	AddFacilityButton("Upgrades", OnShowUpgrades);
}

simulated function OnShowUpgrades()
{
	local XComHQPresentationLayer HQPresLayer;

	HQPresLayer = `HQPRES();

	if (HQPresLayer.ScreenStack.IsNotInStack(class'UILivingQuarters'))
	{
		HQPresLayer.TempScreen = Spawn(class'UILivingQuarters', self);
		HQPresLayer.ScreenStack.Push(HQPresLayer.TempScreen, HQPresLayer.Get3DMovie());
	}
}


simulated function OnPersonnelSelected(StateObjectReference selectedUnitRef)
{
	//TODO: add any logic here for selecting someone in the living quarters
}