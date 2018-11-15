class UISS_CostSlotsContainer extends UIPanel;

var protectedwrite StateObjectReference ActionRef;

var protectedwrite UIList CostSlotsList;
var protectedwrite array<UISS_CostSlot> CostSlots; // Used for updating (so there is no need to cast each update)

delegate PostAnySlotStateChanged();

simulated function InitCostSlots(StateObjectReference InitActionRef)
{
	InitPanel('UISS_CostSlotsContainer');
	ActionRef = InitActionRef;

	CostSlotsList = Spawn(class'UIList', self);
	CostSlotsList.bAnimateOnInit = false;
	CostSlotsList.bStickyHighlight = false;
	CostSlotsList.bSelectFirstAvailable = false; // We do this the first time we gain focus
	CostSlotsList.ItemPadding = 10;
	CostSlotsList.InitList('CostSlotsList');
	CostSlotsList.AnchorTopCenter();
	CostSlotsList.SetPosition(-500, 0);
	CostSlotsList.SetWidth(300);

	Navigator.SetSelected(CostSlotsList);

	CreateSlots();
	UpdateNavigatableStatus();
}

simulated protected function CreateSlots()
{
	local XComGameState_CovertAction Action;
	local UISS_CostSlot CostSlot;
	local int i;

	Action = GetAction();
	CostSlots.Length = Action.CostSlots.Length;

	for (i = 0; i < CostSlots.Length; i++)
	{
		CostSlot = Spawn(class'UISS_CostSlot', CostSlotsList.ItemContainer);
		CostSlot.PostStateChanged = PostAnySlotStateChanged;
		CostSlot.InitCostSlot(ActionRef, i);
		
		CostSlots[i] = CostSlot;
	}
}

simulated protected function UpdateNavigatableStatus()
{
	// Not afforable slots aren't navigatable
	Tag = CostSlotsList.Navigator.Size > 0 ? 'rjSquadSelect_Navigable' : '';
}

simulated function UpdateData()
{
	local UISS_CostSlot CostSlot;

	foreach CostSlots(CostSlot)
	{
		CostSlot.UpdateData();
	}
}

simulated function OnReceiveFocus()
{
	CostSlotsList.Navigator.SelectFirstAvailableIfNoCurrentSelection();
	super.OnReceiveFocus();
}

///////////////
/// Helpers ///
///////////////

simulated function XComGameState_CovertAction GetAction()
{
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(ActionRef.ObjectID));
}

defaultproperties
{
	bIsNavigable = false;
}