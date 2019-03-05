//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: This class is heavily 'inspired' by UISkyrangerArrives therefore
//           is basically the same thing without relying on mission info and 
//           used only for aborting missions from the StrategyLayer
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISkyrangerExfiltrate extends UIScreen;

var public localized String strBody;
var public localized String strSkyrangerExfiltrateTitle;
var public localized String strSkyrangerExfiltrateSubtitle;
var public localized String strConfirmExfiltration;
var public localized String strCancelExfiltration;

var UIPanel LibraryPanel;
var UIPanel ButtonGroup; 
var UIButton Button1, Button2;

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
	LibraryPanel.InitPanel('', 'Alert_SkyrangerLanding');

	ButtonGroup = Spawn(class'UIPanel', LibraryPanel);
	ButtonGroup.InitPanel('ButtonGroup', '');

	Button1 = Spawn(class'UIButton', ButtonGroup);
	if( `ISCONTROLLERACTIVE )
	{
		Button1.InitButton('Button0', "", OnLaunchClicked, eUIButtonStyle_HOTLINK_BUTTON);
		Button1.SetGamepadIcon(class'UIUtilities_Input'.static.GetAdvanceButtonIcon());
		Button1.SetX(-150.0 / 2.0);
		Button1.SetY(-Button1.Height / 2.0);
		Button1.DisableNavigation();
	}
	else
	{
		Button1.SetResizeToText(false);
		Button1.InitButton('Button0', "", OnLaunchClicked);
	}

	Button2 = Spawn(class'UIButton', ButtonGroup);
	if(`ISCONTROLLERACTIVE )
	{
		Button2.InitButton('Button1', "", OnCancelClicked, eUIButtonStyle_HOTLINK_BUTTON);
		Button2.SetGamepadIcon(class'UIUtilities_Input'.static.GetBackButtonIcon());
		Button2.SetX(-175.0 / 2.0);
		Button2.SetY(Button2.Height / 2.0);
		Button2.DisableNavigation();
	}
	else
	{
		Button2.SetResizeToText(false);
		Button2.InitButton('Button1', "", OnCancelClicked);
	}
}

simulated function RefreshNavigation()
{
	if(Button1.bIsVisible)
	{
		if(`ISCONTROLLERACTIVE == false)
		{
			Button1.EnableNavigation();
		}
	}
	else
	{
		Button1.DisableNavigation();
	}

	if(Button2.bIsVisible)
	{
		if(`ISCONTROLLERACTIVE == false)
		{
			Button2.EnableNavigation();
		}
	}
	else
	{
		Button2.DisableNavigation();
	}

	LibraryPanel.bCascadeFocus = false;
	LibraryPanel.bCascadeSelection = false;
	LibraryPanel.SetSelectedNavigation();
	ButtonGroup.bCascadeFocus = false;
	ButtonGroup.bCascadeSelection = false;
	ButtonGroup.Navigator.LoopSelection = true;
	ButtonGroup.SetSelectedNavigation();

	if(Button1.bIsNavigable)
	{
		Button1.SetSelectedNavigation();
	}
	else if(Button2.bIsNavigable)
	{
		Button2.SetSelectedNavigation();
	}
}

simulated function BuildScreen()
{
	local XComGameState NewGameState;

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Geoscape_SkyrangerStop");
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Building SkyrangerExfiltrate Screen");
	`XEVENTMGR.TriggerEvent('OnSkyrangerArrives', , , NewGameState);
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	BuildSkyrangerPanel();
	BuildOptionsPanel();

	RefreshNavigation();
	if (!Movie.IsMouseActive())
	{
		Navigator.Clear();
	}
}

simulated function BuildSkyrangerPanel()
{
	// Send over to flash
	LibraryPanel.MC.BeginFunctionOp("UpdateSkyrangerInfoBlade");
	LibraryPanel.MC.QueueString(strSkyrangerExfiltrateTitle);
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
	LibraryPanel.MC.QueueString(strCancelExfiltration);
	LibraryPanel.MC.EndOp();
}

//////////////////////
/// Event Handling ///
//////////////////////

simulated function OnLaunchClicked(UIButton button)
{
	`HQPRES.UINarrative(XComNarrativeMoment(`CONTENT.RequestGameArchetype("X2NarrativeMoments.Strategy.Avenger_Skyranger_Recalled")));
	GetPickupPoint().ConfirmExfiltrate();
	CloseScreen();
}

simulated function OnCancelClicked(UIButton button)
{
	`HQPRES.UINarrative(XComNarrativeMoment'X2NarrativeMoments.Strategy.Avenger_Skyranger_Recalled');
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
		case class'UIUtilities_Input'.const.FXS_KEY_ENTER:
		case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
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

simulated function String GetOpName()
{
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameState_CovertAction CovertAction;

	PickupPoint = GetPickupPoint();
	CovertAction = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(PickupPoint.ActionRef.ObjectID));
	
	return CovertAction.GetMyNarrativeTemplate().ActionName;
}

simulated function XComGameState_SquadPickupPoint GetPickupPoint()
{
	local array<XComGameState_SquadPickupPoint> PickupPoints;
	local XComGameState_SquadPickupPoint PickupPoint;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_SquadPickupPoint', PickupPoint)
	{
		PickupPoints.AddItem(PickupPoint);
	}

	if (PickupPoints.Length == 1)
	{
		return PickupPoints[0];
	}
	else
	{
		// shit the bed, exit process and purge
		`log("Something went horribly wrong somewhere terminating exfiltration operation is the safest option here",, 'CI');
		class'XComGameState_SquadPickupPoint'.static.Purge();
		CloseScreen();
	}
}

defaultproperties
{
	InputState = eInputState_Consume;
	Package = "/ package/gfxAlerts/Alerts";
	
	bAutoSelectFirstNavigable = false; 
}