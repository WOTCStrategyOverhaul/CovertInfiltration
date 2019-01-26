class X2EventListener_Infiltration extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateStrategyListeners());
	Templates.AddItem(CreateTacticalListeners());

	return Templates;
}

////////////////
/// Strategy ///
////////////////

static function CHEventListenerTemplate CreateStrategyListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_Strategy');
	Template.AddCHEvent('NumCovertActionsToAdd', NumCovertActionToAdd, ELD_Immediate); // Relies on CHL #373, will be avaliable in v1.17
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn NumCovertActionToAdd(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_ResistanceFaction Faction;
	local XComLWTuple Tuple;

	Faction = XComGameState_ResistanceFaction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Faction == none || Tuple == none || Tuple.Id != 'NumCovertActionsToAdd') return ELR_NoInterrupt;

	// Force the same behaviour as with ring
	Tuple.Data[0].i = class'XComGameState_ResistanceFaction'.default.CovertActionsPerInfluence[Faction.Influence];

	return ELR_NoInterrupt;
}

////////////////
/// Tactical ///
////////////////

static function CHEventListenerTemplate CreateTacticalListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'Infiltration_Tactical');
	Template.AddCHEvent('PostMissionObjectivesSpawned', AddCovertEscapeObjective, ELD_Immediate);
	Template.RegisterInTactical = true;

	return Template;
}

static protected function EventListenerReturn AddCovertEscapeObjective(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComTacticalMissionManager MissionManager;
	local XComParcelManager ParcelManager;

	local XComGameStateContext_TacticalGameRule StateChangeContainer;
	local XComGameState_InteractiveObject InteractiveObject;
	local XComGameState_ObjectiveInfo ObjectiveState;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	local XComInteractiveLevelActor VisArchetype;
	local XComInteractiveLevelActor Visualizer;
	local vector ObjectiveLocation;
	local XComWorldData XComWorld;

	`log("AddCovertEscapeObjective hit",, 'CI');

	MissionManager = `TACTICALMISSIONMGR;
	ParcelManager = `PARCELMGR;
	History = `XCOMHISTORY;
	XComWorld = `XWORLD;

	if (MissionManager.ActiveMission.sType != "CovertEscape")
	{
		// DO NOT touch other missions
		`log("AddCovertEscapeObjective skip due to wrong mission type",, 'CI');
		return ELR_NoInterrupt;
	}

	// The following code is heavily "inspired" by XComTacticalMissionManager::CreateObjective_Interact
	// The idea is to just spawn a dummy objective at objective parcel so that LOP works correctly

	VisArchetype = XComInteractiveLevelActor(DynamicLoadObject("XComInteractiveLevelActor'Mission_Assets.Archetypes.ARC_IA_GenericObjectiveMarker'", class'XComInteractiveLevelActor'));
	ObjectiveLocation = ParcelManager.ObjectiveParcel.Location;

	NewGameState = History.GetStartState();
	if(NewGameState == none)
	{
		// the start state has already been locked, so we'll need to make our own
		StateChangeContainer = XComGameStateContext_TacticalGameRule(class'XComGameStateContext_TacticalGameRule'.static.CreateXComGameStateContext());
		StateChangeContainer.GameRuleType = eGameRule_UnitAdded;
		NewGameState = History.CreateNewGameState(true, StateChangeContainer);
	}

	// spawn the game object
	InteractiveObject = XComGameState_InteractiveObject(NewGameState.CreateNewStateObject(class'XComGameState_InteractiveObject'));
	XComWorld.GetFloorTileForPosition(ObjectiveLocation, InteractiveObject.TileLocation);
	InteractiveObject.ArchetypePath = PathName(VisArchetype);
	//InteractiveObject.InteractionBoundingBox = ... Let's hope this isn't needed

	ObjectiveState = XComGameState_ObjectiveInfo(NewGameState.CreateNewStateObject(class'XComGameState_ObjectiveInfo'));
	ObjectiveState.MissionType = "CovertEscape";
	InteractiveObject.AddComponentObject(ObjectiveState);

	// snap the loc to the spawned game object
	ObjectiveLocation = XComWorld.GetPositionFromTileCoordinates(InteractiveObject.TileLocation);
	ObjectiveLocation.Z = XComWorld.GetFloorZForPosition(ObjectiveLocation);

	// submit the new state
	if(NewGameState != History.GetStartState())
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}

	`log("Added dummy objective at objective parcel location",, 'CI');

	// spawn the visualizer object. 
	InteractiveObject.ActorId.Location = ObjectiveLocation; //Set the location on the state object so it can be found when the visualizer spawns. TODO: Is this writing to history after submission?
	Visualizer = `XCOMGAME.Spawn(VisArchetype.Class,,, ObjectiveLocation, rot(0,0,0), VisArchetype, true);
	Visualizer.SetObjectIDFromState(InteractiveObject);

	Visualizer.UpdateLootSparklesEnabled(false, InteractiveObject);

	// No need for this since we are spawning from scratch
	//UpdateObjectiveVisualizerFromSwapInfo(Visualizer, Spawn, SpawnInfo);

	History.SetVisualizer(InteractiveObject.ObjectID, Visualizer);
	InteractiveObject.SetInitialState(Visualizer);
	Visualizer.SetObjectIDFromState(InteractiveObject);

	return ELR_NoInterrupt;
}