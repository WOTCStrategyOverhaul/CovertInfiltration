class UIViewChainButton extends UIPanel;

var protectedwrite UIBGBox BG;
var protectedwrite UIBGBox InnerBG;
var protectedwrite UIText Label;

var string MainColourHex;
var StateObjectReference ChainRef;

var localized string strLabel;

delegate OnLayoutRealized();

const INNER_BG_PADDING = 2;
const LABEL_PADDING = 8;

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

	RealizeContent();
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

simulated protected function RealizeContent ()
{
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
	
	BG.SetWidth(Width);
	InnerBG.SetWidth(Width - INNER_BG_PADDING);

	if (OnLayoutRealized != none) OnLayoutRealized();
}

simulated function OnMouseEvent (int cmd, array<string> args)
{
	super.OnMouseEvent(cmd, args);

	if (cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP)
	{
		class'UIUtilities_Infiltration'.static.UIChainsOverview(ChainRef);
		OnLoseFocus();
	}
}

defaultproperties
{
	bIsNavigable = false
	bProcessesMouseEvents = true
	MainColourHex = "27aae1" // Blue science 
	Height = 60
}