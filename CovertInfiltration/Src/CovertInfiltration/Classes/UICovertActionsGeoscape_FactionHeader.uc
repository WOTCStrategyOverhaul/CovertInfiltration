//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a header item for the list of covert ops in UICovertActionsGeoscape
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape_FactionHeader extends UIPanel;

var protectedwrite XComGameState_ResistanceFaction Faction;
var protectedwrite bool bIsOngoing;

var protectedwrite UIImage PlainIcon;
var protectedwrite UIStackingIcon StackingIcon;
var protectedwrite UIScrollingText Text;

simulated function InitFactionHeader()
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

	PlainIcon = Spawn(class'UIImage', self);
	PlainIcon.Hide();
	PlainIcon.InitImage('PlainIcon', "img:///UILibrary_XPACK_Common.MissionIcon_CovertAction");
	PlainIcon.SetSize(42, 42);

	StackingIcon = Spawn(class'UIStackingIcon', self);
	StackingIcon.Hide();
	StackingIcon.InitStackingIcon('StackingIcon');
	StackingIcon.SetIconSize(42);

	Text = Spawn(class'UIScrollingText', self);
	Text.bAnimateOnInit = false;
	Text.InitScrollingText('Text');
	Text.SetX(StackingIcon.Width);
	Text.SetWidth(Width - Text.X);
}

simulated function SetFaction (XComGameState_ResistanceFaction NewFaction)
{
	Faction = NewFaction;
	bIsOngoing = false;

	StackingIcon.Show();
	PlainIcon.Hide();

	UpdateText();
	UpdateStackingIcon();
}

simulated function SetOngoing ()
{
	Faction = none;
	bIsOngoing = true;

	StackingIcon.Hide();
	PlainIcon.Show();

	UpdateText();
}

simulated protected function UpdateText()
{
	local string strText, strColour;

	if (bIsOngoing)
	{
		strText = class'UIUtilities_Infiltration'.static.MakeFirstCharCapOnly(class'UICovertActions'.default.CovertActions_CurrentActiveHeader);
	}
	else 
	{
		strText = Faction.GetFactionTitle();
	}

	strColour = bIsOngoing ? class'UIUtilities_Colors'.const.COVERT_OPS_HTML_COLOR : GetFactionColour();
	strText = class'UIUtilities_Text'.static.AddFontInfo(strText, Screen.bIsIn3D, true);
	strText = class'UIUtilities_Infiltration'.static.ColourText(strText, strColour);
	 
	Text.SetHTMLText(strText);
}

simulated protected function UpdateStackingIcon()
{
	local StackedUIIconData IconData;
	local int i;

	IconData = Faction.GetFactionIcon();

	// Use small versions of images
	for (i = 0; i < IconData.Images.Length; i++)
	{
		IconData.Images[i] = Repl(IconData.Images[i], ".tga", "_sm.tga");
	}

	StackingIcon.SetImageStack(IconData);
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