//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: CI's version of UIFacility_AcademySlot that handles behaviour change if
//           soldier is not a rookie
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIFacility_AcademySlot_CI extends UIFacility_AcademySlot;

simulated function OnPersonnelSelected (StaffUnitInfo UnitInfo)
{
	local XComGameStateHistory History;
	local XGParamTag LocTag;
	local TDialogueBoxData DialogData;
	local XComGameState_Unit Unit;
	local UICallbackData_StateObjectReference CallbackData;

	History = `XCOMHISTORY;
	Unit = XComGameState_Unit(History.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));

	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	LocTag.StrValue0 = Unit.GetName(eNameType_RankFull);
	LocTag.StrValue1 = class'UIUtilities_Infiltration'.static.GetAcademyTargetRank(Unit);

	CallbackData = new class'UICallbackData_StateObjectReference';
	CallbackData.ObjectRef = Unit.GetReference();
	DialogData.xUserData = CallbackData;
	DialogData.fnCallbackEx = TrainRookieDialogCallback;

	DialogData.eType = eDialog_Alert;
	DialogData.strTitle = m_strTrainRookieDialogTitle;
	DialogData.strText = `XEXPAND.ExpandString(m_strTrainRookieDialogText);
	DialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericYes;
	DialogData.strCancel = class'UIUtilities_Text'.default.m_strGenericNo;

	Movie.Pres.UIRaiseDialog(DialogData);
}

simulated function TrainRookieDialogCallback (Name eAction, UICallbackData xUserData)
{
	local UICallbackData_StateObjectReference CallbackData;
	local XComGameState_Unit Unit;
	
	CallbackData = UICallbackData_StateObjectReference(xUserData);
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(CallbackData.ObjectRef.ObjectID));
	
	if (eAction == 'eUIAction_Accept')
	{
		if (Unit.GetSoldierRank() == 0)
		{
			`HQPRES.UIChooseClass(CallbackData.ObjectRef);
			UpdateChooseClassDurations(CallbackData.ObjectRef);
		}
		else
		{
			InitiateAcademyTraining(CallbackData.ObjectRef);
		}
	}
}

simulated protected function InitiateAcademyTraining (StateObjectReference UnitRef)
{
	local XComGameState_StaffSlot StaffSlotState;
	local StaffUnitInfo UnitInfo;

	StaffSlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(StaffSlotRef.ObjectID));
	
	UnitInfo.UnitRef = UnitRef;
	StaffSlotState.FillSlot(UnitInfo);
		
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("StrategyUI_Staff_Assign");
	UIFacility(Screen).RealizeFacility();
}

static protected function UpdateChooseClassDurations (StateObjectReference UnitRef)
{
	local UIChooseClass ChooseClassScreen;
	local UIScreenStack ScreenStack;
	local int Hours, i;

	ScreenStack = `SCREENSTACK;
	ChooseClassScreen = UIChooseClass(ScreenStack.GetCurrentScreen());
	Hours = class'X2Helper_Infiltration'.static.GetAcademyTrainingHours(UnitRef);

	for (i = 0; i < ChooseClassScreen.arrItems.Length; i++)
	{
		ChooseClassScreen.arrItems[i].OrderHours = Hours;
	}

	// Refresh the actual UI elements
	ChooseClassScreen.PopulateData();
}