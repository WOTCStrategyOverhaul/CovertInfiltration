//-----------------------------------------------------------
// TODO
//-----------------------------------------------------------

class UIListener_ModConfigMenu extends Object config(CovertInfiltrationSettings);

var config int CONFIG_VERSION;

var config bool DAYS_TO_HOURS;
var config int DAYS_BEFORE_HOURS;
var config bool SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED;
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
var config bool ENABLE_TRACE_STARTUP;

// Important: can't use trace logging here
static function TryTransfer ()
{
	// Already done
	if (default.CONFIG_VERSION < 1) return;

	if (default.CONFIG_VERSION < 3)
	{
		`RedScreen("CI MCM error, see log");
		`CI_Log("WARNING: Detected MCM config from before beta 2, can't auto-transfer to the new format");
		`CI_Log("Delete Documents\My Games\XCOM2 War of the Chosen\XComGame\Config\XComCovertInfiltrationSettings.ini to abandon old values and get rid of this warning");
		return;
	}

	if (default.CONFIG_VERSION > 3)
	{
		`RedScreen("CI MCM error, see log");
		`CI_Log("WARNING: Detected MCM config from the old format with an incorrect version, can't auto-transfer to the new format");
		`CI_Log("Delete Documents\My Games\XCOM2 War of the Chosen\XComGame\Config\XComCovertInfiltrationSettings.ini to abandon old values and get rid of this warning");
		return;
	}

	if (class'CovertInfiltration_MCMScreen'.default.VERSION_CFG > 3)
	{
		`RedScreen("CI MCM error, see log");
		`CI_Log("WARNING: Can't auto-transfer MCM config to the new format as the new format already contains user-configured values");
		`CI_Log("Delete Documents\My Games\XCOM2 War of the Chosen\XComGame\Config\XComCovertInfiltrationSettings.ini to abandon old values and get rid of this warning");
		return;
	}

	class'CovertInfiltration_MCMScreen'.default.DAYS_TO_HOURS = default.DAYS_TO_HOURS;
	class'CovertInfiltration_MCMScreen'.default.DAYS_BEFORE_HOURS = default.DAYS_BEFORE_HOURS;
	class'CovertInfiltration_MCMScreen'.default.SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED = default.SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED;
	class'CovertInfiltration_MCMScreen'.default.ENABLE_TUTORIAL = default.ENABLE_TUTORIAL;
	class'CovertInfiltration_MCMScreen'.default.WARN_BEFORE_EXPIRATION = default.WARN_BEFORE_EXPIRATION;
	class'CovertInfiltration_MCMScreen'.default.HOURS_BEFORE_WARNING = default.HOURS_BEFORE_WARNING;
	class'CovertInfiltration_MCMScreen'.default.LOW_SOLDIERS_WARNING = default.LOW_SOLDIERS_WARNING;
	class'CovertInfiltration_MCMScreen'.default.PAUSE_ON_MILESTONE_100 = default.PAUSE_ON_MILESTONE_100;
	class'CovertInfiltration_MCMScreen'.default.PAUSE_ON_MILESTONE_125 = default.PAUSE_ON_MILESTONE_125;
	class'CovertInfiltration_MCMScreen'.default.PAUSE_ON_MILESTONE_150 = default.PAUSE_ON_MILESTONE_150;
	class'CovertInfiltration_MCMScreen'.default.PAUSE_ON_MILESTONE_175 = default.PAUSE_ON_MILESTONE_175;
	class'CovertInfiltration_MCMScreen'.default.PAUSE_ON_MILESTONE_200 = default.PAUSE_ON_MILESTONE_200;
	class'CovertInfiltration_MCMScreen'.default.PAUSE_ON_MILESTONE_225 = default.PAUSE_ON_MILESTONE_225;
	class'CovertInfiltration_MCMScreen'.default.ENABLE_TRACE_STARTUP = default.ENABLE_TRACE_STARTUP;

	class'CovertInfiltration_MCMScreen'.default.VERSION_CFG = 4;
	class'CovertInfiltration_MCMScreen'.static.StaticSaveConfig();

	default.CONFIG_VERSION = -1;
	StaticSaveConfig();
}
