class X2EventListener_Infiltration_SitReps extends X2EventListener;

var localized string strReinforcementDelayBannerMessage;
var localized string strReinforcementDelayBannerSubtitle;
var localized string strReinforcementDelayBannerValue;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateAdventAirPatrolListeners());
	Templates.AddItem(CreateCommsJammingListeners());

	return Templates;
}

//////////////////////////
/// ADVENT Air Patrols ///
//////////////////////////

static function X2SitRepEventListenerTemplate CreateAdventAirPatrolListeners ()
{
	local X2SitRepEventListenerTemplate Template;

	Template = CreateForSitRep('AdventAirPatrols');
	Template.AddEvent('SquadConcealmentBroken', AdventAirPatrol_ConcealmentBroken);

	return Template;
}

static function EventListenerReturn AdventAirPatrol_ConcealmentBroken (Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_CIReinforcementsManager ManagerState;
	local DelayedReinforcementOrder DelayedReinforcementOrder;
	local name EncounterID;
	local int PodStrength, SpawnerDelay, DelayCrit;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: AdventAirPatrol_ConcealmentBroken");
	ManagerState = class'XComGameState_CIReinforcementsManager'.static.GetReinforcementsManager();
	ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));

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
	Template.AddEvent('ReinforcementSpawnerCreated', CommsJamming_ReinforcementDelay);

	return Template;
}

static function EventListenerReturn CommsJamming_ReinforcementDelay(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_AIReinforcementSpawner ReinforcementSpawner;
	local XComGameState NewGameState;

	ReinforcementSpawner = XComGameState_AIReinforcementSpawner(EventSource);
	
	if (ReinforcementSpawner == none)
	{
		`redscreen("SITREP_CommsJamming: could not find ReinformentSpawner, hold onto your britches bitches");

		return ELR_NoInterrupt;
	}
	// we cannot delay instant RNFs
	else if (ReinforcementSpawner.Countdown <= 0)
	{
		return ELR_NoInterrupt;
	}
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Changing Reinforcement Spawner Countdown");

	ReinforcementSpawner = XComGameState_AIReinforcementSpawner(NewGameState.ModifyStateObject(class'XComGameState_AIReinforcementSpawner', ReinforcementSpawner.ObjectID));
	ReinforcementSpawner.Countdown += 1;

	XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = XComReinforcementsDelayedVisualizationFn;
	`TACTICALRULES.SubmitGameState(NewGameState);
	
	return ELR_NoInterrupt;
}

function XComReinforcementsDelayedVisualizationFn(XComGameState VisualizeGameState)
{
	local VisualizationActionMetadata ActionMetadata;
	local X2Action_PlayMessageBanner MessageBanner;

	MessageBanner = X2Action_PlayMessageBanner(class'X2Action_PlayMessageBanner'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
	MessageBanner.AddMessageBanner(default.strReinforcementDelayBannerMessage, , default.strReinforcementDelayBannerSubtitle, default.strReinforcementDelayBannerValue, eUIState_Good);
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