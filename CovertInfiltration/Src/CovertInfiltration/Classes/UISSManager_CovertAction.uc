//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is responsible for adjusting squad select screen to behave suitable for
//           covert action instead of a mission. It relies heavily on SSAAT to do the
//           heavy lifting
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISSManager_CovertAction extends Object;

var UICovertActionsGeoscape CovertOpsScreen;
var bool SkipIntro;

var protected SSAAT_SquadSelectConfiguration Configuration;
var protectedwrite UISquadSelect SquadSelect;

var protected bool bCreatedUIElements;
var protected UISS_InfiltrationReadout InfoDisplay;
var protected UISS_CostSlotsContainer CostSlots;

var localized string strSlotOptionalNote;
var localized string strSlotPenaltyNote;
var localized string strSlotRequiredPrefix;
var localized string strConfirmInfiltration;

simulated function OpenSquadSelect()
{
	BuildConfiguration();
	SubscribeToEvents();

	SquadSelect = class'SSAAT_Opener'.static.ShowSquadSelect(Configuration);
	PostScreenInit();
}

simulated protected function PostScreenInit()
{
	local UISS_TerrainDisplay TerrainDisplay;
	local UISS_CovertActionInfo ActionInfo;

	ActionInfo = SquadSelect.Spawn(class'UISS_CovertActionInfo', SquadSelect);
	ActionInfo.bAnimateOnInit = false;
	ActionInfo.InitCovertActionInfo('CovertActionInfo');
	ActionInfo.UpdateData(GetAction());
	
	InfoDisplay = SquadSelect.Spawn(class'UISS_InfiltrationReadout', SquadSelect);
	InfoDisplay.InitReadout(GetAction());

	CostSlots = SquadSelect.Spawn(class'UISS_CostSlotsContainer', SquadSelect);
	CostSlots.PostAnySlotStateChanged = UpdateUIElements;
	CostSlots.InitCostSlots(GetAction().GetReference());

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(GetAction()))
	{
		TerrainDisplay = SquadSelect.Spawn(class'UISS_TerrainDisplay', SquadSelect);
		TerrainDisplay.InitTerrainDisplay(GetAction());
	}

	bCreatedUIElements = true;
	UpdateUIElements();

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(GetAction()))
	{
		class'UIUtilities_InfiltrationTutorial'.static.InfiltrationLoadout();
	}
	else
	{
		class'UIUtilities_InfiltrationTutorial'.static.CovertActionLoadout();
	}
}

simulated protected function BuildConfiguration()
{
	local XComGameStateHistory History;
	local XComGameState_StaffSlot StaffSlotState;
	local XComGameState_CovertAction CovertAction;
	local XComGameState_Reward RewardState;

	local array<SSAAT_SlotConfiguration> Slots;
	local int i;

	Configuration = new class'SSAAT_SquadSelectConfiguration';
	History = `XCOMHISTORY;

	CovertAction = GetAction();
	
	Slots.Length = CovertAction.StaffSlots.Length;

	for (i = 0; i < Slots.Length; ++i)
	{
		StaffSlotState = XComGameState_StaffSlot(History.GetGameStateForObjectID(CovertAction.StaffSlots[i].StaffSlotRef.ObjectID));
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(CovertAction.StaffSlots[i].RewardRef.ObjectID));

		if (RewardState != none) Slots[i].Notes.AddItem(ConvertRewardToNote(RewardState));
		if (CovertAction.StaffSlots[i].bOptional) Slots[i].Notes.AddItem(CreateOptionalNote());
		if (StaffSlotState.RequiredClass != '') Slots[i].Notes.AddItem(CreateClassNote(StaffSlotState.RequiredClass));
		// The original covert action staff slot code never passed a class here. We're passing one. If `RequiredClass` == '' or the class doesn't
		// have explicit rank names set up, it'll use the standard code path of falling back to the default ranks.
		if (StaffSlotState.RequiredMinRank > 0) Slots[i].Notes.AddItem(CreateRankNote(StaffSlotState.RequiredMinRank, StaffSlotState.RequiredClass));
		
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

	Configuration.SetDisallowAutoFill(true);
	Configuration.SetSkipIntroAnimation(SkipIntro);

	Configuration.SetSlots(Slots);
	Configuration.SetHideMissionInfo(true);
	Configuration.RemoveTerrainAndEnemiesPanels();
	
	Configuration.SetCanClickLaunchFn(CanClickLaunch);
	Configuration.SetLaunchBehaviour(OnLaunch, false);

	if (class'X2Helper_Infiltration'.static.IsInfiltrationAction(CovertAction))
	{
		Configuration.EnableLaunchLabelReplacement(strConfirmInfiltration, "");
	}
	else
	{
		Configuration.EnableLaunchLabelReplacement(class'UICovertActions'.default.CovertActions_LaunchAction, "");
	}
	
	Configuration.SetPreventOnSizeLimitedEvent(true);
	Configuration.SetPreventOnSuperSizeEvent(true);

	Configuration.SetFrozen();
}

///////////////////
/// UI Elements ///
///////////////////

simulated protected function UpdateUIElements()
{
	InfoDisplay.UpdateData(GetAction());
	CostSlots.UpdateData();
}

simulated function bool ShouldShowResourceBar()
{
	return GetAction().CostSlots.Length > 0;
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
	
	Note.Text = default.strSlotOptionalNote; // The localized text reads "OPTIONAL:"
	Note.TextColor = "000000";
	Note.BGColor = class'UIUtilities_Colors'.const.WARNING_HTML_COLOR;

	return Note;
}

static function SSAAT_SlotNote CreatePenaltyNote()
{
	local SSAAT_SlotNote Note;
	
	Note.Text = default.strSlotPenaltyNote;
	Note.TextColor = "000000";
	Note.BGColor = class'UIUtilities_Colors'.const.BAD_HTML_COLOR;

	return Note;
}

static function SSAAT_SlotNote CreateClassNote(name SoldierClassName)
{
	local SSAAT_SlotNote Note;
	local X2SoldierClassTemplateManager ClassManager;
	local X2SoldierClassTemplate ClassTemplate;
	local string DisplayString;

	ClassManager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
	ClassTemplate = ClassManager.FindSoldierClassTemplate(SoldierClassName);

	if (ClassTemplate != none)
	{
		DisplayString = ClassTemplate.DisplayName;
	}

	Note.Text = default.strSlotRequiredPrefix @ DisplayString;
	Note.TextColor = "000000";
	Note.BGColor = class'UIUtilities_Colors'.const.WARNING_HTML_COLOR;

	return Note;
}

static function SSAAT_SlotNote CreateRankNote(int Rank, name SoldierClassName)
{
	local SSAAT_SlotNote Note;
	
	Note.Text = default.strSlotRequiredPrefix @ class'X2ExperienceConfig'.static.GetRankName(Rank, SoldierClassName);
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
	StaffSlotState = XComGameState_StaffSlot(History.GetGameStateForObjectID(GetAction().StaffSlots[iSlot].StaffSlotRef.ObjectID));
	
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
		CovertActionSlot = GetAction().StaffSlots[i];
		StaffSlot = XComGameState_StaffSlot(History.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		IsSlotFilled = UnitRef.ObjectID != 0;

		// Do nothing if evrything is correct already
		if (UnitRef.ObjectID == StaffSlot.AssignedStaff.UnitRef.ObjectID) continue;

		if (IsSlotFilled)
		{
			if (!StaffSlot.AssignStaffToSlot(CreateStaffInfo(UnitRef)))
			{
				`Redscreen("CI: Failed to assign" @ XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectId(UnitRef.ObjectID)).GetFullName() @ "to a staff slot");
			}
		}
		else
		{	
			StaffSlot.EmptySlot();
		}
	}

	class'X2Helper_Infiltration'.static.RecalculateActionRisks(GetAction().GetReference());

	if (bCreatedUIElements) UpdateUIElements();

	return ELR_NoInterrupt;
}

//////////////
/// Launch ///
//////////////

simulated protected function bool CanClickLaunch()
{
	return GetAction().CanBeginAction();	
}

simulated protected function OnLaunch()
{
	ApplyCovertActionModifiers();

	SquadSelect = none;
	UnsubscribeFromAllEvents();

	GetAction().ConfirmAction();
	CovertOpsScreen.FocusCameraOnCurrentAction(); // Look at covert action instead of region
	CovertOpsScreen.MakeMapProperlyShow();

	CovertOpsScreen.bConfirmScreenWasOpened = true;
}

////////////////////////////////////
/// Event interaction management ///
////////////////////////////////////

simulated protected function ApplyCovertActionModifiers()
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_CovertAction CovertAction;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Apply covert action modifiers");

	CovertAction = GetAction();
	CovertAction = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', CovertAction.ObjectID));

	ApplyInfiltrationModifier(XComHQ, CovertAction);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

simulated protected function ApplyInfiltrationModifier(XComGameState_HeadquartersXCom XComHQ, XComGameState_CovertAction CovertAction)
{
	local int SquadDuration;

	SquadDuration = class'X2Helper_Infiltration'.static.GetSquadInfiltration(XComHQ.Squad, CovertAction);
	
	`log("Applying SquadInfiltration:" @ SquadDuration @ "to duration:" @ CovertAction.HoursToComplete,, 'CI');
	CovertAction.HoursToComplete += SquadDuration;
	`log("Covert action total duration is now:" @ CovertAction.HoursToComplete @ "hours",, 'CI');
}

simulated protected function SubscribeToEvents()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
    ThisObj = self;

	EventManager.RegisterForEvent(ThisObj, 'rjSquadSelect_UpdateData', OnSquadSelectUpdate);
}

simulated function UnsubscribeFromAllEvents()
{
    local Object ThisObj;

    ThisObj = self;
    `XEVENTMGR.UnRegisterFromAllEvents(ThisObj);
}

///////////////
/// Helpers ///
///////////////

simulated function XComGameState_CovertAction GetAction()
{
	return CovertOpsScreen.GetAction();
}
