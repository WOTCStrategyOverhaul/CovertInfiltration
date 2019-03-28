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

	AddRisk(SelectFlatRisk(), ActionState);
	ActionState.RecalculateRiskChanceToOccurModifiers();

	return ActionState;
}

function X2CovertActionRiskTemplate SelectFlatRisk()
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2CovertActionRiskTemplate RiskTemplate;
	local int Selection;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Selection = `SYNC_RAND(class'X2Helper_Infiltration'.default.FlatRiskSitReps.Length);
	RiskTemplate = X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(class'X2Helper_Infiltration'.default.FlatRiskSitReps[Selection].FlatRiskName));

	return RiskTemplate;
}

function AddRisk(X2CovertActionRiskTemplate RiskTemplate, XComGameState_CovertAction ActionState)
{
	local CovertActionRisk SelectedRisk;

	SelectedRisk.RiskTemplateName = RiskTemplate.DataName;
	SelectedRisk.ChanceToOccur = (RiskTemplate.MinChanceToOccur + `SYNC_RAND(RiskTemplate.MaxChanceToOccur - RiskTemplate.MinChanceToOccur + 1));

	ActionState.Risks.AddItem(SelectedRisk);
}