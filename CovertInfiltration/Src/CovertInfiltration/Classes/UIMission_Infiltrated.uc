//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Screen for launching an infiltrated mission
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIMission_Infiltrated extends UIMission;

var UIButton ViewSquadButton;

var UIPanel OverInfiltrationPanel;
var UIBGBox OverInfiltrationBG;
var UIX2PanelHeader OverInfiltrationHeader;

var localized string strOverInfiltrationHeader;
var localized string strOverInfiltrationNextBonus;
var localized string strMissionReady;
var localized string strInfiltration;
var localized string strWait;
var localized string strReturnToAvenger;

const BUTTON_X = -175;
const BUTTON_WIDTH = 350;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	BuildScreen();

	`XSTRATEGYSOUNDMGR.SetSwitch('StrategyScreen', 'Avenger');
	`XSTRATEGYSOUNDMGR.SetSwitch('HQChapter', 'Chapter03');
}

simulated function Name GetLibraryID()
{
	return 'XPACK_Alert_MissionBlades';
}

simulated function BuildScreen()
{
	// Add Interception warning and Shadow Chamber info 
	super.BuildScreen();

	PlaySFX("Geoscape_NewResistOpsMissions");

	XComHQPresentationLayer(Movie.Pres).CAMSaveCurrentLocation();

	if (bInstantInterp)
	{
		XComHQPresentationLayer(Movie.Pres).CAMLookAtEarth(GetMission().Get2DLocation(), CAMERA_ZOOM, 0);
	}
	else
	{
		XComHQPresentationLayer(Movie.Pres).CAMLookAtEarth(GetMission().Get2DLocation(), CAMERA_ZOOM);
	}


	if (GetInfiltration().GetNextOverInfiltrationBonus() != none)
	{
		OverInfiltrationPanel = Spawn(class'UIPanel', self);
		OverInfiltrationPanel.InitPanel('OverInfiltrationPanel');
		OverInfiltrationPanel.SetPosition(725, 736);

		OverInfiltrationBG = Spawn(class'UIBGBox', OverInfiltrationPanel);
		OverInfiltrationBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
		OverInfiltrationBG.InitBG('BG', 0, 0, 470, 130);

		OverInfiltrationHeader = Spawn(class'UIX2PanelHeader', OverInfiltrationPanel);
		OverInfiltrationHeader.InitPanelHeader('Header', strOverInfiltrationHeader, GetOverInfiltrationText());
		OverInfiltrationHeader.SetHeaderWidth(OverInfiltrationBG.Width - 20);
		OverInfiltrationHeader.SetPosition(OverInfiltrationBG.X + 10, OverInfiltrationBG.Y + 10);
		OverInfiltrationHeader.Show();
	}

	// There is no navigation on this screen.
	// Also, this fixes selecting "cancel" via keyboard and hitting enter which uses "confirm" button
	Navigator.Clear();

	// Note that the "View chain" button is handled in UIListener_Mission
}

simulated function string GetOverInfiltrationText()
{
	local X2OverInfiltrationBonusTemplate NextBonus;
	
	NextBonus = GetInfiltration().GetNextOverInfiltrationBonus();

	return 
		strOverInfiltrationNextBonus
		@ "(" $ GetInfiltration().GetNextThreshold() $ "%):"
		@ NextBonus.GetBonusName() $ "\n"
		$ NextBonus.GetBonusDescription();
}

simulated function BuildMissionPanel()
{
	LibraryPanel.MC.BeginFunctionOp("UpdateMissionInfoBlade");
	LibraryPanel.MC.QueueString(strMissionReady);
	LibraryPanel.MC.QueueString(""); // Handled by SetFactionIcon
	LibraryPanel.MC.QueueString(m_strMissionDifficulty); // FactionState.GetFactionTitle()
	LibraryPanel.MC.QueueString(GetDifficultyString()); // FactionState.GetFactionName()
	LibraryPanel.MC.QueueString(GetMissionImage()); // FactionState.GetLeaderImage()
	LibraryPanel.MC.QueueString(GetOpName());
	LibraryPanel.MC.QueueString(m_strMissionObjective);
	LibraryPanel.MC.QueueString(GetObjectiveString());
	LibraryPanel.MC.QueueString(m_strReward);
	LibraryPanel.MC.EndOp();
	
	// Since we don't have a faction icon, move the mission text to left
	LibraryPanel.MC.ChildSetNum("factionGroup.factionLabel", "_x", 0);
	LibraryPanel.MC.ChildSetNum("factionGroup.factionName", "_x", 0);

	UpdateRewards(); 

	Button1.OnClickedDelegate = OnLaunchClicked;
	Button2.OnClickedDelegate = OnCancelClicked;

	Button3.Hide();
	ConfirmButton.Hide();
}

function UpdateRewards()
{
	local XComGameState_MissionSite Mission; 
	local XComGameState_Reward RewardState;
	local XComGameStateHistory History;
	local int idx, iSlot;

	History = `XCOMHISTORY;
	iSlot = 0; 
	Mission = GetMission();

	for( idx = 0; idx <Mission.Rewards.Length; idx++ )
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(Mission.Rewards[idx].ObjectID));

		if( RewardState != none )
		{
			UpdateMissionReward(iSlot, RewardState.GetRewardString(), RewardState.GetRewardIcon());
			iSlot++;
		}
	}
}

function UpdateMissionReward(int numIndex, string strLabel, string strRank, optional string strClass)
{
	LibraryPanel.MC.BeginFunctionOp("UpdateMissionReward");
	LibraryPanel.MC.QueueNumber(numIndex);
	LibraryPanel.MC.QueueString(strLabel);
	LibraryPanel.MC.QueueString(strRank); //optional
	LibraryPanel.MC.QueueString(strClass); //optional
	LibraryPanel.MC.EndOp();
}

simulated function BuildOptionsPanel()
{
	// The flash side is setup... very interestingly
	// Yes, veeeeeryyyyyyy interestingly
	// So screw it all, I'll fix it manually
	// ViewSquadButton is obviously custom
	
	ViewSquadButton = Spawn(class'UIButton', ButtonGroup);
	ViewSquadButton.InitButton('ViewSquadButton', "VIEW SQUAD", OnViewSquad);
	ViewSquadButton.SetStyle(eUIButtonStyle_HOTLINK_BUTTON);
	ViewSquadButton.SetGamepadIcon(class'UIUtilities_Input'.const.ICON_X_SQUARE);
	ViewSquadButton.SetResizeToText(false);
	ViewSquadButton.SetOrigin(class'UIUtilities'.const.ANCHOR_MIDDLE_CENTER);
	ViewSquadButton.SetPosition(BUTTON_X, -35);
	ViewSquadButton.SetWidth(BUTTON_WIDTH);

	Button1.SetStyle(eUIButtonStyle_HOTLINK_BUTTON);
	Button1.SetText(m_strLaunchMission);
	Button1.SetWidth(BUTTON_WIDTH);
	Button1.SetPosition(BUTTON_X, 0);
	Button1.Hide();

	Button2.SetStyle(eUIButtonStyle_HOTLINK_BUTTON);
	Button2.SetText(GetInfiltration().MustLaunch() ? strReturnToAvenger : strWait);
	Button2.SetWidth(BUTTON_WIDTH);
	Button2.SetPosition(BUTTON_X, 35);
	Button2.Hide();

	// This call will hide the buttons on flash side, so I hid them above so that unreal isn't confused
	// We cannot actually set the button labels here as that will screw up controller positioning
	LibraryPanel.MC.FunctionString(
		"UpdateMissionButtonBlade",
		GetButtonBladeTitle(GetInfiltration().GetCurrentInfilInt(), GetInfiltration().MaxAllowedInfil)
	);

	if (`ISCONTROLLERACTIVE)
	{
		Button1.SetResizeToText(true);
		Button1.OnSizeRealized = OnButton1SizeRealized;

		Button2.SetResizeToText(true);
		Button2.OnSizeRealized = OnButton2SizeRealized;

		ViewSquadButton.Hide();
		ViewSquadButton.SetResizeToText(true);
		ViewSquadButton.OnSizeRealized = OnViewSquadButtonSizeRealized;
	}
	else
	{
		Button1.Show();
		Button2.Show();
	}
}

static function string GetButtonBladeTitle (int CurrentInfil, int MaxInfil)
{
	local XGParamTag ParamTag;

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = CurrentInfil;
	ParamTag.IntValue1 = MaxInfil;

	return `XEXPAND.ExpandString(default.strInfiltration);
}

simulated function OnButton1SizeRealized()
{
	// Buttons are center-anchored
	Button1.SetX(-Button1.Width / 2);
	Button1.Show();
}

simulated function OnButton2SizeRealized()
{
	// Buttons are center-anchored
	Button2.SetX(-Button2.Width / 2);
	Button2.Show();
}

simulated function OnViewSquadButtonSizeRealized()
{
	// Buttons are center-anchored
	ViewSquadButton.SetX(-ViewSquadButton.Width / 2);
	ViewSquadButton.Show();
}

simulated function RefreshNavigation()
{
	// Override - do nothing
}

simulated function OnButtonSizeRealized()
{
	// Override - do nothing
}

// INPUT

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	if(!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return false;

	switch(cmd)
	{
	case class'UIUtilities_Input'.static.GetAdvanceButtonInputCode():
	case class'UIUtilities_Input'.const.FXS_KEY_ENTER:
	case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
		Button1.OnClickedDelegate(Button1);
		return true;

	case class'UIUtilities_Input'.static.GetBackButtonInputCode():
	case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
	case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
		if(CanBackOut())
		{
			CloseScreen();
		}
		return true;

	case class'UIUtilities_Input'.const.FXS_BUTTON_L3 :
		if (SitrepPanel.bIsVisible)
		{
			SitrepPanel.OnInfoButtonMouseEvent(SitrepPanel.InfoButton);
		}
		return true;
	

	case class'UIUtilities_Input'.const.FXS_BUTTON_X:
		ViewSquadButton.Click();
		return true;
	}

	return super.OnUnrealCommand(cmd, arg);
}

//-------------- EVENT HANDLING --------------------------------------------------------
simulated public function OnLaunchClicked(UIButton button)
{
	local XComGameState_MissionSiteInfiltration MissionSite;
	
	CloseScreenOnly();

	// TODO: Music. The geoscape music in dropship sounds very weird but the start of SS music is also rather not fitting.
	// Maybe move it to when the screen opens? But happens then if player exits to avenger and then back?
	//`XSTRATEGYSOUNDMGR.PlaySquadSelectMusic();

	// Let's try stage 3 avenger music - it's also pretty tense but not as grand/epic as squad select
	// Welp, this just kills all music :( - moved to when the screen opens
	//`XSTRATEGYSOUNDMGR.SetSwitch('StrategyScreen', 'Avenger');
	//`XSTRATEGYSOUNDMGR.SetSwitch('HQChapter', 'Chapter03');

	MissionSite = XComGameState_MissionSiteInfiltration(GetMission());
	MissionSite.SelectSquad();
	MissionSite.StartMission();
}

simulated function CloseScreen()
{
	CloseScreenOnly();

	if (GetInfiltration().MustLaunch())
	{
		// Close the map as well - go back to avenger
		Movie.Stack.GetFirstInstanceOf(class'UIStrategyMap').CloseScreen();
	}
}

// Skips closing the map, even if we must launch
simulated function CloseScreenOnly ()
{
	super.CloseScreen();
}

simulated protected function OnViewSquad(UIButton Button)
{
	class'UIUtilities_Infiltration'.static.UIPersonnel_PreSetList(GetInfiltration().SoldiersOnMission, "DEPLOYED SQUAD");
}

//-------------- GAME DATA HOOKUP --------------------------------------------------------
simulated function EUIState GetLabelColor()
{
	return eUIState_Normal;
}

simulated function XComGameState_MissionSiteInfiltration GetInfiltration()
{
	return XComGameState_MissionSiteInfiltration(GetMission());
}
//==============================================================================

///////////////////////////////////
/// Chosen on screen open/close ///
///////////////////////////////////

simulated function UpdateMissionTacticalTags()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_MissionSite MissionState;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("UIMission: UpdateMissionTacticalTags");
	MissionState = GetMission();
	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	//AlienHQ.AddChosenTacticalTagsToMission(MissionState, true);
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	// TODO
}

simulated function bool ShouldUpdateMissionSpawningInfo()
{
	// TODO

	local XComOnlineEventMgr EventManager;
	local array<X2DownloadableContentInfo> DLCInfos;
	local int i;

	// Check to see if any DLC requires schedule updates
	EventManager = `ONLINEEVENTMGR;
	DLCInfos = EventManager.GetDLCInfos(false);
	for (i = 0; i < DLCInfos.Length; ++i)
	{
		if (DLCInfos[i].ShouldUpdateMissionSpawningInfo(MissionRef))
		{
			return true;
		}
	}

	// Otherwise only update if the shadow chamber is built
	return IsShadowChamberConstructed();
}

defaultproperties
{
	Package = "/ package/gfxXPACK_Alerts/XPACK_Alerts";
	InputState = eInputState_Consume;
}