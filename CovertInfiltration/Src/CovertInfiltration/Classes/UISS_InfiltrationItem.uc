//---------------------------------------------------------------------------------------
//  AUTHOR:  (Integrated from Long War 2) Adapted for overhaul by ArcaneData
//  PURPOSE: Item linking to X2ObjectiveListItem for displaying shadowed text
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UISS_InfiltrationItem extends UIPanel;

var UIPanel TitleIcon;

simulated function UISS_InfiltrationItem InitObjectiveListItem(optional name InitName, optional int InitX = 0, optional int InitY = 0)
{
	InitPanel(InitName);

	TitleIcon = Spawn(class'UIPanel', self).InitPanel('titleIcon');

	SetPosition(InitX, InitY);

	return self;
}

simulated function SetTitleText(string Text)
{
	MC.FunctionString("setTitle", Text);
}

simulated function SetText(string Text)
{
	MC.FunctionString("setLabelRow", Text);
}

simulated function SetSubTitle(string Text, optional string TextColor)
{
	if (TextColor == "")
		MC.FunctionString("setLabelRow", "<font face='$TitleFont' size='22' color='#a7a085'>" $ CAPS(Text) $ "</font>");
	else
		MC.FunctionString("setLabelRow", "<font face='$TitleFont' size='22' color='#" $ TextColor $ "'>" $ CAPS(Text) $ "</font>");

}

simulated function SetInfoValue(string Text, string TextColor)
{
	MC.FunctionString("setLabelRow", "<font face='$NormalFont' size='22' color='#" $ TextColor $ "'>" $ Text  $ "</font>");
}


defaultproperties
{
	LibID = "X2ObjectiveListItem";
	Height = 32; 

	bAnimateOnInit = false;

}