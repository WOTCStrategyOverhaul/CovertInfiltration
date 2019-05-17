class X2ActivityChainTemplate extends X2StrategyElementTemplate;

// For overview UI
var localized string Title;
var localized string Description;

var array<name> Stages;

delegate SetupChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called before stages' callbacks
delegate CleanupChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called after stages' callbacks