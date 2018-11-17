//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a header item for the list of covert ops in UICovertActionsGeoscape
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape_FactionHeader extends UIPanel;

var protectedwrite XComGameState_ResistanceFaction Faction;
var protectedwrite bool bIsOngoing;

var protectedwrite UIStackingIcon Icon;
var protectedwrite UIScrollingText Text;

simulated function InitFactionHeader(XComGameState_ResistanceFaction InitFaction, bool IsOngoing)
{
	local UIList List;

	InitPanel();
	
	List = UIList(GetParent(class'UIList')); // list items must be owned by UIList.ItemContainer
	if (List == none)
	{
		ScriptTrace();
		`warn("UI list items must be owned by UIList.ItemContainer");
	}
	else
	{
		SetWidth(List.Width);
	}

	Faction = InitFaction;
	bIsOngoing = IsOngoing;

	CreateElements();
	UpdateText();
	UpdateIcon();
}

simulated protected function CreateElements()
{
	Icon = Spawn(class'UIStackingIcon', self);
	Icon.InitStackingIcon('Icon');
	Icon.SetIconSize(42);

	Text = Spawn(class'UIScrollingText', self);
	Text.bAnimateOnInit = false;
	Text.InitScrollingText('Text');
	Text.SetX(Icon.Width);
	Text.SetWidth(Width - Text.X);
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

	Text.SetHTMLText(strText);
}

simulated function UpdateIcon()
{
	local StackedUIIconData IconData;
	local int i;

	IconData = Faction.GetFactionIcon();

	// Use small versions of images
	for (i = 0; i < IconData.Images.Length; i++)
	{
		IconData.Images[i] = Repl(IconData.Images[i], ".tga", "_sm.tga");
	}

	Icon.SetImageStack(IconData);
}

/// HELPERS

simulated function string GetFactionColour()
{
	return class'UIUtilities_Colors'.static.GetColorForFaction(Faction.GetMyTemplateName());
}

defaultproperties
{
	Height = 46;
	bIsNavigable = false;
	bAnimateOnInit = false; // Animated by the whole list
}