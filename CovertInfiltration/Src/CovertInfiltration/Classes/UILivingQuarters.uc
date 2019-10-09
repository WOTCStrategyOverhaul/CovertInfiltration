//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: UI for living quarters upgrades
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UILivingQuarters extends UISimpleCommodityScreen;

var StateObjectReference FacilityRef;
var array<X2SoldierUnlockTemplate> m_arrUnlocks;
var X2SoldierUnlockTemplate CurrentTemplate;

//-------------- EVENT HANDLING --------------------------------------------------------
simulated function OnPurchaseClicked(UIList kList, int itemIndex)
{
	if (itemIndex != iSelectedItem)
	{
		iSelectedItem = itemIndex;
	}

	if (!IsItemPurchased(iSelectedItem) && CanAffordItem(iSelectedItem))
	{
		PlaySFX("BuildItem");
		OnUnlockOption(iSelectedItem);
		UIInventory_ListItem(List.GetSelectedItem()).RealizeDisabledState();
		
		GetItems();
		PopulateData();
	}
	else
	{
		PlayNegativeSound(); // bsg-jrebar (4/20/17): New PlayNegativeSound Function in Parent Class
	}
	XComHQPresentationLayer(Movie.Pres).m_kAvengerHUD.UpdateResources();
}

//-------------- GAME DATA HOOKUP --------------------------------------------------------
simulated function GetItems()
{
	arrItems = ConvertOTSUnlocksToCommodities();
}

simulated function array<Commodity> ConvertOTSUnlocksToCommodities()
{
	local int iUnlock;
	local array<Commodity> arrCommodoties;
	local Commodity OTSComm;
	local StrategyCost EmptyCost;
	local StrategyRequirement EmptyReq;

	m_arrUnlocks.Remove(0, m_arrUnlocks.Length);
	m_arrUnlocks = GetUnlocks();
	m_arrUnlocks.Sort(SortUnlocksByCost);
	m_arrUnlocks.Sort(SortUnlocksByRank);
	m_arrUnlocks.Sort(SortUnlocksByClass);
	m_arrUnlocks.Sort(SortUnlocksCanPurchase);
	m_arrUnlocks.Sort(SortUnlocksPurchased);
	
	for (iUnlock = 0; iUnlock < m_arrUnlocks.Length; iUnlock++)
	{
		OTSComm.Title = m_arrUnlocks[iUnlock].GetDisplayName();
		OTSComm.Image = m_arrUnlocks[iUnlock].strImage;
		OTSComm.Desc = m_arrUnlocks[iUnlock].GetSummary();

		if (IsItemPurchased(iUnlock))
		{
			OTSComm.Title = class'UIItemCard'.default.m_strPurchased @ OTSComm.Title;
			OTSComm.Cost = EmptyCost;
			OTSComm.Requirements = EmptyReq;
			OTSComm.OrderHours = -1;
		}
		else
		{
			OTSComm.Cost = m_arrUnlocks[iUnlock].Cost;
			OTSComm.Requirements = m_arrUnlocks[iUnlock].Requirements;
			OTSComm.CostScalars = XComHQ.OTSUnlockScalars;
			OTSComm.DiscountPercent = XComHQ.GTSPercentDiscount;
		}

		arrCommodoties.AddItem(OTSComm);
	}

	return arrCommodoties;
}


simulated function bool IsItemPurchased(int ItemIndex)
{
	return XComHQ.HasSoldierUnlockTemplate(m_arrUnlocks[ItemIndex].DataName);
}

//-----------------------------------------------------------------------------

simulated function array<X2SoldierUnlockTemplate> GetUnlocks()
{
	local XComGameState_FacilityXCom Facility;
	local X2StrategyElementTemplateManager TemplateMan;
	local array<X2SoldierUnlockTemplate> UnlockTemplates;
	local name UnlockName;
	
	Facility = XComGameState_FacilityXCom(`XCOMHISTORY.GetGameStateForObjectID(FacilityRef.ObjectID));
	TemplateMan = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	UnlockTemplates.Length = 0;

	foreach Facility.GetMyTemplate().SoldierUnlockTemplates(UnlockName)
	{
		UnlockTemplates.AddItem(X2SoldierUnlockTemplate(TemplateMan.FindStrategyElementTemplate(UnlockName)));
	}

	return UnlockTemplates;
}

function int SortUnlocksCanPurchase(X2SoldierUnlockTemplate UnlockTemplateA, X2SoldierUnlockTemplate UnlockTemplateB)
{
	local bool CanPurchaseA, CanPurchaseB;

	CanPurchaseA = XComHQ.MeetsRequirmentsAndCanAffordCost(UnlockTemplateA.Requirements, UnlockTemplateA.Cost, XComHQ.OTSUnlockScalars, XComHQ.GTSPercentDiscount);
	CanPurchaseB = XComHQ.MeetsRequirmentsAndCanAffordCost(UnlockTemplateB.Requirements, UnlockTemplateB.Cost, XComHQ.OTSUnlockScalars, XComHQ.GTSPercentDiscount);
	
	if (CanPurchaseA && !CanPurchaseB)
	{
		return 1;
	}
	else if (!CanPurchaseA && CanPurchaseB)
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

private function int SortUnlocksPurchased(X2SoldierUnlockTemplate UnlockTemplateA, X2SoldierUnlockTemplate UnlockTemplateB)
{
	local bool UnlockAPurchased, UnlockBPurchased;

	UnlockAPurchased = XComHQ.HasSoldierUnlockTemplate(UnlockTemplateA.DataName);
	UnlockBPurchased = XComHQ.HasSoldierUnlockTemplate(UnlockTemplateB.DataName);

	if (UnlockAPurchased && !UnlockBPurchased) // Sort all purchased upgrades to the bottom of the list
		return -1;
	else if (!UnlockAPurchased && UnlockBPurchased)
		return 1;
	else
		return 0;
}

private function int SortUnlocksByClass(X2SoldierUnlockTemplate UnlockTemplateA, X2SoldierUnlockTemplate UnlockTemplateB)
{
	local bool UnlockARequiresClass, UnlockBRequiresClass;

	UnlockARequiresClass = (UnlockTemplateA.AllowedClasses.Length > 0);
	UnlockBRequiresClass = (UnlockTemplateB.AllowedClasses.Length > 0);

	if (UnlockARequiresClass && !UnlockBRequiresClass) // Sort all class specific perks to the bottom of the list
		return -1;
	else if (!UnlockARequiresClass && UnlockBRequiresClass)
		return 1;
	else 
		return 0;
}

private function int SortUnlocksByRank(X2SoldierUnlockTemplate UnlockTemplateA, X2SoldierUnlockTemplate UnlockTemplateB)
{
	if (UnlockTemplateA.Requirements.RequiredHighestSoldierRank < UnlockTemplateB.Requirements.RequiredHighestSoldierRank)
		return 1;
	else if (UnlockTemplateA.Requirements.RequiredHighestSoldierRank > UnlockTemplateB.Requirements.RequiredHighestSoldierRank)
		return -1;
	else
		return 0;
}

private function int SortUnlocksByCost(X2SoldierUnlockTemplate UnlockTemplateA, X2SoldierUnlockTemplate UnlockTemplateB)
{
	local int CostA, CostB;

	// Then sort by supply cost
	CostA = class'UIUtilities_Strategy'.static.GetCostQuantity(UnlockTemplateA.Cost, 'Supplies');
	CostB = class'UIUtilities_Strategy'.static.GetCostQuantity(UnlockTemplateB.Cost, 'Supplies');

	if (CostA < CostB)
		return 1;
	else if (CostA > CostB)
		return -1;
	else
		return 0;
}

simulated function bool CanAffordItem(int iOption)
{
	return XComHQ.MeetsRequirmentsAndCanAffordCost(m_arrUnlocks[iOption].Requirements, m_arrUnlocks[iOption].Cost, XComHQ.OTSUnlockScalars, XComHQ.GTSPercentDiscount);
}

function bool OnUnlockOption(int iOption)
{
	local XComGameState NewGameState;

	if (XComHQ.MeetsRequirmentsAndCanAffordCost(m_arrUnlocks[iOption].Requirements, m_arrUnlocks[iOption].Cost, XComHQ.OTSUnlockScalars, XComHQ.GTSPercentDiscount))
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("OTS Ability Unlock -" @ m_arrUnlocks[iOption].DisplayName);

		if (XComHQ.AddSoldierUnlockTemplate(NewGameState, m_arrUnlocks[iOption]))
		{			
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

			//update the stored HQ to our current game state after unlocking the training
			XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ(); 
		}
		else
		{
			`XCOMHISTORY.CleanupPendingGameState(NewGameState);
		}

		return true;
	}

	return false;
}

//----------------------------------------------------------------
simulated function OnCancelButton(UIButton kButton) { OnCancel(); }
simulated function OnCancel()
{	
	CloseScreen();
}

//==============================================================================

simulated function OnLoseFocus()
{
	super.OnLoseFocus();
	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
}

defaultproperties
{
	InputState = eInputState_Consume;

	DisplayTag      = "UIBlueprint_QuartersCommander";
	CameraTag       = "UIBlueprint_QuartersCommander";

	bHideOnLoseFocus = true;
}