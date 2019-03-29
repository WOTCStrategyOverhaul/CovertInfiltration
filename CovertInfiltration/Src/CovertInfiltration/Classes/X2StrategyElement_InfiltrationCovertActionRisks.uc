//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class adds additional CovertActionRisks
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationCovertActionRisks extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> CovertActionRisks;
	local ActionFlatRiskSitRep FlatRiskSitRep;

	// flat risks
	foreach class'X2Helper_Infiltration'.default.FlatRiskSitReps(FlatRiskSitRep)
	{
		CovertActionRisks.AddItem(CreateFlatRiskTemplate(FlatRiskSitRep.FlatRiskName));
	}
	
	return CovertActionRisks;
}

static function X2DataTemplate CreateFlatRiskTemplate(name FlatRiskName)
{
	local X2CovertActionRiskTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, FlatRiskName);
	
	Template.IsRiskAvailableFn = BypassCreateRisks;

	return Template;
}

static function bool BypassCreateRisks(XComGameState_ResistanceFaction FactionState, optional XComGameState NewGameState)
{
	// XCGS_CovertAction::UpdateNegatedRisks sends a gamestate
	// on it's call, return true there to avoid being negated
	if (NewGameState == none)
	{
		return false;
	}
	return true;
}