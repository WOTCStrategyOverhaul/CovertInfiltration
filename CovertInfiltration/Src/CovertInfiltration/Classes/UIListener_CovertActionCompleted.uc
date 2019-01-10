//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class is used to track when a covert action is completed in order to
//	apply soldier will loss
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_CovertActionCompleted extends UIScreenListener config(Infiltration);

//values from config represent a percentage to be removed from total will
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
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SlotState.GetAssignedStaff().ObjectID));

		if (SlotState.IsSlotFilled() && UnitState.IsSoldier())
		{
			UnitState.SetCurrentStat(eStat_Will, GetWillLoss(UnitState.GetMaxStat(eStat_Will)));
			UnitState.UpdateMentalState();

			UpdateWillRecovery(NewGameState, UnitState);
		}
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

function UpdateWillRecovery(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersProjectRecoverWill WillProject;
	
	History = `XCOMHISTORY;
	XComHQ = class'X2StrategyElement_DefaultMissionSources'.static.GetAndAddXComHQ(NewGameState);

	foreach History.IterateByClassType(class'XComGameState_HeadquartersProjectRecoverWill', WillProject)
	{
		if(WillProject.ProjectFocus == UnitState.GetReference())
		{
			XComHQ.Projects.RemoveItem(WillProject.GetReference());
			NewGameState.RemoveStateObject(WillProject.ObjectID);
			break;
		}
	}

	WillProject = XComGameState_HeadquartersProjectRecoverWill(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectRecoverWill'));
	WillProject.SetProjectFocus(UnitState.GetReference(), NewGameState);

	XComHQ.Projects.AddItem(WillProject.GetReference());
}

function int GetWillLoss(int TotalWill)
{
	return int(TotalWill - (RandRange(MIN_WILL_LOSS, MAX_WILL_LOSS) * TotalWill));
}
