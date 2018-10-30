class UICovertActionsGeoscape_Slot extends UIPanel;

var protectedwrite UIText Description;
var protectedwrite UIText RewardText;

simulated function InitSlot(float InitWidth)
{
	InitPanel();
	SetWidth(InitWidth);

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

simulated function UpdateCostSlot(CovertActionCostSlot CostSlotInfo)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local StrategyCost Cost;
	local array<StrategyCostScalar> CostScalars;
	local string strDescription;

	History = `XCOMHISTORY;
	Cost = CostSlotInfo.Cost;
	CostScalars.Length = 0; // Prevent compiler warnning as we want empty array
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	// TODO: this colours the text green if it's affordable, make it white instead
	strDescription = class'UIUtilities_Strategy'.static.GetStrategyCostString(Cost, CostScalars);
	strDescription = class'UICovertActionStaffSlot'.default.m_strOptionalSlot @ strDescription;

	UpdateDescription(strDescription, XComHQ.CanAffordAllStrategyCosts(Cost, CostScalars));
	UpdateReward(XComGameState_Reward(History.GetGameStateForObjectID(CostSlotInfo.RewardRef.ObjectID)));
}

simulated function UpdateStaffSlot(CovertActionStaffSlot StaffSlotInfo)
{
	local XComGameStateHistory History;
	local XComGameState_StaffSlot StaffSlot;
	local string strDescription;

	History = `XCOMHISTORY;
	StaffSlot = XComGameState_StaffSlot(History.GetGameStateForObjectID(StaffSlotInfo.StaffSlotRef.ObjectID));
	strDescription = StaffSlot.GetNameDisplayString();

	if (StaffSlotInfo.bFame)
	{
		strDescription = class'UICovertActionStaffSlot'.default.m_strFamous @ strDescription;
	}

	if (StaffSlotInfo.bOptional)
	{
		strDescription = class'UICovertActionStaffSlot'.default.m_strOptionalSlot @ strDescription;
	}
	else
	{
		strDescription = class'UICovertActionStaffSlot'.default.m_strRequiredSlot @ strDescription;
	}

	UpdateDescription(strDescription, StaffSlot.IsUnitAvailableForThisSlot());
	UpdateReward(XComGameState_Reward(History.GetGameStateForObjectID(StaffSlotInfo.RewardRef.ObjectID)));
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