class UICovertActionsGeoscape_FactionHeader extends UIListItemString;

var protectedwrite XComGameState_ResistanceFaction Faction;
var protectedwrite bool bIsOngoing;

var protectedwrite UIImage BG;

simulated function InitFactionHeader(XComGameState_ResistanceFaction InitFaction, bool IsOngoing)
{
	InitListItem();

	// Remove unneeded parts
	DisableNavigation();
	ButtonBG.Remove();

	Faction = InitFaction;
	bIsOngoing = IsOngoing;

	UpdateText();
	UpdateBG();
}

simulated function UpdateText()
{
	local string strText;

	if (bIsOngoing)
	{
		strText = class'UICovertActions'.default.CovertActions_CurrentActiveHeader;
	}
	else 
	{
		strText = Faction.GetFactionTitle();
	}

	strText = class'UIUtilities_Text'.static.AddFontInfo(strText, Screen.bIsIn3D, true);
	strText = ColourText(strText, GetFactionColour());
	strText = InjectFactionIcon(strText);

	SetHtmlText(strText);
}

simulated function string InjectFactionIcon(string strText)
{
	// For now just space
	return "     " $ strText;
}

simulated function UpdateBG()
{
	local UIFactionIcon d;

	BG = Spawn(class'UIImage', self);
	BG.InitImage('BG', "img:///gfxXPACK_CovertOps.Gradient");
	BG.SetAlpha(0.33); // Doesn't seem to work
	BG.SetColor(GetFactionColour());
	BG.SetHeight(40);
	BG.SetWidth(List.Width);
}

/// HELPERS

simulated function string GetFactionColour()
{
	return class'UIUtilities_Colors'.static.GetColorForFaction(Faction.GetMyTemplateName());
}

static function string ColourText(string strValue, string strColour)
{
	return "<font color='#" $ strColour $ "'>" $ strValue $ "</font>";
}

defaultproperties
{
	Height = 42;
}