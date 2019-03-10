//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Container to hold data structures that need to be accessed from multiple
//           classes to avoid dependson mess
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------
class CI_DataStructures extends Object;

struct ActionExpirationInfo
{
	var StateObjectReference ActionRef;
	var TDateTime Expiration;
	var TDateTime OriginTime;
	var bool bBlockMonthlyCleanup;
};