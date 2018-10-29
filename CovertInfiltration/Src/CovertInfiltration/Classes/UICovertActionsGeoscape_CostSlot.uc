class UICovertActionsGeoscape_CostSlot extends UICovertActionsGeoscape_BaseSlot;

simulated function UpdateCostSlot(CovertActionCostSlot CostSlotInfo)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local StrategyCost Cost;
	local array<StrategyCostScalar> CostScalars;
	local string strDescription;

	History = `XCOMHISTORY;
	Cost = CostSlotInfo.Cost;
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	// TODO: this colours the text green if it's affordable, make it white instead
	strDescription = class'UIUtilities_Strategy'.static.GetStrategyCostString(Cost, CostScalars);
	strDescription = class'UICovertActionStaffSlot'.default.m_strOptionalSlot @ strDescription;

	UpdateDescription(strDescription, XComHQ.CanAffordAllStrategyCosts(Cost, CostScalars));
	UpdateReward(XComGameState_Reward(History.GetGameStateForObjectID(CostSlotInfo.RewardRef.ObjectID)));
}