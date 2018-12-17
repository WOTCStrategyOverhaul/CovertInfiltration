//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a information holder for a single slot on the UICovertActionsGeoscape
//           screen which handles both personnel and cost slots (but not both at the 
//           same time).
//           Separate class to simply logic in UICovertActionsGeoscape (since the info is
//           needed in various places)
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape_SlotInfo extends Object;

var bool ShowPrefix; // Show "REQUIRED:" or "OPTIONAL:" prefix. Used for ongoing CAs
var bool ColorDescription;

var protectedwrite bool IsStaffSlot;
var protectedwrite CovertActionStaffSlot StaffSlotInfo;
var protectedwrite CovertActionCostSlot CostSlotInfo;

simulated function SetStaffSlot(CovertActionStaffSlot InStaffSlotInfo)
{
	local CovertActionCostSlot DummyCostSlot;

	IsStaffSlot = true;
	StaffSlotInfo = InStaffSlotInfo;
	CostSlotInfo = DummyCostSlot;
}

simulated function SetCostSlot(CovertActionCostSlot InCostSlotInfo)
{
	local CovertActionStaffSlot DummyStaffSlot;

	IsStaffSlot = false;
	StaffSlotInfo = DummyStaffSlot;
	CostSlotInfo = InCostSlotInfo;
}

simulated function bool IsOptional()
{
	if (!IsStaffSlot) 
	{
		// Costs/resource slots are always optional
		return false;
	}

	return StaffSlotInfo.bOptional;
}

simulated function bool CanAfford()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local array<StrategyCostScalar> CostScalars;

	if (IsStaffSlot)
	{
		return GetStaffSlotState().IsUnitAvailableForThisSlot();
	}

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	CostScalars.Length = 0; // Prevent compiler warnning as we want empty array

	return XComHQ.CanAffordAllStrategyCosts(CostSlotInfo.Cost, CostScalars);
}

simulated function XComGameState_StaffSlot GetStaffSlotState()
{
	if (!IsStaffSlot)
	{
		`REDSCREEN("Cannot call GetStaffSlotState for a cost slot");
		`REDSCREEN(GetScriptTrace());
		return none;
	}

	return XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(StaffSlotInfo.StaffSlotRef.ObjectID));
}

simulated function XComGameState_Reward GetReward()
{
	local StateObjectReference RewardRef;
	RewardRef = IsStaffSlot ? StaffSlotInfo.RewardRef : CostSlotInfo.RewardRef;

	return XComGameState_Reward(`XCOMHISTORY.GetGameStateForObjectID(RewardRef.ObjectID));
}