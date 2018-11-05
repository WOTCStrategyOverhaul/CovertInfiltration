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
	local name CovertMissionInfoName;
	CovertMissionInfoName = name(default.ACTIONPREFIX $ TemplateName);
	return CovertMissionInfoName;
}

defaultproperties
{
	ACTIONPREFIX = "Infiltration_"
}