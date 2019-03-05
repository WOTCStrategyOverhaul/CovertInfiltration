//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class creates a dummy Geoscape entity allowing HQ to fly over
//           in order to exfiltrate troops from an ongoing covert action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_SquadPickupPoint extends XComGameState_MissionSite;

var StateObjectReference ActionRef;

var bool bSkyrangerDeployed;
var bool bSquadExfiltrated;

var int IntelCost;

function bool RequiresAvenger()
{
	return !bSkyrangerDeployed;
}

function bool RequiresSquad()
{
	return false;
}

function SetupPickupLocation(XComGameState_CovertAction CovertAction, int Cost)
{
	ActionRef = CovertAction.GetReference();
	IntelCost = Cost;

	Location.x = CovertAction.Location.x;
	Location.y = CovertAction.Location.y;
	Region = CovertAction.Region;
}

function FlyToPickupPoint()
{
	local XComGameState_WorldRegion localRegion;

	localRegion = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(ActionRef.ObjectID));

	`XCOMHQ.CrossContinentMission = GetReference();
	// if we have a region fly there
	if (localRegion != none)
	{
		bSkyrangerDeployed = true;
		Continent = localRegion.GetContinent().GetReference();
		localRegion.ConfirmSelection();
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
		// didn't have region for some wierd reason..
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
	bSquadExfiltrated = true;

	PayThePrice();
	ClearUnitsFromAction();
	DestroyTheEvidence();

	`XSTRATEGYSOUNDMGR.PlayGeoscapeMusic();
	InteractionComplete(true);
}

simulated function PayThePrice()
{
	local XComGameState NewGameState;
	local XComGameState_Item Intel;

	Intel = `XCOMHQ.GetItemByName('Intel');
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Exfiltration Intel Cost");

	Intel = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', Intel.GetReference().ObjectID));
	Intel.Quantity -= IntelCost;

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

simulated function ClearUnitsFromAction()
{
	local XComGameState_CovertAction CovertAction;
	local XComGameState_StaffSlot StaffSlot;
	local XComGameStateHistory History;
	local CovertActionStaffSlot CovertActionSlot;

	History = `XCOMHISTORY;
	CovertAction = XComGameState_CovertAction(History.GetGameStateForObjectID(ActionRef.ObjectID));

	foreach CovertAction.StaffSlots(CovertActionSlot)
	{
		StaffSlot = XComGameState_StaffSlot(History.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		StaffSlot.EmptySlot(); // This is noop if the slot is empty
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

static function AbortMission(XComGameState_CovertAction CovertAction, int Cost)
{
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameState NewGameState;
	
	Purge(); // make sure there is never more than one PickupPoint
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Setting up SquadPickupPoint");
	
	PickupPoint = XComGameState_SquadPickupPoint(NewGameState.CreateNewStateObject(class'XComGameState_SquadPickupPoint'));
	PickupPoint.SetupPickupLocation(CovertAction, Cost);
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	PickupPoint.FlyToPickupPoint();
}