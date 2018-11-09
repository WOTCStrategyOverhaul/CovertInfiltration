//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a reusable panel for showing StackedUIIconData. Mainly used for
//           faction icons.
//  NOTE:    The (0,0) position of this panel lies at the center of icon (not at top-left
//           as other UIPanels do). Please account for that when spawining/positioning
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIStackingIcon extends UIPanel;

simulated function SetImageStack(StackedUIIconData IconData, optional bool ValidatePath = true)
{
	local string ImagePath;

	MC.BeginFunctionOp("SetImageStack");
	MC.QueueBoolean(IconData.bInvert);
	
	foreach IconData.Images(ImagePath)
	{
		if (ValidatePath)
		{
			ImagePath = class'UIUtilities_Image'.static.ValidateImagePath(ImagePath);
		}

		MC.QueueString(ImagePath);
	}
	
	MC.EndOp();
}

////////////////////////////
/// UIPanel API override ///
////////////////////////////

simulated function UIPanel SetSize(float NewWidth, float NewHeight)
{
	if (Width != NewWidth || Height != NewHeight )
	{
		Width = NewWidth;
		Height = NewHeight;

		MC.BeginFunctionOp("setIconSize");
		MC.QueueNumber(Width);
		MC.QueueNumber(Height);
		MC.EndOp();
	}

	return self;
}

simulated function SetWidth(float NewWidth)
{
	SetSize(NewWidth, Height);
}

simulated function SetHeight(float NewHeight)
{
	SetSize(Width, NewHeight);
}

defaultproperties
{
	LibID = "XPACKStackingIcon";
	bIsNavigable = false;
	bProcessesMouseEvents = false;
}