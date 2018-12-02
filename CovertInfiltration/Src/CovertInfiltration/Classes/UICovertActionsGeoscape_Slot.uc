//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This is a single slot on the UICovertActionsGeoscape screen which handles
//           both personnel and cost slots (but not both at the same time)
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UICovertActionsGeoscape_Slot extends UIPanel;

var protectedwrite UIScrollingText Description;
var protectedwrite UIScrollingText RewardText;

simulated function InitSlot(float InitWidth)
{
	InitPanel();
	SetWidth(InitWidth);

	Description = Spawn(class'UIScrollingText', self);
	Description.bAnimateOnInit = false;
	Description.InitScrollingText('Description');
	Description.SetWidth(Width);

	RewardText = Spawn(class'UIScrollingText', self);
	RewardText.bAnimateOnInit = false;
	RewardText.InitScrollingText('RewardText');
	RewardText.SetY(23);
	RewardText.SetWidth(Width);
}

simulated function UpdateFromInfo(UICovertActionsGeoscape_SlotInfo SlotInfo)
{
	UpdateDescription(GetDescriptionFromInfo(SlotInfo), SlotInfo.CanAfford(), SlotInfo.ColourDescription);
	UpdateReward(SlotInfo.GetReward());
}

simulated function string GetDescriptionFromInfo(UICovertActionsGeoscape_SlotInfo SlotInfo)
{
	local string strDescription, strPrefix;
	
	// Cost slots
	local array<StrategyCostScalar> CostScalars;

	if (SlotInfo.IsStaffSlot)
	{
		strDescription = SlotInfo.GetStaffSlotState().GetNameDisplayString();

		if (SlotInfo.StaffSlotInfo.bFame)
		{
			strDescription = class'UICovertActionStaffSlot'.default.m_strFamous @ strDescription;
		}

		if (SlotInfo.StaffSlotInfo.bOptional)
		{
			strPrefix = class'UICovertActionStaffSlot'.default.m_strOptionalSlot;
		}
		else
		{
			strPrefix = class'UICovertActionStaffSlot'.default.m_strRequiredSlot;
		}
	}
	else
	{
		CostScalars.Length = 0; // Prevent compiler warning as we want empty array
		
		strDescription = class'UIUtilities_Infiltration'.static.GetStrategyCostStringNoColours(SlotInfo.CostSlotInfo.Cost, CostScalars);
		strPrefix = class'UICovertActionStaffSlot'.default.m_strOptionalSlot;
	}

	if (SlotInfo.ShowPrefix)
	{
		strDescription = strPrefix @ strDescription;
	}

	return strDescription;
}

simulated function UpdateDescription(string strDescription, bool CanFullfil, optional bool ColourText = true)
{
	local EUIState eState;
	
	if (ColourText)
	{
		eState = CanFullfil ? eUIState_Normal : eUIState_Bad;
		strDescription = class'UIUtilities_Text'.static.GetColoredText(strDescription, eState);
	}

	Description.SetText(strDescription);
}

simulated function UpdateReward(XComGameState_Reward Reward)
{
	local string strReward;

	if (Reward == none)
	{
		RewardText.SetText("");
		return;
	}

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