//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a header item for the list of covert ops in UICovertActionsGeoscape
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape_FactionHeader extends UIListItemString;

var protectedwrite XComGameState_ResistanceFaction Faction;
var protectedwrite bool bIsOngoing;

var protectedwrite UIImage BG;
var protectedwrite UIImage Icon;

simulated function InitFactionHeader(XComGameState_ResistanceFaction InitFaction, bool IsOngoing)
{
	InitListItem();

	// Remove unneeded parts
	DisableNavigation();
	ButtonBG.Remove();

	Faction = InitFaction;
	bIsOngoing = IsOngoing;

	CreateElements();
	UpdateText();
	UpdateFactionIcon();
	UpdateBG();
}

simulated protected function CreateElements()
{
	Icon = Spawn(class'UIImage', self);
	Icon.InitImage('Icon');

	/*BG = Spawn(class'UIImage', self);
	BG.InitImage('BG');*/
}

simulated function UpdateText()
{
	local string strText;

	if (bIsOngoing)
	{
		strText = class'UIUtilities_Infiltration'.static.MakeFirstCharCapOnly(class'UICovertActions'.default.CovertActions_CurrentActiveHeader);
	}
	else 
	{
		strText = Faction.GetFactionTitle();
	}

	strText = class'UIUtilities_Text'.static.AddFontInfo(strText, Screen.bIsIn3D, true);
	strText = class'UIUtilities_Infiltration'.static.ColourText(strText, GetFactionColour());
	strText = "       " $ strText; // Add some space for the icon

	SetHtmlText(strText);

	// Note that if (space + text) exceeds the line width, it will scroll together with space.
	// A fix will be to spawn another, smaller sized UIText, but I do not belive this problem will ever happen
}

simulated function UpdateFactionIcon()
{
	// For now we will use just the static image from class template
	
	local X2SoldierClassTemplateManager ClassTemplateManager;
	local X2SoldierClassTemplate ClassTemplate;

	ClassTemplateManager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
	ClassTemplate = ClassTemplateManager.FindSoldierClassTemplate(Faction.GetMyTemplate().ChampionSoldierClass);
	if (ClassTemplate == none) return; // Can't find any image

	if (Icon == none)
	{
		Icon = Spawn(class'UIImage', self);
		Icon.InitImage('Icon');
	}

	Icon.LoadImage(ClassTemplate.IconImage);
	Icon.SetSize(42, 42);
}

simulated function UpdateBG()
{
	// For now do nothing, can't find a good/working bg image

	/*BG.LoadImage("img:///gfxXPACK_CovertOps.Gradient");
	BG.SetAlpha(0.33); // Doesn't seem to work
	BG.SetColor(GetFactionColour());
	BG.SetHeight(40);
	BG.SetWidth(List.Width);*/
}

/// HELPERS

simulated function string GetFactionColour()
{
	return class'UIUtilities_Colors'.static.GetColorForFaction(Faction.GetMyTemplateName());
}

defaultproperties
{
	Height = 46;
	bAnimateOnInit = false; // Animated by the whole list
}