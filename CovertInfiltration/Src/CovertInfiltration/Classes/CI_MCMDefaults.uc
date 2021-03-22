class CI_MCMDefaults extends object config(CovertInfiltration_DEFAULT);

var config int VERSION_CFG;

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

// False is the default, not configurable
var bool ENABLE_TRACE_STARTUP;
