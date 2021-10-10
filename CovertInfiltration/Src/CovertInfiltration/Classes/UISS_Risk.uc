class UISS_Risk extends UIPanel;

var protectedwrite UISS_InfiltrationItem ChanceAndName;
var protectedwrite UIText Description;

var protectedwrite bool bHeightRealizePending;

delegate OnHeightRealized (UISS_Risk Risk);

simulated function InitRisk ()
{
	InitPanel();

	ChanceAndName = Spawn(class'UISS_InfiltrationItem', self);
	ChanceAndName.bAnimateOnInit = false;
	ChanceAndName.InitObjectiveListItem('ChanceAndName');

	Description = Spawn(class'UIText', self);
	Description.bAnimateOnInit = false;
	Description.InitText('Description');
	Description.SetPosition(10, 28);
	Description.SetWidth(360);
	Description.OnTextSizeRealized = OnDescriptionRealized;
	class'UIUtilities_Infiltration'.static.ShadowToText(Description);
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