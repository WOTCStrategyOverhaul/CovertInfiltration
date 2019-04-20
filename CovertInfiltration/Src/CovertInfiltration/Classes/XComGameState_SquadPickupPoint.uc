//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class creates a dummy Geoscape entity allowing HQ to fly over
//           in order to exfiltrate troops from an ongoing covert action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_SquadPickupPoint extends XComGameState_GeoscapeEntity;

var StateObjectReference ActionRef;
var StrategyCost ExfiltrateCost;

// bConsumed is a flag to assure
// each instance is only used once
var bool bConsumed;
var bool bSquadExfiltrated;

simulated function SetupPickupLocation(XComGameState NewGameState, XComGameState_CovertAction CovertAction, StrategyCost Cost)
{
	ExfiltrateCost = Cost;
	Location.x = CovertAction.Location.x;
	Location.y = CovertAction.Location.y;
	ActionRef = CovertAction.GetReference();
	Region = CovertAction.Region;
}

simulated function FlyToPickupPoint()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState NewGameState;

	XComHQ = `XCOMHQ;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Flying Avenger to PickupPoint");
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));
	XComHQ.CrossContinentMission = GetReference();
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	
	XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(Region.ObjectID)).ConfirmSelection();
}

simulated function DestinationReached()
{
	BeginInteraction();
	DisplaySkyrangerExfiltrate();
}

simulated function DisplaySkyrangerExfiltrate()
{
	local XComHQPresentationLayer HQPres;
	local UISkyrangerExfiltrate kScreen;
	
	HQPres = `HQPRES;
	kScreen = HQPres.Spawn(class'UISkyrangerExfiltrate', HQPres);
	HQPres.ScreenStack.Push(kScreen);
}

simulated function CancelExfiltrate()
{
	DestroyTheEvidence();

	`XSTRATEGYSOUNDMGR.PlayGeoscapeMusic();
	InteractionComplete(true);
}

simulated function ConfirmExfiltrate()
{
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameState_HeadquartersXCom XComHQ;
	local array<StrategyCostScalar> CostScalars;
	local XComGameState NewGameState;

	XComHQ = `XCOMHQ;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Exfiltration Confirmed");
	PickupPoint = XComGameState_SquadPickupPoint(NewGameState.ModifyStateObject(class'XComGameState_SquadPickupPoint', self.ObjectID));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));

	CostScalars.Length = 0;
	PickupPoint.bSquadExfiltrated = true;

	XComHQ.PayStrategyCost(NewGameState, ExfiltrateCost, CostScalars);
	PickupPoint.ClearUnitsFromAction(NewGameState);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	
	PickupPoint.DestroyTheEvidence();

	`XSTRATEGYSOUNDMGR.PlayGeoscapeMusic();
	InteractionComplete(true);
}

simulated function ClearUnitsFromAction(XComGameState NewGameState)
{
	local XComGameState_CovertAction CovertAction;
	local XComGameState_StaffSlot SlotState;
	local XComGameState_Unit Unit;
	local XComGameStateHistory History;
	local CovertActionStaffSlot CovertActionSlot;

	History = `XCOMHISTORY;
	CovertAction = XComGameState_CovertAction(History.GetGameStateForObjectID(ActionRef.ObjectID));

	foreach CovertAction.StaffSlots(CovertActionSlot)
	{
		SlotState = XComGameState_StaffSlot(History.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		if (SlotState.IsSlotFilled())
		{
			Unit = SlotState.GetAssignedStaff();
			if (Unit.IsSoldier() && Unit.UsesWillSystem())
			{
				class'X2Helper_Infiltration'.static.CreateWillRecoveryProject(NewGameState, Unit);
			}
			SlotState.EmptySlot(NewGameState);
		}
	}
}

simulated function DestroyTheEvidence()
{
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameState_CovertAction CovertAction;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: SkyrangerExfiltrate Cleanup");

	if (bSquadExfiltrated)
	{
		CovertAction = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionRef.ObjectID));
		CovertAction.RemoveEntity(NewGameState);
	}

	PickupPoint = XComGameState_SquadPickupPoint(NewGameState.ModifyStateObject(class'XComGameState_SquadPickupPoint', GetReference().ObjectID));
	PickupPoint.bConsumed = true;
	Purge(NewGameState);
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

simulated function Purge(XComGameState NewGameState)
{
	local XComGameState_SquadPickupPoint PickupPoint;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_SquadPickupPoint', PickupPoint)
	{
		PickupPoint = XComGameState_SquadPickupPoint(NewGameState.ModifyStateObject(class'XComGameState_SquadPickupPoint', PickupPoint.GetReference().ObjectID));
		PickupPoint.RemoveEntity(NewGameState);
	}
}

static function PreparePickupSite(XComGameState_CovertAction CovertAction, StrategyCost Cost)
{
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameState NewGameState;
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Setting up SquadPickupPoint");

	PickupPoint = XComGameState_SquadPickupPoint(NewGameState.CreateNewStateObject(class'XComGameState_SquadPickupPoint'));
	PickupPoint.SetupPickupLocation(NewGameState, CovertAction, Cost);
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	PickupPoint.FlyToPickupPoint();
}

function RemoveEntity(XComGameState NewGameState)
{
	NewGameState.RemoveStateObject(ObjectID);
}
