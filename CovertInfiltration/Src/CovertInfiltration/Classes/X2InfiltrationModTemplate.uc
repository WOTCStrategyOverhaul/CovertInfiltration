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
var name MultCategory; // other equipped items with a ItemCat matching this have their HoursAdded multiplied by this item's InfilMultiplier
var float InfilMultiplier;

function bool ValidateTemplate(out string strError)
{
	if (MultCategory == '' && InfilMultiplier != 1)
	{
		strError = "CI: Error in templates, InfilMultiplier has been set but MultiplierCategory is blank.";
		return false;
	}
	else if (MultCategory != '' && InfilMultiplier == 1)
	{
		strError = "CI: Error in templates, MultiplierCategory has been set but InfilMultiplier remains default.";
		return false;
	}

	return super.ValidateTemplate(strError);
}

defaultproperties
{
	bShouldCreateDifficultyVariants=false
	TemplateAvailability=BITFIELD_GAMEAREA_Singleplayer
}
