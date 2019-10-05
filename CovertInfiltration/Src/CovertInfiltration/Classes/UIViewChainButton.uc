class UIViewChainButton extends UIPanel;

var protectedwrite UIBGBox BG;
var protectedwrite UIBGBox InnerBG;
var protectedwrite UIText Label;
var protectedwrite UIImage ControllerIcon;

var string MainColourHex;
var string strControllerIcon;

var StateObjectReference ChainRef;
var bool bRestoreCamEarthViewOnOverviewClose;

var localized string strLabel;

delegate OnLayoutRealized (UIViewChainButton Button);

const INNER_BG_PADDING = 2;
const LABEL_PADDING = 8;
const ICON_PADDING = 4;

simulated function InitViewChainButton (optional name InitName)
{
	InitPanel(InitName);

	BG = Spawn(class'UIBGBox', self);
	BG.bAnimateOnInit = false;
	BG.InitBG('BG');
	BG.SetHeight(Height);

	InnerBG = Spawn(class'UIBGBox', self);
	InnerBG.bAnimateOnInit = false;
	InnerBG.InitBG('InnerBG');
	InnerBG.SetPosition(INNER_BG_PADDING, INNER_BG_PADDING);
	InnerBG.SetHeight(Height - INNER_BG_PADDING * 2);

	Label = Spawn(class'UIText', self);
	Label.bAnimateOnInit = false;
	Label.OnTextSizeRealized = RealizeLayout;
	Label.InitText('Label');
	Label.SetPosition(InnerBG.X + LABEL_PADDING, 4);

	if (`ISCONTROLLERACTIVE)
	{
		ControllerIcon = Spawn(class'UIImage', self);
		ControllerIcon.InitImage('ControllerIcon', "img:///gfxGamepadIcons." $ class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ strControllerIcon);
		
		// The icon is 1:2 height:width. So the following code "allocates" a square for the image, but sizes properly
		ControllerIcon.SetWidth(InnerBG.Height - ICON_PADDING * 2);
		ControllerIcon.SetHeight(ControllerIcon.Height / 2);

		// Position it centered vertically
		ControllerIcon.SetY(InnerBG.Y + ICON_PADDING + (ControllerIcon.Width / 2 - ControllerIcon.Height / 2));
	}
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();

	RealizeContent();
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();

	RealizeContent();
}

simulated function RealizeContent ()
{
	MainColourHex = GetActivityChain().ComplicationRefs.Length > 0 ? "bf1e2e" /* Red */ : "27aae1" /* Blue science */ ;

	InnerBG.SetOutline(!bIsFocused, MainColourHex);
	Label.SetHtmlText(
		class'UIUtilities_Text'.static.AddFontInfo(
			class'UIUtilities_Infiltration'.static.ColourText(
				strLabel,
				bIsFocused ? class'UIUtilities_Colors'.const.BLACK_HTML_COLOR : MainColourHex
			),
			Screen.bIsIn3D,,, 40
		)
	);
}

simulated protected function RealizeLayout ()
{
	Width = Label.X + Label.Width + LABEL_PADDING + INNER_BG_PADDING;
	if (ControllerIcon != none) Width += ControllerIcon.Width + ICON_PADDING;

	BG.SetWidth(Width);
	InnerBG.SetWidth(Width - INNER_BG_PADDING);
	if (ControllerIcon != none) ControllerIcon.SetX(Label.X + Label.Width + LABEL_PADDING);

	if (OnLayoutRealized != none) OnLayoutRealized(self);
}

simulated function OnMouseEvent (int cmd, array<string> args)
{
	super.OnMouseEvent(cmd, args);

	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP)
	{
		OpenScreen();
		OnLoseFocus();
	}
}

// Public as it is called by controller input handlers
simulated function OpenScreen ()
{
	class'UIUtilities_Infiltration'.static.UIChainsOverview(ChainRef, bRestoreCamEarthViewOnOverviewClose);
}

function XComGameState_ActivityChain GetActivityChain ()
{
	return XComGameState_ActivityChain(`XCOMHISTORY.GetGameStateForObjectID(ChainRef.ObjectID));
}

defaultproperties
{
	bIsNavigable = false
	bProcessesMouseEvents = true
	Height = 60

	strControllerIcon = "Icon_RT_R2" // Right trigger
}