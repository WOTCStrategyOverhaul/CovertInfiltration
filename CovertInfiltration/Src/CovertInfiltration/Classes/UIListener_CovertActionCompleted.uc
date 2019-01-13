//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class is used to track when a covert action is completed in order to
//	apply soldier will loss
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_CovertActionCompleted extends UIScreenListener config(Infiltration);

//values from config represent a percentage to be removed from total will e.g.(0.25 = 25%, 0.50 = 50%)
var config float MIN_WILL_LOSS;
var config float MAX_WILL_LOSS;

event OnInit(UIScreen Screen)
{
	local XComGameState_CovertAction CovertAction;
	local UICovertActionReport CovertActionReport;

	CovertActionReport = UICovertActionReport(Screen);
	if (CovertActionReport == none) return;

	CovertAction = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(CovertActionReport.ActionRef.ObjectID));

	ApplyWillLossToSoldiers(CovertAction, CovertActionReport);
}

function ApplyWillLossToSoldiers(XComGameState_CovertAction CovertAction, UICovertActionReport CovertActionReport)
{
	local XComGameState NewGameState;
	local XComGameState_StaffSlot StaffSlotState;
	local XComGameState_Unit UnitState;

	local int idx;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Applying will loss to soldiers");

	for (idx = 0; idx < CovertAction.StaffSlots.Length; idx++)
	{
		StaffSlotState = CovertAction.GetStaffSlot(idx);
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', StaffSlotState.GetAssignedStaff().ObjectID));

		if (StaffSlotState.IsSlotFilled() && UnitState.IsSoldier())
		{
			UnitState.SetCurrentStat(eStat_Will, GetWillLoss(UnitState.GetMaxStat(eStat_Will)));
			UpdateWillRecovery(NewGameState, UnitState);
			UnitState.UpdateMentalState();
			ShowTiredOnReport(CovertActionReport, StaffSlotState, UnitState, idx);
		}
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

function int GetWillLoss(int TotalWill)
{
	return int(TotalWill - (RandRange(MIN_WILL_LOSS, MAX_WILL_LOSS) * TotalWill));
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

function ShowTiredOnReport(UICovertActionReport CovertActionReport, XComGameState_StaffSlot StaffSlotState, XComGameState_Unit UnitState, int idx)
{
	local UICovertActionSlot ActionSlot;
	local string Label, RankImage, ClassImage, Value4;
	
	ActionSlot = CovertActionReport.SlotContainer.ActionSlots[idx];
	RankImage = UnitState.IsSoldier() ? class'UIUtilities_Image'.static.GetRankIcon(UnitState.GetRank(), UnitState.GetSoldierClassTemplateName()) : "";
	ClassImage = UnitState.IsSoldier() ? UnitState.GetSoldierClassIcon() : UnitState.GetMPCharacterTemplate().IconImage;

	Label = StaffSlotState.GetNameDisplayString();
	Value4 = class'UIUtilities_Text'.static.GetColoredText("Tired", eUIState_Warning);

	CovertActionReport.AS_SetSlotData(idx, ActionSlot.eState, "", RankImage, ClassImage, Label, ActionSlot.PromoteLabel, ActionSlot.Value1, ActionSlot.Value2, ActionSlot.Value3, Value4);
}