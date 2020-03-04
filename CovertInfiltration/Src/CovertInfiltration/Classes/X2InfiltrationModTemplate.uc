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
var EInfilModifierType ModifyType; // what kind of game element does this template modify
var name ElementName; // the name of the game element this template modifies

function bool ValidateTemplate(out string strError)
{
	local X2DataTemplate             DataTemplate;
	local X2ItemTemplateManager      ItemTemplateManager;
	local X2ItemTemplate             ItemTemplate;
	local X2CharacterTemplateManager CharacterTemplateManager;
	local X2CharacterTemplate        CharacterTemplate;
	local X2AbilityTemplateManager   AbilityTemplateManager;
	local X2AbilityTemplate          AbilityTemplate;
	
	strError = "element does not exist!";
	
	if (ModifyType == eIMT_Item)
	{
		ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
		ItemTemplate = ItemTemplateManager.FindItemTemplate(ElementName);
		return ItemTemplate != none;
	}
	if (ModifyType == eIMT_Ability)
	{
		AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(ElementName);
		return AbilityTemplate != none;
	}
	if (ModifyType == eIMT_Character)
	{
		CharacterTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
		CharacterTemplate = CharacterTemplateManager.FindCharacterTemplate(ElementName);
		return CharacterTemplate != none;
	}
	if (ModifyType == eIMT_Category)
	{
		ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
		return ItemTemplateManager.ItemCategoryIsValid(ElementName);
	}

	strError = "has an invalid or missing ModifyType!";

	return false;
}

defaultproperties
{
	bShouldCreateDifficultyVariants=false
	TemplateAvailability=BITFIELD_GAMEAREA_Singleplayer
}
