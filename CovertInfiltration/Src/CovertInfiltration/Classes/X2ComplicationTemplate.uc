//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Template for a chain complication that activates some effect on
//           the completion of the chain. Template defines the overall behaviour
//           of the complication, such as its chance for activating and its effects
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ComplicationTemplate extends X2StrategyElementTemplate;

var class<XComGameState_Complication> StateClass;

// Info shown in UI
var localized name FriendlyName;
var localized name FriendlyDesc;

// If conditions in CanBeChosen are met, always select
// If false, then selection will depend if a roll from zero to MaxChance lands above MinChance
var config bool AlwaysSelect;

// A random activation chance will be chosen at the beginning of the chain inbetween these two numbers
var config int MinChance;
var config int MaxChance;
// This activation chance will be compared against a 0 to 100 roll at the end of the chain

delegate OnComplicationSetup (XComGameState NewGameState, XComGameState_Complication ComplicationState);

// On which chains can this complication be selected
delegate bool CanBeChosen(XComGameState NewGameState, XComGameState_ActivityChain ChainState);

// What does this complication do when the chain ends in various states
delegate OnChainComplete(XComGameState NewGameState, XComGameState_ActivityChain ChainState);
delegate OnChainBlocked(XComGameState NewGameState, XComGameState_ActivityChain ChainState);

function XComGameState_Complication CreateInstanceFromTemplate (XComGameState NewGameState, optional int TriggerChance = 0)
{
	local XComGameState_Complication ComplicationState;

	`CI_Log("RECIEVED TRIGGER: " $ TriggerChance);

	ComplicationState = XComGameState_Complication(NewGameState.CreateNewStateObject(StateClass, self));
	if (TriggerChance > 0)
	{
		ComplicationState.TriggerChance = TriggerChance;
	}

	ComplicationState.SetupComplication(NewGameState);

	return ComplicationState;
}

defaultproperties
{
	StateClass = class'XComGameState_Complication'
}