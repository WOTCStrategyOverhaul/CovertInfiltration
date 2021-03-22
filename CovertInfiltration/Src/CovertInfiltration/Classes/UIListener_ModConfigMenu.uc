//---------------------------------------------------------------------------------------
//  AUTHOR:   Xymanek
//  PURPOSE:  This class used to house the MCM config, but that was moved to Mr.Nice's
//            integration (see CI_MCMScreen). Now it exists solely to auto-transfer
//            existing configs to the new format
//  IMPORANT: Names (class, config, fields) cannot be changed
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class UIListener_ModConfigMenu extends Object config(CovertInfiltrationSettings);

// Add a note in the config files for the users
var config string IMPORTANT_INFO;

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
		`CI_Log("Delete Documents\\My Games\\XCOM2 War of the Chosen\\XComGame\\Config\\XComCovertInfiltrationSettings.ini to abandon old values and get rid of this warning");
		return;
	}

	if (default.CONFIG_VERSION > 3)
	{
		`RedScreen("CI MCM error, see log");
		`CI_Log("WARNING: Detected MCM config from the old format with an incorrect version, can't auto-transfer to the new format");
		`CI_Log("Delete Documents\\My Games\\XCOM2 War of the Chosen\\XComGame\\Config\\XComCovertInfiltrationSettings.ini to abandon old values and get rid of this warning");
		return;
	}

	if (class'CI_MCMScreen'.default.VERSION_CFG > 3)
	{
		`RedScreen("CI MCM error, see log");
		`CI_Log("WARNING: Can't auto-transfer MCM config to the new format as the new format already contains user-configured values");
		`CI_Log("Delete Documents\\My Games\\XCOM2 War of the Chosen\\XComGame\\Config\\XComCovertInfiltrationSettings.ini to abandon old values and get rid of this warning");
		return;
	}

	class'CI_MCMScreen'.default.DAYS_TO_HOURS = default.DAYS_TO_HOURS;
	class'CI_MCMScreen'.default.DAYS_BEFORE_HOURS = default.DAYS_BEFORE_HOURS;
	class'CI_MCMScreen'.default.SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED = default.SUPPRESS_SKULLJACK_NAG_IF_DEPLOYED;
	class'CI_MCMScreen'.default.ENABLE_TUTORIAL = default.ENABLE_TUTORIAL;
	class'CI_MCMScreen'.default.WARN_BEFORE_EXPIRATION = default.WARN_BEFORE_EXPIRATION;
	class'CI_MCMScreen'.default.HOURS_BEFORE_WARNING = default.HOURS_BEFORE_WARNING;
	class'CI_MCMScreen'.default.LOW_SOLDIERS_WARNING = default.LOW_SOLDIERS_WARNING;
	class'CI_MCMScreen'.default.PAUSE_ON_MILESTONE_100 = default.PAUSE_ON_MILESTONE_100;
	class'CI_MCMScreen'.default.PAUSE_ON_MILESTONE_125 = default.PAUSE_ON_MILESTONE_125;
	class'CI_MCMScreen'.default.PAUSE_ON_MILESTONE_150 = default.PAUSE_ON_MILESTONE_150;
	class'CI_MCMScreen'.default.PAUSE_ON_MILESTONE_175 = default.PAUSE_ON_MILESTONE_175;
	class'CI_MCMScreen'.default.PAUSE_ON_MILESTONE_200 = default.PAUSE_ON_MILESTONE_200;
	class'CI_MCMScreen'.default.PAUSE_ON_MILESTONE_225 = default.PAUSE_ON_MILESTONE_225;
	class'CI_MCMScreen'.default.ENABLE_TRACE_STARTUP = default.ENABLE_TRACE_STARTUP;

	class'CI_MCMScreen'.default.VERSION_CFG = 4;
	class'CI_MCMScreen'.static.StaticSaveConfig();

	default.IMPORTANT_INFO = "This file is no longer in use and can be safely deleted";
	default.CONFIG_VERSION = -1;
	StaticSaveConfig();

	`CI_Log("Auto-transferred the MCM config to the new format");
}
