//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Container to hold data structures that need accessed from multiple places
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