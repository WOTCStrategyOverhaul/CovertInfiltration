//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Event listeners that facilitate functionality for certain SitReps
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2EventListener_Infiltration_SitReps extends X2EventListener;

var localized string strReinforcementDelayBannerMessage;
var localized string strReinforcementDelayBannerSubtitle;
var localized string strReinforcementDelayBannerValue;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateAdventAirPatrolListeners());
	Templates.AddItem(CreateCommsJammingListeners());
	Templates.AddItem(CreateUpdatedFirewallsListeners());

	return Templates;
}

//////////////////////////
/// ADVENT Air Patrols ///
//////////////////////////

static function X2SitRepEventListenerTemplate CreateAdventAirPatrolListeners ()
{
	local X2SitRepEventListenerTemplate Template;

	Template = CreateForSitRep('AdventAirPatrols');
	Template.AddCHEvent('ScamperEnd', AdventAirPatrol_ScamperEnd, ELD_OnStateSubmitted, 99);

	return Template;
}

static function EventListenerReturn AdventAirPatrol_ScamperEnd (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_AIGroup GroupState;
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState_CIReinforcementsManager ManagerState;
	local DelayedReinforcementOrder DelayedReinforcementOrder;
	local name EncounterID;
	local int PodStrength, SpawnerDelay, DelayCrit;

	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	GroupState = XComGameState_AIGroup(EventSource);

	if (GroupState == none || GroupState.TeamName != eTeam_Alien || CIInfo.bAirPatrolsTriggered)
	{
		return ELR_NoInterrupt;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: AdventAirPatrol_ConcealmentBroken");
	ManagerState = class'XComGameState_CIReinforcementsManager'.static.GetReinforcementsManager();
	ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));
	CIInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', CIInfo.ObjectID));

	PodStrength = `SYNC_RAND_STATIC(100) + 1;
	DelayCrit = `SYNC_RAND_STATIC(2);

	if (PodStrength < 33)
	{
		EncounterID = 'ADVx3_Weak';
		SpawnerDelay = 2;
	}
	else if (PodStrength < 66)
	{
		EncounterID = 'ADVx3_Standard';
		SpawnerDelay = 3;
	}
	else
	{
		EncounterID = 'ADVx3_Strong';
		SpawnerDelay = 4;
	}
	
	SpawnerDelay += DelayCrit;

	DelayedReinforcementOrder.EncounterID = EncounterID;
	DelayedReinforcementOrder.TurnsUntilSpawn = SpawnerDelay;

	ManagerState.DelayedReinforcementOrders.AddItem(DelayedReinforcementOrder);
	CIInfo.bAirPatrolsTriggered = true;

	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

//////////////////////
/// Comms Jamming  ///
//////////////////////

static function CHEventListenerTemplate CreateCommsJammingListeners()
{
	local X2SitrepEventListenerTemplate Template;

	Template = CreateForSitRep('CommsJamming');
	Template.AddCHEvent('ReinforcementSpawnerCreated', CommsJamming_ReinforcementDelay, ELD_OnStateSubmitted, 99);

	return Template;
}

static function EventListenerReturn CommsJamming_ReinforcementDelay(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_AIReinforcementSpawner ReinforcementSpawner;
	local XComGameState_CovertInfiltrationInfo CIInfo;
	local XComGameState NewGameState;

	ReinforcementSpawner = XComGameState_AIReinforcementSpawner(EventSource);
	CIInfo = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
	
	if (ReinforcementSpawner == none)
	{
		`redscreen("SITREP_CommsJamming: could not find ReinformentSpawner, hold onto your britches bitches");

		return ELR_NoInterrupt;
	}
	// we cannot delay instant RNFs and we only want to do this once per mission
	else if (ReinforcementSpawner.Countdown <= 0 || CIInfo.bCommsJammingTriggered)
	{
		return ELR_NoInterrupt;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: CommsJamming_ReinforcementDelay");
	ReinforcementSpawner = XComGameState_AIReinforcementSpawner(NewGameState.ModifyStateObject(class'XComGameState_AIReinforcementSpawner', ReinforcementSpawner.ObjectID));
	CIInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', CIInfo.ObjectID));

	ReinforcementSpawner.Countdown += 1;
	CIInfo.bCommsJammingTriggered = true;

	XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = XComReinforcementsDelayedVisualizationFn;
	`TACTICALRULES.SubmitGameState(NewGameState);
	
	return ELR_NoInterrupt;
}

static function XComReinforcementsDelayedVisualizationFn(XComGameState VisualizeGameState)
{
	local VisualizationActionMetadata ActionMetadata;
	local X2Action_PlayMessageBanner MessageBanner;

	MessageBanner = X2Action_PlayMessageBanner(class'X2Action_PlayMessageBanner'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
	MessageBanner.AddMessageBanner(default.strReinforcementDelayBannerMessage, , default.strReinforcementDelayBannerSubtitle, default.strReinforcementDelayBannerValue, eUIState_Good);
}

/////////////////////////
/// Updated Firewalls ///
/////////////////////////

static function CHEventListenerTemplate CreateUpdatedFirewallsListeners ()
{
	local X2SitrepEventListenerTemplate Template;

	Template = CreateForSitRep('UpdatedFirewalls');
	Template.AddCHEvent('AllowInteractHack', UpdatedFirewalls_AllowInteractHack, ELD_Immediate, 99);

	return Template;
}

static function EventListenerReturn UpdatedFirewalls_AllowInteractHack (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_InteractiveObject ObjectState;
	local XComInteractiveLevelActor ObjectActor;
	local XComLWTuple Tuple;

	ObjectState = XComGameState_InteractiveObject(EventSource);
	Tuple = XComLWTuple(EventData);

	if (ObjectState == none || Tuple == none || Tuple.Id != 'AllowInteractHack') return ELR_NoInterrupt;

	ObjectActor = XComInteractiveLevelActor(ObjectState.GetVisualizer());
	
	if (ObjectActor.ActorType == Type_AdventTower)
	{
		Tuple.Data[0].b = false;
	}
	
	return ELR_NoInterrupt;
}

///////////////
/// Helpers ///
///////////////

static function X2SitrepEventListenerTemplate CreateForSitRep (name SitRep)
{
	local X2SitRepEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEventListenerTemplate', Template, name('SitRep_' $ SitRep));
	Template.RequiredSitRep = SitRep;

	return Template;
}