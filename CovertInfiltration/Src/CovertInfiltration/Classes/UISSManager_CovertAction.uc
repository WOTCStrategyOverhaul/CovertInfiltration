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

		// Add notes
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

//////////////
/// Launch ///
//////////////

simulated protected function bool CanClickLaunch()
{
	// TODO
	return true;
	//return Action.CanBeginAction();	
}

simulated protected function OnLaunch()
{
	SquadSelect = none;

	AssignUnitsFromSquadToAction();
	Action.ConfirmAction();
	
	CovertOpsSrceen.FocusCameraOnCurrentAction(); // Look at covert action instead of region
	CovertOpsSrceen.MakeMapProperlyShow();

	CovertOpsSrceen.bConfirmScreenWasOpened = true;
}

simulated protected function AssignUnitsFromSquadToAction()
{
	local XComGameState_HeadquartersXCom XcomHQ;
	local XComGameState_StaffSlot StaffSlot;

	local CovertActionStaffSlot CovertActionSlot;
	local int i;

	XcomHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	
	foreach Action.StaffSlots(CovertActionSlot, i)
	{
		StaffSlot = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		StaffSlot.AssignStaffToSlot(CreateStaffInfo(XcomHQ.Squad[i]));
	}
}

/////////////////
/// Canceling ///
/////////////////
                 
simulated function ClearUnitsFromAction()
{
	local XComGameState_StaffSlot StaffSlot;
	local CovertActionStaffSlot CovertActionSlot;

	foreach Action.StaffSlots(CovertActionSlot)
	{
		StaffSlot = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		if (StaffSlot.IsSlotEmpty()) continue;

		StaffSlot.EmptySlot();
	}
}