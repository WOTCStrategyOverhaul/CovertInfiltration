//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: New Geoscape button, positioned above the factions "triangle" at the bottom
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIStrategyMap_CAButton extends UIPanel;

var UIPanel BG;
var UIText Label;
var UIImage ControllerIcon;

var localized string strLabel;

simulated function InitCAButton()
{
	InitPanel('CovertActionButton');

	BG = Spawn(class'UIPanel', self);
	BG.InitPanel('BG', 'X2MenuBG');
	BG.AnchorBottomCenter();
	BG.SetWidth(140);
	BG.SetX(-(BG.Width / 2));
	BG.SetAlpha(80);

	Label = Spawn(class'UIText', self);
	Label.InitText('Label');
	Label.AnchorBottomCenter();
	Label.SetX(BG.X + 5);
	Label.SetWidth(BG.Width - 10);
	Label.OnTextSizeRealized = OnLabelSizeRealized;
	
	if (`ISCONTROLLERACTIVE)
	{
		ControllerIcon = Spawn(class'UIImage', self);
		ControllerIcon.InitImage('ControllerIcon', "img:///gfxGamepadIcons." $ class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_X_SQUARE);
		ControllerIcon.AnchorBottomCenter();
		ControllerIcon.SetSize(40, 40);
		ControllerIcon.SetX(BG.X + 10);

		Label.SetX(ControllerIcon.X + ControllerIcon.Width + 10);
		Label.SetWidth(BG.Width - ControllerIcon.Width - 20);
	}

	UpdateLabel();
	SubscribeToEvents();
}

// TODO: (3) jump

simulated protected function RealizeLayout()
{
	BG.SetHeight(Max(50, Label.Height + 10));
	BG.SetY(-(133 + BG.Height));

	if (ControllerIcon != none)
	{
		ControllerIcon.SetY(BG.Y + (BG.Height - ControllerIcon.Height) / 2);
	}

	Label.SetY(BG.Y + 5);
}

simulated protected function UpdateLabel()
{
	if (bIsFocused)
	{
		Label.SetCenteredText(class'UIUtilities_Text'.static.AddFontInfo(strLabel, Screen.bIsIn3D,,, 26));
	}
	else
	{
		Label.SetCenteredText(class'UIUtilities_Text'.static.AddFontInfo(strLabel, Screen.bIsIn3D,,, 24));
	}
}

simulated protected function OnLabelSizeRealized()
{
	RealizeLayout();
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	
	UpdateLabel();
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();

	UpdateLabel();
}

simulated function OnMouseEvent(int cmd, array<string> args)
{
	super.OnMouseEvent(cmd, args);

	switch (cmd)
	{
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_UP:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_DOUBLE_UP:
		class'UIUtilities_Infiltration'.static.UICovertActionsGeoscape();
		break;
	}
}

simulated event Removed()
{
	super.Removed();

	UnsubscribeFromAllEvents();
}

/////////////////////////////
/// Geoscape flight event ///
/////////////////////////////

simulated protected function SubscribeToEvents()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	EventManager = `XEVENTMGR;
    ThisObj = self;

	EventManager.RegisterForEvent(ThisObj, 'GeoscapeFlightModeUpdate', OnGeoscapeFlightModeUpdate); // Relies on CHL #358, will be avaliable in v1.17
}

simulated protected function UnsubscribeFromAllEvents()
{
    local Object ThisObj;

    ThisObj = self;
    `XEVENTMGR.UnRegisterFromAllEvents(ThisObj);
}

simulated protected function EventListenerReturn OnGeoscapeFlightModeUpdate(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIStrategyMap StrategyMap;

	StrategyMap = UIStrategyMap(GetParent(class'UIStrategyMap', true));
	SetVisible(!StrategyMap.IsInFlightMode());

	return ELR_NoInterrupt;
}

defaultproperties
{
	bIsNavigable = false;
	bProcessesMouseEvents = true;
}