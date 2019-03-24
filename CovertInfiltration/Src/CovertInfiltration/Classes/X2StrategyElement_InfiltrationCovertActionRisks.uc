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

	// flat risks
	CovertActionRisks.AddItem(CreateAdventPatrolsRiskTemplate());
	CovertActionRisks.AddItem(CreateIntelligenceLeakRiskTemplate());
	CovertActionRisks.AddItem(CreateAdventAirPatrolsRiskTemplate());
	CovertActionRisks.AddItem(CreateGunneryEmplacementsRiskTemplate());
	CovertActionRisks.AddItem(CreateShoddyIntelRiskTemplate());

	return CovertActionRisks;
}

//////////////////
/// Flat Risks ///
//////////////////

static function X2DataTemplate CreateAdventPatrolsRiskTemplate()
{
	local X2CovertActionRiskTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, 'CovertActionRisk_AdventPatrols');

	Template.IsRiskAvailableFn = BypassCreateRisks;

	return Template;
}

static function X2DataTemplate CreateIntelligenceLeakRiskTemplate()
{
	local X2CovertActionRiskTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, 'CovertActionRisk_IntelligenceLeak');

	Template.IsRiskAvailableFn = BypassCreateRisks;

	return Template;
}

static function X2DataTemplate CreateAdventAirPatrolsRiskTemplate()
{
	local X2CovertActionRiskTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, 'CovertActionRisk_AdventAirPatrols');

	Template.IsRiskAvailableFn = BypassCreateRisks;

	return Template;
}

static function X2DataTemplate CreateGunneryEmplacementsRiskTemplate()
{
	local X2CovertActionRiskTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, 'CovertActionRisk_GunneryEmplacements');

	Template.IsRiskAvailableFn = BypassCreateRisks;

	return Template;
}

static function X2DataTemplate CreateShoddyIntelRiskTemplate()
{
	local X2CovertActionRiskTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, 'CovertActionRisk_ShoddyIntel');

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