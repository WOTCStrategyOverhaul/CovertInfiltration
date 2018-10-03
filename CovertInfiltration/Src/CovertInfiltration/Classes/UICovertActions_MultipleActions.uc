class UICovertActions_MultipleActions extends UICovertActions config(GameData);

var config int MAX_ACTIONS_GLOBAL;
var config array<int> MAX_ACTIONS_PERFACTION;
var config array<name> GLOBAL_ACTIONS_UPGRADE;

function int GetMaxGlobalActions()
{
	local name UpgradeName;
	local int Modifier;

	Modifier = 0;
	foreach GLOBAL_ACTIONS_UPGRADE(UpgradeName)
	{
		if (`XCOMHQ.HasFacilityByName(UpgradeName) || `XCOMHQ.HasFacilityUpgradeByName(UpgradeName) || `XCOMHQ.IsTechResearched(UpgradeName))
		{
			Modifier++;
		}
	}
	return MAX_ACTIONS_GLOBAL + Modifier;
}

function name CanStartCovertAction(XComGameState_CovertAction ActionToStart)
{
	local XComGameStateHistory History;
	local XComGameState_CovertAction ActionState;
	local int GlobalActions, LocalActions;

	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if (ActionState.bStarted)
		{
			GlobalActions++;
			if (ActionState.Faction.ObjectID == ActionToStart.Faction.ObjectID)
			{
				LocalActions++;
			}
		}
	}
	//`log("Faction Name:" @ ActionToStart.GetFaction().GetFactionName(),, 'MultCovertActions');
	//`log("Faction Influence:" @ string(EFactionInfluence(ActionToStart.GetFaction().GetInfluence())) @ "(" $ int(ActionToStart.GetFaction().GetInfluence()) $ ")",, 'MultCovertActions');
	//`log("MAX:" @ MAX_ACTIONS_PERFACTION[int(ActionToStart.GetFaction().GetInfluence())],, 'MultCovertActions');

	if (GlobalActions >= GetMaxGlobalActions())
	{
		if (GetMaxGlobalActions() > 1)
			return 'AA_GlobalActionsMax';
		else
			return 'AA_OneActionMax';
	}
	if (LocalActions >= MAX_ACTIONS_PERFACTION[int(ActionToStart.GetFaction().GetInfluence())])
		return 'AA_FactionActionMax';
	return 'AA_Success';
}

function string GetCovertActionError(name ErrorName)
{
	switch (ErrorName)
	{
		case 'AA_OneActionMax':
			return CovertActions_ActionInProgressTooltip;
		case 'AA_GlobalActionsMax':
			return "Maximum number of Covert Action is in progress.";
		case 'AA_FactionActionMax':
			return "Maximum number of Covert Action for this faction's influence is in progress.";
		default:
			break;
	}
	return CovertActions_Unavailable;
}

function BuildScreen()
{
	local name LastFactionName, ErrorName;
	local int idx;
	local UIListItemString Item;
	local UICovertOpsFactionListItem listHeader;
	local bool bNormalList;

	`XSTRATEGYSOUNDMGR.PlayPersistentSoundEvent("UI_CovertOps_Open");
	
	CreateSlotContainer();

	if( List == None )
	{
		List = Spawn(class'UIList', self);
		List.InitList('stageListMC'); 
		List.bStickyClickyHighlight = true;
		List.bStickyHighlight = false;
		List.OnSetSelectedIndex = SelectedItemChanged;

		//bsg-jneal (2.17.17): selection changed update for controller
		if(`ISCONTROLLERACTIVE)
			List.OnSelectionChanged = SelectedItemChanged;
		else
			List.OnItemClicked = SelectedItemChanged;
		//bsg-jneal (2.17.17): end

		Navigator.SetSelected(List);
		List.SetSize(438, 638);
	}

	for( idx = 0; idx < arrActions.Length; idx++ )
	{
		if (arrActions[idx].GetFaction().GetMyTemplateName() != LastFactionName)
		{
			listHeader = Spawn(class'UICovertOpsFactionListItem', List.itemContainer);
			LastFactionName = arrActions[idx].GetFaction().GetMyTemplateName();
			if (arrActions[idx].bStarted)
			{
				listHeader.InitCovertOpsListItem(arrActions[idx].GetFaction().FactionIconData, CovertActions_CurrentActiveHeader, class'UIUtilities_Colors'.const.COVERT_OPS_HTML_COLOR);
			}
			else
			{
				bNormalList = true;				
				listHeader.InitCovertOpsListItem(arrActions[idx].GetFaction().FactionIconData, Caps(arrActions[idx].GetFaction().GetFactionTitle()), class'UIUtilities_Colors'.static.GetColorForFaction(LastFactionName));
			}

			listHeader.DisableNavigation(); //bsg-jneal (2.17.17): disable faction headers in the list so they get skipped over for navigation
		}

		if (!bNormalList && !arrActions[idx].bStarted)
		{
			LastFactionName = '';
			idx--;
			continue;
		}

		Item = Spawn(class'UIListItemString', List.itemContainer);
		Item.InitListItem(GetActionLocString(idx));
		Item.metadataInt = arrActions[idx].ObjectID;

		ErrorName = CanStartCovertAction(arrActions[idx]);
		if( ErrorName != 'AA_Success' && !arrActions[idx].bStarted)
		{
			Item.SetDisabled(true, GetCovertActionError(ErrorName));
		}
		else if (!IsActionInfluenceMet(idx)) // If the covert action requires a higher influence level, disable the button
		{
			Item.SetDisabled(true, CovertActions_InfluenceRequiredTooltip);
		}
		if( List.GetSelectedItem() == None )
		{
			List.SetSelectedItem(Item);
		}
	}
}

function UpdateData()
{
	// Update data values before the UI panels are refreshed
	bHasRewards = DoesActionHaveRewards();
	bHasRisks = DoesActionHaveRisks();

	RefreshMainPanel();
	RefreshFactionPanel();
	RefreshRisksPanel();

	RealizeSlots();

	RefreshNavigation();
	
	// bsg-jrebar (3/30/17) : Disable buttons 
	if (CanStartCovertAction(GetAction()) != 'AA_Success' || !IsInfluenceMet()) 
	{
		//Disable Slots
		SlotContainer.DisableAllSlots();
		LaunchButton.Hide();
	}
	else
	{
		// Enable Slots
		SlotContainer.EnableAllSlots();
		LaunchButton.Show();
	}
	// bsg-jrebar (3/30/17) : end 
}

simulated function RefreshMainPanel()
{
	local string Duration; 
	local name ErrorName;

	if( bHasRewards )
		AS_SetInfoData(GetActionImage(), GetActionName(), GetActionDescription(), CovertActions_RewardHeader, GetRewardString(), GetRewardDetailsString(), Caps(GetWorldLocation()));
	else
		AS_SetInfoData(GetActionImage(), GetActionName(), GetActionDescription(), "", "", "", "");

	ErrorName = CanStartCovertAction(GetAction());
	if (ErrorName != 'AA_Success' && !GetAction().bStarted)
	{
		AS_SetLockData(CovertActions_Unavailable, GetCovertActionError(ErrorName));
	}
	else if (!IsInfluenceMet()) // If the covert action requires a higher influence level, disable the button
	{
		AS_SetLockData(CovertActions_Unavailable, CovertActions_InfluenceRequiredTooltip);
	}
	else
	{
		AS_SetLockData("", "");
	}

	Duration = GetDurationString();
	AS_UpdateCost(Duration);
}

simulated function FindActions()
{
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_CovertAction ActionState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if (ActionState.bStarted && !ActionState.bCompleted) // SHOW ALL IN PROGRESS ACTIONS
		{
			arrActions.InsertItem(0, ActionState); // Always place any currently running Covert Action at the top of the list
			bActionInProgress = true;
		}
		else
		{
			// Only display actions which are actually stored by the Faction. Safety check to prevent
			// actions which were supposed to have been deleted from showing up in the UI and being accessed.
			FactionState = ActionState.GetFaction();
			if (FactionState.CovertActions.Find('ObjectID', ActionState.ObjectID) != INDEX_NONE ||
				FactionState.GoldenPathActions.Find('ObjectID', ActionState.ObjectID) != INDEX_NONE)
			{
				if (ActionState.CanActionBeDisplayed() && (ActionState.GetMyTemplate().bGoldenPath || FactionState.bSeenFactionHQReveal))
				{
					arrActions.AddItem(ActionState);
					if( ActionState.bNewAction)
					{
						NewActionFactions.AddItem(ActionState.GetFaction());
					}
				}
		}
	}
	}

	arrActions.Sort(SortActionsByFactionName);
	arrActions.Sort(SortActionsByFarthestFaction);
	arrActions.Sort(SortActionsByFactionMet);
	arrActions.Sort(SortActionsStarted);

	ActionRef = arrActions[0].GetReference();
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return true; //bsg-jneal (4.25.17): conume the input if repeating

	bHandled = true;

	switch (cmd)
	{
	case class'UIUtilities_Input'.const.FXS_BUTTON_A : //bsg-cballinger (2.8.17): Button swapping should only be handled in XComPlayerController, to prevent double-swapping back to original value.
	case class'UIUtilities_Input'.const.FXS_KEY_ENTER :
	case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR :
		//bsg-jneal (3.10.17): adding controller navigation support for staff slots
		if(SlotContainer.ActionSlots.Length > 0 && CanStartCovertAction(GetAction()) == 'AA_Success' )
		{
			if( bIsSelectingSlots )
			{
				SlotContainer.ActionSlots[SlotContainer.Navigator.SelectedIndex].HandleClick("theButton"); //bsg-jneal (4.25.17): use slot container navigator since navtargets are only reference direct parents and not parents of parents
			}
			else
			{
				SelectStaffSlots();
			}
		}

		bHandled = true;
		break;
	default:
		bHandled = false;
		break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}
