class X2OverInfiltrationBonusTemplate extends X2StrategyElementTemplate config(Infiltration);

var name MetatdataName;

var config int Tier;
var config int Weight;
var config bool DoNotMarkUsed;

var localized string BonusName;
var localized string BonusDescription;

delegate bool IsAvaliableFn(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration);
delegate ApplyFn(X2OverInfiltrationBonusTemplate BonusTemplate, XComGameState_MissionSiteInfiltration Infiltration);