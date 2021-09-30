class X2StrategyElement_DefaultOverInfiltrationBonuses extends X2StrategyElement config(Infiltration);

struct SitRepBonusMapping
{
	var name BonusName;
	var name SitRepName;
	var name MilestoneName;
	var bool bNeverHiddenUI;
	var array<name> SitRepsToRemove;
};

var config array<SitRepBonusMapping> SitRepBonuses;

var localized string NegateRiskDescription;

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
	
	Template.bSitRep = true;
	Template.MetatdataName = Mapping.SitRepName;
	Template.SitRepsToRemove = Mapping.SitRepsToRemove;
	Template.Milestone = Mapping.MilestoneName;
	Template.bNeverHiddenUI = Mapping.bNeverHiddenUI;
	Template.IsAvaliableFn = IsSitRepBonusAvaliable;
	Template.ApplyFn = ApplySitRepBonus;
	Template.GetBonusNameFn = GetSitRepName;
	Template.GetBonusDescriptionFn = GetSitRepDescription;

	return Template;
}

static function bool IsSitRepBonusAvaliable(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	local X2SitRepTemplate SitRepTemplate;

	if (Infiltration.GeneratedMission.SitReps.Find(BonusTemplate.MetatdataName) != INDEX_NONE)
	{
		// Already exists in the mission
		return false;
	}

	SitRepTemplate = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager().FindSitRepTemplate(BonusTemplate.MetatdataName);

	if (SitRepTemplate == none)
	{
		return false;
	}

	if (!SitRepTemplate.MeetsRequirements(Infiltration))
	{
		return false;
	}

	return true;
}

static function ApplySitRepBonus(XComGameState NewGameState, X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	local name SitRepName;

	foreach BonusTemplate.SitRepsToRemove(SitRepName)
	{
		Infiltration.GeneratedMission.SitReps.RemoveItem(SitRepName);
	}

	// While this should not be possible, prevent duplicating sitreps in any case
	if (Infiltration.GeneratedMission.SitReps.Find(BonusTemplate.MetatdataName) == INDEX_NONE)
	{
		Infiltration.GeneratedMission.SitReps.AddItem(BonusTemplate.MetatdataName);
	}

	Infiltration.PostSitRepsChanged(NewGameState);
}

static function string GetSitRepName(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	return class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager()
		.FindSitRepTemplate(BonusTemplate.MetatdataName)
		.GetFriendlyName();
}

static function string GetSitRepDescription(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	return class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager()
		.FindSitRepTemplate(BonusTemplate.MetatdataName)
		.GetDescriptionExpanded();
}

///////////////////
/// Negate risk ///
///////////////////

static function X2OverInfiltrationBonusTemplate CreateNegateRiskBonus()
{
	local X2OverInfiltrationBonusTemplate Template;

	`CREATE_X2TEMPLATE(class'X2OverInfiltrationBonusTemplate', Template, 'OverInfiltrationBonus_NegateRisk');
	
	Template.Milestone = 'RiskRemoval';
	Template.bNeverHiddenUI = true;

	Template.ApplyFn = ApplyNegateRiskBonus;
	Template.IsAvaliableFn = IsNegateRiskBonusAvaliable;
	
	Template.GetBonusDescriptionFn = GetNegateRiskDescription;

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

	Infiltration.PostSitRepsChanged(NewGameState);
}

static function string GetNegateRiskDescription (X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration)
{
	local X2SitRepTemplateManager SitRepManager;
	local X2SitRepTemplate SitRepTemplate;
	local array<string> strRemovedSitreps;
	local XGParamTag ParamTag;
	local name RiskName;
	local int i;

	SitRepManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();

	foreach Infiltration.AppliedFlatRisks(RiskName)
	{
		i = class'X2Helper_Infiltration'.default.FlatRiskSitReps.Find('FlatRiskName', RiskName);
		SitRepTemplate = SitRepManager.FindSitRepTemplate(class'X2Helper_Infiltration'.default.FlatRiskSitReps[i].SitRepName);

		strRemovedSitreps.AddItem(SitRepTemplate.GetFriendlyName());
	}

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	JoinArray(strRemovedSitreps, ParamTag.StrValue0);
	
	return `XEXPAND.ExpandString(default.NegateRiskDescription);
}
