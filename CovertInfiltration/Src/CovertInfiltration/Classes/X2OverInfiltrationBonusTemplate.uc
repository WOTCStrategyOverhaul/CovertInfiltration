class X2OverInfiltrationBonusTemplate extends X2StrategyElementTemplate config(Infiltration);

var name MetatdataName;
var bool bSitRep; // If true, then this bonus adds a sitrep to the mission. MetatdataName must be the template name of the sitrep
var array<name> SitRepsToRemove; // Only takes effect if bSitRep is true

var name Milestone; // TODO: Validate
var int Weight;
var bool DoNotMarkUsed;

var protected localized string BonusName;
var protected localized string BonusDescription;

delegate bool IsAvaliableFn(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration);
delegate ApplyFn(XComGameState NewGameState, X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration);

delegate string GetBonusNameFn(X2OverInfiltrationBonusTemplate BonusTemplate);
delegate string GetBonusDescriptionFn(X2OverInfiltrationBonusTemplate BonusTemplate);

function string GetBonusName()
{
	if (GetBonusNameFn != none)
	{
		return GetBonusNameFn(self);
	}

	return BonusName;
}

function string GetBonusDescription()
{
	if (GetBonusDescriptionFn != none)
	{
		return GetBonusDescriptionFn(self);
	}

	return BonusDescription;
}