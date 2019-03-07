//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class creates a dummy Geoscape entity allowing HQ to fly over
//           in order to exfiltrate troops from an ongoing covert action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_SquadPickupPoint extends XComGameState_MissionSite;

var StateObjectReference ActionRef;
var StrategyCost ExfiltrateCost;

// bConsumed is a flag to assure
// each instance is only used once
var bool bConsumed;
var bool bSquadExfiltrated;

function bool RequiresAvenger()
{
	return false;
}

function bool RequiresSquad()
{
	return false;
}

function SetupPickupLocation(XComGameState NewGameState, XComGameState_CovertAction CovertAction, StrategyCost Cost)
{
	local XComGameState_HeadquartersXCom XComHQ;
	
	XComHQ = `XCOMHQ;

	ExfiltrateCost = Cost;
	Location.x = CovertAction.Location.x;
	Location.y = CovertAction.Location.y;
	ActionRef = CovertAction.GetReference();

	Region = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(CovertAction.Region.ObjectID)).GetReference();
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));
	XComHQ.CrossContinentMission = GetReference();
}

function FlyToPickupPoint()
{
	XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(Region.ObjectID)).ConfirmSelection();
}

function DestinationReached()
{
	BeginInteraction();
	DisplaySkyrangerExfiltrate();
}

function DisplaySkyrangerExfiltrate()
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
	NewGameState.ModifyStateObject(class'XComGameState_SquadPickupPoint', ObjectID);
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));

	CostScalars.Length = 0;
	bSquadExfiltrated = true;

	XComHQ.PayStrategyCost(NewGameState, ExfiltrateCost, CostScalars);
	ClearUnitsFromAction(NewGameState);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	
	DestroyTheEvidence();

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

function DestroyTheEvidence()
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
	PickupPoint.RemoveEntity(NewGameState);
	

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

static function Purge()
{
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local bool bDirty;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Purging SquadPickupPoint(s)");

	foreach History.IterateByClassType(class'XComGameState_SquadPickupPoint', PickupPoint)
	{
		bDirty = true;
		PickupPoint = XComGameState_SquadPickupPoint(NewGameState.ModifyStateObject(class'XComGameState_SquadPickupPoint', PickupPoint.GetReference().ObjectID));
		PickupPoint.RemoveEntity(NewGameState);
	}

	if (bDirty)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

static function PreparePickupSite(XComGameState_CovertAction CovertAction, StrategyCost Cost)
{
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameState NewGameState;
	
	Purge(); // make sure there is never more than one PickupPoint
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Setting up SquadPickupPoint");
	
	PickupPoint = XComGameState_SquadPickupPoint(NewGameState.CreateNewStateObject(class'XComGameState_SquadPickupPoint'));
	PickupPoint.SetupPickupLocation(NewGameState, CovertAction, Cost);
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	PickupPoint.FlyToPickupPoint();
}