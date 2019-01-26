class SeqAct_GetLineOfPlayEndpoint extends SequenceAction;

var Vector Location;

event Activated()
{
	if (!`TACTICALMISSIONMGR.GetLineOfPlayEndpoint(Location))
	{
		`RedScreen("SeqAct_GetLineOfPlayEndpoint: Failed to fetch LOP endpoint from XComTacticalMissionManager");
	}

	`log("LineOfPlayEndpoint: " @ Location,, 'CI');
}

defaultproperties
{
	ObjCategory="Level"
	ObjName="Get LOP Endpoint"

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true
	
	bAutoActivateOutputLinks=true
	OutputLinks(0)=(LinkDesc="Out")

	VariableLinks(0)=(ExpectedType = class'SeqVar_Vector', LinkDesc="Location", PropertyName=Location, bWriteable=TRUE)
}