class UISS_CostSlot extends UIVerticalListItemBase;

var protectedwrite UIBGBox BG;
var protectedwrite UIImage ResourceImage;

var protectedwrite UIScrollingText ResourceText;
var protectedwrite UIScrollingText RewardText;

var protectedwrite UIButton AllocateClearButton;

// Game data
var protectedwrite StateObjectReference ActionRef;
var protectedwrite int CostSlotIndex;

// Config
var protectedwrite float Padding;
var protectedwrite float ImageRightMargin;

delegate PostStateChanged();

simulated function InitCostSlot(StateObjectReference InitActionRef, int InitCostSlotIndex)
{
	local float ContentHeight;
	local float TextPosition, TextWidth;

	InitListItemBase();
	CalculateHeight(); // BG, icon and text X positioning relies on this

	ActionRef = InitActionRef;
	CostSlotIndex = InitCostSlotIndex;

	BG = Spawn(class'UIBGBox', self);
	BG.bAnimateOnInit = false;
	BG.bHighlightOnMouseEvent = false;
	BG.InitBG('BG');
	BG.SetSize(Width, Height);

	ContentHeight = Height - (Padding * 2);

	ResourceImage = Spawn(class'UIImage', self);
	ResourceImage.bAnimateOnInit = false;
	ResourceImage.InitImage('ResourceImage');
	ResourceImage.SetPosition(Padding, Padding);
	ResourceImage.SetSize(ContentHeight, ContentHeight);

	TextPosition = ResourceImage.X + ResourceImage.Width + ImageRightMargin;
	TextWidth = Width - Padding - TextPosition;

	ResourceText = Spawn(class'UIScrollingText', self);
	ResourceText.bAnimateOnInit = false;
	ResourceText.InitScrollingText('ResourceText');
	ResourceText.SetPosition(TextPosition, Padding);
	ResourceText.SetWidth(TextWidth);
	
	RewardText = Spawn(class'UIScrollingText', self);
	RewardText.bAnimateOnInit = false;
	RewardText.InitScrollingText('RewardText');
	RewardText.SetPosition(TextPosition, ResourceText.Y + 23);
	RewardText.SetWidth(TextWidth);
	
	AllocateClearButton = Spawn(class'UIButton', self);
	AllocateClearButton.bAnimateOnInit = false;
	AllocateClearButton.bIsNavigable = false;
	AllocateClearButton.InitButton('AllocateClearButton',, OnButtonClicked);
	AllocateClearButton.SetPosition(TextPosition, RewardText.Y + 32);
	AllocateClearButton.SetWidth(TextWidth);
	AllocateClearButton.SetResizeToText(false);

	if (!CanAfford())
	{
		DisableNavigation();
	}
}

simulated protected function CalculateHeight()
{
	Height = 0;

	Height += 23;
	Height += 32;
	Height += class'UIButton'.default.Height;

	Height += Padding * 2;
}

simulated function UpdateData()
{
	local array<StrategyCostScalar> CostScalars;
	local XComGameState_Reward Reward;
	local bool bIsPurchased;

	if (CanAfford())
	{
		bIsPurchased = IsPurchased();

		BG.SetBGColorState(bIsPurchased ? eUIState_Good : eUIState_Warning);
		AllocateClearButton.EnableButton();
		AllocateClearButton.SetText(bIsPurchased ? class'UICovertActionCostSlot'.default.m_strClearCost : class'UICovertActionCostSlot'.default.m_strPayCost);
	}
	else
	{
		BG.SetBGColorState(eUIState_Bad);
		AllocateClearButton.DisableButton();
		AllocateClearButton.SetText(class'UICovertActionCostSlot'.default.m_strNoResourcesAvailable);
	}

	ResourceImage.LoadImage(GetAction().GetCostSlotImage(CostSlotIndex));
	
	CostScalars.Length = 0; // Avoid compiler warning
	ResourceText.SetText(class'UIUtilities_Strategy'.static.GetStrategyCostString(GetSlotInfo().Cost, CostScalars));

	Reward = GetReward();
	RewardText.SetText(Reward == none ? "" : Reward.GetRewardPreviewString());
}

simulated protected function OnButtonClicked(UIButton Button)
{
	FlipPurchasedState();
}

simulated protected function FlipPurchasedState()
{
	local XComGameState NewGameState;
	local XComGameState_CovertAction ActionState;

	if (!IsPurchased())
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Allocate cost in Covert Action");
		ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionRef.ObjectID));
		ActionState.CostSlots[CostSlotIndex].bPurchased = true;
		ActionState.UpdateNegatedRisks(NewGameState);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		PlayAllocationSound();
	}
	else
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Clear Cost in Covert Action");
		ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionRef.ObjectID));
		ActionState.CostSlots[CostSlotIndex].bPurchased = false;
		ActionState.UpdateNegatedRisks(NewGameState);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		`XSTRATEGYSOUNDMGR.PlayPersistentSoundEvent("StrategyUI_Staff_Remove");
	}

	// This will also call UpdateData() on us
	PostStateChanged();
	`HQPRES.m_kAvengerHUD.UpdateResources();
}

simulated protected function PlayAllocationSound()
{
	// Have to save to a variable first, otherwise the compiler crashes
	local array<ArtifactCost> ResourceCosts;
	ResourceCosts = GetSlotInfo().Cost.ResourceCosts;

	if (ResourceCosts.Length > 0)
	{
		switch (ResourceCosts[0].ItemTemplateName)
		{
			case 'EleriumDust':
			case 'AlienAlloy':
			case 'Supplies':
				`XSTRATEGYSOUNDMGR.PlayPersistentSoundEvent("UI_CovertOps_AddSupplies");
				break;

			case 'Intel':
				`XSTRATEGYSOUNDMGR.PlayPersistentSoundEvent("UI_CovertOps_AddIntel");
				break;
		}
	}
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
 	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return false;

	switch(cmd)
	{
	case class'UIUtilities_Input'.static.GetAdvanceButtonInputCode():
		if (CanAfford())
		{
			FlipPurchasedState();
		}
		return true;
	}

	return super.OnUnrealCommand(cmd, arg);
}

///////////////
/// Helpers ///
///////////////

simulated function XComGameState_CovertAction GetAction()
{
	return XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(ActionRef.ObjectID));
}

simulated function CovertActionCostSlot GetSlotInfo()
{
	return GetAction().CostSlots[CostSlotIndex];
}

simulated function bool CanAfford()
{
	local array<StrategyCostScalar> CostScalars;
	CostScalars.Length = 0; // Avoid compiler warning

	return `XCOMHQ.CanAffordAllStrategyCosts(GetSlotInfo().Cost, CostScalars);
}

simulated function bool IsPurchased()
{
	return GetSlotInfo().bPurchased;
}

simulated function XComGameState_Reward GetReward()
{
	return XComGameState_Reward(`XCOMHISTORY.GetGameStateForObjectID(GetSlotInfo().RewardRef.ObjectID));
}

defaultproperties
{
	Padding = 5;
	ImageRightMargin = 5;

	bCascadeSelection = true;
}