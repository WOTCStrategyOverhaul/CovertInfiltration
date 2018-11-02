class UISS_CovertActionInfo extends UIPanel;

simulated function InitCovertActionInfo(optional name InitName)
{
	InitPanel(InitName);
	SetAnchor(class'UIUtilities'.const.ANCHOR_TOP_LEFT);
}

simulated function UpdateData(XComGameState_CovertAction Action)
{
	mc.BeginFunctionOp("UpdateData");
	mc.QueueString(Action.GetDisplayName());
	mc.QueueString("Objectives");
	mc.QueueString(Action.GetObjective());
	mc.QueueString("Reward:"); // "Difficulty"
	mc.QueueString(Action.GetRewardDescriptionString()); // eg. Easy
	mc.QueueString(" "); // "Reward"
	mc.QueueString(Action.GetRewardDetailsString());
	mc.EndOp();
}

defaultproperties
{
	LibID = "MissionInfo";
	bIsNavigable = false;
	bProcessesMouseEvents = false;
}
