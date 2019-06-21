//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: A row panel for UIBetterSitRepDetails. It can show either sitrep or an
//           effect (but not both at the same time)
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIBetterSitRepDetails_Row extends UIVerticalListItemBase;

var X2SitRepTemplate SitRepTemplate;
var X2SitRepEffectTemplate SitRepEffectTemplate;

var UIScrollingText Title;
var UIText Description;

simulated function InitRow ()
{
	local EUIState ColorState;
	local string strTitle;

	if (SitRepTemplate == none && SitRepEffectTemplate == none)
	{
		`RedScreen(class.name @ "no template set");
	}
	else if (SitRepTemplate != none && SitRepEffectTemplate != none)
	{
		`RedScreen(class.name @ "both templates set");
	}

	InitListItemBase();

	Title = Spawn(class'UIScrollingText', self);
	Title.InitScrollingText('Title');

	Description = Spawn(class'UIText', self);
	Description.InitText('Description');
	Description.OnTextSizeRealized = OnDescriptionSizeRealized;

	if (SitRepTemplate != none)
	{
		Description.SetY(37);

		ColorState = SitRepTemplate.bNegativeEffect ? eUIState_Bad : eUIState_Good;
		strTitle = class'UIUtilities_Text'.static.GetColoredText(SitRepTemplate.GetFriendlyName(), ColorState);

		Title.SetTitle(strTitle);
		Description.SetText(SitRepTemplate.GetDescriptionExpanded());
	}
	else
	{
		// Slightly offset effects to the right
		Title.SetX(10);
		Description.SetPosition(10, 27);

		Title.SetSubTitle(SitRepEffectTemplate.GetFriendlyName());
		Description.SetText(SitRepEffectTemplate.GetDescriptionExpanded());
	}

	Title.SetWidth(Width - Title.X);
	Description.SetWidth(Width - Description.X);
}

simulated protected function OnDescriptionSizeRealized()
{
	SetHeight(Description.Y + Description.Height);
	UIBetterSitRepDetails(GetParent(class'UIBetterSitRepDetails')).RowRealized(self);
}