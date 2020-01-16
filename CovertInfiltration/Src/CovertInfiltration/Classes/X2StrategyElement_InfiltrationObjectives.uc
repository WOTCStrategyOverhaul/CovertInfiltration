//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Houses objetive templates for this mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationObjectives extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Objectives;

	Objectives.AddItem(CreateCI_CompleteFirstRetalTemplate());

	return Objectives;
}

// Replacement for wotc's XP1_M0_ActivateChosen and XP1_M1_RetaliationComplete
// Note that while this is active, retaliation missions will be forced to have a chosen
static function X2DataTemplate CreateCI_CompleteFirstRetalTemplate ()
{
	local X2ObjectiveTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ObjectiveTemplate', Template, 'CI_CompleteFirstRetal');
	Template.bMainObjective = true;
	Template.bNeverShowObjective = true;

	Template.NextObjectives.AddItem('XP1_M2_RevealChosen');

	// Fully activate the chosen (can appear on any mission) after first encounter in a retal
	Template.CompleteObjectiveFn = class'X2StrategyElement_XpackObjectives'.static.ActivateChosen;

	// This triggers even if the mission was skipped or failed
	Template.CompletionEvent = 'RetaliationComplete';

	return Template;
}