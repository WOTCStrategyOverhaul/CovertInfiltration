class X2EventListener_Infiltration extends X2EventListener config(Infiltration);

//values from config represent a percentage to be removed from total will e.g.(25 = 25%, 50 = 50%)
var config int MIN_WILL_LOSS;
var config int MAX_WILL_LOSS;

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
	Template.AddCHEvent('CovertActionCompleted', UpdateReturningSoldiers, ELD_Immediate);
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

static protected function EventListenerReturn UpdateReturningSoldiers(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction CovertAction;

	CovertAction = XComGameState_CovertAction(EventSource);

	if (CovertAction == none)
	{
		return ELR_NoInterrupt;
	}

	UpdateSquadWill(CovertAction, GameState);
	
	return ELR_NoInterrupt;
}

static function UpdateSquadWill(XComGameState_CovertAction CovertAction, XComGameState GameState)
{
	local CovertActionStaffSlot StaffSlot;
	local XComGameState_StaffSlot StaffSlotState;
	local XComGameState_Unit UnitState;

	foreach CovertAction.StaffSlots(StaffSlot)
	{
		StaffSlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(StaffSlot.StaffSlotRef.ObjectID));
		if (StaffSlotState.IsSlotFilled())
		{
			UnitState = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', StaffSlotState.GetAssignedStaff().ObjectID));
			if (UnitState.UsesWillSystem() && !UnitState.IsInjured() && !UnitState.bCaptured)
			{
				UnitState.SetCurrentStat(eStat_Will, GetWillLoss(UnitState));
			}
			UpdateWillRecovery(GameState, UnitState);
			UnitState.UpdateMentalState();
		}
	}

	/*
	local int idx;

	for (idx = 0; idx < CovertAction.StaffSlots.Length; idx++)
	{
		StaffSlotState = CovertAction.GetStaffSlot(idx);
		if (StaffSlotState.IsSlotFilled())
		{
			UnitState = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', StaffSlotState.GetAssignedStaff().ObjectID));
			//soldier not dead or wounded, remove some will
			if (UnitState.UsesWillSystem() && !UnitState.IsInjured() && !UnitState.bCaptured)
			{
				UnitState.SetCurrentStat(eStat_Will, GetWillLoss(UnitState));
			}
			//do not reverse this order or you will divide by zero
			UpdateWillRecovery(GameState, UnitState);
			UnitState.UpdateMentalState();
		}
	}
	*/
}

static function int GetWillLoss(XComGameState_Unit UnitState)
{
	local int WillToLose, LowestWill;

	WillToLose = default.MIN_WILL_LOSS + `SYNC_RAND_STATIC(default.MAX_WILL_LOSS - default.MIN_WILL_LOSS);
	WillToLose *= UnitState.GetMaxStat(eStat_Will) / 100;
	
	LowestWill = (UnitState.GetMaxStat(eStat_Will) * class'X2StrategyGameRulesetDataStructures'.default.MentalStatePercents[eMentalState_Shaken] / 100) + 1;
	
	//never put the soldier into shaken state from covert actions
	if (UnitState.GetMaxStat(eStat_Will) - WillToLose < LowestWill)
	{
		return LowestWill;
	}
	return UnitState.GetMaxStat(eStat_Will) - WillToLose;
}

static function UpdateWillRecovery(XComGameState GameState, XComGameState_Unit UnitState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersProjectRecoverWill WillProject;
	
	History = `XCOMHISTORY;
	XComHQ = class'X2StrategyElement_DefaultMissionSources'.static.GetAndAddXComHQ(GameState);
	
	foreach History.IterateByClassType(class'XComGameState_HeadquartersProjectRecoverWill', WillProject)
	{
		if(WillProject.ProjectFocus == UnitState.GetReference())
		{
			XComHQ.Projects.RemoveItem(WillProject.GetReference());
			GameState.RemoveStateObject(WillProject.ObjectID);
			break;
		}
	}

	WillProject = XComGameState_HeadquartersProjectRecoverWill(GameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectRecoverWill'));
	WillProject.SetProjectFocus(UnitState.GetReference(), GameState);

	XComHQ.Projects.AddItem(WillProject.GetReference());
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