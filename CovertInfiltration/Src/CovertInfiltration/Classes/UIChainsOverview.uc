class UIChainsOverview extends UIScreen;

var UIList ChainsList;
var UIList ActivitiesList;

var array<XComGameState_ActivityChain> Chains;

var localized string strOngoing;
var localized string strEnded;

////////////
/// Init ///
////////////

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	BuildScreen();
}

simulated protected function BuildScreen ()
{
	ChainsList = Spawn(class'UIList', self);
	ChainsList.OnSetSelectedIndex = OnChainSelection;
	ChainsList.InitList('ChainsList',,,,,, true);
	ChainsList.SetPosition(500, 220);
	ChainsList.SetSize(400, 630);

	ActivitiesList = Spawn(class'UIList', self);
	ActivitiesList.InitList('ActivitiesList',,,,,, true);
	ActivitiesList.SetPosition(930, 220);
	ActivitiesList.SetSize(580, 630);
	ActivitiesList.Hide();

	Navigator.HorizontalNavigation = true;
}

simulated function OnInit()
{
	super.OnInit();

	CacheChains();
	FillChainsList();
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
	local UIX2PanelHeader SectionHeader;
	local UIListItemString ListItem;
	
	foreach Chains(ChainState)
	{
		if (PreviousChainState == none || PreviousChainState.bEnded != ChainState.bEnded)
		{
			SectionHeader = Spawn(class'UIX2PanelHeader', ChainsList.ItemContainer);
			SectionHeader.bIsNavigable = false;
			SectionHeader.InitPanelHeader(, ChainState.bEnded ? strEnded : strOngoing);
			SectionHeader.SetHeaderWidth(ChainsList.Width);
		}

		ListItem = Spawn(class'UIListItemString', ChainsList.ItemContainer);
		ListItem.metadataInt = ChainState.ObjectID;
		ListItem.InitListItem(ChainState.GetMyTemplate().Title);

		PreviousChainState = ChainState;
	}
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

	ChainListItem = UIListItemString(ContainerList.GetItem(ItemIndex));
	if (ChainListItem == none)
	{
		ActivitiesList.Hide();
		return;
	}

	ChainState = XComGameState_ActivityChain(History.GetGameStateForObjectID(ChainListItem.metadataInt));
	if (ChainState == none)
	{
		ActivitiesList.Hide();
		return;
	}

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
		ActivityElement.AnimateIn();
		ActivityElement.EnableNavigation();
	}

	// Hide extra rows
	for (i = ChainState.StageRefs.Length; i < ActivitiesList.GetItemCount(); i++)
	{
		ActivitiesList.GetItem(i).Hide();
		ActivitiesList.GetItem(i).DisableNavigation();
	}

	ActivitiesList.Show();
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