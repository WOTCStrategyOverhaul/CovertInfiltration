class X2StrategyElement_DefaultOverInfiltrationBonuses extends X2StrategyElement config(Infiltration);

struct SitRepBonusMapping
{
	var name BonusName;
	var name SitRepName;
};

var config array<SitRepBonusMapping> SitRepBonuses;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Bonuses;
	local SitRepBonusMapping SitRepBonus;
	
	// Create SitRep ones
	foreach default.SitRepBonuses(SitRepBonus)
	{
		Bonuses.AddItem(CreateSitRepBonus(SitRepBonus));
	}

	// Create NegateRisk one
	Bonuses.AddItem(CreateNegateRiskBonus());

	return Bonuses;
}

///////////////
/// SitReps ///
///////////////

static function X2OverInfiltrationBonusTemplate CreateSitRepBonus(SitRepBonusMapping Mapping)
{
	local X2OverInfiltrationBonusTemplate Template;

	`CREATE_X2TEMPLATE(class'X2OverInfiltrationBonusTemplate', Template, Mapping.BonusName);
	
	Template.MetatdataName = Mapping.SitRepName;
	Template.IsAvaliableFn = IsSitRepBonusAvaliable;
	Template.ApplyFn = ApplySitRepBonus;

	return Template;
}

static function bool IsSitRepBonusAvaliable(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	return Infiltration.GeneratedMission.SitReps.Find(BonusTemplate.MetatdataName) == INDEX_NONE;
}

static function ApplySitRepBonus(XComGameState NewGameState, X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	// While this should not be possible, prevent duplicating sitreps in any case
	if (Infiltration.GeneratedMission.SitReps.Find(BonusTemplate.MetatdataName) == INDEX_NONE)
	{
		Infiltration.GeneratedMission.SitReps.AddItem(BonusTemplate.MetatdataName);
		Infiltration.UpdateSitrepTags();
	}
}

///////////////////
/// Negate risk ///
///////////////////

static function X2OverInfiltrationBonusTemplate CreateNegateRiskBonus()
{
	local X2OverInfiltrationBonusTemplate Template;

	`CREATE_X2TEMPLATE(class'X2OverInfiltrationBonusTemplate', Template, 'OverInfiltrationBonus_NegateRisk');
	
	Template.IsAvaliableFn = IsSitRepBonusAvaliable;
	Template.ApplyFn = ApplySitRepBonus;

	return Template;
}

static function bool IsNegateRiskBonusAvaliable(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	return Infiltration.AppliedFlatRisks.Length > 0;
}

static function ApplyNegateRiskBonus(XComGameState NewGameState, X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	local name SitRepName;
	local name RiskName;
	local int i;

	foreach Infiltration.AppliedFlatRisks(RiskName)
	{
		i = class'X2Helper_Infiltration'.default.FlatRiskSitReps.Find('FlatRiskName', RiskName);
		SitRepName = class'X2Helper_Infiltration'.default.FlatRiskSitReps[i].SitRepName;

		Infiltration.GeneratedMission.SitReps.RemoveItem(SitRepName);
	}

	Infiltration.UpdateSitrepTags();
}