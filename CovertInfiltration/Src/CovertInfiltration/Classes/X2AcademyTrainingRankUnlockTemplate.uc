//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: GTS unlock template that increases GTS training target rank
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2AcademyTrainingRankUnlockTemplate extends X2SoldierUnlockTemplate;

var config int RanksMod;

function bool ValidateTemplate (out string strError)
{
	if (RanksMod == 0)
	{
		strError = "RanksMod is 0";
		return false;
	}

	return super.ValidateTemplate(strError);
}

function OnSoldierUnlockPurchased (XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
	XComHQ.BonusTrainingRanks += RanksMod;
}

function string GetSummary ()
{
	local XGParamTag ParamTag;

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = RanksMod;

	return `XEXPAND.ExpandString(Summary);
}