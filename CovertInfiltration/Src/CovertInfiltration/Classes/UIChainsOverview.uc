class UIChainsOverview extends UIScreen;

var UIList ChainsList;

var UIPanel ChainPanel;
var UIBGBox ChainPanelBG;
var UIX2PanelHeader ChainHeader;
var UIList ActivitiesList;

var array<XComGameState_ActivityChain> Chains;

var bool bInstantInterp;
var StateObjectReference ChainToFocusOnInit;

// Fix for UIMission
var bool bRestoreCamEarthViewOnClose;
var protected vector2D EarthSavedViewLoc;
var protected float EarthSavedZoom;

var localized string strOngoing;
var localized string strEnded;

////////////
/// Init ///
////////////

simulated function InitScreen (XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	bInstantInterp = !Movie.Stack.Screens[1].IsA(class'UIFacility_CIC'.Name);

	BuildScreen();
	UpdateNavHelp();
	SaveEarthViewIfNeeded();

	`HQPRES.CAMLookAtNamedLocation("UIDisplayCam_ResistanceScreen", bInstantInterp ? float(0) : `HQINTERPTIME);
}

simulated protected function BuildScreen ()
{
	ChainsList = Spawn(class'UIList', self);
	ChainsList.OnSetSelectedIndex = OnChainSelection;
	ChainsList.BGPaddingTop = 20;
	ChainsList.InitList('ChainsList',,,,,, true, class'UIUtilities_Controls'.const.MC_X2Background);
	ChainsList.SetPosition(500, 230);
	ChainsList.SetSize(400, 630);

	ChainPanel = Spawn(class'UIPanel', self);
	ChainPanel.InitPanel('ChainPanel');
	ChainPanel.SetPosition(920, 210);
	ChainPanel.SetSize(590, 660);
	ChainPanel.Hide();

	ChainPanelBG = Spawn(class'UIBGBox', ChainPanel);
	ChainPanelBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	ChainPanelBG.InitBG('BG', 0, 0, ChainPanel.Width, ChainPanel.Height);

	ChainHeader = Spawn(class'UIX2PanelHeader', ChainPanel);
	ChainHeader.bIsNavigable = false;
	ChainHeader.bRealizeOnSetText = true;
	ChainHeader.InitPanelHeader('Header');
	ChainHeader.SetHeaderWidth(ChainPanelBG.Width - 20);
	ChainHeader.SetPosition(ChainPanelBG.X + 10, ChainPanelBG.Y + 10);

	ActivitiesList = Spawn(class'UIList', ChainPanel);
	ActivitiesList.ItemPadding = 10;
	ActivitiesList.InitList('ActivitiesList',,,,,, true);
	ActivitiesList.SetPosition(ChainHeader.X, ChainHeader.Y + ChainHeader.Height);
	ActivitiesList.SetSize(ChainHeader.headerWidth, ChainPanel.Height - ActivitiesList.Y - 10);

	// The BG is required so that mousewheel scrolling doesn't jerk when the cursor is between the items
	// But we also don't want to have the "fake" BG be visible to the player - we already have our BG
	ActivitiesList.BG.Hide();

	Navigator.HorizontalNavigation = true;
}

simulated function OnInit()
{
	super.OnInit();

	CacheChains();
	FillChainsList();

	if (ChainToFocusOnInit.ObjectID > 0)
	{
		SelectChain(ChainToFocusOnInit);
	}
}

//////////////
/// Chains ///
//////////////

simulated protected function CacheChains ()
{
	local XComGameState_ActivityChain ChainState;

	Chains.Length = 0;
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ActivityChain', ChainState)
	{
		Chains.AddItem(ChainState);
	}

	Chains.Sort(SortChainsOngoing);
}

simulated protected function FillChainsList ()
{
	local XComGameState_ActivityChain ChainState, PreviousChainState;
	local UIChainsOverview_ListSectionHeader SectionHeader;
	local UIListItemString ListItem;
	
	foreach Chains(ChainState)
	{
		if (PreviousChainState == none || PreviousChainState.bEnded != ChainState.bEnded)
		{
			SectionHeader = Spawn(class'UIChainsOverview_ListSectionHeader', ChainsList.ItemContainer);
			SectionHeader.InitHeader();
			SectionHeader.SetText(ChainState.bEnded ? strEnded : strOngoing);
		}

		ListItem = Spawn(class'UIListItemString', ChainsList.ItemContainer);
		ListItem.metadataInt = ChainState.ObjectID;
		ListItem.InitListItem(ChainState.GetMyTemplate().strTitle);

		PreviousChainState = ChainState;
	}

	ChainsList.Navigator.SelectFirstAvailableIfNoCurrentSelection();
}

simulated function SelectChain (StateObjectReference ChainRef)
{
	local UIListItemString ListItem;
	local UIPanel Panel;
	local int i;

	foreach ChainsList.ItemContainer.ChildPanels(Panel, i)
	{
		ListItem = UIListItemString(Panel);
		if (ListItem == none) continue;

		if (ListItem.metadataInt == ChainRef.ObjectID)
		{
			ChainsList.SetSelectedIndex(i);
			return;
		}
	}

	`Redscreen("UIChainsOverview::SelectChain: Failed to find chain with ObjectID" @ ChainRef.ObjectID);
}

//////////////////
/// Activities ///
//////////////////

simulated protected function OnChainSelection (UIList ContainerList, int ItemIndex)
{
	local XComGameState_ActivityChain ChainState;
	local XComGameState_Activity ActivityState;
	local XComGameStateHistory History;

	local UIChainsOverview_Activity ActivityElement;
	local UIListItemString ChainListItem;
	local int i;

	History = `XCOMHISTORY;
	ChainPanel.Hide();
	ChainPanel.DisableNavigation();

	ChainListItem = UIListItemString(ContainerList.GetItem(ItemIndex));
	if (ChainListItem == none) return;

	ChainState = XComGameState_ActivityChain(History.GetGameStateForObjectID(ChainListItem.metadataInt));
	if (ChainState == none) return;

	// Chain info
	ChainHeader.SetText(ChainState.GetOverviewTitle(), ChainState.GetOverviewDescription());

	// Show/Spawn entries we need
	for (i = 0; i < ChainState.StageRefs.Length; i++)
	{
		if (i == ActivitiesList.GetItemCount())
		{
			ActivityElement = Spawn(class'UIChainsOverview_Activity', ActivitiesList.ItemContainer);
			ActivityElement.InitActivity();
		}
		else
		{
			ActivityElement = UIChainsOverview_Activity(ActivitiesList.GetItem(i));
		}

		ActivityState = XComGameState_Activity(History.GetGameStateForObjectID(ChainState.StageRefs[i].ObjectID));
		ActivityElement.UpdateFromState(ActivityState);

		ActivityElement.Show();
		ActivityElement.EnableNavigation();
	}

	// Hide extra rows
	for (i = ChainState.StageRefs.Length; i < ActivitiesList.GetItemCount(); i++)
	{
		ActivitiesList.GetItem(i).Hide();
		ActivitiesList.GetItem(i).DisableNavigation();
	}

	// This is required so that we don't wait a frame for the descriptions size to realize
	Movie.ProcessQueuedCommands();
}

simulated function OnActivitySizeRealized (UIChainsOverview_Activity Activity)
{
	local UIChainsOverview_Activity ActivityElement;
	local UIPanel Panel;

	// Check if all activities are realized
	foreach ActivitiesList.ItemContainer.ChildPanels(Panel)
	{
		if (!Panel.bIsVisible) continue;

		ActivityElement = UIChainsOverview_Activity(Panel);
		if (ActivityElement == none) continue;

		if (ActivityElement.bSizeRealizePending) return;
	}

	// All activities are realized, now realize the list
	ActivitiesList.RealizeItems();
	ActivitiesList.RealizeList();

	// Animate in the elements
	foreach ActivitiesList.ItemContainer.ChildPanels(Panel)
	{
		Panel.AnimateIn();
	}

	ChainPanel.Show();
	ChainPanel.EnableNavigation();
}

/////////////
/// Input ///
/////////////

simulated function bool OnUnrealCommand (int cmd, int arg)
{
	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return false;

	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			CloseScreen();
			return true;
	}

	return super.OnUnrealCommand(cmd, arg);
}

simulated function UpdateNavHelp ()
{
	local UINavigationHelp NavHelp;

	NavHelp = `HQPRES.m_kAvengerHUD.NavHelp;
	NavHelp.ClearButtonHelp();
	NavHelp.AddBackButton(CloseScreen);

	if (!bInstantInterp)
	{
		NavHelp.AddGeoscapeButton();
	}
}

simulated event Removed()
{
	super.Removed();

	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
	RestoreEarthViewIfNeeded();
}

////////////////////////////////
/// Camera fix for UIMission ///
////////////////////////////////

simulated protected function SaveEarthViewIfNeeded ()
{
	local XComEarth Earth;

	if (!bRestoreCamEarthViewOnClose) return;

	Earth = `EARTH;
	EarthSavedViewLoc = Earth.GetViewLocation();
	EarthSavedZoom = Earth.fTargetZoom;
}

simulated protected function RestoreEarthViewIfNeeded ()
{
	if (!bRestoreCamEarthViewOnClose) return;

	`HQPRES.CAMLookAtEarth(EarthSavedViewLoc, EarthSavedZoom, 0);
	`HQPRES.GetCamera().ForceEarthViewImmediately(false);
}

///////////////
/// Sorting ///
///////////////

function int SortChainsOngoing (XComGameState_ActivityChain ChainA, XComGameState_ActivityChain ChainB)
{
	if (ChainA.bEnded && !ChainB.bEnded)
	{
		return -1;
	}
	else if (!ChainA.bEnded && ChainB.bEnded)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

defaultproperties
{
	InputState = eInputState_Consume
}