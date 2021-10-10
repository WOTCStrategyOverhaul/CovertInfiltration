class UISS_Risk extends UIPanel;

var protectedwrite UISS_InfiltrationItem ChanceAndName;
var protectedwrite UIText Description;

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
	class'UIUtilities_Infiltration'.static.ShadowToText(Description);
	// TODO: Realize callback
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
		Description.SetText(class'UIUtilities_Infiltration'.static.SetTextLeading(DisplayInfo.Description, -1));
		Height = Description.Y + Description.Height; // TODO
	}
}

defaultproperties
{
	bAnimateOnInit = false
}