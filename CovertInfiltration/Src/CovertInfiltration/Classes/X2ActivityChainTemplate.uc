class X2ActivityChainTemplate extends X2StrategyElementTemplate;

// For overview UI
var localized string Title;
var localized string Description;

var array<name> Stages;

delegate SetupChain(XComGameState_ActivityChain ChainState); // Called before stage's callbacks
delegate CleanupChain(XComGameState_ActivityChain ChainState); // Called after stage's callbacks