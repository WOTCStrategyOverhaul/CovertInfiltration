class UICovertActionsGeoscape_StaffSlot extends UICovertActionsGeoscape_BaseSlot;

simulated function UpdateStaffSlot(CovertActionStaffSlot StaffSlotInfo)
{
	local XComGameStateHistory History;
	local XComGameState_StaffSlot StaffSlot;
	local string strDescription;

	History = `XCOMHISTORY;
	StaffSlot = XComGameState_StaffSlot(History.GetGameStateForObjectID(StaffSlotInfo.StaffSlotRef.ObjectID));
	strDescription = StaffSlot.GetNameDisplayString();

	if (StaffSlotInfo.bFame)
	{
		strDescription = class'UICovertActionStaffSlot'.default.m_strFamous @ strDescription;
	}

	if (StaffSlotInfo.bOptional)
	{
		strDescription = class'UICovertActionStaffSlot'.default.m_strOptionalSlot @ strDescription;
	}
	else
	{
		strDescription = class'UICovertActionStaffSlot'.default.m_strRequiredSlot @ strDescription;
	}

	UpdateDescription(strDescription, StaffSlot.IsUnitAvailableForThisSlot());
	UpdateReward(XComGameState_Reward(History.GetGameStateForObjectID(StaffSlotInfo.RewardRef.ObjectID)));
}