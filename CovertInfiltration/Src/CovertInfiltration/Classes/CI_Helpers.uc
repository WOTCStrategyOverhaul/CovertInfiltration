class CI_Helpers extends Object;

//////////////////
/// Game state ///
//////////////////
       
// Adapted from UICovertActions           
static function bool ShouldShowCovertAction(XComGameState_CovertAction ActionState)
{
	local XComGameState_ResistanceFaction FactionState;
	FactionState = ActionState.GetFaction();

	// Only display actions which are actually stored by the Faction. Safety check to prevent
	// actions which were supposed to have been deleted from showing up in the UI and being accessed.
	if (
		FactionState.CovertActions.Find('ObjectID', ActionState.ObjectID) == INDEX_NONE &&
		FactionState.GoldenPathActions.Find('ObjectID', ActionState.ObjectID) == INDEX_NONE
	) {
		return false;
	}
	
	// Always show in-progess actions
	if (ActionState.bStarted) return true;
	
	return ActionState.CanActionBeDisplayed() && (ActionState.GetMyTemplate().bGoldenPath || FactionState.bSeenFactionHQReveal);;
}

/// UI/TEXT

static function string ColourText(string strValue, string strColour)
{
	return "<font color='#" $ strColour $ "'>" $ strValue $ "</font>";
}

static function string MakeFirstCharCapOnly(string strValue)
{
	return Caps(Left(strValue, 1)) $ Locs(Right(strValue, Len(strValue) - 1));
}