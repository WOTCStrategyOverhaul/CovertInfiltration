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

struct ActionFlatRiskSitRep
{
	var name FlatRiskName;
	var name SitRepName;
};

struct DelayedReinforcementSpawner
{
	var name EncounterID;
	var int TurnCreated;
	var int SpawnerDelay;
	var int TurnsUntilSpawn;
};