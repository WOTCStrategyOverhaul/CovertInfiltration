class UIVignette extends UIPanel;

var float AnimateInDuration;

var protectedwrite UIImage GradientTop;
var protectedwrite UIImage GradientBottom;

simulated function InitVignette (optional name InitName)
{
	InitPanel(InitName);
	
	GradientTop = Spawn(class'UIImage', self);
	GradientTop.bAnimateOnInit = false;
	GradientTop.InitImage('GradientTop', "img:///UILibrary_CovertInfiltration.gradient_top");
	GradientTop.AnchorTopLeft();
	GradientTop.SetPosition(0, 0);

	GradientBottom = Spawn(class'UIImage', self);
	GradientBottom.bAnimateOnInit = false;
	GradientBottom.InitImage('GradientBottom', "img:///UILibrary_CovertInfiltration.gradient_bottom");
	GradientBottom.AnchorBottomLeft();
	GradientBottom.SetPosition(0, -512);

	SetSizes();

	AnchorWatch = WorldInfo.MyWatchVariableMgr.RegisterWatchVariable(Movie, 'm_v2ScaledDimension', self, SetSizes);
}

simulated protected function SetSizes ()
{
	GradientTop.SetSize(Movie.m_v2ScaledDimension.X, 512);
	GradientBottom.SetSize(Movie.m_v2ScaledDimension.X, 512);
}

simulated function AnimateIn (optional float Delay = 0.0)
{
	local float Duration;

	Duration = AnimateInDuration;
	if (Duration < 0) Duration = class'UIUtilities'.const.INTRO_ANIMATION_TIME;

	GradientTop.AddTweenBetween("_alpha", 0, GradientTop.Alpha, Duration, Delay, "easeoutquad");
	GradientBottom.AddTweenBetween("_alpha", 0, GradientBottom.Alpha, Duration, Delay, "easeoutquad");
}

////////////////////////////////////////////////////////////////////////////////
/// Disable a bunch of methods that are guranteed to break our functionality ///
////////////////////////////////////////////////////////////////////////////////

simulated function UIPanel SetAnchor (int NewAnchor)
{
	`CI_Warn(nameof(SetAnchor) @ "is invalid on" @ class.Name);
	return self;
}

simulated function UIPanel SetSize (float NewWidth, float NewHeight)
{
	`CI_Warn(nameof(SetSize) @ "is invalid on" @ class.Name);
	return self;
}

simulated function UIPanel SetPosition (float NewX, float NewY)
{
	`CI_Warn(nameof(SetPosition) @ "is invalid on" @ class.Name);
	return self;
}

simulated function UIPanel SetPanelScale (float NewScale)
{
	`CI_Warn(nameof(SetPanelScale) @ "is invalid on" @ class.Name);
	return self;
}

defaultproperties
{
	AnimateInDuration = -1
}
