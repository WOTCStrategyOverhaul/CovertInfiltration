class UIInfiltrationDetails_Milestone extends UIVerticalListItemBase;

var UIScrollingText ActivateAtLabel;

var UIBGBox BGBar;
var UIBGBox FillBar;

var UIScrollingText NameLabel;
var UIScrollingText DescriptionLabel;

var UIText HiddenLabel;
// TODO: dags for Hidden 

//////////////////////
/// Initialization /// 
//////////////////////

simulated function InitMilestone ()
{
	InitListItemBase();

	ActivateAtLabel = Spawn(class'UIScrollingText', self);
	ActivateAtLabel.bAnimateOnInit = false;
	ActivateAtLabel.InitScrollingText('ActivateAtLabel', "123%");
	ActivateAtLabel.SetWidth(50);

	BGBar = Spawn(class'UIBGBox', self);
	BGBar.bAnimateOnInit = false;
	BGBar.InitBG('BGBar');
	BGBar.SetBGColor("cyan");
	BGBar.SetPosition(ActivateAtLabel.X + ActivateAtLabel.Width + 10, 0);
	BGBar.SetSize(20, Height);

	FillBar = Spawn(class'UIBGBox', self);
	FillBar.bAnimateOnInit = false;
	FillBar.InitBG('FillBar');
	FillBar.SetBGColor("cyan_highlight");
	FillBar.SetWidth(BGBar.Width);
	FillBar.SetX(BGBar.X);
	FillBar.Hide(); // Y/height is calculated when the progress is set

	NameLabel = Spawn(class'UIScrollingText', self);
	NameLabel.bAnimateOnInit = false;
	NameLabel.InitScrollingText('NameLabel', "SITREP 1");
	NameLabel.SetX(BGBar.X + BGBar.Width + 10);
	NameLabel.SetWidth(Width - NameLabel.X);

	DescriptionLabel = Spawn(class'UIScrollingText', self);
	DescriptionLabel.bAnimateOnInit = false;
	DescriptionLabel.InitScrollingText('DescriptionLabel', "Something awesome happens");
	DescriptionLabel.SetX(NameLabel.X);
	DescriptionLabel.SetWidth(NameLabel.Width);
	DescriptionLabel.SetY(NameLabel.Y + NameLabel.Height);

	HiddenLabel = Spawn(class'UIText', self);
	HiddenLabel.bAnimateOnInit = false;
	HiddenLabel.InitText('HiddenLabel');
	HiddenLabel.OnTextSizeRealized = OnHiddenLabelSizeRealized;
	HiddenLabel.SetText(class'UIUtilities_Text'.static.GetColoredText("HIDDEN", eUIState_Header)); // TODO: Localize
	HiddenLabel.SetY(DescriptionLabel.Y);
}

simulated protected function OnHiddenLabelSizeRealized ()
{
	HiddenLabel.SetX(DescriptionLabel.X + DescriptionLabel.Width - HiddenLabel.Width);
}

/////////////////////
/// Setting looks ///
/////////////////////

simulated function SetProgressInfo (int StartsAt, int EndsAt, int CurrentProgress)
{
	local int Duration, ProgressPercentPoints;

	ActivateAtLabel.SetText(EndsAt $ "%"); // TODO: Localize

	if (CurrentProgress < StartsAt)
	{
		FillBar.Hide();
	}
	else if (CurrentProgress > EndsAt)
	{
		FillBar.Show();
		FillBar.SetHeight(BGBar.Height);
		FillBar.SetY(BGBar.Y);
	}
	else
	{
		Duration = EndsAt - StartsAt;
		ProgressPercentPoints = CurrentProgress - StartsAt;

		FillBar.Show();
		FillBar.SetHeight(BGBar.Height * (float(ProgressPercentPoints) / float(Duration)));
		FillBar.SetY(BGBar.Y + (BGBar.Height - FillBar.Height));
	}
}

simulated function SetUnlocked (string strName, string strDescription)
{
	strName = class'UIUtilities_Text'.static.AddFontInfo(strName, Screen.bIsIn3D, true,, 24);
	NameLabel.SetHTMLText(strName);

	strDescription = class'UIUtilities_Text'.static.AddFontInfo(strDescription, Screen.bIsIn3D, false,, 18);
	strDescription = class'UIUtilities_Text'.static.GetColoredText(strDescription, eUIState_Good);
	DescriptionLabel.SetHTMLText(strDescription);
	DescriptionLabel.Show();

	HiddenLabel.Hide();
}

simulated function SetInProgress (string strName, string strDescription)
{
	strName = class'UIUtilities_Text'.static.AddFontInfo(strName, Screen.bIsIn3D, true,, 24);
	strName = class'UIUtilities_Infiltration'.static.ColourText(strName, "CCC4A3");
	NameLabel.SetHTMLText(strName);

	strDescription = class'UIUtilities_Text'.static.AddFontInfo(strDescription, Screen.bIsIn3D, false,, 18);
	strDescription = class'UIUtilities_Infiltration'.static.ColourText(strDescription, "8C8770");
	DescriptionLabel.SetHTMLText(strDescription);
	DescriptionLabel.Show();

	HiddenLabel.Hide();
}

simulated function SetLocked (string strName)
{
	strName = class'UIUtilities_Text'.static.AddFontInfo(strName, Screen.bIsIn3D, true,, 24);
	strName = class'UIUtilities_Text'.static.GetColoredText(strName, eUIState_Header);
	NameLabel.SetHTMLText(strName);

	DescriptionLabel.Hide();
	HiddenLabel.Show();
}

defaultproperties
{
	Height = 60

	bAnimateOnInit = false
}