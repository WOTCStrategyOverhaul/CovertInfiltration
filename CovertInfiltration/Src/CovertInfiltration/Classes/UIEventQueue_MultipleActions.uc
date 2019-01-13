//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf and ArcaneData
//  PURPOSE: This class is a replacement for base game's UIEventQueue
//           which allows multiple covert actions to be shown.
//           Modified to shift Covert Actions into the regular queue,
//           instead of being stuck at the bottom all the time.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIEventQueue_MultipleActions extends UIEventQueue;

simulated function UpdateEventQueue(array<HQEvent> Events, bool bExpand, bool EnableEditControls)
{
	local bool bIsInStrategyMap;
	local int i, NumItemsToShow;
	local UIEventQueue_ListItem ListItem;

	bIsExpanded = bExpand;

	if(EnableEditControls)
	{
		// no shrinking if we are using edit controls, user needs to see stuff
		ExpandButton.Hide();
		bIsExpanded = true;
	}
	else if(Events.Length > 1) 
	{
		ExpandButton.Show();

		//This special funciton will also format location on the timeline. 
		if(bIsExpanded)
			MC.FunctionString("SetExpandButtonText", ShrinkButtonLabel);
		else
			MC.FunctionString("SetExpandButtonText", ExpandButtonLabel);

		//No buttons when in the strategy map. 
		if( UIStrategyMap(Movie.Stack.GetCurrentScreen()) != none )
		{
			ExpandButton.Hide();
			bIsExpanded = true;
		}
	}
	else
	{
		ExpandButton.Hide();
		bIsExpanded = false;
	}

	bIsInStrategyMap = `ScreenStack.IsInStack(class'UIStrategyMap');
	
	// the full events queue passed to this function only includes 1 covert action - this is fixed here so all covert actions are included
	if (QueueContainsCovertActions(Events))
	{
		RemoveCovertActionFrom(Events);

		AddAllCovertActionsTo(Events);

		Events.sort(SortEventsByTime);

		if (!CovertActionsInProgress())
			AddCovertActionWarningTo(Events);
	}

	if (Events.Length > 0 && !bIsInStrategyMap || (`HQPRES.StrategyMap2D != none && `HQPRES.StrategyMap2D.m_eUIState != eSMS_Flight))
	{
		if( bIsExpanded )
		{
			NumItemsToShow = Events.Length;
		}
		else
		{
			NumItemsToShow = 2;

			// if the covert action warning is displayed:
			if (QueueContainsCovertActions(Events) && !CovertActionsInProgress())
				NumItemsToShow--;
		}
		
		if( List.ItemCount != NumItemsToShow )
			List.ClearItems();

		//Look through all events
		for( i = 0; i < Events.Length; i++ )
		{
			// Display the number of items to show PLUS the covert action warning, if it exists
			if( i < NumItemsToShow || (Events[i].bActionEvent && Events[i].Hours == -1))
			{
				if( List.ItemCount <= i )
				{
					if( Events[i].bActionEvent && Events[i].Hours == -1)
						ListItem = Spawn(class'UIEventQueue_CovertActionListItem_CI', List.itemContainer).InitListItem();
					else if( Events[i].bActionEvent)
						ListItem = Spawn(class'UIEventQueue_MaskedCovertActionListItem', List.itemContainer).InitListItem();
					else
						ListItem = Spawn(class'UIEventQueue_ListItem', List.itemContainer).InitListItem();

					ListItem.OnUpButtonClicked = OnUpButtonClicked;
					ListItem.OnDownButtonClicked = OnDownButtonClicked;
					ListItem.OnCancelButtonClicked = OnCancelButtonClicked;
				}
				else
					ListItem = UIEventQueue_ListItem(List.GetItem(i));

				ListItem.UpdateData(Events[i]);

				// determine which buttons the item should show based on it's location in the list 
				ListItem.AS_SetButtonsEnabled(EnableEditControls && i > 0,
											  EnableEditControls && i < (NumItemsToShow - 1),
											  EnableEditControls);
			}
		}

		List.SetY( -List.ShrinkToFit() - 10 );
		List.SetX( -List.GetTotalWidth() ); // This will take in to account the scrollbar padding or not, and stick the list neatly to the right edge of screen. 
		ShowList();
	}
	else
	{
		HideList();
	}
	
	RefreshDateTime();
}

//---------------------------------------------------------------------------------------
function bool QueueContainsCovertActions(array<HQEvent> arrEvents)
{
	local int i;

	for(i = 0; i < arrEvents.Length; i++)
	{
		if (arrEvents[i].bActionEvent)
		{
			return true;
		}
	}
	return false;
}


function RemoveCovertActionFrom(out array<HQEvent> arrEvents)
{
	local int i;

	for(i = 0; i < arrEvents.Length; i++)
	{
		if (arrEvents[i].bActionEvent)
		{
			arrEvents.Remove(i, 1);
			break;
		}
	}
}

function AddAllCovertActionsTo(out array<HQEvent> arrEvents)
{
	local XComGameState_CovertAction ActionState;
	local HQEvent kEvent;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if (ActionState.bStarted)
		{
			kEvent.Data = ActionState.GetDisplayName();
			kEvent.Hours = ActionState.GetNumHoursRemaining();
			kEvent.ImagePath = class'UIUtilities_Image'.const.EventQueue_Resistance;
			kEvent.ActionRef = ActionState.GetReference();
			kEvent.bActionEvent = true;
			arrEvents.AddItem(kEvent);
		}
	}
}

function bool CovertActionsInProgress()
{
	local XComGameState_CovertAction ActionState;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if (ActionState.bStarted)
		{
			return true;
		}
	}
	return false;
}

function AddCovertActionWarningTo(out array<HQEvent> arrEvents)
{
	local HQEvent kEvent;

	kEvent.Data = class'XComGameState_HeadquartersXCom'.default.CovertActionsSelectOp;
	kEvent.Hours = -1;
	kEvent.ImagePath = class'UIUtilities_Image'.const.EventQueue_Resistance;
	kEvent.bActionEvent = true;

	arrEvents.AddItem(kEvent);
}

function int SortEventsByTime(HQEvent A, HQEvent B)
{
    return A.Hours > B.Hours ? -1 : 0;
}