//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Provides staff slot templates created by this mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_StaffSlots_Infiltration extends X2StrategyElement_DefaultStaffSlots;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> StaffSlots;

	// Completely replace the ring staff slot. This way other mods can OPTC our slot
	StaffSlots.AddItem(CreateResistanceRingStaffSlotTemplate());

	// Special slot template for infiltration actions
	StaffSlots.AddItem(CreateInfiltrationActionSlotTemplate());

	return StaffSlots;
}

////////////
/// Ring ///
////////////

static function X2DataTemplate CreateResistanceRingStaffSlotTemplate()
{
	local X2StaffSlotTemplate Template;

	Template = CreateStaffSlotTemplate('ResistanceRingStaffSlot');
	Template.bEngineerSlot = true;
	Template.FillFn = FillResistanceRingSlot;
	Template.EmptyFn = EmptyResistanceRingSlot;
	Template.CanStaffBeMovedFn = CanStaffBeMovedRing;
	Template.ShouldDisplayToDoWarningFn = ShouldDisplayResistanceRingToDoWarning;
	Template.GetAvengerBonusAmountFn = GetResistanceRingAvengerBonus;
	Template.GetBonusDisplayStringFn = GetResistanceRingBonusDisplayString;
	Template.MatineeSlotName = "Engineer";
	
	return Template;
}

static function FillResistanceRingSlot(XComGameState NewGameState, StateObjectReference SlotRef, StaffUnitInfo UnitInfo, optional bool bTemporary = false)
{
	local XComGameState_HeadquartersResistance NewResHQ;
	local XComGameState_CovertInfiltrationInfo NewInfo;
	local XComGameState_Unit NewUnitState;
	local XComGameState_StaffSlot NewSlotState;
	
	FillSlot(NewGameState, SlotRef, UnitInfo, NewSlotState, NewUnitState);
	NewInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);

	// Do not grant a new slot if we are already at max used and we flip what person is staffed here
	if (NewInfo.bRingStaffReplacement)
	{
		`log("Detected Ring staff slot replacement - not granting an additional slot",, 'CI');
		NewInfo.bRingStaffReplacement = false;
	}
	else
	{
		`log("Ring staff slot filled - granting wildcard order slot",, 'CI');
		NewResHQ = GetNewResHQState(NewGameState);
		NewResHQ.AddWildCardSlot();
	}
}

static function EmptyResistanceRingSlot(XComGameState NewGameState, StateObjectReference SlotRef)
{
	local XComGameState_HeadquartersResistance NewResHQ;
	local XComGameState_CovertInfiltrationInfo NewInfo;
	local XComGameState_Unit NewUnitState;
	local XComGameState_StaffSlot NewSlotState;
	local int iEmptySlot;
	
	EmptySlot(NewGameState, SlotRef, NewSlotState, NewUnitState);
	NewResHQ = GetNewResHQState(NewGameState);
	iEmptySlot = FindEmptyWildcardSlot(NewResHQ);

	if (iEmptySlot > -1)
	{
		`log("Ring staff removed - removing wildcard slot" @ iEmptySlot,, 'CI'); 
		NewResHQ.WildCardSlots.Remove(iEmptySlot, 1);
	}
	else
	{
		// Assume that we are replacing the person in this slot and not simply removing (i.e. the validation works)
		`log("Detected Ring staff slot replacement - recording",, 'CI');

		NewInfo = class'XComGameState_CovertInfiltrationInfo'.static.ChangeForGamestate(NewGameState);
		NewInfo.bRingStaffReplacement = true;
	}
}

static function bool CanStaffBeMovedRing(StateObjectReference SlotRef)
{
	return FindEmptyWildcardSlot(class'UIUtilities_Strategy'.static.GetResistanceHQ()) > -1;
}

static function int FindEmptyWildcardSlot(XComGameState_HeadquartersResistance ResHQ)
{
	local int i;

	for (i = 0; i < ResHQ.WildCardSlots.Length; i++)
	{
		if (ResHQ.WildCardSlots[i].ObjectID == 0)
		{
			return i;
		}
	}

	return -1;
}

static function bool ShouldDisplayResistanceRingToDoWarning(StateObjectReference SlotRef)
{
	return true;
}

static function int GetResistanceRingAvengerBonus(XComGameState_Unit Unit, optional bool bPreview)
{
	return 1;
}

static function string GetResistanceRingBonusDisplayString(XComGameState_StaffSlot SlotState, optional bool bPreview)
{
	local string Contribution;

	if (SlotState.IsSlotFilled())
	{
		Contribution = string(GetResistanceRingAvengerBonus(SlotState.GetAssignedStaff(), bPreview));
	}

	return GetBonusDisplayString(SlotState, "%AVENGERBONUS", Contribution);
}

////////////////////
/// Infiltration ///
////////////////////

static function X2DataTemplate CreateInfiltrationActionSlotTemplate()
{
	local X2StaffSlotTemplate Template;

	Template = CreateStaffSlotTemplate('InfiltrationStaffSlot');

	// Same as default slot
	Template.bPreventFilledPopup = true;
	Template.bSoldierSlot = true;
	Template.FillFn = class'X2StrategyElement_XpackStaffSlots'.static.FillCovertActionSlot;
	Template.CanStaffBeMovedFn = class'X2StrategyElement_XpackStaffSlots'.static.CanStaffBeMovedCovertActions;
	Template.GetNameDisplayStringFn = class'X2StrategyElement_XpackStaffSlots'.static.GetCovertActionSoldierNameDisplayString;
	
	// Custom
	Template.EmptyFn = EmptyInfiltrationSlot;
	Template.IsUnitValidForSlotFn = IsUnitValidForInfiltration;

	return Template;
}

static function EmptyInfiltrationSlot(XComGameState NewGameState, StateObjectReference SlotRef)
{
	local XComGameState_Unit NewUnitState;
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_CovertAction ActionState;

	EmptySlot(NewGameState, SlotRef, NewSlotState, NewUnitState);

	ActionState = NewSlotState.GetCovertAction();

	// The none check is required for cases when history was compressed after the action was deleted
	if (ActionState == none || ActionState.bCompleted)
	{
		// This is an inflitration that is ready to go
		NewUnitState.SetStatus(eStatus_Active);
		return;
	}
	
	// Otherwise we are still in loadout, so do the default things
	// The code below is copy-paste from X2StrategyElement_XpackStaffSlots::EmptyCovertActionSlot

	// Only set a unit status back to normal if they are still listed as being on the covert action
	// Since this means they weren't killed, wounded, or captured on the mission
	if (NewUnitState.GetStatus() == eStatus_CovertAction)
	{
		NewUnitState.SetStatus(eStatus_Active);

		// Don't change super soldier loadouts since they have specialized gear
		if (NewUnitState.IsSoldier() && !NewUnitState.bIsSuperSoldier)
		{
			// First try to upgrade the soldier's primary weapons, in case a tier upgrade happened while
			// they were away on the CA. This is needed to make sure weapon upgrades and customization transfer properly.
			// Issue #230 start
			//CheckToUpgradePrimaryWeapons(NewGameState, NewUnitState);
			class'X2StrategyElement_XpackStaffSlots'.static.CheckToUpgradeItems(NewGameState, NewUnitState);
			// Issue #230 end

			// Then try to equip the rest of the old items
			if (!class'CHHelpers'.default.bDontUnequipCovertOps) // Issue #153
			{
				NewUnitState.EquipOldItems(NewGameState);
			}

			// Try to restart any psi training projects
			class'XComGameStateContext_StrategyGameRule'.static.PostMissionUpdatePsiOperativeTraining(NewGameState, NewUnitState);
		}
	}

	ActionState = GetNewCovertActionState(NewGameState, NewSlotState);
	ActionState.UpdateNegatedRisks(NewGameState);
	ActionState.UpdateDurationForBondmates(NewGameState);
}

static function bool IsUnitValidForInfiltration(XComGameState_StaffSlot SlotState, StaffUnitInfo UnitInfo)
{
	local XComGameState_Unit Unit;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));

	if (
		Unit.IsSoldier() // the following robotic & status check is a baid-aid fix for wounded sparks
		&& (Unit.IsActive(true) || (Unit.IsRobotic() && Unit.GetStatus() != eStatus_CovertAction))
		&& (SlotState.RequiredClass == '' || Unit.GetSoldierClassTemplateName() == SlotState.RequiredClass)
		&& (SlotState.RequiredMinRank == 0 || Unit.GetRank() >= SlotState.RequiredMinRank)
		&& (!SlotState.bRequireFamous || Unit.bIsFamous)
	)
	{
		return true;
	}

	return false;
}