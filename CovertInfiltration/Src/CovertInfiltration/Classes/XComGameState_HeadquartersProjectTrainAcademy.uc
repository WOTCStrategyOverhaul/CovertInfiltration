class XComGameState_HeadquartersProjectTrainAcademy extends XComGameState_HeadquartersProject;

var name NewClassName; // the name of the class the rookie will eventually be promoted to
var int RanksToAdd; // Stored here to prevent changes to max rank during project don't cause chaos

function SetProjectFocus(StateObjectReference FocusRef, optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	local XComGameStateHistory History;
	local XComGameState_GameTime TimeState;
	local XComGameState_Unit UnitState;

	History = `XCOMHISTORY;
	ProjectFocus = FocusRef; // Unit
	AuxilaryReference = AuxRef; // Facility
	
	StartDateTime = class'XComGameState_GeoscapeEntity'.static.GetCurrentTime();
	ProjectPointsRemaining = CalculatePointsToTrain();
	InitialProjectPoints = ProjectPointsRemaining;

	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ProjectFocus.ObjectID));
	UnitState.SetStatus(eStatus_Training);

	RanksToAdd = Max(class'X2Helper_Infiltration'.static.GetAcademyTrainingTargetRank() - UnitState.GetSoldierRank(), 0);
	UpdateWorkPerHour(NewGameState);

	if (MakingProgress())
	{
		SetProjectedCompletionDateTime(StartDateTime);
	}
	else
	{
		// Set completion time to unreachable future
		CompletionDateTime.m_iYear = 9999;
	}
}

function int CalculatePointsToTrain()
{
	// TODO. Also, move this calculation to X2Helper_Infiltration.
	// Also MCO UIChooseClass to (1) update ClassComm.OrderHours (2) replace OnPurchaseClicked


	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	return XComHQ.GetTrainRookieDays() * 24;
}

function int CalculateWorkPerHour(optional XComGameState StartState = none, optional bool bAssumeActive = false)
{
	return 1;
}

function X2SoldierClassTemplate GetTrainingClassTemplate()
{
	return class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager().FindSoldierClassTemplate(NewClassName);
}

function OnProjectCompleted()
{

	// TODO




	// Old:
	
	local HeadquartersOrderInputContext OrderInput;
	local XComHeadquartersCheatManager CheatMgr;

	OrderInput.OrderType = eHeadquartersOrderType_TrainRookieCompleted;
	OrderInput.AcquireObjectReference = self.GetReference();

	class'XComGameStateContext_HeadquartersOrder'.static.IssueHeadquartersOrder(OrderInput);

	CheatMgr = XComHeadquartersCheatManager(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().CheatManager);
	if (CheatMgr == none || !CheatMgr.bGamesComDemo)
	{
		`HQPRES.UITrainingComplete(ProjectFocus);
	}

	// Copy pasta from XComGameStateContext_HeadquartersOrder
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	if (XComHQ != none)
	{
		XComHQ = XComGameState_HeadquartersXCom(AddToGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		XComHQ.Projects.RemoveItem(ProjectState.GetReference());
		AddToGameState.RemoveStateObject(ProjectState.ObjectID);
	}

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ProjectState.ProjectFocus.ObjectID));
	if (UnitState != none)
	{
		// Set the soldier status back to active, and rank them up to their new class
		UnitState = XComGameState_Unit(AddToGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
		UnitState.SetXPForRank(1);
		UnitState.StartingRank = 1;
		UnitState.RankUpSoldier(AddToGameState, ProjectState.NewClassName); // The class template name was set when the project began
		UnitState.ApplySquaddieLoadout(AddToGameState, XComHQ);
		UnitState.ApplyBestGearLoadout(AddToGameState); // Make sure the squaddie has the best gear available
		UnitState.SetStatus(eStatus_Active);

		// If there are bonus ranks, do those rank ups here
		for(idx = 0; idx < XComHQ.BonusTrainingRanks; idx++)
		{
			UnitState.SetXPForRank(idx + 2);
			UnitState.StartingRank++;
			UnitState.RankUpSoldier(AddToGameState);
		}

		// Remove the soldier from the staff slot
		StaffSlotState = UnitState.GetStaffSlot();
		if (StaffSlotState != none)
		{
			StaffSlotState.EmptySlot(AddToGameState);
		}
	}
}