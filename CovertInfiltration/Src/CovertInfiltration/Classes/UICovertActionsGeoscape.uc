//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a new (custom) screen for covert ops that uses the world map
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape extends UIScreen;

// UI elements
var UIList ActionsList;
var UIBGBox ButtonsBG;
var UIButton ConfirmButton, CloseScreenButton;

// Data
var StateObjectReference ActionRef;
var array<XComGameState_CovertAction> arrActions;
var array<XComGameState_ResistanceFaction> NewActionFactions;

const CAMERA_ZOOM = 0.5f;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	GetHQPres().StrategyMap2D.Hide();
}

simulated function OnInit()
{
	super.OnInit();

	GetHQPres().CAMSaveCurrentLocation();

	FindActions();
	BuildScreen();

	`XSTRATEGYSOUNDMGR.PlayPersistentSoundEvent("UI_CovertOps_Open");
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	
	// Came back from UISquadSelect or the confirmation alert
	GetHQPres().m_kXComStrategyMap.OnReceiveFocus();
	FocusCameraOnCurrentAction(true);
	
	if (GetAction().bStarted) // We came from confirmation alert
	{
		`XSTRATEGYSOUNDMGR.PlayGeoscapeMusic(); // Otherwise SS music doesn't stop after confirmation
		UpdateList();
	}
}

simulated function BuildScreen()
{
	// LIST

	ActionsList = Spawn(class'UIList', self);
	ActionsList.InitList(
		'ActionsList',
		50, 50,
		300, 800,
		false, true
	);
	ActionsList.bStickyClickyHighlight = true;
	ActionsList.bStickyHighlight = false;
	ActionsList.OnSetSelectedIndex = SelectedItemChanged;

	PopulateList();
	UpdateData();

	Navigator.SetSelected(ActionsList);

	// Buttons

	ButtonsBG = Spawn(class'UIBGBox', self);
	ButtonsBG.InitBG('ButtonsBG');
	ButtonsBG.AnchorCenter();
	ButtonsBG.SetPosition(200, -50);
	ButtonsBG.SetSize(300, 100);

	ConfirmButton = Spawn(class'UIButton', self);
	ConfirmButton.InitButton('ConfirmButton', "Go to loadout", OnConfirmClicked);
	ConfirmButton.SetResizeToText(false);
	ConfirmButton.AnchorCenter();
	ConfirmButton.SetPosition(210, -40);
	ConfirmButton.SetWidth(280);

	CloseScreenButton = Spawn(class'UIButton', self);
	CloseScreenButton.InitButton('CloseScreenButton', "Close covert ops", OnCloseScreenClicked);
	CloseScreenButton.SetResizeToText(false);
	CloseScreenButton.AnchorCenter();
	CloseScreenButton.SetPosition(210, 10);
	CloseScreenButton.SetWidth(280);
}

simulated function PopulateList()
{
	local name LastFactionName;
	local int idx;
	local UIListItemString Item;
	local UICovertActionsGeoscape_FactionHeader FactionHeader;

	for( idx = 0; idx < arrActions.Length; idx++ )
	{
		if (arrActions[idx].GetFaction().GetMyTemplateName() != LastFactionName)
		{
			// FixMe: If there is 1 "in progress" faction and it's the first faction in normal list
			// then there is no header between "in progress" ands other covert ops for that faction

			FactionHeader = Spawn(class'UICovertActionsGeoscape_FactionHeader', ActionsList.itemContainer);
			FactionHeader.InitFactionHeader(arrActions[idx].GetFaction(), arrActions[idx].bStarted);
		}

		Item = Spawn(class'UIListItemString', ActionsList.itemContainer);
		Item.InitListItem(GetActionLocString(idx));
		Item.metadataInt = arrActions[idx].ObjectID;

		/*if( IsCovertActionInProgress() && !arrActions[idx].bStarted)
		{
			Item.SetDisabled(true, CovertActions_ActionInProgressTooltip);
		}
		else if (!IsActionInfluenceMet(idx)) // If the covert action requires a higher influence level, disable the button
		{
			Item.SetDisabled(true, CovertActions_InfluenceRequiredTooltip);
		}*/
		if( ActionsList.GetSelectedItem() == None )
		{
			ActionsList.SetSelectedItem(Item);
		}

		LastFactionName = arrActions[idx].GetFaction().GetMyTemplateName();
	}
}

simulated function UpdateList()
{
	ActionsList.ClearItems();
	arrActions.Length = 0;

	FindActions();
	PopulateList();
}

simulated function SelectedItemChanged(UIList ContainerList, int ItemIndex)
{
	local UIPanel ListItem;
	local StateObjectReference NewRef;
	local int i;

	ListItem = ContainerList.GetItem(ItemIndex);
	if( ListItem != none )
	{
		for (i = 0; i < arrActions.length; i++)
		{
			if (arrActions[i].ObjectID == UIListItemString(ListItem).metadataInt)
			{
				NewRef = arrActions[i].GetReference();
			}
		}

		if( ActionRef != NewRef )
		{
			ActionRef = NewRef;
			UpdateData();
		}
	}
}

// Copied from UICovertActions
simulated function String GetActionLocString(int iAction)
{
	local XComGameState_CovertAction CurrentAction;
	local string PrefixStr;

	if (iAction >= arrActions.Length) return "";

	CurrentAction = arrActions[iAction];

	if(CurrentAction.bNewAction)
	{
		PrefixStr = "(NEW) ";
	}

	return PrefixStr $ CurrentAction.GetObjective();
}

// Copied from UICovertActions
simulated function FindActions()
{
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_CovertAction ActionState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		// Only display actions which are actually stored by the Faction. Safety check to prevent
		// actions which were supposed to have been deleted from showing up in the UI and being accessed.
		FactionState = ActionState.GetFaction();
		if (FactionState.CovertActions.Find('ObjectID', ActionState.ObjectID) != INDEX_NONE ||
			FactionState.GoldenPathActions.Find('ObjectID', ActionState.ObjectID) != INDEX_NONE)
		{
			if (ActionState.bStarted)
			{
				arrActions.InsertItem(0, ActionState); // Always place any currently running Covert Action at the top of the list
				//bActionInProgress = true; // We don't care whether there is anything in progress
			}
			else if (ActionState.CanActionBeDisplayed() && (ActionState.GetMyTemplate().bGoldenPath || FactionState.bSeenFactionHQReveal))
			{
				arrActions.AddItem(ActionState);
				if( ActionState.bNewAction)
				{
					NewActionFactions.AddItem(ActionState.GetFaction());
				}
			}
		}
	}

	arrActions.Sort(SortActionsByFactionName);
	arrActions.Sort(SortActionsByFarthestFaction);
	arrActions.Sort(SortActionsByFactionMet);
	arrActions.Sort(SortActionsStarted);

	ActionRef = arrActions[0].GetReference();

	`log("Found" @ arrActions.Length @ "actions",, 'CI');
}

// Used to update the screen to show new covert action
simulated function UpdateData()
{
	FocusCameraOnCurrentAction();
}

simulated function FocusCameraOnCurrentAction(optional bool Instant = false)
{
	if (Instant)
	{
		GetHQPres().CAMLookAtEarth(GetAction().Get2DLocation(), CAMERA_ZOOM, 0);
	}
	else
	{
		GetHQPres().CAMLookAtEarth(GetAction().Get2DLocation(), CAMERA_ZOOM);
	}
}

simulated function OpenLoadoutForCurrentAction()
{
	local SquadSelectForCovertActionManager SSManager;

	SSManager = new class'SquadSelectForCovertActionManager';
	SSManager.Action = GetAction();
	SSManager.OpenSquadSelect();

	// TODO: Store SSManager somewhere
}

/// CHILD CALLBAKCS

simulated function OnConfirmClicked(UIButton Button)
{
	OpenLoadoutForCurrentAction();
}

simulated function OnCloseScreenClicked(UIButton Button)
{
	CloseScreen();
}

/// KEYBOARD/CONTROLLER INPUT

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	if(!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return false;

	switch(cmd)
	{
	// TODO
	/*case class'UIUtilities_Input'.const.FXS_BUTTON_A:
	case class'UIUtilities_Input'.const.FXS_KEY_ENTER:
	case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
		if (ConfirmButton != none && ConfirmButton.bIsVisible && !ConfirmButton.IsDisabled)
		{
			ConfirmButton.OnClickedDelegate(ConfirmButton);
			return true;
		}
		else if (Button1 != none && Button1.bIsVisible && !Button1.IsDisabled)
		{
			Button1.OnClickedDelegate(Button1);
			return true;
		}*/

		//If you don't have a current button, fall down and hit the Navigation system. 
	case class'UIUtilities_Input'.const.FXS_BUTTON_B:
	case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
	case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
		CloseScreen();
		return true;		
	}

	return super.OnUnrealCommand(cmd, arg);
}

/// CLOSING

simulated function OnRemoved()
{
	super.OnRemoved();

	//Restore the saved camera location
	GetHQPres().CAMRestoreSavedLocation();

	class'UIUtilities_Sound'.static.PlayCloseSound();
}

/// SORTING

function int SortActionsByFactionName(XComGameState_CovertAction ActionA, XComGameState_CovertAction ActionB)
{
	local string FactionAName, FactionBName;

	FactionAName = ActionA.GetFaction().GetFactionTitle();
	FactionBName = ActionB.GetFaction().GetFactionTitle();

	if (FactionAName < FactionBName)
	{
		return 1;
	}
	else if (FactionAName > FactionBName)
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

function int SortActionsByFactionMet(XComGameState_CovertAction ActionA, XComGameState_CovertAction ActionB)
{
	local bool bFactionAMet, bFactionBMet;
	local bool bLostAndAbandonedActive;
	
	bLostAndAbandonedActive = (class'XComGameState_HeadquartersXCom'.static.GetObjectiveStatus('XP0_M4_RescueMoxComplete') == eObjectiveState_InProgress);

	bFactionAMet = ActionA.GetFaction().bMetXCom;
	bFactionBMet = ActionB.GetFaction().bMetXCom;

	if (!bFactionAMet && bFactionBMet)
	{
		return bLostAndAbandonedActive ? -1 : 1;
	}
	else if (bFactionAMet && !bFactionBMet)
	{
		return bLostAndAbandonedActive ? 1 : -1;
	}
	else
	{
		return 0;
	}
}

function int SortActionsByFarthestFaction(XComGameState_CovertAction ActionA, XComGameState_CovertAction ActionB)
{
	local bool bFactionAFarthest, bFactionBFarthest;
	local bool bLostAndAbandonedActive;

	bLostAndAbandonedActive = (class'XComGameState_HeadquartersXCom'.static.GetObjectiveStatus('XP0_M4_RescueMoxComplete') == eObjectiveState_InProgress);
	
	bFactionAFarthest = ActionA.GetFaction().bFarthestFaction;
	bFactionBFarthest = ActionB.GetFaction().bFarthestFaction;

	if (!bFactionAFarthest && bFactionBFarthest)
	{
		return bLostAndAbandonedActive ? -1 : 1;
	}
	else if (bFactionAFarthest && !bFactionBFarthest)
	{
		return bLostAndAbandonedActive ? 1 : -1;
	}
	else
	{
		return 0;
	}
}

function int SortActionsStarted(XComGameState_CovertAction ActionA, XComGameState_CovertAction ActionB)
{
	if (ActionA.bStarted && !ActionB.bStarted)
	{
		return 1;
	}
	else if (!ActionA.bStarted && ActionB.bStarted)
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

/// HELPERS
simulated function XComGameState_CovertAction GetAction()
{
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(ActionRef.ObjectID));
}

simulated function XComHQPresentationLayer GetHQPres()
{
	return XComHQPresentationLayer(Movie.Pres);
}