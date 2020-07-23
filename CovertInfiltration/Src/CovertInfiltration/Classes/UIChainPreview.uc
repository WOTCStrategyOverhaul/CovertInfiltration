// Note about the positioning: UE3 requires all textures to be power of 2, including the UI ones.
// So, in order to avoid resizing (and losing quality), the textures are padded to closest
// pow2 size with transparency. This works as long as the code doesn't call UIImage::SetSize
// as that will resize including the extra transparency.
// A side effect of the above is that the Width and Height properties on images are bogus
// and ****can not be used for layouting****. If you need a reference, check the UI mockups

class UIChainPreview extends UIPanel;

////////////////////
/// UI tree vars ///
////////////////////

var protectedwrite UIPanel CenterSection;
var protectedwrite UIImage CenterBacklight;

var protectedwrite UIPanel ChainNameContentContainer;
var protectedwrite UIText ChainNameText;
var protectedwrite UIButton OverviewScreenButton;
var protectedwrite UIImage OverviewScreenControllerIcon;

var protectedwrite UIPanel ChainNameDagsLeftContainer; // Actual position
var protectedwrite UIImage ChainNameDagsLeft; // Sliding animation

var protectedwrite UIPanel ChainNameDagsRightContainer; // Actual position
var protectedwrite UIImage ChainNameDagsRight; // Sliding animation

// We support at most 3 now, any more we simply show the counts.
// For sake of simplicity, all 3 are pre-created (and not created on-demand)
var protectedwrite UIChainPreview_Stage Stages[3];
var protectedwrite UIText LeftExtraCountText;
var protectedwrite UIText RightExtraCountText;

var protectedwrite UIPanel ComplicationsSection;
var protectedwrite UIImage ComplicationsBacklight;
var protectedwrite UIText ComplicationsFluffHeader;
var protectedwrite UIImage ComplicationsWarnIcon;
var protectedwrite UIText ComplicationsFluffDescription;
var protectedwrite UIScrollingText ComplicationsNamesText;

/////////////////////
/// UI param vars ///
/////////////////////

var string strControllerIcon;
var int ControllerIconWidthToHeight;

var int iControllerButton;

var protected bool bRegisteredInputHandler;

//////////////////
/// State vars ///
//////////////////

var protectedwrite StateObjectReference FocusedActivityRef;
var bool bRestoreCamEarthViewOnOverviewClose;

////////////////
/// Loc vars ///
////////////////

var localized string strSingleComplicationFluff;
var localized string strMultipleComplicationsFluff;

////////////////////////
/// Layout constants ///
////////////////////////

const ChainNameSectionDagsWidth = 83;
const ChainNameSectionPreButtonSpacing = 10;
const ChainNameSectionButtonWidth = 23;
const ChainNameSectionPreIconSpacing = 7;
const ChainNameSectionMargin = 5;

////////////
/// Init ///
////////////

simulated function InitChainPreview (optional name InitName)
{
	InitPanel(InitName);
	AnchorTopCenter();

	BuildCenter();
	BuildComplications();
}

simulated protected function BuildCenter ()
{
	CenterSection = Spawn(class'UIPanel', self);
	CenterSection.bAnimateOnInit = false;
	CenterSection.InitPanel('CenterSection');
	CenterSection.SetPosition(-543, 0);

	CenterBacklight = Spawn(class'UIImage', CenterSection);
	CenterBacklight.bAnimateOnInit = false;
	CenterBacklight.InitImage('CenterBacklight', "img:///UILibrary_CI_ChainPreview.chains_main_highlight");
	CenterBacklight.SetPosition(178, 0);
	CenterBacklight.SetAlpha(20);

	ChainNameContentContainer = Spawn(class'UIPanel', CenterSection);
	ChainNameContentContainer.bAnimateOnInit = false;
	ChainNameContentContainer.InitPanel('ChainNameContentContainer');

	ChainNameText = Spawn(class'UIText', ChainNameContentContainer);
	ChainNameText.bAnimateOnInit = false;
	ChainNameText.OnTextSizeRealized = OnChainNameRealized;
	ChainNameText.InitText('ChainNameText');
	ChainNameText.SetY(11);

	OverviewScreenButton = Spawn(class'UIButton', ChainNameContentContainer);
	OverviewScreenButton.bAnimateOnInit = false;
	OverviewScreenButton.LibID = 'X2InfoButton';
	OverviewScreenButton.InitButton('OverviewScreenButton');
	OverviewScreenButton.OnClickedDelegate = OnOverviewScreenButtonClicked;
	OverviewScreenButton.SetY(16);

	OverviewScreenControllerIcon = Spawn(class'UIImage', ChainNameContentContainer);
	OverviewScreenControllerIcon.bAnimateOnInit = false;
	OverviewScreenControllerIcon.InitImage('OverviewScreenControllerIcon', "img:///gfxGamepadIcons." $ class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ strControllerIcon);
	OverviewScreenControllerIcon.SetPosition(OverviewScreenButton.X + 30, OverviewScreenButton.Y + 1);
	OverviewScreenControllerIcon.SetHeight(25); // 2px smaller than the OverviewScreenButton
	OverviewScreenControllerIcon.SetWidth(OverviewScreenControllerIcon.Height * ControllerIconWidthToHeight);

	ChainNameDagsLeftContainer = Spawn(class'UIPanel', CenterSection);
	ChainNameDagsLeftContainer.bAnimateOnInit = false;
	ChainNameDagsLeftContainer.InitPanel('ChainNameDagsLeftContainer');
	ChainNameDagsLeftContainer.SetY(20);

	ChainNameDagsLeft = Spawn(class'UIImage', ChainNameDagsLeftContainer);
	ChainNameDagsLeft.bAnimateOnInit = false;
	ChainNameDagsLeft.InitImage('ChainNameDagsLeft', "img:///UILibrary_CI_ChainPreview.ChainName_dags_l");

	ChainNameDagsRightContainer = Spawn(class'UIPanel', CenterSection);
	ChainNameDagsRightContainer.bAnimateOnInit = false;
	ChainNameDagsRightContainer.InitPanel('ChainNameDagsRightContainer');
	ChainNameDagsRightContainer.SetY(20);

	ChainNameDagsRight = Spawn(class'UIImage', ChainNameDagsRightContainer);
	ChainNameDagsRight.bAnimateOnInit = false;
	ChainNameDagsRight.InitImage('ChainNameDagsRight', "img:///UILibrary_CI_ChainPreview.ChainName_dags_r");

	LeftExtraCountText = Spawn(class'UIText', CenterSection);
	LeftExtraCountText.bAnimateOnInit = false;
	LeftExtraCountText.InitText('LeftExtraCountText');
	LeftExtraCountText.SetPosition(168.5, 48);

	RightExtraCountText = Spawn(class'UIText', CenterSection);
	RightExtraCountText.bAnimateOnInit = false;
	RightExtraCountText.InitText('RightExtraCountText');
	RightExtraCountText.SetPosition(899.5, 48);

	Stages[0] = Spawn(class'UIChainPreview_Stage', CenterSection);
	Stages[0].InitChainStage('ChainStage0', false, true);
	Stages[0].SetPosition(207, 41);

	Stages[1] = Spawn(class'UIChainPreview_Stage', CenterSection);
	Stages[1].InitChainStage('ChainStage1', true, true);
	Stages[1].SetPosition(434, 41);

	Stages[2] = Spawn(class'UIChainPreview_Stage', CenterSection);
	Stages[2].InitChainStage('ChainStage2', true, false);
	Stages[2].SetPosition(661, 41);
}

simulated protected function OnChainNameRealized ()
{
	local float RequiredSpace;

	// Text + button
	RequiredSpace = ChainNameText.Width + ChainNameSectionPreButtonSpacing + ChainNameSectionButtonWidth;

	// Add the controller hint icon
	if (OverviewScreenControllerIcon != none)
	{
		RequiredSpace += ChainNameSectionPreIconSpacing + OverviewScreenControllerIcon.Width;
	}

	// Position text
	ChainNameText.SetX(-CenterSection.X - RequiredSpace / 2);

	// Position button
	OverviewScreenButton.SetX(ChainNameText.X + ChainNameText.Width + ChainNameSectionPreButtonSpacing);

	// Position controller hint icon
	if (OverviewScreenControllerIcon != none)
	{
		OverviewScreenControllerIcon.SetX(OverviewScreenButton.X + ChainNameSectionButtonWidth + ChainNameSectionPreIconSpacing);
	}

	// Position the dags
	ChainNameDagsLeftContainer.SetX(ChainNameText.X - ChainNameSectionDagsWidth - ChainNameSectionMargin);
	ChainNameDagsRightContainer.SetX(ChainNameText.X + RequiredSpace + ChainNameSectionMargin);

	// Force everything we touched to update this frame
	ChainNameText.MC.ProcessCommands(true);
	if (ChainNameDagsLeft.bIsInited) ChainNameDagsLeft.MC.ProcessCommands(true);
	if (ChainNameDagsRightContainer.bIsInited) ChainNameDagsRightContainer.MC.ProcessCommands(true);
	if (OverviewScreenControllerIcon != none && OverviewScreenControllerIcon.bIsInited) OverviewScreenControllerIcon.MC.ProcessCommands(true);
}

simulated protected function OnOverviewScreenButtonClicked (UIButton Button)
{
	OpenOverview();
}

simulated protected function BuildComplications ()
{
	ComplicationsSection = Spawn(class'UIPanel', self);
	ComplicationsSection.bAnimateOnInit = false;
	ComplicationsSection.InitPanel('ComplicationsSection');
	ComplicationsSection.SetPosition(-843, 17);

	ComplicationsBacklight = Spawn(class'UIImage', ComplicationsSection);
	ComplicationsBacklight.bAnimateOnInit = false;
	ComplicationsBacklight.InitImage('ComplicationsBacklight', "img:///UILibrary_CI_ChainPreview.complication_highlight");
	ComplicationsBacklight.SetPosition(-201, -17);
	ComplicationsBacklight.SetAlpha(40);

	ComplicationsFluffHeader = Spawn(class'UIText', ComplicationsSection);
	ComplicationsFluffHeader.bAnimateOnInit = false;
	ComplicationsFluffHeader.InitText('ComplicationsFluffHeader');
	ComplicationsFluffHeader.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(class'UIUtilities_Text'.static.GetColoredText(class'UIMission'.default.m_strChosenWarning2, eUIState_Bad), Screen.bIsIn3D, true,, 18)
	);
	ComplicationsFluffHeader.SetPosition(0, 0);

	ComplicationsWarnIcon = Spawn(class'UIImage', ComplicationsSection);
	ComplicationsWarnIcon.bAnimateOnInit = false;
	ComplicationsWarnIcon.InitImage('ComplicationsWarnIcon', "img:///UILibrary_CI_ChainPreview.warning_icon");
	ComplicationsWarnIcon.SetPosition(83, 2); // TODO: Different lang size of ComplicationsFluffHeader

	ComplicationsFluffDescription = Spawn(class'UIText', ComplicationsSection);
	ComplicationsFluffDescription.bAnimateOnInit = false;
	ComplicationsFluffDescription.InitText('ComplicationsFluffDescription');
	ComplicationsFluffDescription.SetPosition(112, 0);

	ComplicationsNamesText = Spawn(class'UIScrollingText', ComplicationsSection);
	ComplicationsNamesText.bAnimateOnInit = false;
	ComplicationsNamesText.InitScrollingText('ComplicationsNamesText');
	ComplicationsNamesText.SetPosition(0, 28);
	ComplicationsNamesText.SetWidth(330);
}

////////////////////////
/// Controller input ///
////////////////////////

simulated function RegisterInputHandler ()
{
	if (bRegisteredInputHandler) return;

	Screen.Movie.Stack.SubscribeToOnInputForScreen(Screen, OnScreenInput);
	bRegisteredInputHandler = true;
}

simulated function UnregisterInputHandler ()
{
	if (!bRegisteredInputHandler) return;

	Screen.Movie.Stack.UnsubscribeFromOnInputForScreen(Screen, OnScreenInput);
	bRegisteredInputHandler = false;
}

simulated protected function bool OnScreenInput (UIScreen InputScreen, int iInput, int ActionMask)
{
	if (!CheckInputIsReleaseOrDirectionRepeat(iInput, ActionMask))
	{
		return false;
	}

	switch (iInput)
	{
		case iControllerButton:
			if (bIsVisible && GetFocusedActivity() != none)
			{
				OpenOverview();
				return true;
			}
		break;
	}

	return false;
}

//////////////////////////
/// Player interaction ///
//////////////////////////

simulated function OpenOverview ()
{
	class'UIUtilities_Infiltration'.static.UIChainsOverview(GetFocusedActivity().ChainRef, bRestoreCamEarthViewOnOverviewClose);
}

////////////////
/// Updating ///
////////////////

function SetFocusedActivity (StateObjectReference InFocusedActivityRef)
{
	FocusedActivityRef = InFocusedActivityRef;

	if (FocusedActivityRef.ObjectID != 0 && GetFocusedActivity() == none)
	{
		`RedScreen("UIChainPreview::SetFocusedActivity - bad ref passed. Setting to 0 (preview will be hidden)");
		`RedScreen(GetScriptTrace());

		FocusedActivityRef.ObjectID = 0;
	}

	UpdateStages();
	UpdateComplications();

	ChainNameText.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(
			class'UIUtilities_Infiltration'.static.ColourText(
				GetFocusedActivity().GetActivityChain().GetOverviewTitle(),
				"90BDBD"
			),
			Screen.bIsIn3D, false,, 28
		)
	);

	// TODO: Halt all ongoing animations
}

protected function UpdateStages ()
{
	local int FocusedStageIndex, LeftExtraCount, RightExtraCount;
	local XComGameState_Activity FocusedActivityState;
	local XComGameState_ActivityChain ChainState;
	local string strLeftExtra, strRightExtra;

	FocusedActivityState = GetFocusedActivity();
	if (FocusedActivityState == none)
	{
		CenterSection.Hide();
		return;
	}

	FocusedStageIndex = FocusedActivityState.GetStageIndex();
	ChainState = FocusedActivityState.GetActivityChain();

	CenterSection.Show();

	// The following code handles with figuring out which slots to assign to which stages.
	// The general logic is to keep the focused (current) activity in the center, unless
	// it is the first or the last one and moving it to a side will allow us to show more
	// activities (instead of wasting a slot and using the extra indicators)

	if (ChainState.StageRefs.Length == 1)
	{
		LeftExtraCountText.Hide();
		RightExtraCountText.Hide();
		
		Stages[0].Hide();
		Stages[2].Hide();

		Stages[1].Show();
		Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(0));
	}
	else if (ChainState.StageRefs.Length == 2)
	{
		LeftExtraCountText.Hide();
		RightExtraCountText.Hide();

		if (FocusedStageIndex == 0)
		{
			Stages[0].Hide();

			Stages[1].Show();
			Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(0));

			Stages[2].Show();
			Stages[2].UpdateForActivity(ChainState.GetActivityAtIndex(1));
		}
		else
		{
			Stages[0].Show();
			Stages[0].UpdateForActivity(ChainState.GetActivityAtIndex(0));

			Stages[1].Show();
			Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(1));

			Stages[2].Hide();
		}
	}
	else if (ChainState.StageRefs.Length == 3)
	{
		LeftExtraCountText.Hide();
		RightExtraCountText.Hide();
		
		Stages[0].Show();
		Stages[0].UpdateForActivity(ChainState.GetActivityAtIndex(0));

		Stages[1].Show();
		Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(1));

		Stages[2].Show();
		Stages[2].UpdateForActivity(ChainState.GetActivityAtIndex(2));
	}
	else // 4 and more
	{
		// Is the current first?
		if (FocusedStageIndex == 0)
		{
			LeftExtraCount = 0;
			RightExtraCount = Max(0, ChainState.StageRefs.Length - 3);

			Stages[0].Show();
			Stages[0].UpdateForActivity(ChainState.GetActivityAtIndex(0));

			Stages[1].Show();
			Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(1));

			Stages[2].Show();
			Stages[2].UpdateForActivity(ChainState.GetActivityAtIndex(2));
		}
		
		// Is the current last?
		else if (FocusedStageIndex == ChainState.StageRefs.Length - 1)
		{
			LeftExtraCount = Max(0, ChainState.StageRefs.Length - 3);
			RightExtraCount = 0;

			Stages[0].Show();
			Stages[0].UpdateForActivity(ChainState.GetActivityAtIndex(ChainState.StageRefs.Length - 1 - 2));

			Stages[1].Show();
			Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(ChainState.StageRefs.Length - 1 - 1));

			Stages[2].Show();
			Stages[2].UpdateForActivity(ChainState.GetActivityAtIndex(ChainState.StageRefs.Length - 1 - 0));
		}

		// We are somewhere in the miss
		else
		{
			LeftExtraCount = Max(0, FocusedStageIndex - 1);
			RightExtraCount = Max(0, ChainState.StageRefs.Length - FocusedStageIndex - 2);

			Stages[0].Show();
			Stages[0].UpdateForActivity(ChainState.GetActivityAtIndex(FocusedStageIndex - 1));

			Stages[1].Show();
			Stages[1].UpdateForActivity(ChainState.GetActivityAtIndex(FocusedStageIndex));

			Stages[2].Show();
			Stages[2].UpdateForActivity(ChainState.GetActivityAtIndex(FocusedStageIndex + 1));
		}
		
		if (LeftExtraCount < 1) LeftExtraCountText.Hide();
		else
		{
			strLeftExtra = "+" $ LeftExtraCount;
			strLeftExtra = class'UIUtilities_Infiltration'.static.ColourText(strLeftExtra, "249182");
			strLeftExtra = class'UIUtilities_Text'.static.AddFontInfo(strLeftExtra, Screen.bIsIn3D, true,, 22);

			LeftExtraCountText.Show();
			LeftExtraCountText.SetHtmlText(strLeftExtra);
		}
		
		if (RightExtraCount < 1) RightExtraCountText.Hide();
		else
		{
			strRightExtra = "+" $ RightExtraCount;
			strRightExtra = class'UIUtilities_Infiltration'.static.ColourText(strRightExtra, "7A7A6E");
			strRightExtra = class'UIUtilities_Text'.static.AddFontInfo(strRightExtra, Screen.bIsIn3D, true,, 22);

			RightExtraCountText.Show();
			RightExtraCountText.SetHtmlText(strRightExtra);
		}
	}
}

protected function UpdateComplications ()
{
	local XComGameState_Complication ComplicationState;
	local XComGameState_Activity FocusedActivityState;
	local XComGameState_ActivityChain ChainState;
	local StateObjectReference ComplicationRef;
	local array<string> ComplicationsNames;
	local XComGameStateHistory Histroy;
	local string strComplications;
	local int i;

	FocusedActivityState = GetFocusedActivity();
	if (FocusedActivityState == none)
	{
		ComplicationsSection.Hide();
		return;
	}

	ChainState = FocusedActivityState.GetActivityChain();
	if (ChainState.ComplicationRefs.Length < 1) 
	{
		ComplicationsSection.Hide();
		return;
	}

	Histroy = `XCOMHISTORY;
	ComplicationsNames.Length = ChainState.ComplicationRefs.Length;
	
	foreach ChainState.ComplicationRefs(ComplicationRef, i)
	{
		ComplicationState = XComGameState_Complication(Histroy.GetGameStateForObjectID(ComplicationRef.ObjectID));
		ComplicationsNames[i] = ComplicationState.GetMyTemplate().FriendlyName;
	}

	ComplicationsFluffDescription.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(
			class'UIUtilities_Text'.static.GetColoredText(
				ComplicationsNames.Length == 1 ? strSingleComplicationFluff : strMultipleComplicationsFluff,
				eUIState_Bad
			),
			Screen.bIsIn3D, true,, 18
		)
	);

	JoinArray(ComplicationsNames, strComplications, ", ");
	ComplicationsNamesText.SetTitle(class'UIUtilities_Text'.static.GetColoredText(strComplications, eUIState_Bad));

	ComplicationsSection.Show();
}

/////////////////
/// Animation ///
/////////////////

simulated function AnimateIn (optional float InitialDelay = 0)
{
	local float StagesDelay, ComplicationsDelay, ComplicationsContentDelay, TitleDelay, DagsDelay;
	local array<UIChainPreview_Stage> LocalStages;
	local UIChainPreview_Stage Stage;
	
	StagesDelay = InitialDelay;
	
	// TODO: Extras

	// Can't iterate fixed arrays
	LocalStages.AddItem(Stages[0]);
	LocalStages.AddItem(Stages[1]);
	LocalStages.AddItem(Stages[2]);
	
	foreach LocalStages(Stage)
	{
		if (Stage.bIsVisible)
		{
			Stage.AnimateIn(StagesDelay);
			StagesDelay += 0.3;
		}
	}

	// The backlight takes same amount of time as the stages
	CenterBacklight.AddTweenBetween("_alpha", 0, CenterBacklight.Alpha, StagesDelay - InitialDelay, StagesDelay, "easeoutquad");

	// TODO: Complications after the chain name
	if (ComplicationsSection.bIsVisible)
	{
		ComplicationsDelay = StagesDelay + 0.2;
		TitleDelay = ComplicationsDelay + 0.3;
		
		ComplicationsBacklight.AddTweenBetween("_alpha", 0, ComplicationsBacklight.Alpha, 0.5, ComplicationsDelay, "easeOutBounce");

		ComplicationsContentDelay = ComplicationsDelay + 0.1;
		ComplicationsFluffHeader.AddTweenBetween("_alpha", 0, ComplicationsFluffHeader.Alpha, 0.5, ComplicationsContentDelay, "easeoutquad");
		ComplicationsWarnIcon.AddTweenBetween("_alpha", 0, ComplicationsWarnIcon.Alpha, 0.5, ComplicationsContentDelay, "easeoutquad");
		ComplicationsFluffDescription.AddTweenBetween("_alpha", 0, ComplicationsFluffDescription.Alpha, 0.5, ComplicationsContentDelay, "easeoutquad");
		ComplicationsNamesText.AddTweenBetween("_alpha", 0, ComplicationsNamesText.Alpha, 0.5, ComplicationsContentDelay, "easeoutquad");
	}
	else
	{
		TitleDelay = StagesDelay + 0.2;
	}

	ChainNameContentContainer.AddTweenBetween("_y", ChainNameContentContainer.Y - 30, ChainNameContentContainer.Y, 0.5, TitleDelay, "easeoutquad");

	ChainNameText.AddTweenBetween("_alpha", 0, ChainNameText.Alpha, 0.5, TitleDelay, "easeoutquad");
	OverviewScreenButton.AddTweenBetween("_alpha", 0, OverviewScreenButton.Alpha, 0.5, TitleDelay, "easeoutquad");

	if (OverviewScreenControllerIcon != none)
	{
		OverviewScreenControllerIcon.AddTweenBetween("_alpha", 0, OverviewScreenControllerIcon.Alpha, 0.5, TitleDelay, "easeoutquad");
	}

	DagsDelay = TitleDelay + 0.3;

	ChainNameDagsLeft.AddTweenBetween("_alpha", 0, ChainNameDagsLeft.Alpha, 0.5, DagsDelay, "easeoutquad");
	ChainNameDagsLeft.AddTweenBetween("_x", ChainNameDagsLeft.X + 60, ChainNameDagsLeft.X, 0.5, DagsDelay, "easeoutquad");

	ChainNameDagsRight.AddTweenBetween("_alpha", 0, ChainNameDagsRight.Alpha, 0.5, DagsDelay, "easeoutquad");
	ChainNameDagsRight.AddTweenBetween("_x", ChainNameDagsRight.X - 60, ChainNameDagsRight.X, 0.5, DagsDelay, "easeoutquad");
}

///////////////
/// Removal ///
///////////////

simulated event Removed ()
{
	UnregisterInputHandler();

	super.Removed();
}

///////////////
/// Helpers ///
///////////////

function XComGameState_Activity GetFocusedActivity ()
{
	return XComGameState_Activity(`XCOMHISTORY.GetGameStateForObjectID(FocusedActivityRef.ObjectID));
}

/////////////////////////
/// defaultproperties ///
/////////////////////////

defaultproperties
{
	bAnimateOnInit = false
	bIsNavigable = false

	strControllerIcon = "Icon_RT_R2" // Right trigger
	ControllerIconWidthToHeight = 2 // The icon is 1:2 height:width

	iControllerButton = 333 // FXS_BUTTON_RTRIGGER
}
