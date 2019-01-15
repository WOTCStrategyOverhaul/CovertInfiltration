//---------------------------------------------------------------------------------------
//  ModConfigMenu Listener & Options Screen
//---------------------------------------------------------------------------------------

class UIListener_ModConfigMenu extends UIScreenListener config(CovertInfiltrationSettings);

`include(CovertInfiltration/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(CovertInfiltration/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config int CONFIG_VERSION;

var config bool DAYS_TO_HOURS;
var config int DAYS_BEFORE_HOURS;

var MCM_API_Checkbox DaysToHours;
var MCM_API_Slider DaysBeforeHours;

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
	Page.SetPageTitle("Covert Infiltration");
	Page.SetSaveHandler(SaveButtonClicked);

	Group = Page.AddGroup('Group1', "Various Settings");

	Group.AddCheckBox('checkbox', "Hours instead of days", "Display hours instead of days in the EventQueue", DAYS_TO_HOURS, CheckboxSaveHandler);
	Group.AddSlider('slider', "Days before hours", "How many days left before displaying hours instead", 1, 3, 1, DAYS_BEFORE_HOURS, SliderSaveHandler);

	Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'ModConfigMenu_Defaults'.default.VERSION, CONFIG_VERSION)

simulated function LoadSavedSettings()
{
    DAYS_TO_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_TO_HOURS_DEFAULT, DAYS_TO_HOURS);
	DAYS_BEFORE_HOURS = `MCM_CH_GetValue(class'ModConfigMenu_Defaults'.default.DAYS_BEFORE_HOURS_DEFAULT, DAYS_BEFORE_HOURS);
}

`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandler, DAYS_TO_HOURS)
`MCM_API_BasicSliderSaveHandler(SliderSaveHandler, DAYS_BEFORE_HOURS)

simulated function CheckboxChangeHandler(MCM_API_Setting Setting, bool Value)
{
		DaysBeforeHours.SetEditable(Value);
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    self.CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}

defaultproperties
{
	ScreenClass=none
}
