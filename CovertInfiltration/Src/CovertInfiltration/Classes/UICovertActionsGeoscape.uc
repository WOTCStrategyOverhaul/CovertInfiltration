//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a new (custom) screen for covert ops that uses the world map
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape extends UIScreen;

// UI elements
var UIList ActionsList;
var UIPanel ButtonGroupWrap;
var UIBGBox ButtonsBG;
var UIButton ConfirmButton, CloseScreenButton;


// Data
var StateObjectReference ActionRef;
var array<XComGameState_CovertAction> arrActions;
var StateObjectReference ActionToShowOnInitRef;

// SquadSelect manager
var protectedwrite UISSManager_CovertAction SSManager;

// Set by UISS controller
var bool bConfirmScreenWasOpened;

// Pre-open values
var protected bool bPreOpenResNetForcedOn;
var protected EStrategyMapState PreOpenMapState;

// Internal state
var protected bool bDontUpdateOnSelectionChange;

const ANIMATE_IN_DURATION = 0.7f;
const CAMERA_ZOOM = 0.5f;

///////////////////////////////
/// SCREEN APPEARING EVENTS ///
///////////////////////////////

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	GetHQPres().StrategyMap2D.Hide();
}

simulated function OnInit()
{
	super.OnInit();

	// We can have 0-n list index changes during bootsratp so we call UpdateData manually once (!) after we are done
	bDontUpdateOnSelectionChange = true;

	GetHQPres().CAMSaveCurrentLocation();
	OnInitForceResistanceNetwork();

	FindActions();
	BuildScreen();
	AttemptSelectAction(ActionToShowOnInitRef);

	bDontUpdateOnSelectionChange = false;
	UpdateData();

	`XSTRATEGYSOUNDMGR.PlayPersistentSoundEvent("UI_CovertOps_Open");
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	
	// Came back from UISquadSelect or the confirmation alert
	GetHQPres().m_kXComStrategyMap.OnReceiveFocus();
	FocusCameraOnCurrentAction(true);
	
	if (bConfirmScreenWasOpened)
	{
		// The covert op was launched
		if (GetAction().bStarted)
		{
			`XSTRATEGYSOUNDMGR.PlayGeoscapeMusic(); // Otherwise SS music doesn't stop after confirmation
			UpdateList();
			SSManager = none;
		} 
		else
		{
			// Go back to loadout. If the player wants to back out of loadout, then he just press back twice
			SSManager.ClearUnitsFromAction();
			OpenLoadoutForCurrentAction();
		}

		bConfirmScreenWasOpened = false;
	}
}

///////////////////////
/// POPULATING INFO ///
///////////////////////

simulated function BuildScreen()
{
	// LIST

	ActionsList = Spawn(class'UIList', self);
	ActionsList.bStickyClickyHighlight = true;
	ActionsList.bStickyHighlight = false;
	ActionsList.bAnimateOnInit = false; // We animate manually
	ActionsList.OnSetSelectedIndex = SelectedItemChanged;
	ActionsList.InitList(
		'ActionsList',
		720, 150,
		300, 800,
		false, true
	);
	ActionsList.AnimateX(240, ANIMATE_IN_DURATION);
	ActionsList.BG.AddTweenBetween("_alpha", 0, 100, ANIMATE_IN_DURATION);

	PopulateList();
	Navigator.SetSelected(ActionsList);

	// Buttons

	ButtonGroupWrap = Spawn(class'UIPanel', self);
	ButtonGroupWrap.bAnimateOnInit = false; // We animate manually
	ButtonGroupWrap.InitPanel('ButtonGroupWrap');
	ButtonGroupWrap.SetPosition(1000, 450);
	ButtonGroupWrap.AnimateX(1320, ANIMATE_IN_DURATION);
	ButtonGroupWrap.AddTweenBetween("_alpha", 0, 100, ANIMATE_IN_DURATION);

	ButtonsBG = Spawn(class'UIBGBox', ButtonGroupWrap);
	ButtonsBG.bAnimateOnInit = false;
	ButtonsBG.InitBG('ButtonsBG');
	ButtonsBG.SetSize(300, 100);

	ConfirmButton = Spawn(class'UIButton', ButtonGroupWrap);
	ConfirmButton.bAnimateOnInit = false;
	ConfirmButton.InitButton('ConfirmButton', "Go to loadout", OnConfirmClicked);
	ConfirmButton.SetResizeToText(false);
	ConfirmButton.SetPosition(10, 10);
	ConfirmButton.SetWidth(280);

	CloseScreenButton = Spawn(class'UIButton', ButtonGroupWrap);
	CloseScreenButton.bAnimateOnInit = false;
	CloseScreenButton.InitButton('CloseScreenButton', "Close covert ops", OnCloseScreenClicked);
	CloseScreenButton.SetResizeToText(false);
	CloseScreenButton.SetPosition(10, 60);
	CloseScreenButton.SetWidth(280);
}

simulated function PopulateList()
{
	local int idx;
	local UICovertActionsGeoscape_CovertAction Item;
	local UICovertActionsGeoscape_FactionHeader FactionHeader, LastHeader;

	for( idx = 0; idx < arrActions.Length; idx++ )
	{
		if (
			LastHeader == none ||
			LastHeader.Faction.GetMyTemplateName() != arrActions[idx].GetFaction().GetMyTemplateName() || 
			LastHeader.bIsOngoing != arrActions[idx].bStarted
		) {
			FactionHeader = Spawn(class'UICovertActionsGeoscape_FactionHeader', ActionsList.itemContainer);
			FactionHeader.InitFactionHeader(arrActions[idx].GetFaction(), arrActions[idx].bStarted);

			LastHeader = FactionHeader;
		}

		Item = Spawn(class'UICovertActionsGeoscape_CovertAction', ActionsList.itemContainer);
		Item.InitCovertAction(arrActions[idx]);

		if (ActionsList.GetSelectedItem() == none)
		{
			ActionsList.SetSelectedItem(Item);
		}
	}
}

simulated function UpdateList()
{
	ActionsList.ClearItems();
	arrActions.Length = 0;

	FindActions();
	PopulateList();
}

// Copied from UICovertActions
simulated function FindActions()
{
	local XComGameStateHistory History;
	local XComGameState_CovertAction ActionState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if (!class'CI_Helpers'.static.ShouldShowCovertAction(ActionState)) continue;		

		if (ActionState.bStarted)
		{
			// Always place any currently running Covert Action at the top of the list
			arrActions.InsertItem(0, ActionState);
		}
		else 
		{
			arrActions.AddItem(ActionState);
		}
	}

	arrActions.Sort(SortActionsByFactionName);
	arrActions.Sort(SortActionsByFarthestFaction);
	arrActions.Sort(SortActionsByFactionMet);
	arrActions.Sort(SortActionsStarted);

	EnsureSelectedActionIsInList();
	if (ActionRef.ObjectID == 0)
	{
		// No action selected, just use the first one
		ActionRef = arrActions[0].GetReference();
	}

	`log("Found" @ arrActions.Length @ "actions",, 'CI');
}

simulated protected function EnsureSelectedActionIsInList()
{
	local XComGameState_CovertAction Action;	
	local bool bFound;

	// Nothing is selected so there is no need to check
	if (ActionRef.ObjectID == 0) return;	

	foreach arrActions(Action)
	{
		if (Action.ObjectID == ActionRef.ObjectID) 
		{
			bFound = true;
			break;
		}
	}	

	if (!bFound)
	{
		// Selected action not in list, just set it to nothing
		ActionRef.ObjectID = 0;
	}
}

// Used to update the screen to show new covert action
simulated function UpdateData()
{
	FocusCameraOnCurrentAction();
	ConfirmButton.SetDisabled(!CanOpenLoadout());
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

simulated function bool CanOpenLoadout()
{
	local XComGameState_CovertAction CurrentAction;
	CurrentAction = GetAction();

	return 
		!CurrentAction.bStarted &&
		CurrentAction.RequiredFactionInfluence <= CurrentAction.GetFaction().GetInfluence();
}

simulated function AttemptSelectAction(StateObjectReference ActionToFocus)
{
	local UIPanel ListItem;
	local UICovertActionsGeoscape_CovertAction ActionListItem;

	if (ActionToFocus.ObjectID == 0)
	{
		// This will fail regrdless
		return;
	}

	foreach ActionsList.ItemContainer.ChildPanels(ListItem)
	{
		ActionListItem = UICovertActionsGeoscape_CovertAction(ListItem);
		if (ActionListItem == none) continue;

		if (ActionListItem.Action.GetReference() == ActionToFocus)
		{
			ActionsList.SetSelectedItem(ActionListItem);
			return;
		}
	}
}

simulated function OpenLoadoutForCurrentAction()
{
	SSManager = new class'UISSManager_CovertAction';
	SSManager.Action = GetAction();
	SSManager.CovertOpsSrceen = self;
	SSManager.OpenSquadSelect();
}

/// CHILD CALLBAKCS

simulated function SelectedItemChanged(UIList ContainerList, int ItemIndex)
{
	local UICovertActionsGeoscape_CovertAction ListItem;
	local StateObjectReference NewRef;

	if (bDontUpdateOnSelectionChange) return;

	ListItem = UICovertActionsGeoscape_CovertAction(ContainerList.GetItem(ItemIndex));
	if (ListItem == none) return;

	NewRef = ListItem.Action.GetReference();

	if (ActionRef != NewRef)
	{
		ActionRef = NewRef;
		UpdateData();
	}
}

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
	case class'UIUtilities_Input'.const.FXS_BUTTON_A:
	case class'UIUtilities_Input'.const.FXS_KEY_ENTER:
	case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
		if (CanOpenLoadout())
		{
			ConfirmButton.OnClickedDelegate(ConfirmButton);
		}
		return true;

	case class'UIUtilities_Input'.const.FXS_BUTTON_B:
	case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
	case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
		CloseScreen();
		return true;		
	}

	return super.OnUnrealCommand(cmd, arg);
}

///////////////
/// CLOSING ///
///////////////

simulated function OnRemoved()
{
	super.OnRemoved();

	//Restore the saved camera location
	GetHQPres().CAMRestoreSavedLocation();

	class'UIUtilities_Sound'.static.PlayCloseSound();
	OnRemoveRestoreResistanceNetwork();
}

//////////////////////////////////
/// SHOWING RESISTANCE NETWORK ///
//////////////////////////////////

simulated protected function OnInitForceResistanceNetwork()
{
	local UIStrategyMap MapUI;
	MapUI = GetHQPres().StrategyMap2D;

	bPreOpenResNetForcedOn = MapUI.m_bResNetForcedOn;
	PreOpenMapState = MapUI.m_eUIState;

	// Cannot use UIStrategyMap::SetUIState(eSMS_Resistance) cuz it gets confused when communications aren't researched
	MapUI.m_eUIState = eSMS_Resistance;
	MapUI.m_bResNetForcedOn = true;
	
	MapUI.XComMap.UpdateVisuals();
	MapUI.UpdateRegionPins();
}

simulated protected function OnRemoveRestoreResistanceNetwork()
{
	local UIStrategyMap MapUI;
	MapUI = GetHQPres().StrategyMap2D;

	MapUI.m_bResNetForcedOn = bPreOpenResNetForcedOn;
	MapUI.SetUIState(PreOpenMapState);
}

///////////////
/// SORTING ///
///////////////

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