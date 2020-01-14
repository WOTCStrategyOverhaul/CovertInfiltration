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
var config bool PAUSE_ON_MILESTONE;

// localized strings
var localized string PageTitle;
var localized string GroupTitle;
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
var localized string PauseOnMilestoneDesc;
var localized string PauseOnMilestoneTooltip;

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
	local MCM_API_SettingsGroup Group;

	LoadSavedSettings();

	Page = ConfigAPI.NewSettingsPage("Covert Infiltration");
	Page.SetPageTitle(PageTitle);
	Page.SetSaveHandler(SaveButtonClicked);

	Group = Page.AddGroup('Group1', GroupTitle);

	Group.AddCheckBox('DaysToHours', DaysToHoursDesc, DaysToHoursTooltip, DAYS_TO_HOURS, DaysToHoursSaveHandler);
	Group.AddSlider('DaysBeforeHours', DaysBeforeHoursDesc, DaysBeforeHoursTooltip, 1, 3, 1, DAYS_BEFORE_HOURS, DaysBeforeHoursSaveHandler);
	Group.AddCheckBox('EnableTutorial', EnableTutorialDesc, EnableTutorialTooltip, ENABLE_TUTORIAL, EnableTutorialSaveHandler);
	Group.AddCheckBox('RemoveNicknamedUpgrades', RemoveNicknamedUpgradesDesc, RemoveNicknamedUpgradesTooltip, REMOVE_NICKNAMED_UPGRADES, RemoveNicknamedUpgradesSaveHandler);
	Group.AddCheckBox('WarnBeforeExpiration', WarnBeforeExpirationDesc, WarnBeforeExpirationTooltip, WARN_BEFORE_EXPIRATION, WarnBeforeExpirationSaveHandler);
	Group.AddSlider('HoursBeforeWarningTooltip', HoursBeforeWarningDesc, HoursBeforeWarningTooltip, 1, 4, 1, HOURS_BEFORE_WARNING, HoursBeforeWarningSaveHandler);
	Group.AddCheckBox('LowSoldiersWarning', LowSoldiersWarningDesc, LowSoldiersWarningTooltip, LOW_SOLDIERS_WARNING, LowSoldiersWarningSaveHandler);
	Group.AddCheckBox('PauseOnMilestone', PauseOnMilestoneDesc, PauseOnMilestoneTooltip, PAUSE_ON_MILESTONE, PauseOnMilestoneSaveHandler);

	Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'ModConfigMenu_Defaults'.default.iVERSION, CONFIG_VERSION)

simulated function LoadSavedSettings()
{
	DAYS_TO_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_TO_HOURS_DEFAULT, DAYS_TO_HOURS);
	DAYS_BEFORE_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_BEFORE_HOURS_DEFAULT, DAYS_BEFORE_HOURS);
	ENABLE_TUTORIAL = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.ENABLE_TUTORIAL_DEFAULT, ENABLE_TUTORIAL);
	REMOVE_NICKNAMED_UPGRADES = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.REMOVE_NICKNAMED_UPGRADES_DEFAULT, REMOVE_NICKNAMED_UPGRADES);
	WARN_BEFORE_EXPIRATION = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.WARN_BEFORE_EXPIRATION_DEFAULT, WARN_BEFORE_EXPIRATION);
	HOURS_BEFORE_WARNING = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.HOURS_BEFORE_WARNING_DEFAULT, HOURS_BEFORE_WARNING);
	LOW_SOLDIERS_WARNING = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.LOW_SOLDIERS_WARNING_DEFAULT, LOW_SOLDIERS_WARNING);
	PAUSE_ON_MILESTONE = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.PAUSE_ON_MILESTONE_DEFAULT, PAUSE_ON_MILESTONE);
}

`MCM_API_BasicCheckboxSaveHandler(DaysToHoursSaveHandler, DAYS_TO_HOURS)
`MCM_API_BasicSliderSaveHandler(DaysBeforeHoursSaveHandler, DAYS_BEFORE_HOURS)
`MCM_API_BasicCheckboxSaveHandler(EnableTutorialSaveHandler, ENABLE_TUTORIAL)
`MCM_API_BasicCheckboxSaveHandler(RemoveNicknamedUpgradesSaveHandler, REMOVE_NICKNAMED_UPGRADES)
`MCM_API_BasicCheckboxSaveHandler(WarnBeforeExpirationSaveHandler, WARN_BEFORE_EXPIRATION)
`MCM_API_BasicSliderSaveHandler(HoursBeforeWarningSaveHandler, HOURS_BEFORE_WARNING)
`MCM_API_BasicCheckboxSaveHandler(LowSoldiersWarningSaveHandler, LOW_SOLDIERS_WARNING)
`MCM_API_BasicCheckboxSaveHandler(PauseOnMilestoneSaveHandler, PAUSE_ON_MILESTONE)

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	self.CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
	self.SaveConfig();
}
