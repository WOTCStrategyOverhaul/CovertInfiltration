//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a single row of slots on the UICovertActionsGeoscape screen
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape_SlotRow extends UIPanel;

var int NumSlots;
var float SpaceBetweenSlots;

var protectedwrite array<UICovertActionsGeoscape_Slot> Slots;

simulated function InitRow()
{
	InitPanel();
}

simulated function CreateSlots()
{
	local UICovertActionsGeoscape_Slot Slot;
	local float TotalEmptySpace, SlotWidth;
	local int i;

	TotalEmptySpace = (NumSlots - 1) * SpaceBetweenSlots; 
	SlotWidth = (Width - TotalEmptySpace) / NumSlots;

	Slots.Length = NumSlots;
	for (i = 0; i < NumSlots; i++)
	{
		Slot = Spawn(class'UICovertActionsGeoscape_Slot', self);
		Slot.InitSlot(SlotWidth);
		Slot.SetX((SlotWidth * i) + (Max(i - 1, 0) * SpaceBetweenSlots));

		Slots[i] = Slot;
	}
}

defaultproperties
{
	NumSlots = 2;
	SpaceBetweenSlots = 10;
	
	Height = 52;
}