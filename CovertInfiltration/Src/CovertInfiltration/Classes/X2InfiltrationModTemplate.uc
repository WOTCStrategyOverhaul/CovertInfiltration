//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class adds a new template which controls
//           infiltration time on a per-item basis and
//           allows items to modify other items' infil
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationModTemplate extends X2DataTemplate;

var int HoursAdded; // to the covert infiltration time
var int Deterrence; // how much this item reduces the risk of injury/capture on non-Infil CAs
var EInfilModifierType ModifyType;

function bool ValidateTemplate(out string strError)
{
	if (ModifyType != none)
	{
		return true;
	}
	else
	{
		strError = "CI: Error in templates, an X2InfiltrationModTemplate does not have a ModifyType which should not be possible!";
		return false;
	}
}

defaultproperties
{
	bShouldCreateDifficultyVariants=false
	TemplateAvailability=BITFIELD_GAMEAREA_Singleplayer
}
