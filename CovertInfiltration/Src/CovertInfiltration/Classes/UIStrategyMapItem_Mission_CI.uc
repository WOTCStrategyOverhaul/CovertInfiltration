class UIStrategyMapItem_Mission_CI extends UIStrategyMapItem_Mission;

var UIStrategyMapItem_OpportunityCI OpportunityPanel;

simulated function UIStrategyMapItem InitMapItem (out XComGameState_GeoscapeEntity Entity)
{
	super.InitMapItem(Entity);

	OpportunityPanel = Spawn(class'UIStrategyMapItem_OpportunityCI', self);
	OpportunityPanel.OnScanButtonClicked = OnMissionLaunch;
	OpportunityPanel.InitOpportunityPanel(); 

	ProccessZoomOut(GetInfiltration() != none);

	return self;
}

function OnGeoscapeEntityUpdated ()
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;

	if (!bIsInited) return;

	InfiltrationState = GetInfiltration();

	if (InfiltrationState == none)
	{
		// Restore the vanilla behaviour

		OpportunityPanel.Hide();
		SetVisible(bIsFocused);
		ProcessMouseEvents();
		ProccessZoomOut(false);
		
		return;
	}

	Show();
	IgnoreMouseEvents();
	ProccessZoomOut(true);

	OpportunityPanel.Show();
	OpportunityPanel.UpdateLaunchedActionBox(InfiltrationState.GetCurrentInfilInt(), InfiltrationState.GetMissionObjectiveText(), true);
}

function UpdateFlyoverText ()
{
	if (GetInfiltration() != none)
	{
		SetHTMLText("");
	}
	else
	{
		SetHTMLText(GetMission().GetMissionSource().MissionPinLabel);// set label to the mission type, e.g. ADVENT Blacksite
	}
}

protected function SetHTMLText (string tempLabel)
{
	if (Label != tempLabel)
	{
		Label = tempLabel;
		MC.FunctionString("setHTMLText", Label);
	}
}

protected function ProccessZoomOut (bool bValue)
{
	bDisableHitTestWhenZoomedOut = bValue;
	bFadeWhenZoomedOut = bValue;
}

simulated function Show()
{
	if (GetInfiltration() != none || bIsFocused)
	{
		super.Show();
	}
}

///////////////
/// Helpers ///
///////////////

simulated protected function XComGameState_MissionSite GetMission ()
{
	return XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(GeoscapeEntityRef.ObjectID));
}

simulated protected function XComGameState_MissionSiteInfiltration GetInfiltration ()
{
	return XComGameState_MissionSiteInfiltration(`XCOMHISTORY.GetGameStateForObjectID(GeoscapeEntityRef.ObjectID));
}

defaultproperties
{
	bAnimateOnInit = false;
}