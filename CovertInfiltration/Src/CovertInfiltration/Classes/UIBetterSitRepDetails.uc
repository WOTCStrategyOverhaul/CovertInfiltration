class UIBetterSitRepDetails extends UIPanel;

var UISitRepInformation CastedScreen;
var array<string> CachedDarkEvents;

var UIList SitRepsList;
var UIScrollingText DarkEventsHeader;
var UIList DarkEventsList;

var protected array<UIBetterSitRepDetails_Row> RowsToRealize;
var protected array<UIBetterSitRepDetails_Row> Rows;

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);

	// Use navigation to forward input to us (needed for controllers)
	Navigator.HorizontalNavigation = true;
	SetSelectedNavigation();

	SitRepsList = Spawn(class'UIList', self);
	SitRepsList.Hide(); // We will show when all items realize
	SitRepsList.InitList('SitRepsList');
	SitRepsList.SetPosition(406, 390);
	SitRepsList.SetSize(746, 392);
	SitRepsList.SetSelectedNavigation();

	CacheDarkEvents();
	if (CachedDarkEvents.Length > 0)
	{
		DarkEventsHeader = Spawn(class'UIScrollingText', self);
		DarkEventsHeader.InitScrollingText('DarkEventsHeader');
		DarkEventsHeader.SetPosition(SitRepsList.X + SitRepsList.Width + 10, SitRepsList.Y);
		DarkEventsHeader.SetWidth(340);

		DarkEventsList = Spawn(class'UIList', self);
		DarkEventsList.InitList('DarkEventsList');
		DarkEventsList.SetPosition(DarkEventsHeader.X, DarkEventsHeader.Y + DarkEventsHeader.Height + 5);
		DarkEventsList.SetSize(DarkEventsHeader.Width, 240);
	}

	CreateSitReps();
	// TODO: Dark events

	return self;
}

simulated protected function CacheDarkEvents()
{
	local XComGameState_ObjectivesList ObjectiveListState;
	local ObjectiveDisplayInfo DisplayInfo;
	
	ObjectiveListState = XComGameState_ObjectivesList(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_ObjectivesList'));
	CachedDarkEvents.Length = 0;

	foreach ObjectiveListState.ObjectiveDisplayInfos(DisplayInfo)
	{
		if (DisplayInfo.bIsDarkEvent)
		{
			CachedDarkEvents.AddItem(DisplayInfo.DisplayLabel);
		}
	}
}

simulated protected function CreateSitReps()
{
	local X2SitRepEffectTemplateManager SitRepEffectManager;
	local X2SitRepEffectTemplate SitRepEffectTemplate;
	local X2SitRepTemplateManager SitRepManager;
	local X2SitRepTemplate SitRepTemplate;
	local UIBetterSitRepDetails_Row Row;
	local name SitRepName, EffectName;
	local UIPanel Spacer;
	local int i;

	SitRepManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
	SitRepEffectManager = class'X2SitRepEffectTemplateManager'.static.GetSitRepEffectTemplateManager();
	i = 0;

	foreach CastedScreen.MissionData.SitReps(SitRepName)
	{
		SitRepTemplate = SitRepManager.FindSitRepTemplate(SitRepName);
		if (SitRepTemplate == none) continue;

		if (i > 0)
		{
			// Not first sitrep, add spacer
			Spacer = SitRepsList.CreateItem(class'UIPanel');
			Spacer.InitPanel();
			Spacer.SetHeight(10);
			Spacer.DisableNavigation();
		}

		Row = Spawn(class'UIBetterSitRepDetails_Row', SitRepsList.ItemContainer);
		Row.SitRepTemplate = SitRepTemplate;
		Row.InitRow();

		Rows.AddItem(Row);

		foreach SitRepTemplate.DisplayEffects(EffectName)
		{
			SitRepEffectTemplate = SitRepEffectManager.FindSitRepEffectTemplate(EffectName);
			if (SitRepEffectTemplate == none) continue;

			Row = Spawn(class'UIBetterSitRepDetails_Row', SitRepsList.ItemContainer);
			Row.SitRepEffectTemplate = SitRepEffectTemplate;
			Row.InitRow();

			Rows.AddItem(Row);
		}

		i++;
	}

	RowsToRealize = Rows;
}

simulated function RowRealized(UIBetterSitRepDetails_Row Row)
{
	local int PanelsAnimated;

	RowsToRealize.RemoveItem(Row);
	if (RowsToRealize.Length > 0) return;

	// Reposition everything and show the list
	SitRepsList.RealizeItems();
	SitRepsList.RealizeList();
	SitRepsList.Show();
	
	// Animate in the list
	foreach Rows(Row)
	{
		Row.Title.AnimateIn(class'UIUtilities'.const.INTRO_ANIMATION_DELAY_PER_INDEX * PanelsAnimated++);
		Row.Description.AnimateIn(class'UIUtilities'.const.INTRO_ANIMATION_DELAY_PER_INDEX * PanelsAnimated++);
	}
}

defaultproperties
{
	MCName = "BetterSitRepDetails";
}