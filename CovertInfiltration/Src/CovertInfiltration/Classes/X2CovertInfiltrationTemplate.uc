//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Special template class for infiltration actions
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2CovertInfiltrationTemplate extends X2CovertActionTemplate;

function XComGameState_CovertAction CreateInstanceFromTemplate(XComGameState NewGameState, StateObjectReference FactionRef)
{
	local XComGameState_CovertAction ActionState;

	ActionState = super.CreateInstanceFromTemplate(NewGameState, FactionRef);
	
	// 1st and 6th slots are optional
	ActionState.StaffSlots[0].bOptional = true;
	ActionState.StaffSlots[5].bOptional = true;
	
	return ActionState;
}