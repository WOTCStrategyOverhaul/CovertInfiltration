//---------------------------------------------------------------------------------------
//  AUTHOR:  
//  PURPOSE: MCO for covert action items on strategy map
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIStrategyMapItem_CovertAction_CI extends UIStrategyMapItem_CovertAction;

var UIStrategyMapItem_OpportunityCI OpportunityPanel;

simulated function OnInitFromGeoscapeEntity (const out XComGameState_GeoscapeEntity GeoscapeEntity)
{
	OpportunityPanel = Spawn(class'UIStrategyMapItem_OpportunityCI', self);
	OpportunityPanel.OnScanButtonClicked = OnScanButtonClick;
	OpportunityPanel.InitOpportunityPanel(); 
}

function UpdateFromGeoscapeEntity(const out XComGameState_GeoscapeEntity GeoscapeEntity)
{
	local XComGameState_CovertAction CovertAction;
	local ActionExpirationInfo ActionExpiration;

	super.UpdateFromGeoscapeEntity(GeoscapeEntity);
	OpportunityPanel.Show();

	CovertAction = GetAction();
	if (CovertAction.bStarted)
	{
		OpportunityPanel.UpdateLaunchedActionBox(GetActionProgress(), CovertAction.GetDisplayName(), class'X2Helper_Infiltration'.static.IsInfiltrationAction(CovertAction));
	}
	else if (class'XComGameState_CovertActionExpirationManager'.static.GetActionExpirationInfo(CovertAction.GetReference(), ActionExpiration))
	{
		OpportunityPanel.UpdateExpiringActionProgressBar(ActionExpiration.OriginTime, ActionExpiration.Expiration);
	}
	else
	{
		OpportunityPanel.Hide();
	}
}

simulated protected function int GetActionProgress ()
{
	local XComGameState_CovertAction CovertAction;
	local float TotalDuration, RemainingDuration;
	
	CovertAction = GetAction();
	TotalDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(CovertAction.EndDateTime, CovertAction.StartDateTime);
	RemainingDuration = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInSeconds(CovertAction.EndDateTime, CovertAction.GetCurrentTime());

	return (1 - (RemainingDuration / TotalDuration)) * 100;
}

function protected OnScanButtonClick()
{
	GetAction().AttemptSelectionCheckInterruption();
}

simulated function XComGameState_CovertAction GetAction()
{
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(GeoscapeEntityRef.ObjectID));
}

simulated function bool IsSelectable()
{
	return true;
}

defaultproperties
{
	bProcessesMouseEvents = false;
	bAnimateOnInit = false;
}