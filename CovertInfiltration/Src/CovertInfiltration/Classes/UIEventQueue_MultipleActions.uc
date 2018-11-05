//---------------------------------------------------------------------------------------
//  AUTHOR:  (Integrated from BountyGiver's mod)
//           Adapted for overhaul by NotSoLoneWolf
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
	local bool bIsInStrategyMap, WasWarningRemoved;
	local int i, j, NumItemsToShow, NumCovert, NumCovertItem;
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

	//When you scan and the supply drop happens
	//And you go back to world map
	//The entry for 1 covert op I had running
	//Gets messed up
	//Going to covert op screen and back fixes it though

	if (Events.Length > 0 && !bIsInStrategyMap || (`HQPRES.StrategyMap2D != none && `HQPRES.StrategyMap2D.m_eUIState != eSMS_Flight))
	{
		// Remove the one covert action in the event queue already
		for(i = 0; i < Events.Length; i++)
		{
			if (Events[i].bActionEvent)
			{
				Events.Remove(i, 1);
				i--;
			}
		}

		//`log("Removed covert actions, new length:" @ Events.Length,, 'MultCovertActions');

		// Add ALL active covert actions to the end of the queue
		GetCovertActionEvents(Events); 

		//`log("Re-added all covert actions, new length:" @ Events.Length,, 'MultCovertActions');

		// Properly sort the events by hours instead of having the Covert Events at the bottom
		Events.sort(EventSorting);

		// Unfortunately since the warning has -1 hours, it goes to the top.
		// So we must remove it and re-add it again to get it to the bottom.
		WasWarningRemoved = false;
		for(i = 0; i < Events.Length; i++)
		{
			if (Events[i].bActionEvent && Events[i].Hours == -1)
			{
				Events.Remove(i, 1);
				i--;
				WasWarningRemoved = true;
			}
		}
		if(WasWarningRemoved)
		{
			GetCovertActionWarning(Events);
		}

		NumCovert = 0;

		for (i = 0; i < Events.Length; i++)
		{
			if (Events[i].bActionEvent)
			{
				NumCovert++;
			}
		}

		if(bIsExpanded)
		{
			NumItemsToShow = Events.Length;
		}
		else
		{
			NumItemsToShow = 1;
		}

		for(i = 0; i < List.ItemCount; i++)
		{
			if (UIEventQueue_CovertActionListItem(List.GetItem(i)) != none)
				NumCovertItem++;
		}
		
		//`log("Refreshing list list_length:" @ List.ItemCount $ ", num item to show:" @ NumItemsToShow,, 'MultCovertActions');
		//`log("Num Covert:" @ NumCovert $ ", Num Covert Item:" @ NumCovertItem,, 'MultCovertActions');

		if(List.ItemCount != NumItemsToShow || NumCovert != NumCovertItem)
			List.ClearItems();

		//Look through all events
		j = 0;
		for(i = 0; i < Events.Length; i++)
		{
			// Display the number of items to show 
			if(i < NumItemsToShow)
			{
				if(List.ItemCount <= j)
				{
					if(Events[i].bActionEvent)
					{
						if(Events[i].Hours == -1)
						{
							ListItem = Spawn(class'UIEventQueue_CovertActionListItem', List.itemContainer).InitListItem();
						} else {
							ListItem = Spawn(class'UIEventQueue_MaskedCovertActionListItem', List.itemContainer).InitListItem();
						}
					} else {
						ListItem = Spawn(class'UIEventQueue_ListItem', List.itemContainer).InitListItem();
					}

					ListItem.OnUpButtonClicked = OnUpButtonClicked;
					ListItem.OnDownButtonClicked = OnDownButtonClicked;
					ListItem.OnCancelButtonClicked = OnCancelButtonClicked;
					//`log("New List entry:" @ i,, 'MultCovertActions');
				}
				else
					ListItem = UIEventQueue_ListItem(List.GetItem(j));

				ListItem.UpdateData(Events[i]);

				// determine which buttons the item should show based on it's location in the list 
				ListItem.AS_SetButtonsEnabled(EnableEditControls && j > 0,
											  EnableEditControls && j < (NumItemsToShow - 1),
											  EnableEditControls);
				j++;
			}
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

//---------------------------------------------------------------------------------------
function GetCovertActionEvents(out array<HQEvent> arrEvents)
{
	local XComGameStateHistory History;
	local XComGameState_CovertAction ActionState;
	local HQEvent kEvent;
	local bool bActionFound;

	History = `XCOMHISTORY;
	
	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if (ActionState.bStarted)
		{
			kEvent.Data = ActionState.GetDisplayName();
			kEvent.Hours = ActionState.GetNumHoursRemaining();
			kEvent.ImagePath = class'UIUtilities_Image'.const.EventQueue_Resistance;
			kEvent.ActionRef = ActionState.GetReference();
			kEvent.bActionEvent = true;
			//Add directly to the end of the events list, not sorted by hours. 
			arrEvents.AddItem(kEvent);
			bActionFound = true;
		}
	}
	
	if (!bActionFound)
	{
		kEvent.Data = class'XComGameState_HeadquartersXCom'.default.CovertActionsSelectOp;

		kEvent.Hours = -1;
		kEvent.ImagePath = class'UIUtilities_Image'.const.EventQueue_Resistance;
		kEvent.bActionEvent = true;
		arrEvents.AddItem(kEvent);
	}
}

function GetCovertActionWarning(out array<HQEvent> arrEvents)
{
	local HQEvent kEvent;

	kEvent.Data = class'XComGameState_HeadquartersXCom'.default.CovertActionsSelectOp;
	kEvent.Hours = -1;
	kEvent.ImagePath = class'UIUtilities_Image'.const.EventQueue_Resistance;
	kEvent.bActionEvent = true;
	arrEvents.AddItem(kEvent);
}

//---------------------------------------------------------------------------------------

function int EventSorting(HQEvent A, HQEvent B)
{
    return A.Hours > B.Hours ? -1 : 0;
}
