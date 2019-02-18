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

function bool RequiresAvenger()
{
	// Does not require the Avenger at the mission site
	return false;
}

function SetupFromAction(XComGameState NewGameState, XComGameState_CovertAction Action)
{
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local X2CovertMissionInfoTemplate MissionInfo;

	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	MissionInfo = InfilMgr.GetCovertMissionInfoTemplateFromCA(Action.GetMyTemplateName());

	MissionInfo.InitMissionFn(NewGameState, Action, self);
	SetSoldiersFromAction(Action);
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

// TODO: Is this needed after the staff slot change?
function SetSoldiersAsOnAction(XComGameState NewGameState)
{
	local StateObjectReference SoldierRef;
	local XComGameState_Unit Soldier;

	foreach SoldiersOnMission(SoldierRef)
	{
		Soldier = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SoldierRef.ObjectID));
		Soldier.SetStatus(eStatus_CovertAction);
	}
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

function UpdateGameBoard()
{
	local XComHQPresentationLayer HQPres;
	local UIMission_Infiltrated MissionUI;
	local UIStrategyMap StrategyMap;
	
	HQPres = `HQPRES;
	StrategyMap = HQPres.StrategyMap2D;
	
	// Don't popup anything while the Avenger or Skyranger are flying
	if (StrategyMap != none && StrategyMap.m_eUIState != eSMS_Flight)
	{
		MissionUI = HQPres.Spawn(class'UIMission_Infiltrated', HQPres);
		MissionUI.MissionRef = GetReference();
		HQPres.ScreenStack.Push(MissionUI);
	}
}