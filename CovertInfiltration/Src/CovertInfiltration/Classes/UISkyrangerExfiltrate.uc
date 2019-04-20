//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class is heavily 'inspired' by UISkyrangerArrives therefore
//           is basically the same thing without relying on mission info and 
//           used only for aborting missions from the StrategyLayer
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISkyrangerExfiltrate extends UIScreen;

var localized String strBody;
var localized String strSkyrangerExfiltrateSubtitle;
var localized String strConfirmExfiltration;

var UIPanel LibraryPanel;
var UIPanel ButtonGroup; 
var UIButton ConfirmButton, CloseScreenButton;

///////////////
/// Members ///
///////////////

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	BindLibraryItem();
	BuildScreen();
}

simulated function BindLibraryItem()
{
	LibraryPanel = Spawn(class'UIPanel', self);
	LibraryPanel.bAnimateOnInit = false;
	LibraryPanel.bCascadeFocus = false;
	LibraryPanel.InitPanel('', 'Alert_SkyrangerLanding');

	ButtonGroup = Spawn(class'UIPanel', LibraryPanel);
	ButtonGroup.bCascadeFocus = false;
	ButtonGroup.InitPanel('ButtonGroup', '');

	ConfirmButton = Spawn(class'UIButton', ButtonGroup);
	if (`ISCONTROLLERACTIVE)
	{
		ConfirmButton.InitButton('Button0', "", OnLaunchClicked, eUIButtonStyle_HOTLINK_BUTTON);
		ConfirmButton.SetGamepadIcon(class'UIUtilities_Input'.static.GetAdvanceButtonIcon());
		ConfirmButton.SetY(-ConfirmButton.Height / 2.0);
		ConfirmButton.DisableNavigation();
		
		ConfirmButton.OnSizeRealized = OnConfirmButtonSizeRealized;
		ConfirmButton.Hide();
	}
	else
	{
		ConfirmButton.SetResizeToText(false);
		ConfirmButton.InitButton('Button0', "", OnLaunchClicked);
	}

	CloseScreenButton = Spawn(class'UIButton', ButtonGroup);
	if(`ISCONTROLLERACTIVE )
	{
		CloseScreenButton.InitButton('Button1', "", OnCancelClicked, eUIButtonStyle_HOTLINK_BUTTON);
		CloseScreenButton.SetGamepadIcon(class'UIUtilities_Input'.static.GetBackButtonIcon());
		CloseScreenButton.SetX(-175.0 / 2.0);
		CloseScreenButton.SetY(CloseScreenButton.Height / 2.0);
		CloseScreenButton.DisableNavigation();

		CloseScreenButton.OnSizeRealized = OnCloseScreenButtonSizeRealized;
		CloseScreenButton.Hide();
	}
	else
	{
		CloseScreenButton.SetResizeToText(false);
		CloseScreenButton.InitButton('Button1', "", OnCancelClicked);
	}
}

simulated protected function OnConfirmButtonSizeRealized()
{
	ConfirmButton.SetX(-ConfirmButton.Width / 2);
	ConfirmButton.Show();
}

simulated protected function OnCloseScreenButtonSizeRealized()
{
	CloseScreenButton.SetX(-CloseScreenButton.Width / 2);
	CloseScreenButton.Show();
}

simulated function BuildScreen()
{
	local XComGameState NewGameState;

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Geoscape_SkyrangerStop");
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Building SkyrangerExfiltrate Screen");
	`XEVENTMGR.TriggerEvent('OnSkyrangerExfiltrate', , , NewGameState);
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	BuildSkyrangerPanel();
	BuildOptionsPanel();

	if (!Movie.IsMouseActive())
	{
		Navigator.Clear();
	}
	else
	{
		LibraryPanel.SetSelectedNavigation();
		ButtonGroup.SetSelectedNavigation();

		ButtonGroup.Navigator.LoopSelection = true;
		ConfirmButton.SetSelectedNavigation();
	}
}

simulated function BuildSkyrangerPanel()
{
	// Send over to flash
	LibraryPanel.MC.BeginFunctionOp("UpdateSkyrangerInfoBlade");
	LibraryPanel.MC.QueueString(class'UISkyrangerArrives'.default.m_strSkyrangerArrivesTitle);
	LibraryPanel.MC.QueueString(strSkyrangerExfiltrateSubtitle);
	LibraryPanel.MC.EndOp();
}

simulated function BuildOptionsPanel()
{
	// Send over to flash
	LibraryPanel.MC.BeginFunctionOp("UpdateSkyrangerButtonBlade");
	LibraryPanel.MC.QueueString(GetOpName());
	LibraryPanel.MC.QueueString(strBody);
	LibraryPanel.MC.QueueString(strConfirmExfiltration);
	LibraryPanel.MC.QueueString(class'UISkyrangerArrives'.default.m_strReturnToBase);
	LibraryPanel.MC.EndOp();
}

//////////////////////
/// Event Handling ///
//////////////////////

simulated function OnLaunchClicked(UIButton button)
{
	PlayAbortActionNarrativeMoment();
	GetPickupPoint().ConfirmExfiltrate();
	CloseScreen();
}

simulated function OnCancelClicked(UIButton button)
{
	`HQPRES.UINarrative(XComNarrativeMoment(`CONTENT.RequestGameArchetype("X2NarrativeMoments.Strategy.Avenger_Skyranger_Recalled")));
	GetPickupPoint().CancelExfiltrate();
	CloseScreen();
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if(!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	bHandled = true;

	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_A:
			OnLaunchClicked(none);
			break;
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			OnCancelClicked(none);
			break;
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

///////////////////
/// Data Hookup ///
///////////////////

simulated function string GetOpName()
{
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameState_CovertAction CovertAction;

	PickupPoint = GetPickupPoint();
	CovertAction = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(PickupPoint.ActionRef.ObjectID));
	
	return CovertAction.GetMyNarrativeTemplate().ActionName;
}

simulated function XComGameState_SquadPickupPoint GetPickupPoint()
{
	local XComGameState_SquadPickupPoint PickupPoint;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_SquadPickupPoint', PickupPoint)
	{
		if (!PickupPoint.bConsumed)
		{
			return PickupPoint;
		}
	}
}

simulated function PlayAbortActionNarrativeMoment()
{
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;

	switch (`SYNC_RAND(4))
	{
		case 0:
			HQPres.UINarrative(XComNarrativeMoment'X2NarrativeMoments.T_EVAC_All_Out_Firebrand_02');
			break;
		case 1:
			HQPres.UINarrative(XComNarrativeMoment'X2NarrativeMoments.T_EVAC_All_Out_Firebrand_03');
			break;
		case 2:
			HQPres.UINarrative(XComNarrativeMoment'X2NarrativeMoments.T_EVAC_All_Out_Firebrand_04');
			break;
		case 3:
			HQPres.UINarrative(XComNarrativeMoment'X2NarrativeMoments.T_EVAC_All_Out_Firebrand_05');
			break;
		default:
			break;
	}
}

defaultproperties
{
	InputState = eInputState_Consume;
	Package = "/ package/gfxAlerts/Alerts";
	
	bAutoSelectFirstNavigable = false; 
}