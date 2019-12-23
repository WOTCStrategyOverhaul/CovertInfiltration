//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Template for an infiltration mission as an activity
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ActivityTemplate_Infiltration extends X2ActivityTemplate_Mission config(Infiltration);

var name CovertActionName;

var localized string ActionRewardDisplayName;
var localized string ActionRewardDetails;

var string MissionReadySound;
var string MilestoneSound;

// Expiry in hours
var config bool bExpires;
var config int ExpirationBaseTime;
var config int ExpirationVariance;
var config bool ExpirationNotBlocksCleanup; // Inverted, so that default is "block cleanup"

delegate string GetRewardDetailStringFn(XComGameState_Activity ActivityState, XComGameState_Reward RewardState);

//////////////////////
/// Initialization ///
//////////////////////

static function DefaultInfiltrationSetup (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	CreateCovertAction(NewGameState, ActivityState);
	CreateMission(NewGameState, ActivityState);

	AddExpiration(NewGameState, ActivityState);
	SetupFlatRisk(NewGameState, ActivityState);
}

static function CreateCovertAction (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local X2ActivityTemplate_Infiltration ActivityTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_ResistanceFaction FactionState;
	local X2CovertActionTemplate ActionTemplate;
	local XComGameState_CovertAction ActionState;

	FactionState = ActivityState.GetActivityChain().GetFaction();
	ActivityTemplate = X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate());
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(TemplateManager.FindStrategyElementTemplate(ActivityTemplate.CovertActionName));

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
	ActionState = XComGameState_CovertAction(NewGameState.CreateNewStateObject(class'XComGameState_CovertAction', ActionTemplate));
	ActivityState.SecondaryObjectRef = ActionState.GetReference(); // Needed here so that we can get reference to chain for region select inside Spawn
	
	ActionState.PostCreateInit(NewGameState, FactionState.GetReference());
	ActionState.Spawn(NewGameState);
	ActionState.RequiredFactionInfluence = eFactionInfluence_Minimal;
	ActionState.bNewAction = true;

	FactionState.CovertActions.AddItem(ActionState.GetReference());

	XComGameState_Activity_Infiltration(ActivityState).RegisterForActionEvents();
}

static function AddExpiration (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local X2ActivityTemplate_Infiltration ActivityTemplate;
	local TDateTime Expiration;
	
	ActivityTemplate = X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate());
	
	if (ActivityTemplate.bExpires)
	{
		Expiration = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
		ActionExpirationManager = class'XComGameState_CovertActionExpirationManager'.static.GetExpirationManager();
		ActionExpirationManager = XComGameState_CovertActionExpirationManager(NewGameState.ModifyStateObject(class'XComGameState_CovertActionExpirationManager', ActionExpirationManager.ObjectID));

		class'X2StrategyGameRulesetDataStructures'.static.AddHours(Expiration, ActivityTemplate.ExpirationBaseTime + CreateExpirationVariance(ActivityTemplate));

		ActionExpirationManager.AddActionExpirationInfo(ActivityState.SecondaryObjectRef, Expiration, !ActivityTemplate.ExpirationNotBlocksCleanup);
	}
}

static function int CreateExpirationVariance (X2ActivityTemplate_Infiltration ActivityTemplate)
{
	local int Variance;
	local bool bNegVariance;

	Variance = `SYNC_RAND_STATIC(ActivityTemplate.ExpirationVariance);

	// roll chance for negative variance
	bNegVariance = `SYNC_RAND_STATIC(2) < 1;
	if (bNegVariance) Variance *= -1;

	return Variance;
}

static function CreateMission (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSiteInfiltration MissionState;

	MissionState = XComGameState_MissionSiteInfiltration(NewGameState.CreateNewStateObject(class'XComGameState_MissionSiteInfiltration'));
	ActivityState.PrimaryObjectRef = MissionState.GetReference();
	
	MissionState.InitializeFromActivity(NewGameState);
}

static function SetupFlatRisk (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSiteInfiltration MissionState;
	local X2CovertActionRiskTemplate RiskTemplate;
	local XComGameState_CovertAction ActionState;

	MissionState = XComGameState_MissionSiteInfiltration(`XCOMHISTORY.GetGameStateForObjectID(ActivityState.PrimaryObjectRef.ObjectID));
	ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActivityState.SecondaryObjectRef.ObjectID));
	
	RiskTemplate = SelectFlatRisk(MissionState);

	if (RiskTemplate != none)
	{
		class'X2Helper_Infiltration'.static.AddRiskToAction(RiskTemplate, ActionState);
		ActionState.RecalculateRiskChanceToOccurModifiers();
	}
}

static function X2CovertActionRiskTemplate SelectFlatRisk (XComGameState_MissionSiteInfiltration MissionState)
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2SitRepTemplateManager SitRepManager;
	local ActionFlatRiskSitRep FlatRiskDef;
	local X2SitRepTemplate SitRepTemplate;
	local X2CardManager CardManager;
	local array<string> CardLabels;
	local name RiskName;
	local string sRisk;
	local int i;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	SitRepManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
	CardManager = class'X2CardManager'.static.GetCardManager();

	// Build the deck
	class'X2Helper_Infiltration'.static.BuildFlatRisksDeck();

	// Try to find a matching one
	CardManager.GetAllCardsInDeck('FlatRisks', CardLabels);
	foreach CardLabels(sRisk)
	{
		RiskName = name(sRisk);
		i = class'X2Helper_Infiltration'.default.FlatRiskSitReps.Find('FlatRiskName', RiskName);

		if (i != INDEX_NONE)
		{
			FlatRiskDef = class'X2Helper_Infiltration'.default.FlatRiskSitReps[i];
			SitRepTemplate = SitRepManager.FindSitRepTemplate(FlatRiskDef.SitRepName);

			if (SitRepTemplate.MeetsRequirements(MissionState))
			{
				CardManager.MarkCardUsed('FlatRisks', sRisk);
				return X2CovertActionRiskTemplate(StratMgr.FindStrategyElementTemplate(FlatRiskDef.FlatRiskName));
			}
		}
	}

	`RedScreen("CI: Failed to find a flat risk to use for infiltration");
	return none;
}

static function DefaultSetupStageSubmitted (XComGameState_Activity ActivityState)
{
	class'UIUtilities_Infiltration'.static.InfiltrationAvaliable(
		XComGameState_MissionSiteInfiltration(class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState))
	);
}

/////////////////
/// Callbacks ///
/////////////////

static function string DefaultGetMissionImageInfiltration (XComGameState_Activity ActivityState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	
	local X2CovertActionNarrativeTemplate NarrativeTemplate;
	local X2ActivityTemplate_Infiltration ActivityTemplate;
	local X2CovertActionTemplate ActionTemplate;

	// The easiest way would be to call XComGameState_CovertAction::GetImage() but that breaks
	// if we went on a mission since the XCGS_Infiltration became avaliable

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	ActivityTemplate = X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate());
	ActionTemplate = X2CovertActionTemplate(TemplateManager.FindStrategyElementTemplate(ActivityTemplate.CovertActionName));
	NarrativeTemplate = X2CovertActionNarrativeTemplate(TemplateManager.FindStrategyElementTemplate(ActionTemplate.Narratives[0]));

	return NarrativeTemplate.ActionImage;
}

static function string DefaultGetRewardDetails (XComGameState_Activity ActivityState, XComGameState_Reward RewardState)
{
	return X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate()).ActionRewardDetails;
}

static function string DefaultGetOverviewStatusInfiltration (XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;

	if (ActivityState.IsOngoing())
	{
		InfiltrationState = XComGameState_MissionSiteInfiltration(class'X2Helper_Infiltration'.static.GetMissionStateFromActivity(ActivityState));
		
		// SoldiersOnMission is set when the CA is launched, so we don't need to make a distiction here
		if (InfiltrationState.SoldiersOnMission.Length > 0)
		{
			return class'UIUtilities_Infiltration'.default.strCompletionStatusLabel_Infiltrating;
		}
		else
		{
			return class'UIUtilities_Infiltration'.default.strCompletionStatusLabel_Available;
		}
	}

	return DefaultGetOverviewStatus(ActivityState);
}

defaultproperties
{
	SetupStage = DefaultInfiltrationSetup
	SetupStageSubmitted = DefaultSetupStageSubmitted
	GetMissionImage = DefaultGetMissionImageInfiltration
	GetRewardDetailStringFn = DefaultGetRewardDetails
	GetOverviewStatus = DefaultGetOverviewStatusInfiltration

	StateClass = class'XComGameState_Activity_Infiltration'
	ScreenClass = class'UIMission_Infiltrated'
	MissionReadySound = "Play_SoldierPromotion"
	MilestoneSound = "Play_SoldierPromotion"
}