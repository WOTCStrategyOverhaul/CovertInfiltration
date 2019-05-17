class X2ActivityTemplate extends X2StrategyElementTemplate abstract;

var class<XComGameState_Activity> StateClass;

delegate SetupChain(XComGameState_Activity ActivityState); // Called at start of the chain
delegate SetupStage(XComGameState_Activity ActivityState); // Called when this activity/stage is reached

delegate CleanupStage(XComGameState_Activity ActivityState); // Called when this activity/stage is finished and no longer accessible by player
delegate CleanupChain(XComGameState_Activity ActivityState); // Called when the whole chain is finished and no longer accessible by player