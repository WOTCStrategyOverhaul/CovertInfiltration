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
var UIMask CenterSectionMask; // Used to animate in
var UIPanel RightPane;

// UI - action info (top)
var UIPanel ActionInfoTopContainer;

// UI - action image
//var UIImage ActionImageBorder;
var UIImage ActionImage;

// UI - action brief
var UIPanel ActionBriefContainer;
var UIBGBox ActionBriefBG;
var UIImage ActionDisplayNameBG;
var UIText ActionDisplayName;
var UITextContainer ActionDescription;

// UI - action info (bottom)
var UIPanel ActionInfoBottomContainer;

// UI - action reward
var UIPanel ActionRewardContainer;
var UIImage ActionRewardHeaderBG;
var UIText ActionRewardHeader;
var UIPanel ActionRewardTextBG;
var UIText ActionRewardText;

// UI - progress bar
var UIProgressBar ActionProgressBar;

// UI - action slots
var UIPanel ActionSlotsContainer;
var UIImage ActionSlotsHeaderBG;
var UIText ActionSlotsHeader;
var UIPanel ActionSlotsTextBG;
var UIList ActionSlotRows;

// UI - faction info
var UIPanel FactionInfoConatiner;
var UIPanel FactionInfoBG; // pixel
var UIImage FactionInfoBorder;
var UIStackingIcon FactionInfoIcon;
var UIText FactionGenericName;
var UIScrollingText FactionNarrativeName;
var UIText FactionInfluenceLabel;
var UIText FactionInfluenceValue;
var UIImage FactionLeaderImage;
var UIMask FactionLeaderImageMask;

// UI - buttons
var UIPanel ButtonGroupWrap;
var UIBGBox ButtonsBG;
var UIText DurationLabel;
var UIText DurationValue;
var UIButton ConfirmButton, CloseScreenButton;

// UI - action risks
var UIPanel ActionRisksContainer;
var UIImage ActionRisksHeaderBG;
var UIText ActionRisksHeader;
var UIPanel ActionRisksTextBG;
var UIText ActionRisksText;

// Data
var StateObjectReference ActionRef;
var array<XComGameState_CovertAction> arrActions;
var StateObjectReference ActionToShowOnInitRef;
var protected array<UICovertActionsGeoscape_SlotInfo> CurrentSlots;

// SquadSelect manager
var protectedwrite UISSManager_CovertAction SSManager;

// Set by UISS controller
var bool bConfirmScreenWasOpened;

// Pre-open values
var protected bool bPreOpenResNetForcedOn;
var protected EStrategyMapState PreOpenMapState;

// Internal state
var protected bool bDontUpdateData;

// Localization strings
var localized string strRewardHeader;
var localized string strSlotsHeader;
var localized string strOpenLoadout;
var localized string strCloseScreen;
var localized string strRisksHeader;

const ANIMATE_IN_DURATION = 0.5f;
const CAMERA_ZOOM = 0.5f;

const UI_INFO_BOX_MARGIN = 10;
const ACTION_SLOTS_PER_ROW = 2;

///////////////////////
/// Creating screen ///
///////////////////////

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	`log("Opening UICovertActionsGeoscape",, 'CI');

	super.InitScreen(InitController, InitMovie, InitName);

	// Testing code
	//if (ActionToShowOnInitRef.ObjectID != 0) bAnimateOnInit = false;

	GetHQPres().StrategyMap2D.Hide();
	GetHQPres().StrategyMap2D.HideCursor();
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

	CenterSectionMask = Spawn(class'UIMask', self);
	CenterSectionMask.bAnimateOnInit = false;
	CenterSectionMask.InitMask('CenterSectionMask', CenterSection);
	CenterSectionMask.SetPosition(CenterSection.X - UI_INFO_BOX_MARGIN, 0);
	CenterSectionMask.SetSize(CenterSection.Width + UI_INFO_BOX_MARGIN * 2, 1080);

	BuildActionInfoTop();
	BuildActionInfoBottom();
}

simulated protected function BuildActionInfoTop()
{
	ActionInfoTopContainer = Spawn(class'UIPanel', CenterSection);
	ActionInfoTopContainer.bAnimateOnInit = false;
	ActionInfoTopContainer.InitPanel('ActionInfoTopContainer');
	ActionInfoTopContainer.SetPosition(0, 150);
	ActionInfoTopContainer.SetSize(960, 195);

	BuildActionImage();
	BuildActionBrief();
}

simulated protected function BuildActionImage()
{
	/*ActionImageBorder = Spawn(class'UIImage', ActionInfoTopContainer);
	ActionImageBorder.bAnimateOnInit = false;
	ActionImageBorder.InitImage('ActionImageBorder', "img:///UILibrary_CovertInfiltration.Ops_Border_Full");
	ActionImageBorder.SetPosition(-10, -2);
	ActionImageBorder.SetSize(320, 172);*/

	ActionImage = Spawn(class'UIImage', ActionInfoTopContainer);
	ActionImage.bAnimateOnInit = false;
	ActionImage.InitImage('ActionImage');
	ActionImage.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionImage.SetSize(384, ActionInfoTopContainer.Height + UI_INFO_BOX_MARGIN * 2);
}

simulated protected function BuildActionBrief()
{
	ActionBriefContainer = Spawn(class'UIPanel', ActionInfoTopContainer);
	ActionBriefContainer.bAnimateOnInit = false;
	ActionBriefContainer.InitPanel('ActionBriefContainer');
	ActionBriefContainer.SetPosition(390, 0);
	ActionBriefContainer.SetSize(ActionInfoTopContainer.Width - 390, ActionInfoTopContainer.Height);

	ActionBriefBG = Spawn(class'UIBGBox', ActionBriefContainer);
	ActionBriefBG.bAnimateOnInit = false;
	ActionBriefBG.InitBG('ActionBriefBG');
	ActionBriefBG.SetAlpha(60);
	ActionBriefBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionBriefBG.SetSize(ActionBriefContainer.Width + UI_INFO_BOX_MARGIN * 2, ActionBriefContainer.Height + UI_INFO_BOX_MARGIN * 2);

	ActionDisplayNameBG = Spawn(class'UIImage', ActionBriefContainer);
	ActionDisplayNameBG.bAnimateOnInit = false;
	ActionDisplayNameBG.InitImage('ActionDisplayNameBG', "img:///UILibrary_CovertInfiltration.Ops_Header_BG");
	ActionDisplayNameBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionDisplayNameBG.SetSize(ActionBriefContainer.Width + UI_INFO_BOX_MARGIN * 2, 60);

	ActionDisplayName = Spawn(class'UIText', ActionBriefContainer);
	ActionDisplayName.bAnimateOnInit = false;
	ActionDisplayName.InitText('ActionDisplayName');
	ActionDisplayName.SetSize(ActionBriefContainer.Width, 55);

	ActionDescription = Spawn(class'UITextContainer', ActionBriefContainer);
	ActionDescription.bAnimateOnInit = false;
	ActionDescription.InitTextContainer('ActionDescription');
	//ActionDescription.bAutoScroll = true; // Doesn't work properly for some reason
	ActionDescription.SetPosition(0, 50);
	ActionDescription.SetSize(ActionBriefContainer.Width, ActionBriefContainer.Height - ActionDescription.Y);
}

simulated protected function BuildActionInfoBottom()
{
	ActionInfoBottomContainer = Spawn(class'UIPanel', CenterSection);
	ActionInfoBottomContainer.bAnimateOnInit = false;
	ActionInfoBottomContainer.InitPanel('ActionInfoBottomContainer');
	ActionInfoBottomContainer.SetPosition(0, 740);
	ActionInfoBottomContainer.SetSize(960, 210);

	BuildActionProgressBar();
	BuildActionReward();
	BuildActionSlots();
}

simulated protected function BuildActionProgressBar()
{
	ActionProgressBar = Spawn(class'UIProgressBar', ActionInfoBottomContainer);
	ActionProgressBar.bAnimateOnInit = false;
	ActionProgressBar.InitProgressBar('ActionProgressBar');
	ActionProgressBar.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN - 50);
	ActionProgressBar.SetSize(ActionInfoBottomContainer.Width + UI_INFO_BOX_MARGIN * 2, 40);
	ActionProgressBar.SetColor(class'UIUtilities_Colors'.const.COVERT_OPS_HTML_COLOR);
}

simulated protected function BuildActionReward()
{
	ActionRewardContainer = Spawn(class'UIPanel', ActionInfoBottomContainer);
	ActionRewardContainer.bAnimateOnInit = false;
	ActionRewardContainer.InitPanel('ActionRewardContainer');
	ActionRewardContainer.SetPosition(0, 0);
	ActionRewardContainer.SetSize(310, ActionInfoBottomContainer.Height);

	ActionRewardTextBG = Spawn(class'UIPanel', ActionRewardContainer);
	ActionRewardTextBG.bAnimateOnInit = false;
	ActionRewardTextBG.InitPanel('ActionRewardTextBG', class'UIUtilities_Controls'.const.MC_GenericPixel);
	ActionRewardTextBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionRewardTextBG.SetSize(ActionRewardContainer.Width + UI_INFO_BOX_MARGIN * 2, ActionRewardContainer.Height + UI_INFO_BOX_MARGIN * 2);
	ActionRewardTextBG.SetColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
	ActionRewardTextBG.SetAlpha(60);

	ActionRewardHeaderBG = Spawn(class'UIImage', ActionRewardContainer);
	ActionRewardHeaderBG.bAnimateOnInit = false;
	ActionRewardHeaderBG.InitImage('ActionRewardHeaderBG', "img:///UILibrary_CovertInfiltration.Ops_Header_BG");
	ActionRewardHeaderBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionRewardHeaderBG.SetSize(ActionRewardContainer.Width + UI_INFO_BOX_MARGIN * 2, 60);

	ActionRewardHeader = Spawn(class'UIText', ActionRewardContainer);
	ActionRewardHeader.bAnimateOnInit = false;
	ActionRewardHeader.InitText('ActionRewardHeader');
	ActionRewardHeader.SetSize(ActionRewardContainer.Width, 55);
	ActionRewardHeader.SetCenteredText(class'UIUtilities_Text'.static.AddFontInfo(strRewardHeader, bIsIn3D, true));

	ActionRewardText = Spawn(class'UIText', ActionRewardContainer);
	ActionRewardText.bAnimateOnInit = false;
	ActionRewardText.InitText('ActionRewardText');
	ActionRewardText.SetPosition(0, 50);
	ActionRewardText.SetSize(ActionRewardContainer.Width, ActionRewardContainer.Height - ActionRewardText.Y);
}

simulated protected function BuildActionSlots()
{
	ActionSlotsContainer = Spawn(class'UIPanel', ActionInfoBottomContainer);
	ActionSlotsContainer.bAnimateOnInit = false;
	ActionSlotsContainer.InitPanel('ActionSlotsContainer');
	ActionSlotsContainer.SetPosition(340, 0);
	ActionSlotsContainer.SetSize(ActionInfoBottomContainer.Width - ActionSlotsContainer.X, ActionInfoBottomContainer.Height);

	ActionSlotsTextBG = Spawn(class'UIPanel', ActionSlotsContainer);
	ActionSlotsTextBG.bAnimateOnInit = false;
	ActionSlotsTextBG.InitPanel('AActionSlotsTextBG', class'UIUtilities_Controls'.const.MC_GenericPixel);
	ActionSlotsTextBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionSlotsTextBG.SetSize(ActionSlotsContainer.Width + UI_INFO_BOX_MARGIN * 2, ActionSlotsContainer.Height + UI_INFO_BOX_MARGIN * 2);
	ActionSlotsTextBG.SetColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
	ActionSlotsTextBG.SetAlpha(60);

	ActionSlotsHeaderBG = Spawn(class'UIImage', ActionSlotsContainer);
	ActionSlotsHeaderBG.bAnimateOnInit = false;
	ActionSlotsHeaderBG.InitImage('ActionSlotsHeaderBG', "img:///UILibrary_CovertInfiltration.Ops_Header_BG");
	ActionSlotsHeaderBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionSlotsHeaderBG.SetSize(ActionSlotsContainer.Width + UI_INFO_BOX_MARGIN * 2, 60);

	ActionSlotsHeader = Spawn(class'UIText', ActionSlotsContainer);
	ActionSlotsHeader.bAnimateOnInit = false;
	ActionSlotsHeader.InitText('ActionSlotsHeader');
	ActionSlotsHeader.SetSize(ActionSlotsContainer.Width, 55);
	ActionSlotsHeader.SetCenteredText(class'UIUtilities_Text'.static.AddFontInfo(strSlotsHeader, bIsIn3D, true));

	ActionSlotRows = Spawn(class'UIList', ActionSlotsContainer);
	ActionSlotRows.bAnimateOnInit = false;
	ActionSlotRows.InitList('ActionSlotRows');
	ActionSlotRows.SetPosition(0, 50);
	ActionSlotRows.SetSize(ActionSlotsContainer.Width, ActionSlotsContainer.Height - ActionSlotRows.Y);
	ActionSlotRows.DisableNavigation();
}

simulated protected function BuildRightPane()
{
	RightPane = Spawn(class'UIPanel', self);
	RightPane.bAnimateOnInit = false;
	RightPane.InitPanel('RightPane');
	RightPane.SetPosition(1500, 0); // RightPane spans the entire viewport vertically
	RightPane.SetSize(300, 1080);

	BuildFactionInfo();
	BuildButtons();
	BuildRisks();
}

simulated protected function BuildFactionInfo()
{
	FactionInfoConatiner = Spawn(class'UIPanel', RightPane);
	FactionInfoConatiner.bAnimateOnInit = false;
	FactionInfoConatiner.InitPanel('FactionInfoConatiner');
	FactionInfoConatiner.SetPosition(0, 140);
	FactionInfoConatiner.SetSize(RightPane.Width, 300);

	FactionInfoBorder = Spawn(class'UIImage', FactionInfoConatiner);
	FactionInfoBorder.bAnimateOnInit = false;
	FactionInfoBorder.InitImage('FactionInfoBorder', "img:///UILibrary_CovertInfiltration.Ops_Border_Full");
	FactionInfoBorder.SetPosition(-10, -2);
	FactionInfoBorder.SetSize(320, 258);

	FactionInfoBG = Spawn(class'UIPanel', FactionInfoConatiner);
	FactionInfoBG.bAnimateOnInit = false;
	FactionInfoBG.InitPanel('FactionInfoBG', class'UIUtilities_Controls'.const.MC_GenericPixel);
	FactionInfoBG.SetSize(FactionInfoConatiner.Width, 95); // Background for space above the leader image
	FactionInfoBG.SetColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);

	FactionInfoIcon = Spawn(class'UIStackingIcon', FactionInfoConatiner);
	FactionInfoIcon.bAnimateOnInit = false;
	FactionInfoIcon.InitStackingIcon('FactionInfoIcon');
	FactionInfoIcon.SetIconSize(60);
	FactionInfoIcon.SetPosition(5, 5);

	FactionGenericName = Spawn(class'UIText', FactionInfoConatiner);
	FactionGenericName.bAnimateOnInit = false;
	FactionGenericName.InitText('FactionGenericName');
	FactionGenericName.SetPosition(70, 10);
	FactionGenericName.SetWidth(FactionInfoConatiner.Width - UI_INFO_BOX_MARGIN - 70);

	FactionNarrativeName = Spawn(class'UIScrollingText', FactionInfoConatiner);
	FactionNarrativeName.bAnimateOnInit = false;
	FactionNarrativeName.InitScrollingText('FactionNarrativeName');
	FactionNarrativeName.SetPosition(70, 30);
	FactionNarrativeName.SetWidth(FactionInfoConatiner.Width - UI_INFO_BOX_MARGIN - 70);

	FactionInfluenceLabel = Spawn(class'UIText', FactionInfoConatiner);
	FactionInfluenceLabel.bAnimateOnInit = false;
	FactionInfluenceLabel.InitText('FactionInfluenceLabel', class'UICovertActions'.default.CovertActions_InfluenceLabel);
	FactionInfluenceLabel.SetPosition(UI_INFO_BOX_MARGIN, 65);
	FactionInfluenceLabel.SetWidth(FactionInfoConatiner.Width - UI_INFO_BOX_MARGIN * 2);

	FactionInfluenceValue = Spawn(class'UIText', FactionInfoConatiner);
	FactionInfluenceValue.bAnimateOnInit = false;
	FactionInfluenceValue.InitText('FactionInfluenceValue');
	FactionInfluenceValue.SetPosition(UI_INFO_BOX_MARGIN, 65);
	FactionInfluenceValue.SetWidth(FactionInfoConatiner.Width - UI_INFO_BOX_MARGIN * 2);

	FactionLeaderImage = Spawn(class'UIImage', FactionInfoConatiner);
	FactionLeaderImage.bAnimateOnInit = false;
	FactionLeaderImage.InitImage('FactionLeaderImage');
	FactionLeaderImage.SetPosition(-8, 95);
	FactionLeaderImage.SetSize(316, 158);

	FactionLeaderImageMask = Spawn(class'UIMask', FactionInfoConatiner);
	FactionLeaderImageMask.InitMask('FactionLeaderImageMask', FactionLeaderImage);
	FactionLeaderImageMask.SetPosition(0, 95);
	FactionLeaderImageMask.SetSize(FactionInfoConatiner.Width, FactionLeaderImage.Height);
}

simulated protected function BuildButtons()
{
	ButtonGroupWrap = Spawn(class'UIPanel', RightPane);
	ButtonGroupWrap.bAnimateOnInit = false;
	ButtonGroupWrap.InitPanel('ButtonGroupWrap');
	ButtonGroupWrap.SetPosition(0, 490);
	ButtonGroupWrap.SetSize(RightPane.Width, 100);

	ButtonsBG = Spawn(class'UIBGBox', ButtonGroupWrap);
	ButtonsBG.bAnimateOnInit = false;
	ButtonsBG.InitBG('ButtonsBG');
	ButtonsBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ButtonsBG.SetSize(ButtonGroupWrap.Width + UI_INFO_BOX_MARGIN * 2, ButtonGroupWrap.Height + UI_INFO_BOX_MARGIN * 2);

	DurationLabel = Spawn(class'UIText', ButtonGroupWrap);
	DurationLabel.bAnimateOnInit = false;
	DurationLabel.InitText('DurationLabel');
	DurationLabel.SetWidth(ButtonGroupWrap.Width);
	
	DurationValue = Spawn(class'UIText', ButtonGroupWrap);
	DurationValue.bAnimateOnInit = false;
	DurationValue.InitText('DurationValue');
	DurationValue.SetWidth(ButtonGroupWrap.Width);

	ConfirmButton = Spawn(class'UIButton', ButtonGroupWrap);
	ConfirmButton.bAnimateOnInit = false;
	ConfirmButton.InitButton('ConfirmButton', strOpenLoadout, OnConfirmClicked, eUIButtonStyle_HOTLINK_BUTTON);
	ConfirmButton.SetGamepadIcon(class'UIUtilities_Input'.static.GetAdvanceButtonIcon());
	ConfirmButton.SetResizeToText(false);
	ConfirmButton.SetPosition(0, 35);
	ConfirmButton.SetWidth(ButtonGroupWrap.Width);

	CloseScreenButton = Spawn(class'UIButton', ButtonGroupWrap);
	CloseScreenButton.bAnimateOnInit = false;
	CloseScreenButton.InitButton('CloseScreenButton', strCloseScreen, OnCloseScreenClicked, eUIButtonStyle_HOTLINK_BUTTON);
	CloseScreenButton.SetGamepadIcon(class'UIUtilities_Input'.static.GetBackButtonIcon());
	CloseScreenButton.SetResizeToText(false);
	CloseScreenButton.SetPosition(0, 70);
	CloseScreenButton.SetWidth(ButtonGroupWrap.Width);

	if (`ISCONTROLLERACTIVE)
	{
		ConfirmButton.OnSizeRealized = OnConfirmButtonSizeRealized;
		ConfirmButton.SetResizeToText(true);
		ConfirmButton.Hide();

		CloseScreenButton.OnSizeRealized = OnCloseScreenButtonSizeRealized;
		CloseScreenButton.SetResizeToText(true);
		CloseScreenButton.Hide();
	}
}

simulated protected function OnConfirmButtonSizeRealized()
{
	ConfirmButton.SetX(ButtonGroupWrap.Width / 2 - ConfirmButton.Width / 2);
	ConfirmButton.Show();
}

simulated protected function OnCloseScreenButtonSizeRealized()
{
	CloseScreenButton.SetX(ButtonGroupWrap.Width / 2 - CloseScreenButton.Width / 2);
	CloseScreenButton.Show();
}

simulated protected function BuildRisks()
{
	ActionRisksContainer = Spawn(class'UIPanel', RightPane);
	ActionRisksContainer.bAnimateOnInit = false;
	ActionRisksContainer.InitPanel('ActionRisksContainer');
	ActionRisksContainer.SetPosition(0, ActionInfoBottomContainer.Y);
	ActionRisksContainer.SetSize(RightPane.Width, ActionInfoBottomContainer.Height);

	ActionRisksTextBG = Spawn(class'UIPanel', ActionRisksContainer);
	ActionRisksTextBG.bAnimateOnInit = false;
	ActionRisksTextBG.InitPanel('ActionRisksTextBG', class'UIUtilities_Controls'.const.MC_GenericPixel);
	ActionRisksTextBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionRisksTextBG.SetSize(ActionRisksContainer.Width + UI_INFO_BOX_MARGIN * 2, ActionRisksContainer.Height + UI_INFO_BOX_MARGIN * 2);
	ActionRisksTextBG.SetColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
	ActionRisksTextBG.SetAlpha(60);

	ActionRisksHeaderBG = Spawn(class'UIImage', ActionRisksContainer);
	ActionRisksHeaderBG.bAnimateOnInit = false;
	ActionRisksHeaderBG.InitImage('ActionRisksHeaderBG', "img:///UILibrary_CovertInfiltration.Ops_Header_BG");
	ActionRisksHeaderBG.SetPosition(-UI_INFO_BOX_MARGIN, -UI_INFO_BOX_MARGIN);
	ActionRisksHeaderBG.SetSize(ActionRisksContainer.Width + UI_INFO_BOX_MARGIN * 2, 60);

	ActionRisksHeader = Spawn(class'UIText', ActionRisksContainer);
	ActionRisksHeader.bAnimateOnInit = false;
	ActionRisksHeader.InitText('ActionRisksHeader');
	ActionRisksHeader.SetSize(ActionRisksContainer.Width, 55);
	ActionRisksHeader.SetCenteredText(class'UIUtilities_Text'.static.AddFontInfo(strRisksHeader, bIsIn3D, true));

	ActionRisksText = Spawn(class'UIText', ActionRisksContainer);
	ActionRisksText.bAnimateOnInit = false;
	ActionRisksText.InitText('ActionRisksText');
	ActionRisksText.SetPosition(0, 50);
	ActionRisksText.SetSize(ActionRisksContainer.Width, ActionRisksContainer.Height - ActionRisksText.Y);
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

	CenterSection.AddTweenBetween("_alpha", 0, 100, ANIMATE_IN_DURATION, Delay, "easeoutquad");
	CenterSectionMask.AddTweenBetween("_x", 960, CenterSectionMask.X, ANIMATE_IN_DURATION, Delay, "easeoutquad");
	CenterSectionMask.AddTweenBetween("_width", 0, CenterSectionMask.Width, ANIMATE_IN_DURATION, Delay, "easeoutquad");

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
		if (!class'UIUtilities_Infiltration'.static.ShouldShowCovertAction(ActionState)) continue;		

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
	
	PrepareSlotsInfo();

	FocusCameraOnCurrentAction();
	ConfirmButton.SetDisabled(!CanOpenLoadout());
	UpdateCovertActionInfo();
	UpdateProgressBar();
}

simulated function bool CanOpenLoadout()
{
	local XComGameState_CovertAction CurrentAction;
	local UICovertActionsGeoscape_SlotInfo SlotInfo;
	local bool UnaffordableRequiredSlot;

	CurrentAction = GetAction();

	if (CurrentAction.bStarted)
	{
		return false;
	}

	if (CurrentAction.RequiredFactionInfluence > CurrentAction.GetFaction().GetInfluence())
	{
		return false;
	}

	foreach CurrentSlots(SlotInfo)
	{
		if (!SlotInfo.CanAfford() && !SlotInfo.IsOptional())
		{
			UnaffordableRequiredSlot = true;
			break;
		}
	}

	if (UnaffordableRequiredSlot)
	{
		return false;
	}

	return true;
}

simulated function UpdateCovertActionInfo()
{
	local XComGameState_CovertAction CurrentAction;
	CurrentAction = GetAction();

	FactionInfoIcon.SetImageStack(CurrentAction.GetFaction().FactionIconData);
	FactionGenericName.SetHtmlText(class'UIUtilities_Text'.static.AddFontInfo(
		class'UIUtilities_Infiltration'.static.ColourText(
			Caps(CurrentAction.GetFaction().GetFactionTitle()),
			"808080"
		),
		bIsIn3D, true, true, 17
	));
	FactionNarrativeName.SetHtmlText(class'UIUtilities_Text'.static.AddFontInfo(
		class'UIUtilities_Infiltration'.static.ColourText(
			CurrentAction.GetFaction().FactionName,
			class'UIUtilities_Colors'.static.GetColorForFaction(CurrentAction.GetFaction().GetMyTemplateName())
		),
		bIsIn3D, true, true, 19
	));
	FactionInfluenceValue.SetSubTitle(class'UIUtilities_Text'.static.AlignRight(CurrentAction.GetFaction().GetInfluenceString()));
	FactionLeaderImage.LoadImage(CurrentAction.GetFaction().GetLeaderImage());

	ActionImage.LoadImage(CurrentAction.GetImage());
	ActionDisplayName.SetCenteredText(class'UIUtilities_Text'.static.AddFontInfo(CurrentAction.GetDisplayName(), bIsIn3D, true));
	ActionDescription.text.SetCenteredText(class'UIUtilities_Text'.static.AddFontInfo(CurrentAction.GetNarrative(), bIsIn3D));

	ActionRewardText.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(CurrentAction.GetRewardDescriptionString(), bIsIn3D, true, true) $ "<br/>" $ // Short
		class'UIUtilities_Text'.static.AddFontInfo(CurrentAction.GetRewardDetailsString(), bIsIn3D) // Long
	);

	DurationLabel.SetText(CurrentAction.bStarted ? class'UICovertActions'.default.CovertActions_TimeRemaining : class'UICovertActions'.default.CovertActions_Duration);
	DurationValue.SetText(class'UIUtilities_Text'.static.AlignRight(CurrentAction.GetDurationString()));

	UpdateSlots();
	UpdateRisks();
}

simulated protected function UpdateSlots()
{
	local UICovertActionsGeoscape_SlotInfo SlotInfo;
	local UICovertActionsGeoscape_SlotRow Row;
	local UICovertActionsGeoscape_Slot SlotUI;
	local int iCurrentSlot, iCurrentRow;
	local int TotalNeededRows;

	TotalNeededRows = FCeil(CurrentSlots.Length / float(ACTION_SLOTS_PER_ROW));

	// Show/Spawn rows we need
	for (iCurrentRow = 0; iCurrentRow < TotalNeededRows; iCurrentRow++)
	{
		if (iCurrentRow == ActionSlotRows.GetItemCount())
		{
			Row = Spawn(class'UICovertActionsGeoscape_SlotRow', ActionSlotRows.ItemContainer);
			Row.NumSlots = ACTION_SLOTS_PER_ROW;
			Row.InitRow();
			Row.SetWidth(ActionSlotRows.Width);
			Row.CreateSlots();
		}

		ActionSlotRows.GetItem(iCurrentRow).Show();
	}

	// Hide extra rows
	for (iCurrentRow = TotalNeededRows; iCurrentRow < ActionSlotRows.GetItemCount(); iCurrentRow++)
	{
		ActionSlotRows.GetItem(iCurrentRow).Hide();
	}

	// Update used slots with curent info
	foreach CurrentSlots(SlotInfo, iCurrentSlot)
	{
		Row = UICovertActionsGeoscape_SlotRow(ActionSlotRows.GetItem(iCurrentSlot / ACTION_SLOTS_PER_ROW));
		SlotUI = Row.Slots[iCurrentSlot % ACTION_SLOTS_PER_ROW];
		
		SlotUI.UpdateFromInfo(SlotInfo);
		SlotUI.Show();
	}

	// Hide unused slots in current row
	for (iCurrentSlot = (iCurrentSlot % ACTION_SLOTS_PER_ROW) + 1; iCurrentSlot < Row.Slots.Length; iCurrentSlot++)
	{
		Row.Slots[iCurrentSlot].Hide();
	}
}

simulated protected function PrepareSlotsInfo()
{
	local XComGameState_CovertAction CurrentAction;
	local UICovertActionsGeoscape_SlotInfo SlotInfo;

	local CovertActionStaffSlot StaffSlot;
	local CovertActionCostSlot CostSlot;

	CurrentAction = GetAction();
	CurrentSlots.Length = 0;

	foreach CurrentAction.StaffSlots(StaffSlot)
	{
		if (
			CurrentAction.bStarted &&
			XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(StaffSlot.StaffSlotRef.ObjectID)).IsSlotEmpty()
		)
		{
			// Do not show empty slots on already deployed ops
			continue;
		}

		SlotInfo = new class'UICovertActionsGeoscape_SlotInfo';
		SlotInfo.ShowPrefix = !CurrentAction.bStarted;
		SlotInfo.ColorDescription = !CurrentAction.bStarted;
		SlotInfo.SetStaffSlot(StaffSlot);

		CurrentSlots.AddItem(SlotInfo);
	}

	foreach CurrentAction.CostSlots(CostSlot)
	{
		if (CurrentAction.bStarted && !CostSlot.bPurchased)
		{
			// Do not show empty slots on already deployed ops
			continue;
		}

		SlotInfo = new class'UICovertActionsGeoscape_SlotInfo';
		SlotInfo.ShowPrefix = !CurrentAction.bStarted;
		SlotInfo.ColorDescription = !CurrentAction.bStarted;
		SlotInfo.SetCostSlot(CostSlot);

		CurrentSlots.AddItem(SlotInfo);
	}
}

simulated protected function UpdateRisks()
{
	local XComGameState_CovertAction CurrentAction;
	local array<string> RiskStrings;
	local string strRisks;
	local int idx;
	
	CurrentAction = GetAction();
	RiskStrings = class'UIUtilities_Infiltration'.static.GetRisksStringsFor(CurrentAction);

	for (idx = 0; idx < RiskStrings.Length; idx++)
	{
		strRisks $= "<p>" $ class'UIUtilities_Text'.static.AddFontInfo(RiskStrings[idx], bIsIn3D) $ "</p>";
	}

	ActionRisksText.SetHtmlText(strRisks);
	ActionRisksContainer.SetVisible(RiskStrings.Length > 0);
}

simulated protected function UpdateProgressBar()
{
	local XComGameState_CovertAction CurrentAction;
	local float TotalDuration, RemainingDuration;

	CurrentAction = GetAction();

	if (CurrentAction.bStarted)
	{
		TotalDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(CurrentAction.EndDateTime, CurrentAction.StartDateTime);
		RemainingDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(CurrentAction.EndDateTime, CurrentAction.GetCurrentTime());

		ActionProgressBar.Show();
		ActionProgressBar.SetPercent(1 - RemainingDuration / TotalDuration);
	}
	else
	{
		ActionProgressBar.Hide();
	}
}

//////////////////////////////////////
/// Interaction with other screens ///
//////////////////////////////////////

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	
	// Came back from UISquadSelect or the confirmation alert
	MakeMapProperlyShow();
	FocusCameraOnCurrentAction(true);
	
	if (bConfirmScreenWasOpened)
	{
		// The covert op was launched
		if (GetAction().bStarted)
		{
			`XSTRATEGYSOUNDMGR.PlayGeoscapeMusic(); // Otherwise SS music doesn't stop after confirmation
			SSManager = none;
			UpdateList();
		} 
		else
		{
			// Go back to loadout. If the player wants to back out of loadout, then he just press back twice
			// Note that we need to kick units from action, otherwise they will be considered busy and kicked from squad (which will actually kick them from the action)
			// This way they will get re-added as soon as the UISS screen initializes
			ClearUnitsFromAction();
			UndoCovertActionModifiers();
			OpenLoadoutForCurrentAction(true);
		}

		bConfirmScreenWasOpened = false;
	}
	else
	{
		ClearUnitsFromAction();
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

simulated function OpenLoadoutForCurrentAction(optional bool SkipIntro = false)
{
	// The player might have spent the resources since "allocating" them for cost slots, so make sure that the allocation status is removed
	ClearUnaffordableCostSlots();

	SSManager = new class'UISSManager_CovertAction';
	SSManager.CovertOpsScreen = self;
	SSManager.SkipIntro = SkipIntro;
	SSManager.OpenSquadSelect();
}

simulated function MakeMapProperlyShow()
{
	GetHQPres().GetCamera().ForceEarthViewImmediately(false);
}

//////////////////////////////
/// Gamestate manipulation ///
//////////////////////////////

simulated function ClearUnitsFromAction()
{
	local XComGameState_StaffSlot StaffSlot;
	local CovertActionStaffSlot CovertActionSlot;

	foreach GetAction().StaffSlots(CovertActionSlot)
	{
		StaffSlot = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(CovertActionSlot.StaffSlotRef.ObjectID));
		StaffSlot.EmptySlot(); // This is noop if the slot is empty
	}
}

simulated protected function UndoCovertActionModifiers()
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_CovertAction CovertAction;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Undo covert action modifiers");

	CovertAction = GetAction();
	CovertAction = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', CovertAction.ObjectID));

	UndoDeterrenceModifier(XComHQ, CovertAction);
	UndoInfiltrationModifier(XComHQ, CovertAction);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

simulated protected function UndoDeterrenceModifier(XComGameState_HeadquartersXCom XComHQ, XComGameState_CovertAction CovertAction)
{
	local int SquadDeterrence, idx;

	SquadDeterrence = class'X2Helper_Infiltration'.static.GetSquadDeterrence(XComHQ.Squad);

	`log("Removing SquadDeterrence: " @ SquadDeterrence @ " from CA risks",, 'CI');
	for (idx = 0; idx < CovertAction.Risks.Length; idx++)
	{
		CovertAction.Risks[idx].ChanceToOccurModifier += SquadDeterrence;
		`log("Risk modifier for" @ CovertAction.Risks[idx].RiskTemplateName @ "is" @ CovertAction.Risks[idx].ChanceToOccurModifier,, 'CI');
	}
}

simulated protected function UndoInfiltrationModifier(XComGameState_HeadquartersXCom XComHQ, XComGameState_CovertAction CovertAction)
{
	local int SquadDuration;

	SquadDuration = class'X2Helper_Infiltration'.static.GetSquadInfiltration(XComHQ.Squad);
	
	`log("Removing SquadInfiltration:" @ SquadDuration @ "from duration:" @ CovertAction.HoursToComplete);
	CovertAction.HoursToComplete -= SquadDuration;
	`log("Covert action total duration is now:" @ CovertAction.HoursToComplete @ "hours");
}

simulated function ClearUnaffordableCostSlots()
{
	local XComGameState_CovertAction CurrentAction;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XcomHQ;
	local array<StrategyCostScalar> CostScalars;
	local bool Dirty;
	local int i;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Clear purchased but no longer affordable cost slots");
	CurrentAction = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionRef.ObjectID));
	XcomHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	CostScalars.Length = 0; // Avoid compiler warning

	for (i = 0; i < CurrentAction.CostSlots.Length; i++)
	{
		if (CurrentAction.CostSlots[i].bPurchased && !XcomHQ.CanAffordAllStrategyCosts(CurrentAction.CostSlots[i].Cost, CostScalars))
		{
			CurrentAction.CostSlots[i].bPurchased = false;
			Dirty = true;
		}
	}

	if (Dirty)
	{
		CurrentAction.UpdateNegatedRisks(NewGameState);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
	}
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
	case class'UIUtilities_Input'.static.GetAdvanceButtonInputCode():
	case class'UIUtilities_Input'.const.FXS_KEY_ENTER:
	case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
		if (CanOpenLoadout())
		{
			ConfirmButton.OnClickedDelegate(ConfirmButton);
		}
		else
		{
			class'UIUtilities_Sound'.static.PlayNegativeSound();
		}
		return true;

	case class'UIUtilities_Input'.static.GetBackButtonInputCode():
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

	GetHQPres().CAMRestoreSavedLocation();
	GetHQPres().StrategyMap2D.ShowCursor();
	OnRemoveRestoreResistanceNetwork();

	class'UIUtilities_Sound'.static.PlayCloseSound();
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