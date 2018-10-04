class UIEventQueue_MultipleActions extends UIEventQueue;

simulated function UpdateEventQueue(array<HQEvent> Events, bool bExpand, bool EnableEditControls)
{
	local bool bIsInStrategyMap;
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

	//`log("EventList: Update",, 'MultCovertActions');
	//`log("DETECTED IN STRATEGY MAP", bIsInStrategyMap, 'MultCovertActions');
	//`log("List is expanded", bIsExpanded, 'MultCovertActions');


	if (Events.Length > 0 && !bIsInStrategyMap || (`HQPRES.StrategyMap2D != none && `HQPRES.StrategyMap2D.m_eUIState != eSMS_Flight))
	{
		// Remove all covert actions first, we will need to do something else with it
		for( i = 0; i < Events.Length; i++ )
		{
			if (Events[i].bActionEvent)
			{
				Events.Remove(i, 1);
				i--;
			}
		}

		//`log("Removed all covert actions, new length:" @ Events.Length,, 'MultCovertActions');


		GetCovertActionEvents(Events); // Re-add covert actions, now adding all actions

		//`log("Re-added all covert actions, new length:" @ Events.Length,, 'MultCovertActions');

		NumCovert = 0;

		for (i = 0; i < Events.Length; i++)
		{
			if (Events[i].bActionEvent)
			{
				NumCovert++;
			}
		}

		if( bIsExpanded )
		{
			NumItemsToShow = Events.Length - NumCovert;
		}
		else
		{
			NumItemsToShow = 1;
		}

		
		for( i = 0; i < List.ItemCount; i++ )
		{
			if (UIEventQueue_CovertActionListItem(List.GetItem(i)) != none)
				NumCovertItem++;
		}
		
		//`log("Refreshing list list_length:" @ List.ItemCount $ ", num item to show:" @ NumItemsToShow,, 'MultCovertActions');
		//`log("Num Covert:" @ NumCovert $ ", Num Covert Item:" @ NumCovertItem,, 'MultCovertActions');

		if( List.ItemCount != NumItemsToShow + NumCovert || NumCovert != NumCovertItem )
			List.ClearItems();

		//Look through all events
		j = 0;
		for( i = 0; i < Events.Length; i++ )
		{
			// Display the number of items to show PLUS all covert action events. 
			// Covert actions should never hide. 
			if( i < NumItemsToShow || Events[i].bActionEvent )
			{
				if( List.ItemCount <= j )
				{
					if( Events[i].bActionEvent )
						ListItem = Spawn(class'UIEventQueue_MaskedCovertActionListItem', List.itemContainer).InitListItem();
					else
						ListItem = Spawn(class'UIEventQueue_ListItem', List.itemContainer).InitListItem();

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
function GetCovertActionEvents(out array<HQEvent> arrEvents)
{
	local XComGameStateHistory History;
	local XComGameState_CovertAction ActionState;
	local XComGameState_HeadquartersResistance ResHQ;
	local HQEvent kEvent;
	local bool bActionFound, bRingBuilt;

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

	ResHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
	bRingBuilt = `XCOMHQ.HasFacilityByName('ResistanceRing');
	if (!bActionFound && (ResHQ.NumMonths >= 1 || bRingBuilt))
	{
		if (bRingBuilt)
			kEvent.Data = class'XComGameState_HeadquartersXCom'.default.CovertActionsGoToRing;
		else if (!ResHQ.bCovertActionStartedThisMonth)
			kEvent.Data = class'XComGameState_HeadquartersXCom'.default.CovertActionsSelectOp;
		else
			kEvent.Data = class'XComGameState_HeadquartersXCom'.default.CovertActionsBuildRing;

		kEvent.Hours = -1;
		kEvent.ImagePath = class'UIUtilities_Image'.const.EventQueue_Resistance;
		kEvent.bActionEvent = true;
		arrEvents.AddItem(kEvent);
	}
}