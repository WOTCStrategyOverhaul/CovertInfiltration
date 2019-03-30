class X2StrategyElement_DefaultOverInfiltrationBonuses extends X2StrategyElement;

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

static function ApplySitRepBonus(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	// TODO
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
	return Infiltration.AppliedFlatRiskName != '';
}

static function ApplyNegateRiskBonus(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	// TODO
}