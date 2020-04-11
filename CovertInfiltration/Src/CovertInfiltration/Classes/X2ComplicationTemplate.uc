//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Template for a chain complication that activates some effect on
//           the completion of the chain. Template defines the overall behaviour
//           of the complication, such as its chance for activating and its effects
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ComplicationTemplate extends X2StrategyElementTemplate config(Infiltration);

var class<XComGameState_Complication> StateClass;

// Info shown in UI
var localized string FriendlyName;
var localized string FriendlyDesc;

// If conditions in CanBeChosen are met, selection will depend if a roll from 1 to 100 lands between MinChance and MaxChance
// If AlwaysSelect is true, a roll that lands outside Min and Max will be clamped to the closest valid number
// If the roll succeeds, then the roll becomes the complication's activation chance
// This activation chance will be compared against a 0 to 100 roll at the end of the chain
var config bool AlwaysSelect;
var config int MinChance;
var config int MaxChance;

var bool bExclusiveOnChain; // Can be the only complication on any particular chain
var bool bNoSimultaneous; // Cannot be selected if it already exists on another ongoing chain

delegate OnComplicationSetup (XComGameState NewGameState, XComGameState_Complication ComplicationState);

// On which chains can this complication be selected
delegate bool CanBeChosen(XComGameState NewGameState, XComGameState_ActivityChain ChainState);

// What does this complication do when the chain ends in various states
delegate OnChainComplete(XComGameState NewGameState, XComGameState_Complication ComplicationState);
delegate OnChainBlocked(XComGameState NewGameState, XComGameState_Complication ComplicationState);

delegate OnComplicationRemoval(XComGameState NewGameState, XComGameState_Complication ComplicationState);

// Called when the associated chain is deemed relevant to the tactical history and enlisted/copied over
// together with all the related states (activities and complications).
// Use/set this delegate when additional states need to be enlisted into tactical.
// Note: the chain/activity/complications states are already copied over when this is called
// Note: the ComplicationState is already modified (tactical) one
delegate OnEnlistStateIntoTactical(XComGameState StartGameState, XComGameState_Complication ComplicationState);

function bool ValidateTemplate (out string strError)
{
	if (MinChance > MaxChance)
	{
		strError = "MinChance is larger than MaxChance";
		return false;
	}

	return true;
}

function XComGameState_Complication CreateInstanceFromTemplate (XComGameState NewGameState, XComGameState_ActivityChain ChainState, optional int TriggerChance = 0, optional bool bActivated = false)
{
	local XComGameState_Complication ComplicationState;

	ComplicationState = XComGameState_Complication(NewGameState.CreateNewStateObject(StateClass, self));
	if (TriggerChance > 0)
	{
		ComplicationState.TriggerChance = TriggerChance;
	}

	ComplicationState.bTriggered = bActivated;
	
	if (ChainState != none)
	{
		ComplicationState.ChainRef = ChainState.GetReference();
	}

	ComplicationState.SetupComplication(NewGameState);

	return ComplicationState;
}

defaultproperties
{
	StateClass = class'XComGameState_Complication'
}