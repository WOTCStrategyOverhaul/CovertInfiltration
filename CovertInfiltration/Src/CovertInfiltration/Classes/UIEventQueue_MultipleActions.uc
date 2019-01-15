//---------------------------------------------------------------------------------------
//  AUTHOR:  (Integrated from BountyGiver's mod)
//           Adapted for overhaul by NotSoLoneWolf, robojumper
//  PURPOSE: This class is a replacement for base game's UIEventQueue
//           which allows multiple covert actions to be shown.
//           Modified to shift Covert Actions into the regular queue,
//           instead of being stuck at the bottom all the time.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIEventQueue_MultipleActions extends UIEventQueue config(UI);

var config int MaxEntriesWhenCollapsed;

simulated function UpdateEventQueue(array<HQEvent> Events, bool bExpand, bool EnableEditControls)
{
	local bool bIsInStrategyMap;
	local int i, NumItemsToShow;
	local UIEventQueue_ListItem ListItem;
	local bool MustClear;
	local HQEvent MockEvent;

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
		if(UIStrategyMap(Movie.Stack.GetCurrentScreen()) != none)
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

	//`log("EventList: Update",, 'MultCovertActions');
	//`log("DETECTED IN STRATEGY MAP", bIsInStrategyMap, 'MultCovertActions');
	//`log("List is expanded", bIsExpanded, 'MultCovertActions');

	if (Events.Length > 0 && !bIsInStrategyMap || (`HQPRES.StrategyMap2D != none && `HQPRES.StrategyMap2D.m_eUIState != eSMS_Flight))
	{
		if(bIsExpanded)
		{
			NumItemsToShow = Events.Length;
		}
		else
		{
			NumItemsToShow = Min(MaxEntriesWhenCollapsed, Events.Length);
		}

		// The standard HQ Events list contains a single mock "hey, let's start a covert action" item.
		// We want to move this to the bottom of the queue
		for(i = Events.Length - 1; i >= 0; i--)
		{
			if (Events[i].bActionEvent && Events[i].Hours == -1)
			{
				MockEvent = Events[i];
				Events.Remove(i, 1);
				// Push it to the lowest visible position
				Events.InsertItem(NumItemsToShow - 1, MockEvent);
				break;
			}
		}

		// We need to clear the items if the list has more than we need;
		MustClear = NumItemsToShow < List.ItemCount;
		// Otherwise, check if every list item class that already exists matches the class we need
		// Warning: This interacts unfavorably with ModClassOverrides, but doesn't break
		// it in any way -- MustClear will always be true with ModClassOverrides.
		for (i = 0; i < Min(NumItemsToShow, List.ItemCount) && !MustClear; i++)
		{
			if(Events[i].bActionEvent)
			{
				if(Events[i].Hours == -1)
					MustClear = MustClear || List.GetItem(i).Class != class'UIEventQueue_CovertActionListItem_CI';
				else
					MustClear = MustClear || List.GetItem(i).Class != class'UIEventQueue_MaskedCovertActionListItem';
			}
			else
				MustClear = MustClear || List.GetItem(i).Class != class'UIEventQueue_ListItem';
		}

		if (MustClear)
		{
			List.ClearItems();
		}

		//Look through all events
		for(i = 0; i < NumItemsToShow; i++)
		{
			if(i >= List.ItemCount)
			{
				if(Events[i].bActionEvent)
				{
					if(Events[i].Hours == -1)
						ListItem = Spawn(class'UIEventQueue_CovertActionListItem_CI', List.itemContainer).InitListItem();
					else
						ListItem = Spawn(class'UIEventQueue_MaskedCovertActionListItem', List.itemContainer).InitListItem();
				}
				else
					ListItem = Spawn(class'UIEventQueue_ListItem_CI', List.itemContainer).InitListItem();

				ListItem.OnUpButtonClicked = OnUpButtonClicked;
				ListItem.OnDownButtonClicked = OnDownButtonClicked;
				ListItem.OnCancelButtonClicked = OnCancelButtonClicked;
			}
			else
			{
				ListItem = UIEventQueue_ListItem(List.GetItem(i));
			}

			ListItem.UpdateData(Events[i]);

			// determine which buttons the item should show based on it's location in the list 
			ListItem.AS_SetButtonsEnabled(EnableEditControls && i > 0,
										  EnableEditControls && i < (NumItemsToShow - 1),
										  EnableEditControls);
		}

		List.SetY(-List.ShrinkToFit() - 10);
		List.SetX(-List.GetTotalWidth()); // This will take in to account the scrollbar padding or not, and stick the list neatly to the right edge of screen. 
		ShowList();
	}
	else
	{
		HideList();
	}
	
	RefreshDateTime();
}
