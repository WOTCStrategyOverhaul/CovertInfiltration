class X2ActivityTemplate_CovertAction extends X2ActivityTemplate;

var name CovertActionName;

var config bool bExpires;
var config int ExpirationBaseTime;
var config int ExpirationVariance;
var config bool ExpirationNotBlocksCleanup; // Inverted, so that default is "block cleanup"

static function DefaultCovertActionSetup (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_Activity_CovertAction CAActivity;

	CreateCovertAction(NewGameState, ActivityState);
	AddExpiration(NewGameState, ActivityState);

	class'UIUtilities_Infiltration'.static.InfiltrationActionAvaliable(ActivityState.SecondaryObjectRef, NewGameState);

	CAActivity = XComGameState_Activity_CovertAction(ActivityState);
	CAActivity.RegisterForActionEvents();
}

static function CreateCovertAction (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local X2ActivityTemplate_CovertAction ActivityTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState_ResistanceFaction FactionState;
	local X2CovertActionTemplate ActionTemplate;
	local XComGameState_CovertAction ActionState;

	FactionState = ActivityState.GetActivityChain().GetFaction();
	ActivityTemplate = X2ActivityTemplate_CovertAction(ActivityState.GetMyTemplate());
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(TemplateManager.FindStrategyElementTemplate(ActivityTemplate.CovertActionName));

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
	ActionState = ActionTemplate.CreateInstanceFromTemplate(NewGameState, FactionState.GetReference());
	ActivityState.PrimaryObjectRef = ActionState.GetReference(); // Needed here so that we can get reference to chain for region select inside Spawn
	
	ActionState.Spawn(NewGameState);
	ActionState.RequiredFactionInfluence = eFactionInfluence_Minimal;
	ActionState.bNewAction = true;

	FactionState.CovertActions.AddItem(ActionState.GetReference());
}

static function AddExpiration (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComGameState_CovertActionExpirationManager ActionExpirationManager;
	local X2ActivityTemplate_CovertAction ActivityTemplate;
	local TDateTime Expiration;
	
	ActivityTemplate = X2ActivityTemplate_CovertAction(ActivityState.GetMyTemplate());
	
	if (ActivityTemplate.bExpires)
	{
		Expiration = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
		ActionExpirationManager = class'XComGameState_CovertActionExpirationManager'.static.GetExpirationManager();
		ActionExpirationManager = XComGameState_CovertActionExpirationManager(NewGameState.ModifyStateObject(class'XComGameState_CovertActionExpirationManager', ActionExpirationManager.ObjectID));

		class'X2StrategyGameRulesetDataStructures'.static.AddHours(Expiration, ActivityTemplate.ExpirationBaseTime * 24 + CreateExpirationVariance(ActivityTemplate));

		ActionExpirationManager.AddActionExpirationInfo(ActivityState.PrimaryObjectRef, Expiration, !ActivityTemplate.ExpirationNotBlocksCleanup);
	}
}

defaultproperties
{
	SetupStage = DefaultCovertActionSetup
	StateClass = class'XComGameState_Activity_CovertAction'
}