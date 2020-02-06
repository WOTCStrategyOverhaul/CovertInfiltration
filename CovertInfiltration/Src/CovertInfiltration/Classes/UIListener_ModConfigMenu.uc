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
var config bool REMOVE_NICKNAMED_UPGRADES;
var config bool WARN_BEFORE_EXPIRATION;
var config int HOURS_BEFORE_WARNING;
var config bool LOW_SOLDIERS_WARNING;
var config bool PAUSE_ON_MILESTONE_100;
var config bool PAUSE_ON_MILESTONE_125;
var config bool PAUSE_ON_MILESTONE_150;
var config bool PAUSE_ON_MILESTONE_175;
var config bool PAUSE_ON_MILESTONE_200;
var config bool PAUSE_ON_MILESTONE_225;

// localized strings
var localized string PageTitle;
var localized string Group1Title;
var localized string Group2Title;
var localized string Group3Title;
var localized string DaysToHoursDesc;
var localized string DaysToHoursTooltip;
var localized string DaysBeforeHoursDesc;
var localized string DaysBeforeHoursTooltip;
var localized string EnableTutorialDesc;
var localized string EnableTutorialTooltip;
var localized string RemoveNicknamedUpgradesDesc;
var localized string RemoveNicknamedUpgradesTooltip;
var localized string WarnBeforeExpirationDesc;
var localized string WarnBeforeExpirationTooltip;
var localized string HoursBeforeWarningDesc;
var localized string HoursBeforeWarningTooltip;
var localized string LowSoldiersWarningDesc;
var localized string LowSoldiersWarningTooltip;
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
	local MCM_API_SettingsGroup Group1, Group2, Group3;

	LoadSavedSettings();

	Page = ConfigAPI.NewSettingsPage("Covert Infiltration");
	Page.SetPageTitle(PageTitle);
	Page.SetSaveHandler(SaveButtonClicked);

	Group1 = Page.AddGroup('Group1', Group1Title);

	Group1.AddCheckBox('DaysToHours', DaysToHoursDesc, DaysToHoursTooltip, DAYS_TO_HOURS, DaysToHoursSaveHandler);
	Group1.AddSlider('DaysBeforeHours', DaysBeforeHoursDesc, DaysBeforeHoursTooltip, 1, 3, 1, DAYS_BEFORE_HOURS, DaysBeforeHoursSaveHandler);
	Group1.AddCheckBox('RemoveNicknamedUpgrades', RemoveNicknamedUpgradesDesc, RemoveNicknamedUpgradesTooltip, REMOVE_NICKNAMED_UPGRADES, RemoveNicknamedUpgradesSaveHandler);
	Group1.AddCheckBox('WarnBeforeExpiration', WarnBeforeExpirationDesc, WarnBeforeExpirationTooltip, WARN_BEFORE_EXPIRATION, WarnBeforeExpirationSaveHandler);
	Group1.AddSlider('HoursBeforeWarningTooltip', HoursBeforeWarningDesc, HoursBeforeWarningTooltip, 1, 4, 1, HOURS_BEFORE_WARNING, HoursBeforeWarningSaveHandler);
	
	Group2 = Page.AddGroup('Group2', Group2Title);
	
	Group2.AddCheckBox('EnableTutorial', EnableTutorialDesc, EnableTutorialTooltip, ENABLE_TUTORIAL, EnableTutorialSaveHandler);
	Group2.AddCheckBox('LowSoldiersWarning', LowSoldiersWarningDesc, LowSoldiersWarningTooltip, LOW_SOLDIERS_WARNING, LowSoldiersWarningSaveHandler);
	
	Group3 = Page.AddGroup('Group3', Group3Title);

	Group3.AddCheckBox('PauseOnMilestone100', PauseOnMilestone100Desc, PauseOnMilestone100Tooltip, PAUSE_ON_MILESTONE_100, PauseOnMilestone100SaveHandler);
	Group3.AddCheckBox('PauseOnMilestone125', PauseOnMilestone125Desc, PauseOnMilestone125Tooltip, PAUSE_ON_MILESTONE_125, PauseOnMilestone125SaveHandler);
	Group3.AddCheckBox('PauseOnMilestone150', PauseOnMilestone150Desc, PauseOnMilestone150Tooltip, PAUSE_ON_MILESTONE_150, PauseOnMilestone150SaveHandler);
	Group3.AddCheckBox('PauseOnMilestone175', PauseOnMilestone175Desc, PauseOnMilestone175Tooltip, PAUSE_ON_MILESTONE_175, PauseOnMilestone175SaveHandler);
	Group3.AddCheckBox('PauseOnMilestone200', PauseOnMilestone200Desc, PauseOnMilestone200Tooltip, PAUSE_ON_MILESTONE_200, PauseOnMilestone200SaveHandler);
	Group3.AddCheckBox('PauseOnMilestone225', PauseOnMilestone225Desc, PauseOnMilestone225Tooltip, PAUSE_ON_MILESTONE_225, PauseOnMilestone225SaveHandler);

	Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'ModConfigMenu_Defaults'.default.iVERSION, CONFIG_VERSION)

simulated function LoadSavedSettings()
{
	DAYS_TO_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_TO_HOURS_DEFAULT, DAYS_TO_HOURS);
	DAYS_BEFORE_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_BEFORE_HOURS_DEFAULT, DAYS_BEFORE_HOURS);
	REMOVE_NICKNAMED_UPGRADES = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.REMOVE_NICKNAMED_UPGRADES_DEFAULT, REMOVE_NICKNAMED_UPGRADES);
	WARN_BEFORE_EXPIRATION = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.WARN_BEFORE_EXPIRATION_DEFAULT, WARN_BEFORE_EXPIRATION);
	HOURS_BEFORE_WARNING = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.HOURS_BEFORE_WARNING_DEFAULT, HOURS_BEFORE_WARNING);
	
	ENABLE_TUTORIAL = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.ENABLE_TUTORIAL_DEFAULT, ENABLE_TUTORIAL);
	LOW_SOLDIERS_WARNING = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.LOW_SOLDIERS_WARNING_DEFAULT, LOW_SOLDIERS_WARNING);
	
	PAUSE_ON_MILESTONE_100 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_100_DEFAULT, PAUSE_ON_MILESTONE_100);
	PAUSE_ON_MILESTONE_125 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_125_DEFAULT, PAUSE_ON_MILESTONE_125);
	PAUSE_ON_MILESTONE_150 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_150_DEFAULT, PAUSE_ON_MILESTONE_150);
	PAUSE_ON_MILESTONE_175 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_175_DEFAULT, PAUSE_ON_MILESTONE_175);
	PAUSE_ON_MILESTONE_200 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_200_DEFAULT, PAUSE_ON_MILESTONE_200);
	PAUSE_ON_MILESTONE_225 = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_225_DEFAULT, PAUSE_ON_MILESTONE_225);
}

`MCM_API_BasicCheckboxSaveHandler(DaysToHoursSaveHandler, DAYS_TO_HOURS)
`MCM_API_BasicSliderSaveHandler(DaysBeforeHoursSaveHandler, DAYS_BEFORE_HOURS)
`MCM_API_BasicCheckboxSaveHandler(RemoveNicknamedUpgradesSaveHandler, REMOVE_NICKNAMED_UPGRADES)
`MCM_API_BasicCheckboxSaveHandler(WarnBeforeExpirationSaveHandler, WARN_BEFORE_EXPIRATION)
`MCM_API_BasicSliderSaveHandler(HoursBeforeWarningSaveHandler, HOURS_BEFORE_WARNING)

`MCM_API_BasicCheckboxSaveHandler(EnableTutorialSaveHandler, ENABLE_TUTORIAL)
`MCM_API_BasicCheckboxSaveHandler(LowSoldiersWarningSaveHandler, LOW_SOLDIERS_WARNING)

`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone100SaveHandler, PAUSE_ON_MILESTONE_100)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone125SaveHandler, PAUSE_ON_MILESTONE_125)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone150SaveHandler, PAUSE_ON_MILESTONE_150)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone175SaveHandler, PAUSE_ON_MILESTONE_175)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone200SaveHandler, PAUSE_ON_MILESTONE_200)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestone225SaveHandler, PAUSE_ON_MILESTONE_225)

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	self.CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
	self.SaveConfig();
}
