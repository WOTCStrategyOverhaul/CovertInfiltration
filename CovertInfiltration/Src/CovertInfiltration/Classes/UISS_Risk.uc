class UISS_Risk extends UIPanel;

var protectedwrite UISS_InfiltrationItem ChanceAndName;
var protectedwrite UISS_InfiltrationItem Description;

simulated function InitRisk ()
{
	InitPanel();

	ChanceAndName = Spawn(class'UISS_InfiltrationItem', self);
	ChanceAndName.bAnimateOnInit = false;
	ChanceAndName.InitObjectiveListItem('ChanceAndName');

	Description = Spawn(class'UISS_InfiltrationItem', self);
	Description.bAnimateOnInit = false;
	Description.InitObjectiveListItem('Description');
	Description.SetPosition(10, 28);
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