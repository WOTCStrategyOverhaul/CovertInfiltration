class X2ActivityTemplate extends X2StrategyElementTemplate abstract;

var class<XComGameState_Activity> StateClass;

delegate SetupChain(XComGameState NewGameState, XComGameState_Activity ActivityState); // Called at start of the chain
delegate SetupStage(XComGameState NewGameState, XComGameState_Activity ActivityState); // Called when this activity/stage is reached

delegate CleanupStage(XComGameState NewGameState, XComGameState_Activity ActivityState); // Called when this activity/stage is finished and no longer accessible by player
delegate CleanupChain(XComGameState NewGameState, XComGameState_Activity ActivityState); // Called when the whole chain is finished and no longer accessible by player