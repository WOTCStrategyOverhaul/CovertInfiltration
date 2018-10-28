//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a new (custom) screen for covert ops that uses the world map
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape extends UIScreen;

// UI - list
var UIList ActionsList;

// UI - layout. Note that there is no need for left pane since UIList is a container on its own
var UIPanel CenterSection;
var UIPanel RightPane;

// UI - action info (top)
var UIPanel ActionInfoTopContainer;
var UIMask ActionInfoMask; // Used to animate in
var UIBGBox ActionInfoBG;
var UIImage ActionDisplayNameBG;
var UIText ActionDisplayName;
var UIText ActionDescription;

// UI - action info (bottom)
var UIPanel ActionInfoBottomContainer;

// UI - action reward
var UIPanel ActionRewardContainer;
var UIImage ActionRewardHeaderBG;
var UIText ActionRewardHeader;
var UIPanel ActionRewardTextBG;
var UIText ActionRewardText;

// UI - action deploayable resources
var UIPanel ActionResourcesContainer;
var UIImage ActionResourcesHeaderBG;
var UIText ActionResourcesHeader;
var UIPanel ActionResourcesTextBG;
var UIText ActionResourcesText;

// UI - action risks
var UIPanel ActionRisksContainer;
var UIImage ActionRisksHeaderBG;
var UIText ActionRisksHeader;
var UIPanel ActionRisksTextBG;
var UIText ActionRisksText;

// UI - action image
var UIImage ActionImageBorder;
var UIImage ActionImage;

// UI - buttons
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
var protected bool bDontUpdateData;

const ANIMATE_IN_DURATION = 0.5f;
const CAMERA_ZOOM = 0.5f;

const UI_INFO_BOX_MARGIN = 10;

///////////////////////
/// Creating screen ///
///////////////////////

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	// Testing code
	if (ActionToShowOnInitRef.ObjectID != 0) bAnimateOnInit = false;

	GetHQPres().StrategyMap2D.Hide();
	GetHQPres().CAMSaveCurrentLocation();
	OnInitForceResistanceNetwork();

	BuildScreen();
}

simulated function OnInit()
{
	super.OnInit();

	// We can have 0-n list index changes during bootsratp so we call UpdateData manually once (!) after we are done
	bDontUpdateData = true;

	FindActions();
	PopulateList();
	AttemptSelectAction(ActionToShowOnInitRef);

	bDontUpdateData = false;
	UpdateData();

	`XSTRATEGYSOUNDMGR.PlayPersistentSoundEvent("UI_CovertOps_Open");
}

simulated function BuildScreen()
{
	// Note that bAnimateOnInit is set to false on most elements since we do custom animations

	BuildActionsList();
	BuildCenterSection();
	BuildRightPane();
}

simulated protected function BuildActionsList()
{
	ActionsList = Spawn(class'UIList', self);
	ActionsList.bStickyClickyHighlight = true;
	ActionsList.bStickyHighlight = false;
	ActionsList.bAnimateOnInit = false;
	ActionsList.OnSetSelectedIndex = SelectedItemChanged;
	ActionsList.InitList(
		'ActionsList',
		120, 150,
		300, 800,
		false, true
	);
	Navigator.SetSelected(ActionsList);
}

simulated protected function BuildCenterSection()
{
	CenterSection = Spawn(class'UIPanel', self);
	CenterSection.bAnimateOnInit = false;
	CenterSection.InitPanel('CenterSection');
	CenterSection.SetPosition(480, 0); // CenterSection spans the entire viewport vertically
	CenterSection.SetSize(960, 1080);

	BuildActionInfoTop();
}

simulated protected function BuildActionInfoTop()
{
	ActionInfoTopContainer = Spawn(class'UIPanel', CenterSection);
	ActionInfoTopContainer.bAnimateOnInit = false;
	ActionInfoTopContainer.InitPanel('ActionInfoTopContainer');
	ActionInfoTopContainer.SetPosition(0, 150);
	ActionInfoTopContainer.SetSize(960, 195);

	ActionInfoMask = Spawn(class'UIMask', self);
	ActionInfoMask.bAnimateOnInit = false;
	ActionInfoMask.InitMask('ActionInfoMask', ActionInfoTopContainer);
	ActionInfoMask.SetPosition(CenterSection.X + ActionInfoTopContainer.X - UI_INFO_BOX_MARGIN, ActionInfoTopContainer.Y - UI_INFO_BOX_MARGIN);
	ActionInfoMask.SetSize(ActionInfoTopContainer.Width + UI_INFO_BOX_MARGIN * 2, ActionInfoTopContainer.Height + UI_INFO_BOX_MARGIN * 2);

	ActionInfoBG = Spawn(class'UIBGBox', ActionInfoTopContainer);
	ActionInfoBG.bAnimateOnInit = false;
	ActionInfoBG.InitBG('ActionInfoBG');
	ActionInfoBG.SetAlpha(60);
	ActionInfoBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionInfoBG.SetSize(ActionInfoTopContainer.Width + UI_INFO_BOX_MARGIN * 2, ActionInfoTopContainer.Height + UI_INFO_BOX_MARGIN * 2);

	ActionDisplayNameBG = Spawn(class'UIImage', ActionInfoTopContainer);
	ActionDisplayNameBG.bAnimateOnInit = false;
	ActionDisplayNameBG.InitImage('ActionDisplayNameBG', "img:///UILibrary_CovertInfiltration.Ops_Header_BG");
	ActionDisplayNameBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionDisplayNameBG.SetSize(ActionInfoTopContainer.Width + UI_INFO_BOX_MARGIN * 2, 60);

	ActionDisplayName = Spawn(class'UIText', ActionInfoTopContainer);
	ActionDisplayName.bAnimateOnInit = false;
	ActionDisplayName.InitText('ActionDisplayName');
	ActionDisplayName.SetSize(ActionInfoTopContainer.Width, 55);

	ActionDescription = Spawn(class'UIText', ActionInfoTopContainer);
	ActionDescription.bAnimateOnInit = false;
	ActionDescription.InitText('ActionDescription');
	ActionDescription.SetPosition(0, 50);
	ActionDescription.SetSize(ActionInfoTopContainer.Width, ActionInfoTopContainer.Height - ActionDescription.Y);
}

simulated protected function BuildRightPane()
{
	RightPane = Spawn(class'UIPanel', self);
	RightPane.bAnimateOnInit = false;
	RightPane.InitPanel('RightPane');
	RightPane.SetPosition(1500, 0); // RightPane spans the entire viewport vertically
	RightPane.SetSize(300, 1080);

	BuildActionImage();
	BuildButtons();
}

simulated protected function BuildActionImage()
{
	ActionImageBorder = Spawn(class'UIImage', RightPane);
	ActionImageBorder.bAnimateOnInit = false;
	ActionImageBorder.InitImage('ActionImageBorder', "img:///UILibrary_CovertInfiltration.Ops_Border_Full");
	ActionImageBorder.SetPosition(-10, 148);
	ActionImageBorder.SetSize(320, 172);

	ActionImage = Spawn(class'UIImage', RightPane);
	ActionImage.bAnimateOnInit = false;
	ActionImage.InitImage('ActionImage');
	ActionImage.SetPosition(0, 150);
	ActionImage.SetSize(300, 168);
}

simulated protected function BuildButtons()
{
	ButtonGroupWrap = Spawn(class'UIPanel', RightPane);
	ButtonGroupWrap.bAnimateOnInit = false;
	ButtonGroupWrap.InitPanel('ButtonGroupWrap');
	ButtonGroupWrap.SetPosition(0, 500);
	ButtonGroupWrap.SetSize(RightPane.Width, 80);

	ButtonsBG = Spawn(class'UIBGBox', ButtonGroupWrap);
	ButtonsBG.bAnimateOnInit = false;
	ButtonsBG.InitBG('ButtonsBG');
	ButtonsBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ButtonsBG.SetSize(ButtonGroupWrap.Width + UI_INFO_BOX_MARGIN * 2, ButtonGroupWrap.Height + UI_INFO_BOX_MARGIN * 2);

	ConfirmButton = Spawn(class'UIButton', ButtonGroupWrap);
	ConfirmButton.bAnimateOnInit = false;
	ConfirmButton.InitButton('ConfirmButton', "Go to loadout", OnConfirmClicked);
	ConfirmButton.SetResizeToText(false);
	ConfirmButton.SetWidth(ButtonGroupWrap.Width);

	CloseScreenButton = Spawn(class'UIButton', ButtonGroupWrap);
	CloseScreenButton.bAnimateOnInit = false;
	CloseScreenButton.InitButton('CloseScreenButton', "Close covert ops", OnCloseScreenClicked);
	CloseScreenButton.SetResizeToText(false);
	CloseScreenButton.SetPosition(0, 50);
	CloseScreenButton.SetWidth(ButtonGroupWrap.Width);
}

//////////////////
/// Animations ///
//////////////////

simulated function AnimateIn(optional float Delay = 0.0)
{
	// Left

	ActionsList.AddTweenBetween("_x", 600, ActionsList.X, ANIMATE_IN_DURATION, Delay, "easeoutquad");
	ActionsList.AddTweenBetween("_alpha", 0, 100, ANIMATE_IN_DURATION, Delay, "easeoutquad");

	// Center

	ActionInfoMask.AddTweenBetween("_x", 960, ActionInfoMask.X, ANIMATE_IN_DURATION, Delay, "easeoutquad");
	ActionInfoMask.AddTweenBetween("_width", 0, ActionInfoMask.Width, ANIMATE_IN_DURATION, Delay, "easeoutquad");
	CenterSection.AddTweenBetween("_alpha", 0, 100, ANIMATE_IN_DURATION, Delay, "easeoutquad");

	// Right

	RightPane.AddTweenBetween("_x", 1320, RightPane.X, ANIMATE_IN_DURATION, Delay, "easeoutquad");
	RightPane.AddTweenBetween("_alpha", 0, 100, ANIMATE_IN_DURATION, Delay, "easeoutquad");
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

///////////////////////////////////
/// Populating the actions list ///
///////////////////////////////////

// Adapted from UICovertActions
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

simulated function PopulateList()
{
	local int idx;
	local UICovertActionsGeoscape_CovertAction Item;
	local UICovertActionsGeoscape_FactionHeader FactionHeader, LastHeader;

	for (idx = 0; idx < arrActions.Length; idx++)
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

/////////////////////////////////////
/// Refreshing displayed elements ///
/////////////////////////////////////

simulated function UpdateList()
{
	ActionsList.ClearItems();
	arrActions.Length = 0;

	FindActions();
	PopulateList();
	UpdateData();
}

// Used to update the screen to show new covert action
simulated function UpdateData()
{
	if (bDontUpdateData) return;

	FocusCameraOnCurrentAction();
	ConfirmButton.SetDisabled(!CanOpenLoadout());
	UpdateCovertActionInfo();
}

simulated function bool CanOpenLoadout()
{
	local XComGameState_CovertAction CurrentAction;
	CurrentAction = GetAction();

	return 
		!CurrentAction.bStarted &&
		CurrentAction.RequiredFactionInfluence <= CurrentAction.GetFaction().GetInfluence();
}

simulated function UpdateCovertActionInfo()
{
	local XComGameState_CovertAction CurrentAction;
	CurrentAction = GetAction();

	ActionImage.LoadImage(CurrentAction.GetImage());
	ActionDisplayName.SetCenteredText(class'UIUtilities_Text'.static.AddFontInfo(CurrentAction.GetDisplayName(), bIsIn3D, true));
	ActionDescription.SetCenteredText(class'UIUtilities_Text'.static.AddFontInfo(CurrentAction.GetNarrative(), bIsIn3D));
}

//////////////////////////////////////
/// Interaction with other screens ///
//////////////////////////////////////

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

		if (ActionListItem.Action.ObjectID == ActionToFocus.ObjectID)
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

///////////////////////
/// Child callbacks ///
///////////////////////

simulated function SelectedItemChanged(UIList ContainerList, int ItemIndex)
{
	local UICovertActionsGeoscape_CovertAction ListItem;
	local StateObjectReference NewRef;

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

/////////////////////////////////////
/// Keyboard and controller input ///
/////////////////////////////////////

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	if(!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return false;

	switch(cmd)
	{
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

//////////////////////
/// Closing screen ///
//////////////////////

simulated function OnRemoved()
{
	super.OnRemoved();

	//Restore the saved camera location
	GetHQPres().CAMRestoreSavedLocation();

	class'UIUtilities_Sound'.static.PlayCloseSound();
	OnRemoveRestoreResistanceNetwork();
}

//////////////////////////////////////////
/// Resistance network display control ///
//////////////////////////////////////////

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
/// Helpers ///
///////////////

simulated function XComGameState_CovertAction GetAction()
{
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(ActionRef.ObjectID));
}

simulated function XComHQPresentationLayer GetHQPres()
{
	return XComHQPresentationLayer(Movie.Pres);
}

///////////////////////
/// Sorting actions ///
///////////////////////

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

defaultproperties
{
    InputState=eInputState_Consume
}