class UICovertActionsGeoscape_Risk extends UIPanel;

var protectedwrite UIScrollingText ChanceAndName;
var protectedwrite UIText Description;

var protectedwrite bool bHeightRealizePending;

delegate OnHeightRealized (UICovertActionsGeoscape_Risk Risk);

simulated function InitRisk (float InitWidth)
{
	InitPanel();
	SetWidth(InitWidth);

	ChanceAndName = Spawn(class'UIScrollingText', self);
	ChanceAndName.bAnimateOnInit = false;
	ChanceAndName.InitScrollingText('ChanceAndName');
	ChanceAndName.SetWidth(Width);

	Description = Spawn(class'UIText', self);
	Description.bAnimateOnInit = false;
	Description.InitText('Description');
	Description.SetPosition(10, 28);
	Description.SetWidth(Width - Description.X);
	Description.OnTextSizeRealized = OnDescriptionRealized;
}

simulated function UpdateFromInfo (ActionRiskDisplayInfo DisplayInfo)
{
	ChanceAndName.SetText(DisplayInfo.ChanceText  $ " - " $ DisplayInfo.RiskName);

	if (DisplayInfo.Description == "")
	{
		Description.Hide();
		Height = ChanceAndName.Height;

		bHeightRealizePending = false;
	}
	else
	{
		Description.Show();
		Description.SetText(class'UIUtilities_Infiltration'.static.SetTextLeading(DisplayInfo.Description, -1));

		if (Description.TextSizeRealized)
		{
			SetHeightWithDescription();
		}
		else
		{
			bHeightRealizePending = true;
		}
	}
}

simulated protected function OnDescriptionRealized ()
{
	SetHeightWithDescription();

	if (OnHeightRealized != none) OnHeightRealized(self);
}

simulated protected function SetHeightWithDescription ()
{
	if (!Description.bIsVisible) return; // Rapid updates that set no description?

	Height = Description.Y + Description.Height;
	bHeightRealizePending = false;
}

defaultproperties
{
	bAnimateOnInit = false
}