//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class creates a dummy Geoscape entity allowing HQ to fly over
//           in order to exfiltrate troops from an ongoing covert action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_SquadPickupPoint extends XComGameState_GeoscapeEntity;

var StateObjectReference ActionRef;
var StateObjectReference RegionRef;

var StrategyCost ExfiltrateCost;

var bool bSkyrangerDeployed;
var bool bSquadExfiltrated;

function bool RequiresAvenger()
{
	return !bSkyrangerDeployed;
}

function bool RequiresSquad()
{
	return false;
}

function SetupPickupLocation(XComGameState NewGameState, XComGameState_CovertAction CovertAction, StrategyCost Cost)
{
	local XComGameState_HeadquartersXCom XComHQ;
	ActionRef = CovertAction.GetReference();
	RegionRef = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(ActionRef.ObjectID)).GetReference();

	ExfiltrateCost = Cost;

	Location.x = CovertAction.Location.x;
	Location.y = CovertAction.Location.y;
	
	XComHQ = `XCOMHQ;

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));
	XComHQ.CrossContinentMission = GetReference();
}

function FlyToPickupPoint()
{
	// if we have a region fly there
	if (RegionRef.ObjectID != 0)
	{
		XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(RegionRef.ObjectID)).ConfirmSelection();
	}
	// if we don't just fly to the mission site
	else
	{
		ConfirmSelection();
	}
}

function DestinationReached()
{
	if (!bSkyrangerDeployed)
	{
		// cheat the system to deploy a skyranger if we
		// didn't have region for some weird reason..
		bSkyrangerDeployed = true;
		`XCOMHQ.UpdateFlightStatus();
	}
	else
	{
		BeginInteraction();
		DisplaySkyrangerExfiltrate();
	}
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
	local XComGameState NewGameState;

	bSquadExfiltrated = true;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Exfiltration Confirmed");

	PayThePrice(NewGameState);
	ClearUnitsFromAction(NewGameState);
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	
	DestroyTheEvidence();

	`XSTRATEGYSOUNDMGR.PlayGeoscapeMusic();
	InteractionComplete(true);
}

simulated function PayThePrice(XComGameState NewGameState)
{
	local XComGameState_Item Intel;
	local ArtifactCost Cost;

	Intel = `XCOMHQ.GetItemByName('Intel');

	Intel = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', Intel.GetReference().ObjectID));
	
	foreach ExfiltrateCost.ResourceCosts(Cost)
	{
		if (Cost.ItemTemplateName == 'Intel')
		{
			Intel.Quantity -= Cost.Quantity;
			break;
		}
	}
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
			SlotState.EmptySlot();
		}
	}
}

function DestroyTheEvidence()
{
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameState_CovertAction CovertAction;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: SkyrangerExfiltrate Cleanup");

	PickupPoint = XComGameState_SquadPickupPoint(NewGameState.ModifyStateObject(class'XComGameState_SquadPickupPoint', GetReference().ObjectID));
	PickupPoint.RemoveEntity(NewGameState);

	if (bSquadExfiltrated)
	{
		CovertAction = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionRef.ObjectID));
		CovertAction.RemoveEntity(NewGameState);
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

static function Purge()
{
	local array<XComGameState_SquadPickupPoint> PickupPoints;
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local bool bDirty;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Purging SquadPickupPoint(s)");

	foreach History.IterateByClassType(class'XComGameState_SquadPickupPoint', PickupPoint)
	{
		PickupPoints.AddItem(PickupPoint);
	}

	if (PickupPoints.Length > 0)
	{
		bDirty = true;
		foreach PickupPoints(PickupPoint)
		{
			PickupPoint = XComGameState_SquadPickupPoint(NewGameState.ModifyStateObject(class'XComGameState_SquadPickupPoint', PickupPoint.GetReference().ObjectID));
			PickupPoint.RemoveEntity(NewGameState);
		}
	}
	if (bDirty)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
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