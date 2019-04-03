class UIBetterSitRepDetails extends UIPanel;

var UISitRepInformation CastedScreen;
var array<string> CachedDarkEvents;

var UIList SitRepsList;
var UIText DarkEventsHeader;
var UIList DarkEventsList;

var protected array<UIBetterSitRepDetails_Row> RowsToRealize;
var protected array<UIBetterSitRepDetails_Row> Rows;

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	local UITextStyleObject DarkEventHeaderStyle;
	local float RightPanelX;

	super.InitPanel(InitName, InitLibID);

	// Use navigation to forward input to us (needed for controllers)
	Navigator.HorizontalNavigation = true;
	SetSelectedNavigation();

	SitRepsList = Spawn(class'UIList', self);
	SitRepsList.Hide(); // We will show when all items realize
	SitRepsList.InitList('SitRepsList');
	SitRepsList.SetPosition(406, 390);
	SitRepsList.SetSize(726, 392);
	SitRepsList.SetSelectedNavigation();
	CreateSitReps();

	CacheDarkEvents();
	if (CachedDarkEvents.Length > 0)
	{
		RightPanelX = SitRepsList.X + SitRepsList.Width + 30;

		DarkEventHeaderStyle.iState = eUIState_Bad;
		DarkEventHeaderStyle.bUseTitleFont = true;
		DarkEventHeaderStyle.FontSize = 22;
		DarkEventHeaderStyle.Alignment = "CENTER";

		// Move the dark events icon
		Screen.MC.ChildSetNum("DarkEventRow", "_x", RightPanelX);
		Screen.MC.ChildSetNum("DarkEventRow", "_y", SitRepsList.Y);
		Screen.MC.ChildSetBool("DarkEventRow", "_visible", true);
		Screen.MC.ChildSetBool("DarkEventRow.theTitle", "_visible", false);
		Screen.MC.ChildSetBool("DarkEventRow.theDescription", "_visible", false);

		DarkEventsHeader = Spawn(class'UIText', self);
		DarkEventsHeader.InitText('DarkEventsHeader');
		DarkEventsHeader.SetTitle(class'UIUtilities_Text'.static.ApplyStyle(class'UISitRepInformation'.default.m_strDarkEventsLabel, DarkEventHeaderStyle));
		DarkEventsHeader.SetPosition(RightPanelX + 50, SitRepsList.Y);
		DarkEventsHeader.SetSize(290, 46);

		DarkEventsList = Spawn(class'UIList', self);
		DarkEventsList.InitList('DarkEventsList');
		DarkEventsList.SetPosition(RightPanelX, DarkEventsHeader.Y + DarkEventsHeader.Height + 5);
		DarkEventsList.SetSize(340, 230);

		CreateDarkEvents();
	}

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
			Spacer.ProcessMouseEvents(SitRepsList.OnChildMouseEvent);
		}

		Row = Spawn(class'UIBetterSitRepDetails_Row', SitRepsList.ItemContainer);
		Row.SitRepTemplate = SitRepTemplate;
		Row.InitRow();
		Row.ProcessMouseEvents(SitRepsList.OnChildMouseEvent);

		Rows.AddItem(Row);

		foreach SitRepTemplate.DisplayEffects(EffectName)
		{
			SitRepEffectTemplate = SitRepEffectManager.FindSitRepEffectTemplate(EffectName);
			if (SitRepEffectTemplate == none) continue;

			Row = Spawn(class'UIBetterSitRepDetails_Row', SitRepsList.ItemContainer);
			Row.SitRepEffectTemplate = SitRepEffectTemplate;
			Row.InitRow();
			Row.ProcessMouseEvents(SitRepsList.OnChildMouseEvent);

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

simulated function CreateDarkEvents()
{
	local UIScrollingText Text;
	local string DarkEvent;

	foreach CachedDarkEvents(DarkEvent)
	{
		Text = Spawn(class'UIScrollingText', DarkEventsList.ItemContainer);
		Text.bIsNavigable = true; // Allow controller scroll
		Text.InitScrollingText(, class'UIUtilities_Text'.static.GetColoredText(DarkEvent, eUIState_Bad));
		Text.SetWidth(DarkEventsList.Width);
		Text.AnimateIn();
	}

	DarkEventsList.RealizeItems();
	DarkEventsList.RealizeList();
}

defaultproperties
{
	MCName = "BetterSitRepDetails";
}