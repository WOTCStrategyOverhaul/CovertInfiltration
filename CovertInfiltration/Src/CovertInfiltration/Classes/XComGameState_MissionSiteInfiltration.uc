//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains the special logic used for
//           infiltration missions, such as autoselecting the
//           mission squad from the infiltration Covert Action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_MissionSiteInfiltration extends XComGameState_MissionSite;

var array<StateObjectReference> SoldiersOnMission;

var StateObjectReference CorrespondingActionRef;
var name AppliedFlatRiskName;

/////////////
/// Setup ///
/////////////

function SetupFromAction(XComGameState NewGameState, XComGameState_CovertAction Action)
{
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local X2CovertMissionInfoTemplate MissionInfo;

	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	MissionInfo = InfilMgr.GetCovertMissionInfoTemplateFromCA(Action.GetMyTemplateName());
	
	CorrespondingActionRef = Action.GetReference();
	// AppliedFlatRiskName

	MissionInfo.InitMissionFn(NewGameState, Action, self);

	SelectPlotAndBiome();
	ApplyFlatRisk();
	SelectOverfInfiltrationBonuses();
	PrepareChosen(); // This might be better suited in update

	SetSoldiersFromAction(Action);
	RegisterForEvents();
}

function SetBasicInfo()
{
	// TODO
}

function SelectPlotAndBiome()
{
	// TODO
}

function ApplyFlatRisk()
{
	// TODO
}

function SelectOverfInfiltrationBonuses()
{
	// TODO
}

function PrepareChosen()
{
	// TODO
}

protected function SetSoldiersFromAction(XComGameState_CovertAction Action)
{
	local XComGameState_StaffSlot SlotState;
	local int idx;

	// Just in case somebody was here before
	SoldiersOnMission.Length = 0;

	for (idx = 0; idx < Action.StaffSlots.Length; idx++)
	{
		SlotState = Action.GetStaffSlot(idx);

		if (SlotState != none && SlotState.IsSoldierSlot() && SlotState.IsSlotFilled())
		{
			SoldiersOnMission.AddItem(SlotState.GetAssignedStaffRef());
		}
	}
}

/////////////////
/// Overinfil ///
/////////////////

function UpdateGameBoard()
{
	`RedScreen(class.name @ "is ticking!!!!! Alarm!!!!");
	// TODO
}

protected function EventListenerReturn OnPreventGeoscapeTick(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIMission_Infiltrated MissionUI;
	local XComHQPresentationLayer HQPres;
	local UIStrategyMap StrategyMap;
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'PreventGeoscapeTick') return ELR_NoInterrupt;

	HQPres = `HQPRES;
	StrategyMap = HQPres.StrategyMap2D;
	
	// Don't popup anything while the Avenger or Skyranger are flying
	if (StrategyMap != none && StrategyMap.m_eUIState != eSMS_Flight)
	{
		MissionUI = HQPres.Spawn(class'UIMission_Infiltrated', HQPres);
		MissionUI.MissionRef = GetReference();
		HQPres.ScreenStack.Push(MissionUI);

		Tuple.Data[0].b = true;
		return ELR_InterruptListeners;
	}

	return ELR_NoInterrupt;
}

//////////////
/// Launch ///
//////////////

function bool RequiresAvenger()
{
	// Does not require the Avenger at the mission site
	return false;
}

function SelectSquad()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_StaffSlot SlotState;
	local StateObjectReference SoldierRef;
	local XComGameState_Unit Soldier;
	
	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Set up infiltrating squad");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	
	// Soldiers are no longer on covert action
	foreach SoldiersOnMission(SoldierRef)
	{
		Soldier = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SoldierRef.ObjectID));
		SlotState = XComGameState_StaffSlot(NewGameState.ModifyStateObject(class'XComGameState_StaffSlot', Soldier.StaffingSlot.ObjectID));
		SlotState.EmptySlot(NewGameState);
	}

	// Replace the squad with the soldiers who were on the Covert Action
	XComHQ.Squad = SoldiersOnMission;

	// This isn't needed to properly spawn units into battle, but without this
	// the transition screen shows last selection in streategy, not people on this mission
	XComHQ.AllSquads.Length = 1;
	XComHQ.AllSquads[0].SquadMembers = SoldiersOnMission;
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

function StartMission()
{
	local XGStrategy StrategyGame;
	
	BeginInteraction();
	
	StrategyGame = `GAME;
	StrategyGame.PrepareTacticalBattle(ObjectID);
	
	// Transfer directly to the mission, no squad select. Squad is set up based on the covert action soldiers.
	ConfirmMission();
}

////////////
/// Misc ///
////////////

function RemoveEntity(XComGameState NewGameState)
{
	super.RemoveEntity(NewGameState);
	UnRegisterFromEvents();
}

////////////////////////
/// Event management ///
////////////////////////

protected function RegisterForEvents()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
	ThisObj = self;

	EventManager.RegisterForEvent(ThisObj, 'PreventGeoscapeTick', OnPreventGeoscapeTick);
}

protected function UnRegisterFromEvents()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
	ThisObj = self;

	EventManager.UnRegisterFromAllEvents(ThisObj);
}