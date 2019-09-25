class XComGameState_Complication_RewardInterception extends XComGameState_Complication;

var StateObjectReference ResourceContainerRef;

function SetupComplication (XComGameState NewGameState)
{
	super.SetupComplication(NewGameState);

	ResourceContainerRef = NewGameState.CreateNewStateObject(class'XComGameState_ResourceContainer').GetReference();
}

function XComGameState_ResourceContainer GetResourceContainer ()
{
	return XComGameState_ResourceContainer(`XCOMHISTORY.GetGameStateForObjectID(ResourceContainerRef.ObjectID));
}