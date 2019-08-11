//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Template for a chain complication that activates some effect on
//           the completion of the chain. Template defines the overall behaviour
//           of the complication, such as its chance for activating and its effects
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ComplicationTemplate extends X2StrategyElementTemplate;

// Name shown in UI
var name CompName;

// If conditions in CanBeChosen are met, always select
var bool AlwaysSelect;
// If false, then selection will depend if a roll from zero to MaxChance lands above MinChance

// A random activation chance will be chosen at the beginning of the chain inbetween these two numbers
var int MinChance;
var int MaxChance;
// This activation chance will be compared against a 0 to 100 roll at the end of the chain

// On which chains can this complication be selected
delegate bool CanBeChosen(XComGameState NewGameState, XComGameState_ActivityChain ChainState);

// What does this complication do
delegate CompEffect(XComGameState NewGameState, XComGameState_ActivityChain ChainState);
