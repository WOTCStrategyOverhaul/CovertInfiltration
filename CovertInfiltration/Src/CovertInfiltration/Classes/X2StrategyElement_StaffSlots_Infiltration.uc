//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Provides staff slot templates created by this mod. Currently used to
//           completely replace Resistance Ring staff slot
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_StaffSlots_Infiltration extends X2StrategyElement_DefaultStaffSlots;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> StaffSlots;

	// Completely replace the ring staff slot. This way other mods can OPTC our slot
	StaffSlots.AddItem(CreateResistanceRingStaffSlotTemplate());

	return StaffSlots;
}

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
