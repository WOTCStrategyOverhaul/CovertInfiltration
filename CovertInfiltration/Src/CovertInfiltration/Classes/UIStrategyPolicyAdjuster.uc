class UIStrategyPolicyAdjuster extends Object within UIStrategyPolicy;

var protected array<float> StoredScrollbarPercents;
var protected UIStrategyPolicy_Card CurrentSelectedCard;

////////////
/// Init ///
////////////

simulated function OnScreenInit ()
{
	local Object SelfObj;

	OnInitAdjustements();

	// Register for events
	SelfObj = self;
	`XEVENTMGR.RegisterForEvent(SelfObj, 'UIStrategyPolicy_PreRefreshAllDecks', PreRefreshAllDecks,,, Outer);
	`XEVENTMGR.RegisterForEvent(SelfObj, 'UIStrategyPolicy_PostRealizeColumn', PostRealizeColumn,,, Outer);
	`XEVENTMGR.RegisterForEvent(SelfObj, 'UIStrategyPolicy_PreSelect', PreSelect,,, Outer);
	`XEVENTMGR.RegisterForEvent(SelfObj, 'UIStrategyPolicy_PreClearSelection', PreClearSelection,,, Outer);
	`XEVENTMGR.RegisterForEvent(SelfObj, 'UIStrategyPolicy_DraggingStarted', DraggingStarted,,, Outer);
	`XEVENTMGR.RegisterForEvent(SelfObj, 'UIStrategyPolicy_DraggingEnded', DraggingEnded,,, Outer);
	
	// Register for cleanup
	Outer.AddOnRemovedDelegate(OnScreenRemoved);
}

simulated protected function OnInitAdjustements ()
{
	local XComGameState_CovertInfiltrationInfo Info;
	local XComGameState NewGameState;

	// Pre-first change - use smooth camera transition instead of instant jump from commander's quaters
	if (Outer.Movie.Stack.Screens[1].IsA(class'UIFacility_CIC'.Name))
	{
		Outer.bInstantInterp = false;
	}

	// First and main change - redirect the camera. This cannot be done in UISL as there will be a frame of camera jump
	class'UIUtilities_Infiltration'.static.CamRingView(Outer.bInstantInterp ? float(0) : `HQINTERPTIME);

	// Second change - allow editing cards if did not assign before. This can be done in UISL but why have so many places?
	if (!Outer.bResistanceReport && !class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bCompletedFirstOrdersAssignment)
	{
		Outer.bResistanceReport = true;
	}

	// Last change: set bCompletedFirstOrdersAssignment to true. Cannot be inside previous if block as player may build the ring
	// and then wait until supply drop to assign orders. Can also be in UISL
	if (!class'XComGameState_CovertInfiltrationInfo'.static.GetInfo().bCompletedFirstOrdersAssignment)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Completing first order assignment");
		
		Info = class'XComGameState_CovertInfiltrationInfo'.static.GetInfo();
		Info = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', Info.ObjectID));
		Info.bCompletedFirstOrdersAssignment = true;
		
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

//////////////////
/// Refreshing ///
//////////////////

protected function EventListenerReturn PreRefreshAllDecks (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local int i;

	StoredScrollbarPercents.Length = Columns.Length;
	for (i = 0; i < Columns.Length; i++)
	{
		if (Columns[i] != none && Columns[i].Scrollbar != none)
		{
			StoredScrollbarPercents[i] = Columns[i].Scrollbar.percent;
		}
		else
		{
			StoredScrollbarPercents[i] = 0;
		}
	}

	return ELR_NoInterrupt;
}

protected function EventListenerReturn PostRealizeColumn (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIStrategyPolicy_Card Card;
	local UIList Column;
	local int i;

	Column = UIList(EventData);

	// Sometimes the z order bugs out while dragging with mouse - remove the hint from all but last slot
	for (i = 0; i < Column.GetItemCount() - 1; i++)
	{
		Card = UIStrategyPolicy_Card(Column.GetItem(i));
		Card.SetCardSlotHint("");
	}

	// Probably not needed, but doesn't hurt
	Column.ItemContainer.ClearScroll();

	Column.LeftMaskOffset = -40;
	Column.ItemPadding = -5;

	Column.RealizeItems();
	Column.TotalItemSize += 20;

	Column.bAutosizeItems = false;
	Column.SetSize(353, 424);

	if (Column.Mask != none)
	{
		// Allow the highlight while dragging to extend under the scrollbar
		Column.Mask.SetWidth(Column.Mask.Width + 40);
	}

	if (Column.Scrollbar != none)
	{
		if (`ISCONTROLLERACTIVE && !bResistanceReport)
		{
			Column.Scrollbar.Hide();
			Column.ItemContainer.AnimateScroll(Column.TotalItemSize, Column.Mask.Height);
		}
		else
		{
			// Retain previous scroll position, which is reset in RefreshAllDecks
			i = Columns.Find(Column);
			Column.Scrollbar.SetThumbAtPercent(StoredScrollbarPercents[i]);

			if (`ISCONTROLLERACTIVE)
			{
				Column.Scrollbar.onPercentChangeDelegate = OnColumnPercentChanges;
			}
		}
	}

	return ELR_NoInterrupt;
}

////////////////////////////////////
/// Controller selection visuals ///
////////////////////////////////////

protected function EventListenerReturn PreSelect (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIStrategyPolicy_Card TargetCard;
	local int iColumn, iSlot;

	TargetCard = UIStrategyPolicy_Card(EventData);
	CurrentSelectedCard = TargetCard;

	GetSelectedCardLocation(iColumn, iSlot);
	if (iColumn > INDEX_NONE)
	{
		// Copy paste from UIList::NavigatorSelectionChanged
		if (Columns[iColumn].Scrollbar != none)
		{
			Columns[iColumn].Scrollbar.SetThumbAtPercent(float(iSlot) / float(Columns[iColumn].ItemCount - 1));
		}
	}

	return ELR_NoInterrupt;
}

protected function EventListenerReturn PreClearSelection (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	CurrentSelectedCard = none;

	return ELR_NoInterrupt;
}

// Support for RowBasedScrollSpeedWotc's scroll animation
simulated protected function OnColumnPercentChanges (float newPercent)
{
	local int iColumn, iSlot;

	GetSelectedCardLocation(iColumn, iSlot);
	if (iColumn > INDEX_NONE)
	{
		MC.FunctionString("Select", string(CurrentSelectedCard.MCPath));
	}
}

// There are m_iColumnIndex, m_iSlotIndex and m_bSelectingHand in UIStrategyPolicy
// but the whole class is a mess so I don't want to rely on them.
// The comment also specifies that they are for naviagtion, while we are handling visuals here
simulated protected function GetSelectedCardLocation (out int iColumn, out int iSlot)
{
	if (CurrentSelectedCard != none)
	{
		for (iColumn = 0; iColumn < Columns.Length; iColumn++)
		{
			for (iSlot = 0; iSlot < Columns[iColumn].GetItemCount(); iSlot++)
			{
				if (Columns[iColumn].GetItem(iSlot) == CurrentSelectedCard)
				{
					return;
				}
			}
		}
	}

	iColumn = INDEX_NONE;
	iSlot = INDEX_NONE;
}

//////////////////////
/// Mouse dragging ///
//////////////////////

protected function EventListenerReturn DraggingStarted (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIList Column;

	foreach Columns(Column)
	{
		if (Column.Scrollbar == none) continue;
		
		if (Column.Scrollbar.percent ~= 0)
		{
			Column.Mask.SetY(-40);
			Column.Mask.SetHeight(Column.Mask.Height + 40);
		}
	}

	return ELR_NoInterrupt;
}

protected function EventListenerReturn DraggingEnded (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIList Column;

	foreach Columns(Column)
	{
		if (Column.Scrollbar == none) continue;
		
		if (Column.Mask.Y < -39)
		{
			Column.Mask.SetY(0);
			Column.Mask.SetHeight(Column.Height);
		}
	}

	return ELR_NoInterrupt;
}

///////////////
/// Exiting ///
///////////////

simulated protected function OnScreenRemoved (UIPanel Panel)
{
	local Object SelfObj;

	SelfObj = self;
	`XEVENTMGR.UnRegisterFromAllEvents(SelfObj);
}
