//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone, Xymanek
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

struct DelayedReinforcementOrder
{
	var name EncounterID;
	var int TurnsUntilSpawn;
	var bool Repeating;
	var int RepeatTime;
};

struct ItemAvaliableImageReplacement
{
	var name TargetItem;
	
	// Directly set the image (preferred)
	var string strImage;
	
	// Pull image from template
	var name ImageSourceItem;
};

struct ActivityMissionFamilyMapping
{
	var name ActivityTemplate;
	var string MissionFamily;
};

enum EActivityCompletion
{
	// The chain hasn't progressed to this activity yet
	eActivityCompletion_NotReached,

	// The player is still able to do the activity (or is doing it now)
	eActivityCompletion_NotCompleted,

	// The player failed to handle this activity in time limit
	eActivityCompletion_Expired,
	
	eActivityCompletion_Failure,
	eActivityCompletion_PartialSuccess,
	eActivityCompletion_Success
};

struct ResourcePackage {
	var name ItemType;
	var int ItemAmount;
};

struct InfilBonusMilestoneDef
{
	var name Tier;
	var int Progress;
};

struct InfilBonusMilestoneSelection
{
	var name Tier;
	var name Bonus;
	var bool bGranted;
};

struct InfilChosenModifer
{
	var int Progress;
	var float Multiplier;
};