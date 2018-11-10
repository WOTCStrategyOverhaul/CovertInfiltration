//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a reusable panel for showing StackedUIIconData. Mainly used for
//           faction icons.
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIStackingIcon extends UIPanel;

var protectedwrite float IconSize;
var protected UIPanel ActualIcon;

simulated function InitStackingIcon(optional name InitName)
{
	InitPanel(InitName);

	ActualIcon = Spawn(class'UIPanel', self);
	ActualIcon.bAnimateOnInit = false;
	ActualIcon.InitPanel('ActualIcon', 'XPACKStackingIcon');
}

simulated function SetImageStack(StackedUIIconData IconData, optional bool ValidatePath = true)
{
	local string ImagePath;

	ActualIcon.MC.BeginFunctionOp("SetImageStack");
	ActualIcon.MC.QueueBoolean(IconData.bInvert);
	
	foreach IconData.Images(ImagePath)
	{
		if (ValidatePath)
		{
			ImagePath = class'UIUtilities_Image'.static.ValidateImagePath(ImagePath);
		}

		ActualIcon.MC.QueueString(ImagePath);
	}
	
	ActualIcon.MC.EndOp();
}

simulated function SetIconSize(float NewIconSize)
{
	local float IconSizeHalf;

	if (IconSize == NewIconSize) return;

	IconSize = NewIconSize;
	ActualIcon.MC.FunctionNum("setIconSize", IconSize);

	// XPACKStackingIcon uses center as origin, not top-left corner as everything else
	IconSizeHalf = IconSize / 2;
	ActualIcon.SetPosition(IconSizeHalf, IconSizeHalf);

	Width = IconSize;
	Height = IconSize;
}

////////////////////////////
/// UIPanel API override ///
////////////////////////////

simulated function UIPanel SetSize(float NewWidth, float NewHeight)
{
	if (NewWidth != NewHeight)
	{
		`REDSCREEN("UIStackingIcon must be a square, ignoring NewHeight");
		ScriptTrace();
	}

	SetIconSize(NewWidth);
	return self;
}

simulated function SetWidth(float NewWidth)
{
	SetIconSize(NewWidth);
}

simulated function SetHeight(float NewHeight)
{
	SetIconSize(NewHeight);
}

defaultproperties
{
	LibID = "XPACKStackingIcon";
	bIsNavigable = false;
	bProcessesMouseEvents = false;
}