class SeqAct_GetObjectiveParcelLocation extends SequenceAction;

var Vector Location;

event Activated()
{
	local XComParcelManager ParcelManager;
	ParcelManager = `PARCELMGR;

	Location = ParcelManager.ObjectiveParcel.Location;
}

defaultproperties
{
	ObjCategory="Level"
	ObjName="Get objective parcel location"

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true
	
	bAutoActivateOutputLinks=true
	OutputLinks(0)=(LinkDesc="Out")

	VariableLinks(0)=(ExpectedType = class'SeqVar_Vector', LinkDesc="Location", PropertyName=Location, bWriteable=TRUE)
}