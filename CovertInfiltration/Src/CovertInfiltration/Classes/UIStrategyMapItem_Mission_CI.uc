class UIStrategyMapItem_Mission_CI extends UIStrategyMapItem_Mission;

var UIStrategyMapItem_OpportunityCI OpportunityPanel;

simulated function UIStrategyMapItem InitMapItem(out XComGameState_GeoscapeEntity Entity)
{
	if (XComGameState_MissionSiteInfiltration(Entity) != none) bProcessesMouseEvents = false;

	return super.InitMapItem(Entity);
}

simulated function OnInitFromGeoscapeEntity (const out XComGameState_GeoscapeEntity GeoscapeEntity)
{
	OpportunityPanel = Spawn(class'UIStrategyMapItem_OpportunityCI', self);
	OpportunityPanel.OnScanButtonClicked = OnMissionLaunch;
	OpportunityPanel.InitOpportunityPanel(); 

	SetVisible(GetActivity() == none);
	ProccessZoomOut(GetActivity() != none);
}

function UpdateFromGeoscapeEntity (const out XComGameState_GeoscapeEntity GeoscapeEntity)
{
	local XComGameState_MissionSiteInfiltration InfiltrationState;
	local XComGameState_Activity_Assault AssaultActivityState;

	super.UpdateFromGeoscapeEntity(GeoscapeEntity);

	AssaultActivityState = XComGameState_Activity_Assault(GetActivity());
	InfiltrationState = GetInfiltration();

	if (InfiltrationState == none && AssaultActivityState == none)
	{
		// Restore the vanilla behaviour

		OpportunityPanel.Hide();
		SetVisible(bIsFocused);
		ProccessZoomOut(false);
		
		return;
	}

	Show();
	ProccessZoomOut(true);
	OpportunityPanel.Show();

	if (InfiltrationState != none)
	{
		OpportunityPanel.UpdateLaunchedActionBox(InfiltrationState.GetCurrentInfilInt(), InfiltrationState.GetMissionObjectiveText(), true);
	}
	else
	{
		OpportunityPanel.UpdateExpiringActionProgressBar(AssaultActivityState.ExpiryTimerStart, AssaultActivityState.ExpiryTimerEnd);
		// TODO: Empty black box for controller button and "LABEL" text remain
	}
}

function UpdateFlyoverText ()
{
	if (GetActivity() != none)
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
	if (GetActivity() != none || bIsFocused)
	{
		super(UIStrategyMapItem).Show();
	}
}

simulated function OnLoseFocus()
{
	super(UIStrategyMapItem).OnLoseFocus();
	
	if (GetActivity() == none)
	{
		Hide();
	}
}

///////////////
/// Helpers ///
///////////////

simulated protected function XComGameState_Activity GetActivity ()
{
	return class'XComGameState_Activity'.static.GetActivityFromPrimaryObjectID(GeoscapeEntityRef.ObjectID);
}

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