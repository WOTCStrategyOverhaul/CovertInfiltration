//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Screen for launching an infiltrated mission
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIMission_Infiltrated extends UIMission;

var UIPanel OverInfiltrationPanel;
var UIBGBox OverInfiltrationBG;
var UIX2PanelHeader OverInfiltrationHeader;

var localized string strOverInfiltrationHeader;
var localized string strOverInfiltrationNextBonus;
var localized string strMissionReady;
var localized string strInfiltration;
var localized string strWait;
var localized string strReturnToAvenger;

//----------------------------------------------------------------------------
// MEMBERS

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

//bsg-crobinson (5.12.17): Dont refresh navigation for this screen
simulated function RefreshNavigation()
{
	super.RefreshNavigation();

	if(`ISCONTROLLERACTIVE)
	{
		Button1.SetStyle(eUIButtonStyle_HOTLINK_WHEN_SANS_MOUSE);
		Button1.SetGamepadIcon("");
		Button1.SetPosition(-90,0);
		Button1.SetText(class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Input'.static.GetAdvanceButtonIcon(),20,20,-10) @ m_strLaunchMission);

		Button2.SetStyle(eUIButtonStyle_HOTLINK_WHEN_SANS_MOUSE);
		Button2.SetGamepadIcon("");
		Button2.SetPosition(-55,25);
		Button2.SetText(class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Input'.static.GetBackButtonIcon(),20,20,-10) @ m_strIgnore);

		Navigator.Clear();
	}
}
//bsg-crobinson (5.12.17): end

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
	LibraryPanel.MC.BeginFunctionOp("UpdateMissionButtonBlade");
	LibraryPanel.MC.QueueString(strInfiltration @ "-" @ GetInfiltration().GetCurrentInfilInt() $ "%"); // m_strResOpsMission
	LibraryPanel.MC.QueueString(m_strLaunchMission);
	LibraryPanel.MC.QueueString(GetInfiltration().MustLaunch() ? strReturnToAvenger : strWait); // m_strIgnore
	LibraryPanel.MC.EndOp();
}

simulated function OnButtonSizeRealized()
{
	//Override - do nothing
}

//-------------- EVENT HANDLING --------------------------------------------------------
simulated public function OnLaunchClicked(UIButton button)
{
	local XComGameState_MissionSiteInfiltration MissionSite;
	
	CloseScreen();

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
	super.CloseScreen();

	if (GetInfiltration().MustLaunch())
	{
		// Close the map as well - go back to avenger
		Movie.Stack.GetFirstInstanceOf(class'UIStrategyMap').CloseScreen();
	}
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

defaultproperties
{
	Package = "/ package/gfxXPACK_Alerts/XPACK_Alerts";
	InputState = eInputState_Consume;
}