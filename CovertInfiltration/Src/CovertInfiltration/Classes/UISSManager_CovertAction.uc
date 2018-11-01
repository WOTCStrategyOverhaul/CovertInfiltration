class UISSManager_CovertAction extends Object;

var XComGameState_CovertAction Action;
var UICovertActionsGeoscape CovertOpsSrceen;

var protected SSAAT_SquadSelectConfiguration Configuration;
var protectedwrite UISquadSelect SquadSelect;

simulated function OpenSquadSelect()
{
	if (Action == none)
	{
		`REDSCREEN("UISSManager_CovertAction::OpenSquadSelect called without setting Action");
		`REDSCREEN(GetScriptTrace());
		return;
	}

	BuildConfiguration();
	SubscribeToEvents();

	SquadSelect = class'SSAAT_Opener'.static.ShowSquadSelect(Configuration);
	PostScreenInit();
}

simulated protected function PostScreenInit()
{
	local UISquadSelectCovertActionInfo ActionInfo;

	ActionInfo = SquadSelect.Spawn(class'UISquadSelectCovertActionInfo', SquadSelect);
	ActionInfo.bAnimateOnInit = false;
	ActionInfo.InitCovertActionInfo('CovertActionInfo');
	ActionInfo.UpdateData(Action);
}

simulated protected function BuildConfiguration()
{
	local XComGameStateHistory History;
	local XComGameState_StaffSlot StaffSlotState;
	local XComGameState_Reward RewardState;

	local array<SSAAT_SlotConfiguration> Slots;
	local int i;

	Configuration = new class'SSAAT_SquadSelectConfiguration';
	History = `XCOMHISTORY;

	Slots.Length = Action.StaffSlots.Length;
	for (i = 0; i < Slots.Length; ++i)
	{
		StaffSlotState = XComGameState_StaffSlot(History.GetGameStateForObjectID(Action.StaffSlots[i].StaffSlotRef.ObjectID));
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(Action.StaffSlots[i].RewardRef.ObjectID));

		// Add notes. TODO: Add required class and rank notes
		if (RewardState != none) Slots[i].Notes.AddItem(ConvertRewardToNote(RewardState));
		if (Action.StaffSlots[i].bOptional) Slots[i].Notes.AddItem(CreateOptionalNote());

		// Change the slot type if needed
		if (StaffSlotState.IsEngineerSlot())
		{
			Slots[i].PersonnelType = eUIPersonnel_Engineers;
		}
		else if (StaffSlotState.IsScientistSlot())
		{
			Slots[i].PersonnelType = eUIPersonnel_Scientists;
		}

		Slots[i].CanUnitBeSelectedFn = CanSelectUnit;
	}

	Configuration.SetSlots(Slots);
	Configuration.SetHideMissionInfo(true);
	Configuration.RemoveTerrainAndEnemiesPanels();
	
	Configuration.SetCanClickLaunchFn(CanClickLaunch);
	Configuration.SetLaunchBehaviour(OnLaunch, false);
	
	Configuration.SetPreventOnSizeLimitedEvent(true);
	Configuration.SetPreventOnSuperSizeEvent(true);

	Configuration.SetFrozen();
}

//////////////////
/// Slot notes ///
//////////////////

static function SSAAT_SlotNote ConvertRewardToNote(XComGameState_Reward RewardState)
{
	local SSAAT_SlotNote Note;
	local string RewardText;

	RewardText = RewardState.GetRewardPreviewString();
	if (RewardText != "" && RewardState.GetMyTemplateName() != 'Reward_DecreaseRisk')
	{
		RewardText = class'UICovertActionStaffSlot'.default.m_strSoldierReward @ RewardText;
	}

	Note.Text = RewardText;
	Note.TextColor = "000000";
	Note.BGColor = class'UIUtilities_Colors'.const.GOOD_HTML_COLOR;

	return Note;
}

static function SSAAT_SlotNote CreateOptionalNote()
{
	local SSAAT_SlotNote Note;
	
	Note.Text = "Optional"; // The localized text reads "OPTIONAL:"
	Note.TextColor = "000000";
	Note.BGColor = class'UIUtilities_Colors'.const.WARNING_HTML_COLOR;

	return Note;
}

////////////////////////
/// Slot interaction ///
////////////////////////

simulated protected function bool CanSelectUnit(XComGameState_Unit Unit, int iSlot)
{
	local XComGameState_StaffSlot StaffSlotState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	StaffSlotState = XComGameState_StaffSlot(History.GetGameStateForObjectID(Action.StaffSlots[iSlot].StaffSlotRef.ObjectID));
	
	return StaffSlotState.ValidUnitForSlot(CreateStaffInfo(Unit.GetReference()));
}

simulated protected function StaffUnitInfo CreateStaffInfo(StateObjectReference UnitRef)
{
	local StaffUnitInfo StaffInfo;

	StaffInfo.UnitRef = UnitRef;
	StaffInfo.bGhostUnit = false;

	return StaffInfo;
}

simulated protected function EventListenerReturn OnSquadSelectUpdate(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XcomHQ;
	local XComGameState_StaffSlot StaffSlot;

	local StateObjectReference UnitRef;
	local CovertActionStaffSlot CovertActionSlot;
	
	local bool IsSlotFilled;
	local int i;

	History = `XCOMHISTORY;
	XcomHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	foreach XcomHQ.Squad(UnitRef, i)
	{
		CovertActionSlot = Action.StaffSlots[i];
		StaffSlot = XComGameState_StaffSlot(History.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		IsSlotFilled = UnitRef.ObjectID != 0;

		// Do nothing if evrything is correct already
		if (UnitRef.ObjectID == StaffSlot.AssignedStaff.UnitRef.ObjectID) continue;

		if (IsSlotFilled)
		{
			StaffSlot.AssignStaffToSlot(CreateStaffInfo(UnitRef));
		}
		else
		{	
			StaffSlot.EmptySlot();
		}
	}

	return ELR_NoInterrupt;
}

//////////////
/// Launch ///
//////////////

simulated protected function bool CanClickLaunch()
{
	return Action.CanBeginAction();	
}

simulated protected function OnLaunch()
{
	SquadSelect = none;
	UnsubscribeFromAllEvents();

	Action.ConfirmAction();
	
	CovertOpsSrceen.FocusCameraOnCurrentAction(); // Look at covert action instead of region
	CovertOpsSrceen.MakeMapProperlyShow();

	CovertOpsSrceen.bConfirmScreenWasOpened = true;
}

////////////////////////////////////
/// Event interaction management ///
////////////////////////////////////

simulated protected function SubscribeToEvents()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
    ThisObj = self;

	EventManager.RegisterForEvent(ThisObj, 'rjSquadSelect_UpdateData', OnSquadSelectUpdate);
}

simulated protected function UnsubscribeFromAllEvents()
{
    local Object ThisObj;

    ThisObj = self;
    `XEVENTMGR.UnRegisterFromAllEvents(ThisObj);
}