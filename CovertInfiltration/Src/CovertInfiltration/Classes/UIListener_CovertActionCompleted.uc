//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class is used to track when a covert action is completed in order to
//	apply soldier will loss
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_CovertActionCompleted extends UIScreenListener config(Infiltration);

var config float MIN_WILL_LOSS;
var config float MAX_WILL_LOSS;

event OnInit(UIScreen Screen)
{
	local XComGameState_CovertAction CovertAction;
	local StateObjectReference Action;

	if (Screen != UICovertActionReport(Screen)) return;
	
	Action = UICovertActionReport(Screen).ActionRef;
	CovertAction = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(Action.ObjectID));

	ApplyWillLossToSoldiers(CovertAction);
}

function ApplyWillLossToSoldiers(XComGameState_CovertAction CovertAction)
{
	local XComGameState NewGameState;
	local XComGameState_StaffSlot SlotState;
	local XComGameState_Unit UnitState;

	local int idx;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Applying will loss to soldiers");

	for (idx = 0; idx < CovertAction.StaffSlots.Length; idx++)
	{
		SlotState = CovertAction.GetStaffSlot(idx);
		UnitState = SlotState.GetAssignedStaff();

		if (SlotState.IsSlotFilled() && UnitState.IsSoldier())
		{
			UnitState.SetCurrentStat(eStat_Will, GetWillLoss(UnitState.GetMaxStat(eStat_Will)));
			UnitState.UpdateMentalState();
		}
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

function int GetWillLoss(int TotalWill)
{
	return int(TotalWill - (RandRange(MIN_WILL_LOSS, MAX_WILL_LOSS) * TotalWill));
}
