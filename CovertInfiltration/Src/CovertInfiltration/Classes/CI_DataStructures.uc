//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone, Xymanek
//  PURPOSE: Container to hold data structures that need to be accessed from multiple
//           classes to avoid dependson mess
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------
class CI_DataStructures extends Object;

enum EInfilModifierType
{
	eIMT_Item,
	eIMT_Category,
	eIMT_Ability,
	eIMT_Character
};

struct InfiltrationModifier
{
	var name DataName;
	var int InfilHoursAdded;
	var float RiskReductionPercent;
	var EInfilModifierType ModifyType;
	var string DLC;

	structdefaultproperties
    {
		InfilHoursAdded = 0;
		RiskReductionPercent = 0;
		ModifyType = eIMT_Item;
    }
};

struct ActionExpirationInfo
{
	var StateObjectReference ActionRef;
	var TDateTime Expiration;
	var TDateTime OriginTime;
	var bool bBlockMonthlyCleanup;
	var bool bAlreadyWarnedOfExpiration;
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

struct InfilBonusMilestoneSelection
{
	var name MilestoneName;
	var name BonusName;
	var bool bGranted;
};

struct InfilChosenModifer
{
	var int Progress;
	var float Multiplier;
};

struct MultiStepLerpStep
{
	var float X;
	var float Y;
};

struct MultiStepLerpConfig
{
	var array<MultiStepLerpStep> Steps;

	var float ResultIfNoSteps;
	var float ResultIfXExceedsBottomBoundary;
	var float ResultIfXExceedsUpperBoundary;
};

struct BarracksStatusReport
{
	var int Ready;
	var int Tired;
	var int Wounded;
	var int Infiltrating;
	var int OnCovertAction;
	var int Unavailable;
};

struct ActionRiskDisplayInfo
{
	var string ChanceText;
	var string RiskName;
	var string Description;
};
