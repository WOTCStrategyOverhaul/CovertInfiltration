//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek and statusNone
//  PURPOSE: Houses X2EventListenerTemplates that affect gameplay. Mostly CHL hooks
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2EventListener_Infiltration extends X2EventListener config(Infiltration);

//values from config represent a percentage to be removed from total will e.g.(25 = 25%, 50 = 50%)
var config int MIN_WILL_LOSS;
var config int MAX_WILL_LOSS;

var localized string strReinforcementDelayBannerMessage;
var localized string strReinforcementDelayBannerSubtitle;
var localized string strReinforcementDelayBannerValue;

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
	Template.AddCHEvent('NumCovertActionsToAdd', NumCovertActionToAdd, ELD_Immediate);
	Template.AddCHEvent('CovertActionCompleted', CovertActionCompleted, ELD_Immediate);
	Template.AddCHEvent('AllowDarkEventRisk', AllowDarkEventRisk, ELD_Immediate);
	Template.AddCHEvent('CovertActionRisk_AlterChanceModifier', AlterRiskChanceModifier, ELD_Immediate);
	Template.AddCHEvent('CovertAction_PreventGiveRewards', PreventActionRewards, ELD_Immediate);
	Template.AddCHEvent('CovertAction_RemoveEntity_ShouldEmptySlots', ShouldEmptySlotsOnActionRemoval, ELD_Immediate);
	Template.AddCHEvent('ShouldCleanupCovertAction', ShouldCleanupCovertAction, ELD_Immediate);
	Template.AddCHEvent('OnResearchReport', TriggerPrototypeAlert, ELD_OnStateSubmitted);
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

static protected function EventListenerReturn CovertActionCompleted(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_MissionSiteInfiltration MissionState;
	local XComGameState_CovertAction CovertAction;

	CovertAction = XComGameState_CovertAction(EventSource);

	if (CovertAction == none)
	{
		return ELR_NoInterrupt;
	}

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(CovertAction))
	{
		`log(CovertAction.GetMyTemplateName() @ "finished, spawning infiltration ",, 'CI');

		MissionState = XComGameState_MissionSiteInfiltration(GameState.CreateNewStateObject(class'XComGameState_MissionSiteInfiltration'));
		MissionState.SetupFromAction(GameState, CovertAction);

		// Do not show the CA report, the mission will show its screen instead
		CovertAction.bNeedsActionCompletePopup = false;

		// Remove the CA, the mission takes over from here
		CovertAction.RemoveEntity(GameState);
	}
	else
	{
		`log(CovertAction.GetMyTemplateName() @ "finished, it was not an infiltration - applying fatigue",, 'CI');

		ApplyPostActionWillLoss(CovertAction, GameState);
	}
	
	return ELR_NoInterrupt;
}

static protected function ApplyPostActionWillLoss(XComGameState_CovertAction CovertAction, XComGameState NewGameState)
{
	local CovertActionStaffSlot CovertActionSlot;
	local XComGameState_StaffSlot SlotState;
	local XComGameState_Unit UnitState;
	
	foreach CovertAction.StaffSlots(CovertActionSlot)
	{
		SlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		if (SlotState.IsSlotFilled())
		{
			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SlotState.GetAssignedStaff().ObjectID));
			if (UnitState.UsesWillSystem() && !UnitState.IsInjured() && !UnitState.bCaptured)
			{
				class'X2Helper_Infiltration'.static.CreateWillRecoveryProject(NewGameState, UnitState);
				UnitState.SetCurrentStat(eStat_Will, GetWillLoss(UnitState));
				UnitState.UpdateMentalState();
			}
		}
	}
}

static protected function int GetWillLoss(XComGameState_Unit UnitState)
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

	return UnitState.GetCurrentStat(eStat_Will) - WillToLose;
}

static protected function EventListenerReturn AllowDarkEventRisk(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Action == none || Tuple == none || Tuple.Id != 'AllowDarkEventRisk') return ELR_NoInterrupt;

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		// Infiltrations cannot get DE risks (at least for now)
		Tuple.Data[1].b = false;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn AlterRiskChanceModifier(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local array<StateObjectReference> ActionSquad;
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Action == none || Tuple == none || Tuple.Id != 'CovertActionRisk_AlterChanceModifier') return ELR_NoInterrupt;
	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action)) return ELR_NoInterrupt;

	ActionSquad = class'X2Helper_Infiltration'.static.GetCovertActionSquad(Action);
	Tuple.Data[4].i -= class'X2Helper_Infiltration'.static.GetSquadDeterrence(ActionSquad);
	`log("Risk modifier for" @ Tuple.Data[0].n @ "is" @ Tuple.Data[4].i $ ", base chance is" @ Tuple.Data[1].i,, 'CI');

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn PreventActionRewards(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Action == none || Tuple == none || Tuple.Id != 'CovertAction_PreventGiveRewards') return ELR_NoInterrupt;

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		// The reward is the mission, you greedy
		Tuple.Data[0].b = true;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn ShouldEmptySlotsOnActionRemoval(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Action = XComGameState_CovertAction(EventSource);
	Tuple = XComLWTuple(EventData);
	
	if (Action == none || Tuple == none || Tuple.Id != 'CovertAction_RemoveEntity_ShouldEmptySlots') return ELR_NoInterrupt;

	if (!Action.bStarted && class'X2Helper_Infiltration'.static.IsInfiltrationAction(Action))
	{
		// do not kick people from finished infiltration - we will do it right before launching the mission
		Tuple.Data[0].b = false;
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn ShouldCleanupCovertAction(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local ActionExpirationInfo ExpirationInfo;
	local XComGameState_CovertAction Action;
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'ShouldCleanupCovertAction') return ELR_NoInterrupt;

	Action = XComGameState_CovertAction(Tuple.Data[0].o);

	if (class'XComGameState_CovertActionExpirationManager'.static.GetActionExpirationInfo(Action.GetReference(), ExpirationInfo))
	{
		if (ExpirationInfo.bBlockMonthlyCleanup)
		{
			Tuple.Data[1].b = false;
		}
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn TriggerPrototypeAlert(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_Tech TechState;
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;
	local array<name> ItemRewards;
	local name ItemName;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	TechState = XComGameState_Tech(EventData);

	if(TechState == none) return ELR_NoInterrupt;

	ItemRewards = TechState.GetMyTemplate().ItemRewards;
	foreach ItemRewards(ItemName)
	{
		if(Left(string(ItemName), 4) == "TLE_")
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Add Prototype Item");
			ItemTemplate = ItemTemplateManager.FindItemTemplate(ItemName);
			class'XComGameState_HeadquartersXCom'.static.GiveItem(NewGameState, ItemTemplate);
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

			`HQPRES.UIItemReceived(ItemTemplate);
		}
	}

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
	Template.AddEvent('SquadConcealmentBroken', AdventAirPatrol_ConcealmentBroken);
	Template.AddEvent('ReinforcementSpawnerCreated', CommsJamming_ReinforcementDelay);
	Template.AddCHEvent('OnTacticalBeginPlay', OnTacticalPlayBegun, ELD_OnStateSubmitted);
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

static function EventListenerReturn AdventAirPatrol_ConcealmentBroken(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_BattleData BattleData;
	local XComGameState_CIReinforcementsManager ManagerState;
	local DelayedReinforcementOrder DelayedReinforcementOrder;
	local name EncounterID;
	local int PodStrength, SpawnerDelay, DelayCrit;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Updating Reinforcements Manager (Mid Turn)");
	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	ManagerState = class'XComGameState_CIReinforcementsManager'.static.GetReinforcementsManager();
	ManagerState = XComGameState_CIReinforcementsManager(NewGameState.ModifyStateObject(class'XComGameState_CIReinforcementsManager', ManagerState.ObjectID));

	if (BattleData.ActiveSitReps.Find('AdventAirPatrols') == INDEX_NONE)
	{
		return ELR_NoInterrupt;
	}
	
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

static function EventListenerReturn CommsJamming_ReinforcementDelay(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_AIReinforcementSpawner ReinforcementSpawner;
	local XComGameState_BattleData BattleData;
	local XComGameState NewGameState;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	ReinforcementSpawner = XComGameState_AIReinforcementSpawner(EventSource);

	if (BattleData.ActiveSitReps.Find('CommsJamming') == INDEX_NONE)
	{
		return ELR_NoInterrupt;
	}
	
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

static function EventListenerReturn OnTacticalPlayBegun(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	class'XComGameState_CIReinforcementsManager'.static.CreateReinforcementsManager();

	return ELR_NoInterrupt;
}