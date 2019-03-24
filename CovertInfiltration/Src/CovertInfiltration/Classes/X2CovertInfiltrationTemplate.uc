//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Special template class for infiltration actions
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2CovertInfiltrationTemplate extends X2CovertActionTemplate config(Infiltration);

var config array<name> arrInfiltrationFlatRisk;

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

	return ActionState;
}

function X2CovertActionRiskTemplate SelectFlatRisk()
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2CovertActionRiskTemplate RiskTemplate;
	local int Selection;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Selection = `SYNC_RAND(arrInfiltrationFlatRisk.Length);
	RiskTemplate = X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(arrInfiltrationFlatRisk[Selection]));

	return RiskTemplate;
}

function AddRisk(X2CovertActionRiskTemplate RiskTemplate, XComGameState_CovertAction ActionState)
{
	local CovertActionRisk SelectedRisk;
	
	SelectedRisk.RiskTemplateName = RiskTemplate.DataName;
	SelectedRisk.ChanceToOccur = (RiskTemplate.MinChanceToOccur + `SYNC_RAND(RiskTemplate.MaxChanceToOccur - RiskTemplate.MinChanceToOccur + 1));
	SelectedRisk.Level = GetRiskLevel(SelectedRisk);

	ActionState.Risks.AddItem(SelectedRisk);
}

function int GetRiskLevel(CovertActionRisk Risk)
{
	local array<int> RiskThresholds;
	local int TotalChanceToOccur, Threshold, iThreshold;

	RiskThresholds = class'X2StrategyGameRulesetDataStructures'.default.RiskThresholds;
	TotalChanceToOccur = Risk.ChanceToOccur + Risk.ChanceToOccurModifier;

	// Set the risk threshold based on the chance to occur (not whether it actually does)
	foreach RiskThresholds(Threshold, iThreshold)
	{
		if (TotalChanceToOccur <= Threshold)
		{
			break;
		}
	}

	return iThreshold;
}
