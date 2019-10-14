class X2StrategyElement_DefaultInfiltrationBonusMilestones extends X2StrategyElement config(Infiltration);

struct InfilBonusMilestoneDef
{
	var name Milestone;
	var int Progress;
};

var config array<InfilBonusMilestoneDef> Milestones;

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;
	local InfilBonusMilestoneDef Def;
	
	foreach default.Milestones(Def)
	{
		Templates.AddItem(CreateTemplateFromDef(Def));
	}

	return Templates;
}

static function X2InfiltrationBonusMilestoneTemplate CreateTemplateFromDef (InfilBonusMilestoneDef Def)
{
	local X2InfiltrationBonusMilestoneTemplate Template;

	`CREATE_X2TEMPLATE(class'X2InfiltrationBonusMilestoneTemplate', Template, Def.Milestone);
	Template.ActivateAtProgress = Def.Progress;

	return Template;
}