class X2OverInfiltrationBonusTemplate extends X2StrategyElementTemplate;

var name MetatdataName;

var config int Tier;

var localized string BonusName;
var localized string BonusDescription;

delegate bool IsAvaliable(XComGameState_MissionSiteInfiltration Infiltration);
delegate Apply(XComGameState_MissionSiteInfiltration Infiltration);