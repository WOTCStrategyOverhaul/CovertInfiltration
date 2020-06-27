class UIAlert_CovertInfiltration extends UIAlert;

var localized string strRewardsIntercepted_Title;
var localized string strRewardsIntercepted_Description;

simulated function BuildAlert ()
{
	BindLibraryItem();

	switch (eAlertName)
	{
		case 'eAlert_RewardsIntercepted':
			BuildRewardsInterceptedAlert();
		break;

		default:
			AddBG(MakeRect(0, 0, 1000, 500), eUIState_Normal).SetAlpha(0.75f);
		break;
	}

	// Set up the navigation *after* the alert is built, so that the button visibility can be used. 
	RefreshNavigation();
}

simulated function name GetLibraryID ()
{
	switch (eAlertName)
	{
		case 'eAlert_RewardsIntercepted':				return 'Alert_Warning';

		default:
			return '';
	}
}

simulated function PresentUIEffects ()
{
	super.PresentUIEffects();
}

simulated protected function BuildRewardsInterceptedAlert ()
{
	local XComGameState_ResourceContainer TotalResContainer;
	local XGParamTag ParamTag;
	local TAlertHelpInfo Info;

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	TotalResContainer = XComGameState_ResourceContainer(`XCOMHISTORY.GetGameStateForObjectID(
		class'X2StrategyGameRulesetDataStructures'.static.GetDynamicIntProperty(DisplayPropertySet, 'ContainerObjectID')
	));

	ParamTag.StrValue0 = TotalResContainer.GetCommaSeparatedContents();

	Info.strTitle = strRewardsIntercepted_Title;
	Info.strHeader = m_strMissionExpiredFlare; // WARNING
	Info.strDescription = `XEXPAND.ExpandString(strRewardsIntercepted_Description);
	Info.strImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Advent_Ops_Appear";		
	Info.strCarryOn = m_strOK;

	BuildHelpAlert(Info);
	Button2.SetGamepadIcon(class'UIUtilities_Input'.static.GetAdvanceButtonIcon());
}
