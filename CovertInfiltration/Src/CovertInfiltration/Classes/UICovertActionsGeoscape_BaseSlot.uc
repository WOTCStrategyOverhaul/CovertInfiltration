class UICovertActionsGeoscape_BaseSlot extends UIPanel abstract;

var privatewrite UIList ParentList;

var protectedwrite UIText Description;
var protectedwrite UIText RewardText;

simulated function InitSlotBase()
{
	InitPanel();

	ParentList = UIList(GetParent(class'UIList')); // list items must be owned by UIList.ItemContainer
	if (ParentList == none)
	{
		ScriptTrace();
		`warn("UI list items must be owned by UIList.ItemContainer");
	}

	SetWidth(ParentList.Width);

	Description = Spawn(class'UIText', self);
	Description.bAnimateOnInit = false;
	Description.InitText('Description');
	Description.SetWidth(Width);

	RewardText = Spawn(class'UIText', self);
	RewardText.bAnimateOnInit = false;
	RewardText.InitText('RewardText');
	RewardText.SetY(23);
	RewardText.SetWidth(Width);
}

simulated function UpdateDescription(string strDescription, bool CanFullfil)
{
	local EUIState eState;
	eState = CanFullfil ? eUIState_Normal : eUIState_Bad;
	
	strDescription = class'UIUtilities_Text'.static.GetColoredText(strDescription, eState);
	Description.SetText(strDescription);
}

simulated function UpdateReward(XComGameState_Reward Reward)
{
	local string strReward;

	strReward = Reward.GetRewardPreviewString();
	strReward = class'UIUtilities_Text'.static.GetColoredText(strReward, eUIState_Good);
	
	RewardText.SetText(strReward);
}

defaultproperties
{
	bAnimateOnInit = false;
	bIsNavigable = false;
	Height = 52;
}