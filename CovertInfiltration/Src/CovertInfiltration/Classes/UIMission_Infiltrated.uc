//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Screen for launching an infiltrated mission
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIMission_Infiltrated extends UIMission;

var public localized string m_strResOpsMission;
var public localized string m_strImageGreeble;

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

	// TODO: Remove the faction title BG
}

simulated function BuildMissionPanel()
{
	//local XComGameState_ResistanceFaction FactionState;

	//FactionState = GetMission().GetResistanceFaction();

	LibraryPanel.MC.BeginFunctionOp("UpdateMissionInfoBlade");
	LibraryPanel.MC.QueueString("MISSION READY");
	LibraryPanel.MC.QueueString(""); // Handled by SetFactionIcon
	LibraryPanel.MC.QueueString(""); // FactionState.GetFactionTitle()
	LibraryPanel.MC.QueueString(""); // FactionState.GetFactionName()
	LibraryPanel.MC.QueueString(GetMissionImage()); // FactionState.GetLeaderImage()
	LibraryPanel.MC.QueueString(GetOpName());
	LibraryPanel.MC.QueueString(m_strMissionObjective);
	LibraryPanel.MC.QueueString(GetObjectiveString());
	LibraryPanel.MC.QueueString(m_strReward);
	LibraryPanel.MC.EndOp();
	
	UpdateRewards(); 

	//SetFactionIcon(FactionState.GetFactionIcon());

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
	LibraryPanel.MC.QueueString("INFILTRATION"); // m_strResOpsMission
	LibraryPanel.MC.QueueString(m_strLaunchMission);
	LibraryPanel.MC.QueueString("Return to Avenger"); // m_strIgnore
	LibraryPanel.MC.EndOp();
}

function SetFactionIcon(StackedUIIconData factionIcon)
{
	local int i;
	LibraryPanel.MC.BeginFunctionOp("SetFactionIcon");

	LibraryPanel.MC.QueueBoolean(factionIcon.bInvert);
	for (i = 0; i < factionIcon.Images.Length; i++)
	{
		LibraryPanel.MC.QueueString("img:///" $ factionIcon.Images[i]);
	}
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

	// Close the map as well - go back to avenger
	Movie.Stack.GetFirstInstanceOf(class'UIStrategyMap').CloseScreen();
}

//-------------- GAME DATA HOOKUP --------------------------------------------------------
simulated function EUIState GetLabelColor()
{
	return eUIState_Normal;
}
//==============================================================================

defaultproperties
{
	Package = "/ package/gfxXPACK_Alerts/XPACK_Alerts";
	InputState = eInputState_Consume;
}