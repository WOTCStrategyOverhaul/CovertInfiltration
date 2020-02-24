class UIStrategyMapItem_Mission_CI extends UIStrategyMapItem_Mission;

var UIStrategyMapItem_OpportunityCI OpportunityPanel;

var protected bool bHintIsVisible;
var protected float HintOffsetY;

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

		SetHintVisibility(true);
		SetHintOffsetY(0);

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
		// No hint at all for infiltrations
		SetHintVisibility(false);

		if (InfiltrationState.Available)
		{
			OpportunityPanel.UpdateLaunchedActionBox(InfiltrationState.GetCurrentInfilInt(), InfiltrationState.GetMissionObjectiveText(), true);
		}
		else
		{
			Hide();
		}
	}
	else
	{
		OpportunityPanel.UpdateExpiringActionProgressBar(AssaultActivityState.ExpiryTimerStart, AssaultActivityState.ExpiryTimerEnd);
		
		SetHintVisibility(bIsFocused); // Hint is visible only if we are currently "hovering" with the controller crosshairs
		SetHintOffsetY(17); // Move the hint slightly down
	}
}

function UpdateFlyoverText ()
{
	local X2ActivityTemplate_Assault AssaultTemplate;
	local XComGameState_Activity ActivityState;
	
	if (GetInfiltration() != none)
	{
		SetHTMLText("");
	}
	else
	{
		ActivityState = GetActivity();
		if (ActivityState != none) AssaultTemplate = X2ActivityTemplate_Assault(ActivityState.GetMyTemplate());

		if (AssaultTemplate != none)
		{
			SetHTMLText(AssaultTemplate.MissionPinLabel);
		}
		else
		{
			SetHTMLText(GetMission().GetMissionSource().MissionPinLabel); // set label to the mission type, e.g. ADVENT Blacksite
		}
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

protected function SetHintVisibility (bool bNewHintIsVisible)
{
	if (bNewHintIsVisible != bHintIsVisible)
	{
		bHintIsVisible = bNewHintIsVisible;

		MC.ChildSetBool("hintBG", "_visible", bHintIsVisible);
		MC.ChildFunctionVoid("SimpleHintIconMC", bHintIsVisible ? "Show" : "Hide");
		MC.ChildSetBool("hintLabel", "_visible", bHintIsVisible);
	}
}

protected function SetHintOffsetY (float NewHintOffsetY)
{
	if (NewHintOffsetY != HintOffsetY)
	{
		HintOffsetY = NewHintOffsetY;

		MC.ChildSetNum("hintBG", "_y", HintOffsetY + 0);
		MC.ChildSetNum("SimpleHintIconMC", "_y", HintOffsetY + 8.65);
		MC.ChildSetNum("hintLabel", "_y", HintOffsetY + 3.8);
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

	// By default the hint starts visible
	bHintIsVisible = true;
}