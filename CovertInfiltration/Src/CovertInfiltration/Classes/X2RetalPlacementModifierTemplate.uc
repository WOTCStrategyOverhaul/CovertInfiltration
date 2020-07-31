class X2RetalPlacementModifierTemplate extends X2DataTemplate config(Infiltration);

var config int DefaultDelta;

delegate bool IsRelevantToRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState);
delegate int GetDeltaForRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState);

//////////////////
/// Validation ///
//////////////////

function bool ValidateTemplate (out string strError)
{
	if (GetDeltaForRegion == DefaultGetDeltaForRegion && IsRelevantToRegion == none)
	{
		strError = "DefaultGetDeltaForRegion requires IsRelevantToRegion to be set";
		return false;
	}

	return true;
}

////////////////
/// Defaults ///
////////////////

function int DefaultGetDeltaForRegion (XComGameState NewGameState, XComGameState_WorldRegion RegionState)
{
	if (IsRelevantToRegion(NewGameState, RegionState))
	{
		return DefaultDelta;
	}

	return 0;
}

defaultproperties
{
	GetDeltaForRegion = DefaultGetDeltaForRegion
}
