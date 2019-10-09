//---------------------------------------------------------------------------------------
//  AUTHOR:  ArcaneData
//  PURPOSE: Manages barracks size limit and upgrades
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_BarracksSizeLimit extends XComGameState_BaseObject;

static function CreateSizeLimit(optional XComGameState StartState)
{
	local XComGameState NewGameState;

	if (StartState != none)
	{
		StartState.CreateNewStateObject(class'XComGameState_BarracksSizeLimit');
	}
	else if (GetBarracksSizeLimit(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating barracks size limit singleton");

		NewGameState.CreateNewStateObject(class'XComGameState_BarracksSizeLimit');

		`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	}
}

static function XComGameState_BarracksSizeLimit GetBarracksSizeLimit(optional bool AllowNull = false)
{
	return XComGameState_BarracksSizeLimit(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BarracksSizeLimit', AllowNull));
}