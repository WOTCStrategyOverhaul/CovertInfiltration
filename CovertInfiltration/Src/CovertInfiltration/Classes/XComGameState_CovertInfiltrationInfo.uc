class XComGameState_CovertInfiltrationInfo extends XComGameState_BaseObject;

var bool bCompletedFirstOrdersAssignment; // If false (just built the ring) - allow player to assign orders at any time without waiting for supply drop
var bool bRingStaffReplacement; // True if we are replacing the staff assigned to resistance ring and no empty wildcard slots - do not un-grant/grant slot

static function XComGameState_CovertInfiltrationInfo GetInfo(optional bool AllowNull = false)
{
	return XComGameState_CovertInfiltrationInfo(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CovertInfiltrationInfo', AllowNull));
}

static function XComGameState_CovertInfiltrationInfo ChangeForGamestate(XComGameState NewGameState)
{
	local XComGameState_CovertInfiltrationInfo NewInfo;

	foreach NewGameState.IterateByClassType(class'XComGameState_CovertInfiltrationInfo', NewInfo)
	{
		break;
	}

	if (NewInfo == none)
	{
		NewInfo = GetInfo();
		NewInfo = XComGameState_CovertInfiltrationInfo(NewGameState.ModifyStateObject(class'XComGameState_CovertInfiltrationInfo', NewInfo.ObjectID));
	}

	return NewInfo;
}

static function CreateInfo(optional XComGameState StartState)
{
	local XComGameState_CovertInfiltrationInfo Info;
	local XComGameState NewGameState;

	if (StartState != none)
	{
		Info = XComGameState_CovertInfiltrationInfo(StartState.CreateNewStateObject(class'XComGameState_CovertInfiltrationInfo'));
		return;
	}

	// Do not create if already exists
	if (GetInfo(true) != none) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating CI Info Singleton");
	
	Info = XComGameState_CovertInfiltrationInfo(NewGameState.CreateNewStateObject(class'XComGameState_CovertInfiltrationInfo'));
	Info.InitExistingCampaign();
		
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}

protected function InitExistingCampaign()
{
	if (class'UIUtilities_Strategy'.static.GetResistanceHQ().NumMonths > 0)
	{
		bCompletedFirstOrdersAssignment = true;
	}
}