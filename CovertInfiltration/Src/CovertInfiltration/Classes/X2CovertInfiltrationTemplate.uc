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
	local XComGameState_HeadquartersAlien AlienHQ;
	local X2SitRepTemplateManager SitRepManager;
	local ActionFlatRiskSitRep FlatRiskDef;
	local X2SitRepTemplate SitRepTemplate;
	local X2CardManager CardManager;
	local array<string> CardLabels;
	local string sRisk;
	local name RiskName;
	local int i;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	SitRepManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
	CardManager = class'X2CardManager'.static.GetCardManager();
	AlienHQ = class'UIUtilities_Strategy'.static.GetAlienHQ();

	// Build the deck
	class'X2Helper_Infiltration'.static.BuildFlatRisksDeck();

	// Try to find a matching one
	CardManager.GetAllCardsInDeck('FlatRisks', CardLabels);
	foreach CardLabels(sRisk)
	{
		RiskName = name(sRisk);
		i = class'X2Helper_Infiltration'.default.FlatRiskSitReps.Find('FlatRiskName', RiskName);

		if (i != INDEX_NONE)
		{
			FlatRiskDef = class'X2Helper_Infiltration'.default.FlatRiskSitReps[i];
			SitRepTemplate = SitRepManager.FindSitRepTemplate(FlatRiskDef.SitRepName);

			if (AlienHQ.GetForceLevel() >= SitRepTemplate.MinimumForceLevel)
			{
				CardManager.MarkCardUsed('FlatRisks', sRisk);
				return X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(FlatRiskDef.FlatRiskName));
			}
		}
	}

	`RedScreen("CI: Failed to find a flat risk to use for action");
	return none;
}

function AddRisk(X2CovertActionRiskTemplate RiskTemplate, XComGameState_CovertAction ActionState)
{
	local CovertActionRisk SelectedRisk;

	SelectedRisk.RiskTemplateName = RiskTemplate.DataName;
	SelectedRisk.ChanceToOccur = (RiskTemplate.MinChanceToOccur + `SYNC_RAND(RiskTemplate.MaxChanceToOccur - RiskTemplate.MinChanceToOccur + 1));

	ActionState.Risks.AddItem(SelectedRisk);
}