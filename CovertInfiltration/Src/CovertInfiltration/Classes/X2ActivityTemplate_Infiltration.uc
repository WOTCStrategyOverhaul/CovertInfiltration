class X2ActivityTemplate_Infiltration extends X2ActivityTemplate_Mission config(Infiltration);

var name CovertActionName;

var config bool bExpires;
var config int ExpirationBaseTime;
var config int ExpirationVariance;
var config bool ExpirationNotBlocksCleanup; // Inverted, so that default is "block cleanup"

delegate array<StateObjectReference> InitializeRewards(XComGameState NewGameState, XComGameState_MissionSiteInfiltration MissionSite);

// TODO:
// (1) Remove X2CovertMissionInfoTemplate
// (2) Make just one infiltration mission source
// (3) Create XComGameState_MissionSiteInfiltration when the covert action itself is created and pick the mission type then

static function DefaultInfiltrationSetup (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	ActivityState.SecondaryObjectRef = CreateCovertAction(NewGameState, ActivityState);
	ActivityState.PrimaryObjectRef = CreateMission(NewGameState, ActivityState);

	AddExpiration(NewGameState, ActivityState);

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(NewActionRef, NewGameState);
}

static function StateObjectReference CreateCovertAction (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local X2ActivityTemplate_Infiltration ActivityTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_ResistanceFaction FactionState;
	local X2CovertActionTemplate ActionTemplate;
	local StateObjectReference NewActionRef;

	ActivityTemplate = X2ActivityTemplate_Infiltration(ActivityState.GetMyTemplate());
	FactionState = class'XComGameState_PhaseOneActionsSpawner'.static.GetFactionForNewAction();
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(TemplateManager.FindStrategyElementTemplate(ActivityTemplate.CovertActionName));

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
	NewActionRef = FactionState.CreateCovertAction(NewGameState, ActionTemplate, eFactionInfluence_Minimal);
	FactionState.CovertActions.AddItem(NewActionRef);
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

		class'X2StrategyGameRulesetDataStructures'.static.AddHours(Expiration, ActivityTemplate.ExpirationBaseTime * 24 + CreateExpirationVariance(ActivityTemplate));

		ActionExpirationManager.AddActionExpirationInfo(ActivityState.SecondaryObjectRef, Expiration, !ActivityTemplate.ExpirationNotBlocksCleanup);
	}
}

static function int CreateExpirationVariance (X2ActivityTemplate_Infiltration ActivityTemplate)
{
	local int Variance;
	local bool bNegVariance;

	Variance = `SYNC_RAND(ActivityTemplate.ExpirationVariance);

	// roll chance for negative variance
	bNegVariance = `SYNC_RAND(2) < 1;
	if (bNegVariance) Variance *= -1;

	return Variance;
}

static function StateObjectReference CreateMission (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	// TODO
}

defaultproperties
{
	SetupStage = static.DefaultInfiltrationSetup
}