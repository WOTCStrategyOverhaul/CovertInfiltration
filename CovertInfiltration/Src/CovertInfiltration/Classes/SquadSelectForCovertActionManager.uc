class SquadSelectForCovertActionManager extends Object;

var XComGameState_CovertAction Action;

var protected SSAAT_SquadSelectConfiguration Configuration;

simulated function OpenSquadSelect()
{
	if (Action == none)
	{
		`REDSCREEN("SquadSelectForCovertActionManager::OpenSquadSelect called without setting Action");
		`REDSCREEN(GetScriptTrace());
		return;
	}

	BuildConfiguration();

	class'SSAAT_Opener'.static.ShowSquadSelect(Configuration);
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

		// TODO: use proper callback. The problem - different arguments are passed
		Slots[i].CanUnitBeSelectedFn = class'SSAAT_SquadSelectConfiguration'.static.DefaultCanSoldierBeSelected;
	}

	Configuration.SetSlots(Slots);
	Configuration.SetHideMissionInfo(true);
	Configuration.RemoveTerrainAndEnemiesPanels();
	
	Configuration.SetCanClickLaunchFn(CanClickLaunch); // TODO
	Configuration.SetLaunchBehaviour(OnLaunch, true); // There is no option to make it false for now, but we probably would want to in future
	
	Configuration.SetPreventOnSizeLimitedEvent(true);
	Configuration.SetPreventOnSuperSizeEvent(true);

	Configuration.SetFrozen();
}



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

//////////////
/// LAUNCH ///
//////////////

simulated protected function bool CanClickLaunch()
{
	return true;	
}

simulated protected function OnLaunch()
{
	AssignUnitsFromSquadToAction();
	Action.ConfirmAction();
	
	`HQPRES.m_kXComStrategyMap.OnReceiveFocus();
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

simulated protected function StaffUnitInfo CreateStaffInfo(StateObjectReference UnitRef)
{
	local StaffUnitInfo StaffInfo;

	StaffInfo.UnitRef = UnitRef;
	StaffInfo.bGhostUnit = false;

	return StaffInfo;
}