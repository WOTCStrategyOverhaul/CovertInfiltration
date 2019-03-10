//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Base class for data set of X2CovertMissionInfos
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2CovertMissionInfo extends X2DataSet config(Infiltration);

var const string ACTIONPREFIX;

static function name GetCovertMissionInfoName(name TemplateName)
{
	return name(default.ACTIONPREFIX $ TemplateName);
}

defaultproperties
{
	ACTIONPREFIX = "Infiltration_"
}