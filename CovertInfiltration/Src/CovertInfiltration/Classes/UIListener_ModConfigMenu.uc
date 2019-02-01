//---------------------------------------------------------------------------------------
//  ModConfigMenu Listener & Options Screen
//---------------------------------------------------------------------------------------

class UIListener_ModConfigMenu extends UIScreenListener config(CovertInfiltrationSettings);

`include(CovertInfiltration/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(CovertInfiltration/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config int CONFIG_VERSION;

var config bool DAYS_TO_HOURS;
var config int DAYS_BEFORE_HOURS;

// localized strings
var localized string PageTitle;
var localized string GroupTitle;
var localized string DaysToHoursDesc;
var localized string DaysToHoursTooltip;
var localized string DaysBeforeHoursDesc;
var localized string DaysBeforeHoursTooltip;

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

	Group.AddCheckBox('checkbox', DaysToHoursDesc, DaysToHoursTooltip, DAYS_TO_HOURS, CheckboxSaveHandler);
	Group.AddSlider('slider', DaysBeforeHoursDesc, DaysBeforeHoursTooltip, 1, 3, 1, DAYS_BEFORE_HOURS, SliderSaveHandler);

	Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'ModConfigMenu_Defaults'.default.iVERSION, CONFIG_VERSION)

simulated function LoadSavedSettings()
{
    DAYS_TO_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_TO_HOURS_DEFAULT, DAYS_TO_HOURS);
	DAYS_BEFORE_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_BEFORE_HOURS_DEFAULT, DAYS_BEFORE_HOURS);
}

`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandler, DAYS_TO_HOURS)
`MCM_API_BasicSliderSaveHandler(SliderSaveHandler, DAYS_BEFORE_HOURS)

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    self.CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}
