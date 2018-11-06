//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class adds several functions that help
//           in creating X2CovertMissionInfoTemplates
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