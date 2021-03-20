class CovertInfiltration_MCMScreen extends Object config(CovertInfiltration);

// TODO: trace option
var config int VERSION_CFG;

var localized string ModName;
var localized string PageTitle;

var localized string VariousSettingsTitle;
var localized string TipsTitle;
var localized string OverInfiltrationTitle;

`include(CovertInfiltration\Src\ModConfigMenuAPI\MCM_API_Includes.uci)

`MCM_API_AutoCheckBoxVars(DAYS_TO_HOURS);
`MCM_API_AutoSliderVars(DAYS_BEFORE_HOURS);

`MCM_API_AutoCheckBoxVars(SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED);

`MCM_API_AutoCheckBoxVars(ENABLE_TUTORIAL);

`MCM_API_AutoCheckBoxVars(WARN_BEFORE_EXPIRATION);
`MCM_API_AutoSliderVars(HOURS_BEFORE_WARNING);

`MCM_API_AutoCheckBoxVars(LOW_SOLDIERS_WARNING);

`MCM_API_AutoCheckBoxVars(PAUSE_ON_MILESTONE_100);
`MCM_API_AutoCheckBoxVars(PAUSE_ON_MILESTONE_125);
`MCM_API_AutoCheckBoxVars(PAUSE_ON_MILESTONE_150);
`MCM_API_AutoCheckBoxVars(PAUSE_ON_MILESTONE_175);
`MCM_API_AutoCheckBoxVars(PAUSE_ON_MILESTONE_200);
`MCM_API_AutoCheckBoxVars(PAUSE_ON_MILESTONE_225);

`include(CovertInfiltration\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

`MCM_API_AutoCheckBoxFns(DAYS_TO_HOURS, 1);
`MCM_API_AutoSliderFns(DAYS_BEFORE_HOURS,, 1);

`MCM_API_AutoCheckBoxFns(SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED, 1);

`MCM_API_AutoCheckBoxFns(ENABLE_TUTORIAL, 1);

`MCM_API_AutoCheckBoxFns(WARN_BEFORE_EXPIRATION, 1);
`MCM_API_AutoSliderFns(HOURS_BEFORE_WARNING,, 1);

`MCM_API_AutoCheckBoxFns(LOW_SOLDIERS_WARNING, 1);

`MCM_API_AutoCheckBoxFns(PAUSE_ON_MILESTONE_100, 1);
`MCM_API_AutoCheckBoxFns(PAUSE_ON_MILESTONE_125, 1);
`MCM_API_AutoCheckBoxFns(PAUSE_ON_MILESTONE_150, 1);
`MCM_API_AutoCheckBoxFns(PAUSE_ON_MILESTONE_175, 1);
`MCM_API_AutoCheckBoxFns(PAUSE_ON_MILESTONE_200, 1);
`MCM_API_AutoCheckBoxFns(PAUSE_ON_MILESTONE_225, 1);

event OnInit(UIScreen Screen)
{
	`MCM_API_Register(Screen, ClientModCallback);
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
	local MCM_API_SettingsPage Page;
	local MCM_API_SettingsGroup Group;

	LoadSavedSettings();
	Page = ConfigAPI.NewSettingsPage(ModName);
	Page.SetPageTitle(PageTitle);
	Page.SetSaveHandler(SaveButtonClicked);
	
	//Uncomment to enable reset
	//Page.EnableResetButton(ResetButtonClicked);

	Group = Page.AddGroup('VariousSettingsGroup', VariousSettingsTitle);
	`MCM_API_AutoAddCheckBox(Group, DAYS_TO_HOURS);
	`MCM_API_AutoAddSlider(Group, DAYS_BEFORE_HOURS, 1, 3, 1);
	`MCM_API_AutoAddCheckBox(Group, SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED);

	Group = Page.AddGroup('TipsGroup', TipsTitle);
	`MCM_API_AutoAddCheckBox(Group, ENABLE_TUTORIAL);
	`MCM_API_AutoAddCheckBox(Group, WARN_BEFORE_EXPIRATION);
	`MCM_API_AutoAddSlider(Group, HOURS_BEFORE_WARNING, 1, 4, 1);
	`MCM_API_AutoAddCheckBox(Group, LOW_SOLDIERS_WARNING);

	Group = Page.AddGroup('OverInfiltrationGroup', OverInfiltrationTitle);
	`MCM_API_AutoAddCheckBox(Group, PAUSE_ON_MILESTONE_100);
	`MCM_API_AutoAddCheckBox(Group, PAUSE_ON_MILESTONE_125);
	`MCM_API_AutoAddCheckBox(Group, PAUSE_ON_MILESTONE_150);
	`MCM_API_AutoAddCheckBox(Group, PAUSE_ON_MILESTONE_175);
	`MCM_API_AutoAddCheckBox(Group, PAUSE_ON_MILESTONE_200);
	`MCM_API_AutoAddCheckBox(Group, PAUSE_ON_MILESTONE_225);

	Page.ShowSettings();
}

simulated function LoadSavedSettings()
{
	DAYS_TO_HOURS = `GETMCMVAR(DAYS_TO_HOURS);
	DAYS_BEFORE_HOURS = `GETMCMVAR(DAYS_BEFORE_HOURS);

	SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED = `GETMCMVAR(SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED);

	ENABLE_TUTORIAL = `GETMCMVAR(ENABLE_TUTORIAL);

	WARN_BEFORE_EXPIRATION = `GETMCMVAR(WARN_BEFORE_EXPIRATION);
	HOURS_BEFORE_WARNING = `GETMCMVAR(HOURS_BEFORE_WARNING);
	
	LOW_SOLDIERS_WARNING = `GETMCMVAR(LOW_SOLDIERS_WARNING);

	PAUSE_ON_MILESTONE_100 = `GETMCMVAR(PAUSE_ON_MILESTONE_100);
	PAUSE_ON_MILESTONE_125 = `GETMCMVAR(PAUSE_ON_MILESTONE_125);
	PAUSE_ON_MILESTONE_150 = `GETMCMVAR(PAUSE_ON_MILESTONE_150);
	PAUSE_ON_MILESTONE_175 = `GETMCMVAR(PAUSE_ON_MILESTONE_175);
	PAUSE_ON_MILESTONE_200 = `GETMCMVAR(PAUSE_ON_MILESTONE_200);
	PAUSE_ON_MILESTONE_225 = `GETMCMVAR(PAUSE_ON_MILESTONE_225);
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	`MCM_API_AutoReset(DAYS_TO_HOURS);
	`MCM_API_AutoReset(DAYS_BEFORE_HOURS);

	`MCM_API_AutoReset(SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED);

	`MCM_API_AutoReset(ENABLE_TUTORIAL);

	`MCM_API_AutoReset(WARN_BEFORE_EXPIRATION);
	`MCM_API_AutoReset(HOURS_BEFORE_WARNING);
	
	`MCM_API_AutoReset(LOW_SOLDIERS_WARNING);

	`MCM_API_AutoReset(PAUSE_ON_MILESTONE_100);
	`MCM_API_AutoReset(PAUSE_ON_MILESTONE_125);
	`MCM_API_AutoReset(PAUSE_ON_MILESTONE_150);
	`MCM_API_AutoReset(PAUSE_ON_MILESTONE_175);
	`MCM_API_AutoReset(PAUSE_ON_MILESTONE_200);
	`MCM_API_AutoReset(PAUSE_ON_MILESTONE_225);
}


simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	VERSION_CFG = `MCM_CH_GetCompositeVersion();
	SaveConfig();
}


