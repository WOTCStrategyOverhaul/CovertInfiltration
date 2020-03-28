//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone and Xymanek
//  PURPOSE: ModConfigMenu options screen for this mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_ModConfigMenu extends UIScreenListener config(CovertInfiltrationSettings);

`include(CovertInfiltration/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(CovertInfiltration/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config int CONFIG_VERSION;

var config bool DAYS_TO_HOURS;
var config int DAYS_BEFORE_HOURS;
var config bool ENABLE_TUTORIAL;
var config bool WARN_BEFORE_EXPIRATION;
var config int HOURS_BEFORE_WARNING;
var config bool LOW_SOLDIERS_WARNING;
var config bool PAUSE_ON_MILESTONE_100;
var config bool PAUSE_ON_MILESTONE_125;
var config bool PAUSE_ON_MILESTONE_150;
var config bool PAUSE_ON_MILESTONE_175;
var config bool PAUSE_ON_MILESTONE_200;
var config bool PAUSE_ON_MILESTONE_225;

// Development tools
var config bool ENABLE_TRACE_STARTUP; // False is the default value, so there is no corresponding field in defaults

// localized strings
var localized string PageTitle;
var localized string VariousSettingsTitle;
var localized string TipsTitle;
var localized string OverInfiltrationTitle;

var localized string DaysToHoursDesc;
var localized string DaysToHoursTooltip;
var localized string DaysBeforeHoursDesc;
var localized string DaysBeforeHoursTooltip;

var localized string EnableTutorialDesc;
var localized string EnableTutorialTooltip;
var localized string LowSoldiersWarningDesc;
var localized string LowSoldiersWarningTooltip;
var localized string WarnBeforeExpirationDesc;
var localized string WarnBeforeExpirationTooltip;
var localized string HoursBeforeWarningDesc;
var localized string HoursBeforeWarningTooltip;

var localized string PauseOnMilestone100Desc;
var localized string PauseOnMilestone100Tooltip;
var localized string PauseOnMilestone125Desc;
var localized string PauseOnMilestone125Tooltip;
var localized string PauseOnMilestone150Desc;
var localized string PauseOnMilestone150Tooltip;
var localized string PauseOnMilestone175Desc;
var localized string PauseOnMilestone175Tooltip;
var localized string PauseOnMilestone200Desc;
var localized string PauseOnMilestone200Tooltip;
var localized string PauseOnMilestone225Desc;
var localized string PauseOnMilestone225Tooltip;

event OnInit(UIScreen Screen)
{
	if (MCM_API(Screen) != none)
	{
		`MCM_API_Register(Screen, ClientModCallback);
	}
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
	local MCM_API_SettingsPage Page;
	local MCM_API_SettingsGroup VariousSettingsGroup, TipsGroup, OverInfiltrationGroup, DeveloperToolsGroup;

	LoadSavedSettings();

	Page = ConfigAPI.NewSettingsPage("Covert Infiltration");
	Page.SetPageTitle(PageTitle);
	Page.SetSaveHandler(SaveButtonClicked);

	VariousSettingsGroup = Page.AddGroup('VariousSettingsGroup', VariousSettingsTitle);

	VariousSettingsGroup.AddCheckBox('DaysToHours', DaysToHoursDesc, DaysToHoursTooltip, DAYS_TO_HOURS, DaysToHoursSaveHandler);
	VariousSettingsGroup.AddSlider('DaysBeforeHours', DaysBeforeHoursDesc, DaysBeforeHoursTooltip, 1, 3, 1, DAYS_BEFORE_HOURS, DaysBeforeHoursSaveHandler);
	
	TipsGroup = Page.AddGroup('TipsGroup', TipsTitle);
	
	TipsGroup.AddCheckBox('EnableTutorial', EnableTutorialDesc, EnableTutorialTooltip, ENABLE_TUTORIAL, EnableTutorialSaveHandler);
	TipsGroup.AddCheckBox('LowSoldiersWarning', LowSoldiersWarningDesc, LowSoldiersWarningTooltip, LOW_SOLDIERS_WARNING, LowSoldiersWarningSaveHandler);
	TipsGroup.AddCheckBox('WarnBeforeExpiration', WarnBeforeExpirationDesc, WarnBeforeExpirationTooltip, WARN_BEFORE_EXPIRATION, WarnBeforeExpirationSaveHandler);
	TipsGroup.AddSlider('HoursBeforeWarningTooltip', HoursBeforeWarningDesc, HoursBeforeWarningTooltip, 1, 4, 1, HOURS_BEFORE_WARNING, HoursBeforeWarningSaveHandler);
	
	OverInfiltrationGroup = Page.AddGroup('OverInfiltrationGroup', OverInfiltrationTitle);

	OverInfiltrationGroup.AddCheckBox('PauseOnMilestone100', PauseOnMilestone100Desc, PauseOnMilestone100Tooltip, PAUSE_ON_MILESTONE_100, PauseOnMilestone100SaveHandler);
	OverInfiltrationGroup.AddCheckBox('PauseOnMilestone125', PauseOnMilestone125Desc, PauseOnMilestone125Tooltip, PAUSE_ON_MILESTONE_125, PauseOnMilestone125SaveHandler);
	OverInfiltrationGroup.AddCheckBox('PauseOnMilestone150', PauseOnMilestone150Desc, PauseOnMilestone150Tooltip, PAUSE_ON_MILESTONE_150, PauseOnMilestone150SaveHandler);
	OverInfiltrationGroup.AddCheckBox('PauseOnMilestone175', PauseOnMilestone175Desc, PauseOnMilestone175Tooltip, PAUSE_ON_MILESTONE_175, PauseOnMilestone175SaveHandler);
	OverInfiltrationGroup.AddCheckBox('PauseOnMilestone200', PauseOnMilestone200Desc, PauseOnMilestone200Tooltip, PAUSE_ON_MILESTONE_200, PauseOnMilestone200SaveHandler);
	OverInfiltrationGroup.AddCheckBox('PauseOnMilestone225', PauseOnMilestone225Desc, PauseOnMilestone225Tooltip, PAUSE_ON_MILESTONE_225, PauseOnMilestone225SaveHandler);

	// Not localized on purpose
	DeveloperToolsGroup = Page.AddGroup('DeveloperToolsGroup', "Developer tools");
	DeveloperToolsGroup.AddCheckBox('EnableTraceStartup', "Enable trace on startup", "WARNING: Can flood logs with internal info. WILL reveal things that player is not supposed to be aware of", ENABLE_TRACE_STARTUP, EnableTraceStartupSaveHandler);

	Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'ModConfigMenu_Defaults'.default.iVERSION, CONFIG_VERSION)

simulated function LoadSavedSettings()
{
	DAYS_TO_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_TO_HOURS_DEFAULT, DAYS_TO_HOURS);
	DAYS_BEFORE_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_BEFORE_HOURS_DEFAULT, DAYS_BEFORE_HOURS);
	
	ENABLE_TUTORIAL = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.ENABLE_TUTORIAL_DEFAULT, ENABLE_TUTORIAL);
	LOW_SOLDIERS_WARNING = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.LOW_SOLDIERS_WARNING_DEFAULT, LOW_SOLDIERS_WARNING);
	WARN_BEFORE_EXPIRATION = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.WARN_BEFORE_EXPIRATION_DEFAULT, WARN_BEFORE_EXPIRATION);
	HOURS_BEFORE_WARNING = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.HOURS_BEFORE_WARNING_DEFAULT, HOURS_BEFORE_WARNING);
	
	PAUSE_ON_MILESTONE_100 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_100_DEFAULT, PAUSE_ON_MILESTONE_100);
	PAUSE_ON_MILESTONE_125 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_125_DEFAULT, PAUSE_ON_MILESTONE_125);
	PAUSE_ON_MILESTONE_150 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_150_DEFAULT, PAUSE_ON_MILESTONE_150);
	PAUSE_ON_MILESTONE_175 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_175_DEFAULT, PAUSE_ON_MILESTONE_175);
	PAUSE_ON_MILESTONE_200 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_200_DEFAULT, PAUSE_ON_MILESTONE_200);
	PAUSE_ON_MILESTONE_225 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_225_DEFAULT, PAUSE_ON_MILESTONE_225);
}

`MCM_API_BasicCheckboxSaveHandler(DaysToHoursSaveHandler, DAYS_TO_HOURS)
`MCM_API_BasicSliderSaveHandler(DaysBeforeHoursSaveHandler, DAYS_BEFORE_HOURS)

`MCM_API_BasicCheckboxSaveHandler(EnableTutorialSaveHandler, ENABLE_TUTORIAL)
`MCM_API_BasicCheckboxSaveHandler(LowSoldiersWarningSaveHandler, LOW_SOLDIERS_WARNING)
`MCM_API_BasicCheckboxSaveHandler(WarnBeforeExpirationSaveHandler, WARN_BEFORE_EXPIRATION)
`MCM_API_BasicSliderSaveHandler(HoursBeforeWarningSaveHandler, HOURS_BEFORE_WARNING)

`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone100SaveHandler, PAUSE_ON_MILESTONE_100)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone125SaveHandler, PAUSE_ON_MILESTONE_125)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone150SaveHandler, PAUSE_ON_MILESTONE_150)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone175SaveHandler, PAUSE_ON_MILESTONE_175)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone200SaveHandler, PAUSE_ON_MILESTONE_200)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone225SaveHandler, PAUSE_ON_MILESTONE_225)

`MCM_API_BasicCheckboxSaveHandler(EnableTraceStartupSaveHandler, ENABLE_TRACE_STARTUP)

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	self.CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
	self.SaveConfig();
}
