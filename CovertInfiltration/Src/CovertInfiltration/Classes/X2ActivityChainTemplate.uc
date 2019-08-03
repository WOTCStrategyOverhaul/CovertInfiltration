//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Template for a chain of X2ActivityTemplates. Defines the overall behaviour
//           of the chain, such as what region it takes place it, etc
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ActivityChainTemplate extends X2StrategyElementTemplate;

// For overview UI
var localized string Title;
var localized string Description;

// Names of X2ActivityTemplates that act as stages for this chain
var array<name> Stages;

var bool SpawnInDeck; // If true, spawned automatically using the deck system
var int NumInDeck; // The larger the number, the more common this chain is

delegate bool DeckReq(XComGameState NewGameState); // Conditions that must be met for the chain to be added to the deck

delegate SetupChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called before stages' callbacks
delegate CleanupChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called after stages' callbacks

delegate PostStageSetup(XComGameState NewGameState, XComGameState_Activity ActivityState);

delegate ChooseRegions(XComGameState_ActivityChain ChainState, out StateObjectReference PrimaryRegionRef, out StateObjectReference SecondaryRegionRef);
delegate StateObjectReference ChooseFaction(XComGameState_ActivityChain ChainState, XComGameState NewGameState);

function XComGameState_ActivityChain CreateInstanceFromTemplate (XComGameState NewGameState, optional array<StateObjectReference> ChainObjectRefs)
{
	local XComGameState_ActivityChain ActivityState;

	ActivityState = XComGameState_ActivityChain(NewGameState.CreateNewStateObject(class'XComGameState_ActivityChain', self));
	ActivityState.ChainObjectRefs = ChainObjectRefs;
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

////////////////
/// Defaults ///
////////////////

static function bool AlwaysAvailable(XComGameState NewGameState)
{
	return true;
}

defaultproperties
{
	DeckReq = AlwaysAvailable
}