class UIInfiltrationDetails_Milestone extends UIVerticalListItemBase;

var UIScrollingText ActivateAtLabel;

var UIBGBox BGBar;
var UIBGBox FillBar;

var UIScrollingText NameLabel;
var UIScrollingText DescriptionLabel;

// TODO: UI for Hidden 

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
	BGBar.SetPosition(ActivateAtLabel.X + ActivateAtLabel.Width + 5, 0);
	BGBar.SetSize(20, Height);

	FillBar = Spawn(class'UIBGBox', self);
	FillBar.bAnimateOnInit = false;
	FillBar.InitBG('FillBar');
	FillBar.SetBGColor("cyan_highlight");
	FillBar.SetWidth(BGBar.Width);
	FillBar.Hide(); // Size/position is calculated when the progress is set

	NameLabel = Spawn(class'UIScrollingText', self);
	NameLabel.bAnimateOnInit = false;
	NameLabel.InitScrollingText('NameLabel', "SITREP 1");
	NameLabel.SetX(BGBar.X + BGBar.Width + 5);
	NameLabel.SetWidth(Width - NameLabel.X);

	DescriptionLabel = Spawn(class'UIScrollingText', self);
	DescriptionLabel.bAnimateOnInit = false;
	DescriptionLabel.InitScrollingText('DescriptionLabel', "Something awesome happens");
	DescriptionLabel.SetX(NameLabel.X);
	DescriptionLabel.SetWidth(NameLabel.Width);
	DescriptionLabel.SetY(NameLabel.Y + NameLabel.Height);
}

defaultproperties
{
	Height = 60

	bAnimateOnInit = false
}