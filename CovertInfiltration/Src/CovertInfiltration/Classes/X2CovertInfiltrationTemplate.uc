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
	local int i;

	ActionState = super.CreateInstanceFromTemplate(NewGameState, FactionRef);

	// 5th and 6th are optional
	for (i = 4; i < ActionState.StaffSlots.Length; i++)
	{
		ActionState.StaffSlots[i].bOptional = true;
	}

	return ActionState;
}