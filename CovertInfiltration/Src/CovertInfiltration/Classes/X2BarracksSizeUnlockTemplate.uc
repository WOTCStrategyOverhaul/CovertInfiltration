//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Template for barracks size unlocks.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2BarracksSizeUnlockTemplate extends X2StrategyElementTemplate;

var string strImage;
var config StrategyCost Cost;
var config StrategyRequirement Requirements;

var localized string DisplayName;
var protected localized string Summary;

function string GetDisplayName() { return DisplayName; }
function string GetSummary() { return `XEXPAND.ExpandString(Summary); }

//---------------------------------------------------------------------------------------
DefaultProperties
{
	bShouldCreateDifficultyVariants = true
}