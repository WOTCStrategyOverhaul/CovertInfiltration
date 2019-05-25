class X2ActivityChainTemplate extends X2StrategyElementTemplate;

// For overview UI
var localized string Title;
var localized string Description;

var array<name> Stages;

delegate SetupChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called before stages' callbacks
delegate CleanupChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called after stages' callbacks

delegate PostStageSetup(XComGameState NewGameState, XComGameState_Activity ActivityState);

delegate ChooseRegions(XComGameState_ActivityChain ChainState, out StateObjectReference PrimaryRegionRef, out StateObjectReference SecondaryRegionRef);
delegate StateObjectReference ChooseFaction(XComGameState_ActivityChain ChainState);

function XComGameState_ActivityChain CreateInstanceFromTemplate (XComGameState NewGameState)
{
	local XComGameState_ActivityChain ActivityState;

	ActivityState = XComGameState_ActivityChain(NewGameState.CreateNewStateObject(class'XComGameState_ActivityChain', self));
	ActivityState.SetupChain(NewGameState);

	return ActivityState;
}

function bool ValidateTemplate (out string strError)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityTemplate ActivityTemplate;
	local name StageName;

	if (Stages.Length == 0)
	{
		strError = "chain has no stages";
		return false;
	}

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	foreach Stages(StageName)
	{
		ActivityTemplate = X2ActivityTemplate(TemplateManager.FindStrategyElementTemplate(StageName));

		if (ActivityTemplate == none)
		{
			strError = "template for stage" @ StageName @ "not found";
			return false;
		}
	}

	return true;
}