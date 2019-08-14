class UIChainsOverview_Activity extends UIPanel;

simulated function InitActivity (optional name InitName)
{
	InitPanel(InitName);
}

simulated function UpdateFromState (XComGameState_Activity ActivityState)
{
}

defaultproperties
{
	bCascadeSelection = true;
}