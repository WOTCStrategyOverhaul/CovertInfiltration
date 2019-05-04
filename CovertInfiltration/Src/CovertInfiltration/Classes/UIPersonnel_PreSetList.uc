class UIPersonnel_PreSetList extends UIPersonnel;

simulated function PrepareFromArray(array<StateObjectReference> UnitRefs)
{
	local XComGameStateHistory Histroy;
	local StateObjectReference UnitRef;
	local XComGameState_Unit UnitState;

	if (bIsInited)
	{
		`RedScreen("Calling UIPersonnel_PreSetList::PrepareFromArray after the screen was intialized is not allowed");
		return;
	}

	// Destroy old data
	m_arrSoldiers.Length = 0;
	m_arrScientists.Length = 0;
	m_arrEngineers.Length = 0;
	m_arrDeceased.Length = 0;

	Histroy = `XCOMHISTORY;

	foreach UnitRefs(UnitRef)
	{
		UnitState = XComGameState_Unit(Histroy.GetGameStateForObjectID(UnitRef.ObjectID));
		if (UnitState == none) continue;

		if (UnitState.IsDead())
		{
			m_arrDeceased.AddItem(UnitRef);
		}
		else if (UnitState.IsEngineer())
		{
			m_arrEngineers.AddItem(UnitRef);
		}
		else if (UnitState.IsScientist())
		{
			m_arrScientists.AddItem(UnitRef);
		}
		else if (UnitState.IsSoldier())
		{
			m_arrSoldiers.AddItem(UnitRef);
		}
		else
		{
			`RedScreen("UIPersonnel_PreSetList:" @ UnitState.GetFullName() @ "is a very weird unit");
		}
	}

	// Check what we have
	m_arrNeededTabs.Length = 0;

	if (m_arrSoldiers.Length > 0)
	{
		m_arrNeededTabs.AddItem(eUIPersonnel_Soldiers);
	}

	if (m_arrScientists.Length > 0)
	{
		m_arrNeededTabs.AddItem(eUIPersonnel_Scientists);
	}
	
	if (m_arrEngineers.Length > 0)
	{
		m_arrNeededTabs.AddItem(eUIPersonnel_Engineers);
	}
	
	if (m_arrDeceased.Length > 0)
	{
		m_arrNeededTabs.AddItem(eUIPersonnel_Engineers);
	}

	// Set list type

	if (m_arrNeededTabs.Length > 1)
	{
		m_eListType = eUIPersonnel_All;
	}
	else if (m_arrNeededTabs.Length == 0)
	{
		// Do nothing, InitScreen will spew a redscreen
	}
	else
	{
		m_eListType = m_arrNeededTabs[0];
	}
}

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super(UIScreen).InitScreen(InitController, InitMovie, InitName);
	
	if (m_arrNeededTabs.Length == 0)
	{
		`RedScreen("UIPersonnel_PreSetList launched without setting list of units or empty list of units. Showing empty list of soldiers");
		m_arrNeededTabs.AddItem(eUIPersonnel_Soldiers);
		m_eListType = eUIPersonnel_Soldiers;
	}

	// Prepare list

	ListBG = Spawn(class'UIPanel', self);
	ListBG.InitPanel('SoldierListBG'); 
	ListBG.bShouldPlayGenericUIAudioEvents = false;
	ListBG.Show();

	m_kList = Spawn(class'UIList', self);
	m_kList.bIsNavigable = true;
	m_kList.InitList('listAnchor',,, m_iMaskWidth, m_iMaskHeight);
	m_kList.bStickyHighlight = false;
	
	ListBG.ProcessMouseEvents(m_kList.OnChildMouseEvent);

	// Tabs

	if( m_arrNeededTabs.Find(eUIPersonnel_Soldiers) != INDEX_NONE )
	{
		m_arrTabButtons[eUIPersonnel_Soldiers] = CreateTabButton('SoldierTab', m_strSoldierTab, SoldiersTab);
		m_arrTabButtons[eUIPersonnel_Soldiers].bIsNavigable = false;
	}

	if( m_arrNeededTabs.Find(eUIPersonnel_Engineers) != INDEX_NONE )
	{
		m_arrTabButtons[eUIPersonnel_Engineers] = CreateTabButton('EngineerTab', m_strEngineerTab, EngineersTab);
		m_arrTabButtons[eUIPersonnel_Engineers].bIsNavigable = false;
	}

	if( m_arrNeededTabs.Find(eUIPersonnel_Scientists) != INDEX_NONE )
	{
		m_arrTabButtons[eUIPersonnel_Scientists] = CreateTabButton('ScientistTab', m_strScientistTab, ScientistTab);
		m_arrTabButtons[eUIPersonnel_Scientists].bIsNavigable = false;
	}

	if( m_arrNeededTabs.Find(eUIPersonnel_Deceased) != INDEX_NONE )
	{
		m_arrTabButtons[eUIPersonnel_Deceased] = CreateTabButton('DeceasedTab', m_strDeceasedTab, DeceasedTab);
		m_arrTabButtons[eUIPersonnel_Deceased].bIsNavigable = false;
	}

	// Unfortunately, this is used by many a thing to check objectives progression
	// Much easier to do this here instead of overriding multiple functions
	HQState = class'UIUtilities_Strategy'.static.GetXComHQ();

	// Misc

	CreateSortHeaders();
	UpdateNavHelp();
	RefreshTitle();
	SpawnNavHelpIcons();
	
	if(m_eListType != eUIPersonnel_All)
		SwitchTab(m_eListType);
	else
		SwitchTab(m_arrNeededTabs[0]);

	if (!`ISCONTROLLERACTIVE)
	{
		EnableNavigation();

		Navigator.LoopSelection = true;
		Navigator.SelectedIndex = 0;
		Navigator.OnSelectedIndexChanged = SelectedHeaderChanged;
	}
}

simulated function UpdateData()
{
	// No-op
}