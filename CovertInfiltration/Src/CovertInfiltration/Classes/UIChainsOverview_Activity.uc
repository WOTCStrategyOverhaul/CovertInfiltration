class UIChainsOverview_Activity extends UIPanel;

var UIBGBox BG;

var UIX2PanelHeader Header;
var UIText Description;

var UIBGBox StatusLineBG;
var UIScrollingText StatusLine;

const CONTENT_PADDING = 10;
var Vector2D ContentTopLeft;
var float ContentWidth;

var protectedwrite bool bSizeRealizePending;

// Non-native packages don't seem to support BoundEnum (or something, no idea) so we manually list the completion statuses
var localized string strCompletionStatusLabel_NotReached;
var localized string strCompletionStatusLabel_NotCompleted;
var localized string strCompletionStatusLabel_Expired;
var localized string strCompletionStatusLabel_Failure;
var localized string strCompletionStatusLabel_PartialSuccess;
var localized string strCompletionStatusLabel_Success;

simulated function InitActivity (optional name InitName)
{
	InitPanel(InitName);
	SetWidth(GetParent(class'UIList', true).Width);

	ContentTopLeft.X = CONTENT_PADDING;
	ContentTopLeft.Y = CONTENT_PADDING;
	ContentWidth = Width - CONTENT_PADDING * 2;

	BG = Spawn(class'UIBGBox', self);
	BG.InitBG('BG');
	BG.SetWidth(Width);
	
	Header = Spawn(class'UIX2PanelHeader', self);
	Header.bIsNavigable = false;
	Header.InitPanelHeader('Header');
	Header.SetPosition(ContentTopLeft.X, ContentTopLeft.Y);
	Header.SetHeaderWidth(ContentWidth);

	Description = Spawn(class'UIText', self);
	Description.OnTextSizeRealized = OnDesciptionSizeRealized;
	Description.InitText('Description');
	Description.SetPosition(ContentTopLeft.X, Header.Y + Header.Height);
	Description.SetWidth(ContentWidth);

	StatusLineBG = Spawn(class'UIBGBox', self);
	StatusLineBG.InitBG('StatusLineBG');
	StatusLineBG.SetSize(Width, 40);

	StatusLine = Spawn(class'UIScrollingText', self);
	StatusLine.InitScrollingText('StatusLine');
	StatusLine.SetX(CONTENT_PADDING);
	StatusLine.SetWidth(ContentWidth);
}

simulated function UpdateFromState (XComGameState_Activity ActivityState)
{
	local EUIState UIState;

	switch (ActivityState.CompletionStatus)
	{
		case eActivityCompletion_NotReached:
			UIState = eUIState_Disabled;
		break;

		case eActivityCompletion_NotCompleted:
			UIState = eUIState_Highlight;
		break;

		case eActivityCompletion_Expired:
			UIState = eUIState_Faded;
		break;

		case eActivityCompletion_Failure:
			UIState = eUIState_Bad;
		break;

		case eActivityCompletion_PartialSuccess:
			UIState = eUIState_Warning;
		break;

		case eActivityCompletion_Success:
			UIState = eUIState_Good;
		break;
	}

	BG.SetBGColorState(UIState);
	Header.SetColor(class'UIUtilities_Colors'.static.GetColorLabelFromState(UIState));
	StatusLineBG.SetBGColorState(UIState);
	StatusLineBG.SetHighlighed(true);

	Header.SetText(ActivityState.GetOverviewHeader());
	StatusLine.SetText(strCompletionStatusLabels[ActivityState.CompletionStatus]);
	Description.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(
			class'UIUtilities_Text'.static.GetColoredText(ActivityState.GetOverviewDescription(), UIState),
			Screen.bIsIn3D
		),, true // Disable lazy refresh, otherwise we get stuck on bSizeRealizePending
	);

	bSizeRealizePending = true;
}

simulated protected function OnDesciptionSizeRealized ()
{
	StatusLineBG.SetY(Description.Y + Description.Height + 5);
	StatusLine.SetY(StatusLineBG.Y + 2);

	SetHeight(StatusLineBG.Y + StatusLineBG.Height);
	BG.SetHeight(Height);

	bSizeRealizePending = false;
	UIChainsOverview(GetParent(class'UIChainsOverview', true)).OnActivitySizeRealized(self);
}

static function string GetLabelForCompletionStatus (EActivityCompletion eCompletion)
{
	switch (eCompletion)
	{
		case eActivityCompletion_NotReached:
			return default.strCompletionStatusLabel_NotReached;

		case eActivityCompletion_NotCompleted:
			return default.strCompletionStatusLabel_NotCompleted;

		case eActivityCompletion_Expired:
			return default.strCompletionStatusLabel_Expired;

		case eActivityCompletion_Failure:
			return default.strCompletionStatusLabel_Failure;

		case eActivityCompletion_PartialSuccess:
			return default.strCompletionStatusLabel_PartialSuccess;

		case eActivityCompletion_Success:
			return default.strCompletionStatusLabel_Success;
	}

	return "WRONG EActivityCompletion";
}

defaultproperties
{
	bCascadeSelection = true;
}