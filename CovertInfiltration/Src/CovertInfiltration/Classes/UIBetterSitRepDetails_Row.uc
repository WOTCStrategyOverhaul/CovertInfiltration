class UIBetterSitRepDetails_Row extends UIVerticalListItemBase;

var X2SitRepTemplate SitRepTemplate;
var X2SitRepEffectTemplate SitRepEffectTemplate;

var UIScrollingText Title;
var UIText Description;

simulated function InitRow ()
{
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
	Description.SetY(Title.Height + 5);
	Description.OnTextSizeRealized = OnDescriptionSizeRealized;

	if (SitRepTemplate != none)
	{
		Title.SetTitle(SitRepTemplate.GetFriendlyName());
		Description.SetText(SitRepTemplate.Description);
	}
	else
	{
		// Slightly offset effects to the right
		Title.SetX(10);
		Description.SetX(10);

		Title.SetTitle(SitRepEffectTemplate.GetFriendlyName());
		Description.SetText(SitRepEffectTemplate.Description);
	}

	Title.SetWidth(Width - Title.X);
	Description.SetWidth(Width - Description.X);
}

simulated protected function OnDescriptionSizeRealized()
{
	SetHeight(Description.Y + Description.Height);
	UIBetterSitRepDetails(GetParent(class'UIBetterSitRepDetails')).RowRealized(self);
}