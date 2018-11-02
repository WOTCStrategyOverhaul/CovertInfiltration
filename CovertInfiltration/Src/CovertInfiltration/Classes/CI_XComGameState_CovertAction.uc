//---------------------------------------------------------------------------------------
// THIS IS A DEVELOPMENT-ONLY CLASS. It will be converted to CHL hooks or other 
// mechanisms to avoid using ModClassOverwrite
//---------------------------------------------------------------------------------------

class CI_XComGameState_CovertAction extends XComGameState_CovertAction;

function bool ShouldBeVisible()
{
	return class'UIUtilities_Infiltration'.static.ShouldShowCovertAction(self);
}

protected function bool CanInteract()
{
	return true;
}

// On attempted selection, if an additional prompt is required before action, displays that prompt and returns true; 
// otherwise returns false.
protected function bool DisplaySelectionPrompt()
{
	class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape(GetReference());	
	return true;
}
