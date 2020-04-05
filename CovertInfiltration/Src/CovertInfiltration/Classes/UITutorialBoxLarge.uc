class UITutorialBoxLarge extends UIScreen;

var UIPanel MainContainer;
var UIBGBox MainContainerBG;

var UIText HeaderText;
var UIDags DagsRight;
var UIPanel HeaderSeparator;

var UITextContainer MainText;

const MARGIN_LEFT_RIGHT = 20;
const MARGIN_TOP_BOTTOM = 10;

/////////////
/// Setup ///
/////////////

simulated function InitScreen (XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	// For some reason this is config
	bPlayAnimateInDistortion = true;

	super.InitScreen(InitController, InitMovie, InitName);

	BuildScreen();
	UpdateNavHelp();

	SetContents("Muh Title", "ASDASDASDASD ADASDasd asdasdasdasdasfdwdgsdger234ty");
}

simulated protected function BuildScreen ()
{
	MainContainer = Spawn(class'UIPanel', self);
	MainContainer.bAnimateOnInit = false;
	MainContainer.InitPanel('MainContainer');
	MainContainer.SetPosition(460, 300);
	MainContainer.SetSize(1000, 560);

	MainContainerBG = Spawn(class'UIBGBox', MainContainer);
	MainContainerBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	MainContainerBG.bAnimateOnInit = false;
	MainContainerBG.AddOnInitDelegate(OnMainContainerBGInit);
	MainContainerBG.InitBG('MainContainerBG');
	MainContainerBG.SetSize(1000, 560);

	// Dags' x is calculated when the header is realized
	DagsRight = Spawn(class'UIDags', MainContainer);
	DagsRight.bAnimateOnInit = false;
	DagsRight.InitPanel('DagsRight');
	DagsRight.SetColor(class'UIUtilities_Colors'.const.WARNING_HTML_COLOR);
	DagsRight.SetAlpha(40);
	DagsRight.SetY(32);

	HeaderText = Spawn(class'UIText', MainContainer);
	HeaderText.bAnimateOnInit = false;
	HeaderText.OnTextSizeRealized = OnHeaderTextRealized;
	HeaderText.InitText('HeaderText');
	HeaderText.SetPosition(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM);

	// Slightly modified version of class'UIUtilities_Controls'.static.CreateDividerLineBeneathControl
	HeaderSeparator = Spawn(class'UIPanel', MainContainer);
	HeaderSeparator.bAnimateOnInit = false;
	HeaderSeparator.InitPanel('HeaderSeparator', class'UIUtilities_Controls'.const.MC_GenericPixel);
	HeaderSeparator.SetPosition(MARGIN_LEFT_RIGHT, HeaderText.Y + HeaderText.height + 10); 
	HeaderSeparator.SetSize(MainContainer.Width - MARGIN_LEFT_RIGHT * 2, 2);
	HeaderSeparator.SetColor(class'UIUtilities_Colors'.const.WARNING_HTML_COLOR);
	HeaderSeparator.SetAlpha(30);

	MainText = Spawn(class'UITextContainer', MainContainer);
	MainText.bAnimateOnInit = false;
	MainText.InitTextContainer('MainText');
	MainText.SetPosition(HeaderSeparator.X, HeaderSeparator.Y + HeaderSeparator.Height);
	MainText.SetSize(HeaderSeparator.Width, MainContainer.Height - MainText.Y - MARGIN_TOP_BOTTOM);
}

simulated protected function OnHeaderTextRealized ()
{
	DagsRight.SetX(HeaderText.X + HeaderText.Width + 10);
	DagsRight.SetWidth(MainContainer.Width - MARGIN_LEFT_RIGHT - DagsRight.X);
}

simulated protected function OnMainContainerBGInit (UIPanel Panel)
{
	AS_SetMCColor(MainContainerBG.MCPath $ ".topLines", class'UIUtilities_Colors'.const.WARNING_HTML_COLOR);
	AS_SetMCColor(MainContainerBG.MCPath $ ".bottomLines", class'UIUtilities_Colors'.const.WARNING_HTML_COLOR);
}

simulated function OnInit()
{
	super.OnInit();

	// TODO: This doesn't work (probably because we are not in tactical)
	`SOUNDMGR.PlaySoundEvent("TacticalUI_Tutorial_Popup");
}

simulated function UpdateNavHelp ()
{
	local UINavigationHelp NavHelp;

	NavHelp = XComHQPresentationLayer(Movie.Pres).m_kAvengerHUD.NavHelp;
	NavHelp.ClearButtonHelp();
	NavHelp.AddContinueButton(CloseScreen);
}

//////////////////////////
/// Setting the values ///
//////////////////////////

simulated function SetContents (string strHeader, string strBody)
{
	strHeader = class'UIUtilities_Text'.static.GetColoredText(strHeader, eUIState_Warning);
	strHeader = class'UIUtilities_Text'.static.AddFontInfo(strHeader, bIsIn3D, true);
	HeaderText.SetHtmlText(strHeader);

	MainText.SetText(strBody);
}

//////////////
/// Events ///
//////////////

simulated function OnReceiveFocus ()
{
	super.OnReceiveFocus();

	UpdateNavHelp();
}

simulated function bool OnUnrealCommand (int cmd, int arg)
{
	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return true;

	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
		case class'UIUtilities_Input'.const.FXS_BUTTON_A:
		case class'UIUtilities_Input'.const.FXS_KEY_ENTER:
		case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
			CloseScreen();
			return true;
	}

	return super.OnUnrealCommand(cmd, arg);
}

/////////////////
/// Animation ///
/////////////////

simulated function AnimateIn (optional float Delay = 0.0)
{
	//super.AnimateIn(Delay);
	// No need to call parent (especially not UIPanel) - we do everything manually

	// Step 1 - UI distorsion (copy paste from UIScreen)
	if (bPlayAnimateInDistortion && !PC.IsPaused())
	{
		if (Delay > 0.0) SetTimer(Delay, false, nameof(BeginAnimateInDistortion));
		else BeginAnimateInDistortion();
	}

	// Step 2 - Hide everything apart from BG - we will be unhiding them as they begin animating in
	HideWithDelay(HeaderText, Delay);
	HideWithDelay(DagsRight, Delay);
	HideWithDelay(HeaderSeparator, Delay);
	HideWithDelay(MainText, Delay);

	// Step 3 - vertically expand the BG
	MainContainerBG.AddTweenBetween("_y", MainContainerBG.Y + MainContainerBG.Height / 2, MainContainerBG.Y, 0.20, Delay, "easeoutquad");
	MainContainerBG.AddTweenBetween("_height", 1, MainContainerBG.Height, 0.20, Delay, "easeoutquad");
	Delay += 0.20;

	// Step 4 - once BG is complete, start showing the header
	ShowWithDelay(HeaderText, Delay);
	HeaderText.AddTweenBetween("_alpha", 0, HeaderText.Alpha, 0.25, Delay, "easeoutquad");
	HeaderText.AddTweenBetween("_x", HeaderText.X - 10, HeaderText.X, 0.25, Delay, "easeoutquad");
	Delay += 0.125;

	// Step 5 - halfway through the header animation, start showing the dags
	// Note that we can't touch dags's x as we might waiting on the header text to realize
	ShowWithDelay(DagsRight, Delay);
	DagsRight.AddTweenBetween("_alpha", 0, DagsRight.Alpha, 0.25, Delay, "easeoutquad");
	Delay += 0.125;

	// Step 6 - halfway through the dags animation, start showing the separator (the header animation should be completed exactly now)
	ShowWithDelay(HeaderSeparator, Delay);
	HeaderSeparator.AddTweenBetween("_alpha", 0, HeaderSeparator.Alpha, 0.25, Delay, "easeoutquad");
	HeaderSeparator.AddTweenBetween("_y", HeaderSeparator.Y + 5, HeaderSeparator.Y, 0.25, Delay, "easeoutquad");
	Delay += 0.125;

	// Step 7 - halfway through the separator animation, start showing the text (the dags animation should be completed exactly now)
	ShowWithDelay(MainText, Delay);
	MainText.AddTweenBetween("_alpha", 0, MainText.Alpha, 0.25, Delay, "easeoutquad");
	MainText.AddTweenBetween("_y", MainText.Y + 5, MainText.Y, 0.25, Delay, "easeoutquad");

	// We are done. HUZZAH
}

static protected function ShowWithDelay (UIPanel Panel, float Delay)
{
	if (Delay > 0.0) Panel.SetTimer(Delay, false, nameof(Show), Panel);
	else Panel.Show();
}

static protected function HideWithDelay (UIPanel Panel, float Delay)
{
	if (Delay > 0.0) Panel.SetTimer(Delay, false, nameof(Hide), Panel);
	else Panel.Hide();
}

defaultproperties
{
	InputState = eInputState_Consume;
	bConsumeMouseEvents = true;

	bAnimateOnInit = true;
}
