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

		if (StaffSlotState.IsSlotFilled() && UnitState.IsSoldier() && !UnitState.IsInjured() && !UnitState.bCaptured)
		{
			UnitState.SetCurrentStat(eStat_Will, GetWillLoss(UnitState));
			UpdateWillRecovery(NewGameState, UnitState);
			UnitState.UpdateMentalState();
			ShowTiredOnReport(CovertActionReport, StaffSlotState, UnitState, idx);
		}
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

	function int GetWillLoss(XComGameState_Unit UnitState)
{
	local int WillToLose, LowestWill;

	WillToLose = int(UnitState.GetMaxStat(eStat_Will) * RandRange(MIN_WILL_LOSS, MAX_WILL_LOSS));
	LowestWill = int((UnitState.GetMaxStat(eStat_Will) * 0.33) + 1);
	
	//never put the soldier into shaken state from covertactions
	if (UnitState.GetMaxStat(eStat_Will) - WillToLose < LowestWill)
	{
		return LowestWill;
	}

	return UnitState.GetMaxStat(eStat_Will) - WillToLose;
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

	// Danger zone
	local GFxObject TiredTextBG;
	local ASColorTransform ColorTransform;
	// Danger zone end
	
	ActionSlot = CovertActionReport.SlotContainer.ActionSlots[idx];
	RankImage = UnitState.IsSoldier() ? class'UIUtilities_Image'.static.GetRankIcon(UnitState.GetRank(), UnitState.GetSoldierClassTemplateName()) : "";
	ClassImage = UnitState.IsSoldier() ? UnitState.GetSoldierClassIcon() : UnitState.GetMPCharacterTemplate().IconImage;

	Label = StaffSlotState.GetNameDisplayString();
	Value4 = class'UIUtilities_Text'.static.GetColoredText(class'X2StrategyGameRulesetDataStructures'.default.MentalStateLabels[eMentalState_Tired], eUIState_Warning);

	// Replace the text
	CovertActionReport.AS_SetSlotData(idx, ActionSlot.eState, "", RankImage, ClassImage, Label, ActionSlot.PromoteLabel, ActionSlot.Value1, ActionSlot.Value2, ActionSlot.Value3, Value4);

	// DANGER ZONE AHEAD! Do not try this at home kids
	TiredTextBG = CovertActionReport.Movie.GetVariableObject(CovertActionReport.MCPath $ ".infoPanelMC.slot" $ idx $ ".row3.bg");
	if (TiredTextBG == none)
	{
		`REDSCREEN("CI: Failed to get GFxObject for tired text bg");
	}
	else
	{
		// Set the yellow colour
		ColorTransform.multiply.R = 0;
		ColorTransform.multiply.G = 0;
		ColorTransform.multiply.B = 0;
		ColorTransform.add.R = 253;
		ColorTransform.add.G = 206;
		ColorTransform.add.B = 43;

		// Note: this is not using queuing system but that's irrelevant since the movie clip is guranteed to be already initialized
		// and no other code touches the color transform
		TiredTextBG.SetColorTransform(ColorTransform);
	}
}