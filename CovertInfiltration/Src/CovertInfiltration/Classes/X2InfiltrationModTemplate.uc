//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class adds a new template which controls
//           infiltration time on a per-item basis and
//           allows items to modify other items' infil
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2InfiltrationModTemplate extends X2DataTemplate;

// Number of hours this item adds to the Covert Action clock
var int InfilModifier;
// When equipping this item, items with an ItemCat matching MultCategory
// will have their InfilModifier multiplied by this item's InfilMultiplier
var float InfilMultiplier;
var name MultCategory;
// How much this item reduces the risk of injury/capture on non-Infil CAs
var int Deterrence;

defaultproperties
{
	InfilModifier=0
	InfilMultiplier=1
	MultCategory=""
	Deterrence=0

	bShouldCreateDifficultyVariants=false
	TemplateAvailability=BITFIELD_GAMEAREA_Singleplayer
}
