class UIChainsOverview_Activity extends UIPanel;

var UIBGBox BG;

var UIX2PanelHeader Header;
var UIText Description;

var UIBGBox StatusLineBG;
var UIScrollingText StatusLine;

const CONTENT_PADDING = 10;
var Vector2D ContentTopLeft;
var float ContentWidth;

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
	Description.InitText('Description');
	Description.SetPosition(ContentTopLeft.X, ContentTopLeft.Y + Header.Y);
	Description.SetHeaderWidth(ContentWidth);

	// TODO:
	// (1) status line
	// (2) description size realize + queue in the screen + flush commands queue after updating the activities
}

simulated function UpdateFromState (XComGameState_Activity ActivityState)
{
	local EUIState UIState;
}

defaultproperties
{
	bCascadeSelection = true;
}