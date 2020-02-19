class UICovertActionsGeoscape_Risk extends UIPanel;

var protectedwrite UIScrollingText ChanceAndName;
var protectedwrite UIScrollingText Description;

simulated function InitRisk (float InitWidth)
{
	InitPanel();
	SetWidth(InitWidth);

	ChanceAndName = Spawn(class'UIScrollingText', self);
	ChanceAndName.bAnimateOnInit = false;
	ChanceAndName.InitScrollingText('ChanceAndName');
	ChanceAndName.SetWidth(Width);

	Description = Spawn(class'UIScrollingText', self);
	Description.bAnimateOnInit = false;
	Description.InitScrollingText('Description');
	Description.SetPosition(10, 28);
	Description.SetWidth(Width - Description.X);
}

simulated function UpdateFromInfo (ActionRiskDisplayInfo DisplayInfo)
{
	ChanceAndName.SetText(DisplayInfo.ChanceText  $ " - " $ DisplayInfo.RiskName);

	if (DisplayInfo.Description == "")
	{
		Description.Hide();
		Height = ChanceAndName.Height;
	}
	else
	{
		Description.Show();
		Description.SetText(DisplayInfo.Description);
		Height = Description.Y + Description.Height;
	}
}

defaultproperties
{
	bAnimateOnInit = false
}