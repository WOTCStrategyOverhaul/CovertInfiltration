//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Screen listener for UIStrategyMap to force open new covert ops screen
//           when the map opens
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIMapToCovertActionsForcer extends UIPanel;

var protected StateObjectReference ActionRef;

static function ForceCAOnNextMapTick(optional StateObjectReference InActionRef)
{
	local UIMapToCovertActionsForcer Forcer;
	local XComHQPresentationLayer HQPres;
	local UIAvengerHUD HUD;

	HQPres = `HQPRES;
	HUD = HQPres.m_kAvengerHUD;
	Forcer = UIMapToCovertActionsForcer(HUD.GetChildByName(default.MCName, false));

	if (Forcer == none)
	{
		Forcer = HUD.Spawn(class'UIMapToCovertActionsForcer', HUD);
		Forcer.InitPanel();
	}

	Forcer.ActionRef = InActionRef;
}

static function bool IsQueued()
{
	local UIMapToCovertActionsForcer Forcer;
	local XComHQPresentationLayer HQPres;
	local UIAvengerHUD HUD;

	HQPres = `HQPRES;
	HUD = HQPres.m_kAvengerHUD;
	Forcer = UIMapToCovertActionsForcer(HUD.GetChildByName(default.MCName, false));

	return Forcer != none;
}

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	local X2EventManager EventManager;
	local Object ThisObj;

	super.InitPanel(InitName, InitLibID);

	EventManager = `XEVENTMGR;
	ThisObj = self;

	// XComGameState_MissionSiteInfiltration MutsLaunch is priority 500, this should be after it
	EventManager.RegisterForEvent(ThisObj, 'PreventGeoscapeTick', OnPreventGeoscapeTick, ELD_Immediate, 400);

	return self;
}

simulated protected function EventListenerReturn OnPreventGeoscapeTick(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'PreventGeoscapeTick') return ELR_NoInterrupt;

	Tuple.Data[0].b = true;

	if (!IsTimerActive(nameof(OpenScreenConditionally)))
	{
		// Set a short timer to make sure that nothing is going on when the map opens. Example: golden path mission reveal on map
		SetTimer(0.1f, false, nameof(OpenScreenConditionally));
	}

	return ELR_InterruptListeners;
}

simulated protected function OpenScreenConditionally()
{
	local XComHQPresentationLayer HQPres;
	local XGGeoscape Geoscape;

	HQPres = XComHQPresentationLayer(Movie.Pres);
	Geoscape =`GAME.GetGeoscape();

	if (
		Geoscape.IsPaused() ||
		HQPres.ScreenStack.GetCurrentScreen() != HQPres.StrategyMap2D ||
		HQPres.StrategyMap2D.m_eUIState == eSMS_Flight ||
		HQPres.CAMIsBusy()
	)
	{
		// Something is going on - allow next tick to handle it
		return;
	}

	class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape(ActionRef);
	Remove();
}

simulated event Removed()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	super.Removed();

	EventManager = `XEVENTMGR;
	ThisObj = self;

	EventManager.UnRegisterFromAllEvents(ThisObj);
}

defaultproperties
{
	MCName = "UIMapToCovertActionsForcer";
}