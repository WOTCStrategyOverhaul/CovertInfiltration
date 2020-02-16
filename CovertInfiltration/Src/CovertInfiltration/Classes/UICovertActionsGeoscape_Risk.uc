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
	Description.SetWidth(Width);
}

simulated function UpdateFromInfo (ActionRiskDisplayInfo DisplayInfo)
{
	// TODO: Description

	ChanceAndName.SetText(DisplayInfo.ChanceText  $ " - " $ DisplayInfo.RiskName);
	Height = ChanceAndName.Height;
}

defaultproperties
{
	bAnimateOnInit = false
}