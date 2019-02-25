//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class is used to track when a covert action is completed in order to
//	apply soldier will loss
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_CovertActionCompleted extends UIScreenListener config(Infiltration);


event OnInit(UIScreen Screen)
{
	local XComGameState_CovertAction CovertAction;
	local UICovertActionReport CovertActionReport;

	CovertActionReport = UICovertActionReport(Screen);
	if (CovertActionReport == none) return;

	CovertAction = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(CovertActionReport.ActionRef.ObjectID));

	CheckForTiredSoldiers(CovertAction, CovertActionReport);
}

function CheckForTiredSoldiers(XComGameState_CovertAction CovertAction, UICovertActionReport CovertActionReport)
{
	local XComGameState_StaffSlot StaffSlotState;
	local XComGameState_Unit UnitState;

	local int idx;

	for (idx = 0; idx < CovertAction.StaffSlots.Length; idx++)
	{
		StaffSlotState = CovertAction.GetStaffSlot(idx);
		if (StaffSlotState.IsSlotFilled())
		{
			UnitState = StaffSlotState.GetAssignedStaff();
			if (UnitState.GetMentalState() == eMentalState_Tired)
			{
				ShowTiredOnReport(CovertActionReport, StaffSlotState, UnitState, idx);
			}
		}
	}
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