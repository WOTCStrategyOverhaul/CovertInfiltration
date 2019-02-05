# CovertInfiltration
A mod that overhauls the Covert Actions system to bring back the Infiltration mechanic from Long War 2.

This mod will later become the foundation of a much larger transformational Strategy Overhaul

# Building and running
In order to build this mod, make sure that you clone the repository **with submodules** and our custom build script will properly setup all dependencies. There is also VSCode integration if you want to use that.

**Warning**: When you switch between debug/release script modes, the compile will fail first time. Just build again

In order to run this mod, the following are needed (in addition to this mod):

* X2WOTCCommunityHighlander - we maintain our own repo/branch where we merge our changes before the workshop version. You can generally find a built/cooked version [here](https://github.com/WOTCStrategyOverhaul/X2WOTCCommunityHighlander/releases)
* SquadSelectAnytime - workshop version will suffice
* [robojumperSquadSelect](https://github.com/robojumper/robojumperSquadSelect) - requires a **local build** (workshop version is behind)

# Contributing
When contributing please use the Community Highlander code style:

  * use tabs
  * use new lines for braces
  * use appropriate spacing
  * use braces even for one-line if/else bodies
  
The following code should illustrate all of this:

    static function CompleteStrategyFromTacticalTransfer()
    {
    	local XComOnlineEventMgr EventManager;
    	local array<X2DownloadableContentInfo> DLCInfos;
    	local int i;

    	UpdateSkyranger();
    	CleanupProxyVips();
    	ProcessMissionResults();
    	SquadTacticalToStrategyTransfer();

    	EventManager = `ONLINEEVENTMGR;
    	DLCInfos = EventManager.GetDLCInfos(false);
    	for (i = 0; i < DLCInfos.Length; ++i)
    	{
    		DLCInfos[i].OnPostMission();
    	}
    }

**Please aim for you code to be easily readable** - it should clearly convey its purpose/intend/what it is doing. As such please use appropriate tools - comments, spacing/empty lines, specific variable/function/class names, etc.

**Use correct log category** - `CI` (or `CI_*` - eg. `CI_P1Spawner`). Any PR that uses `ScriptLog` (eg. `log("Something")`) __will not be merged__

## Naming files/classes

Please keep the following guidelines in mind:

* Try to keep to same naming style as X2 codebase
* If you need to add `CI` to class name (eg. MCO), please **append** it. Eg. `SomeClass` -> `SomeClass_CI`
* If your class derives from `XComGameState_BaseObject` (even if not directly), it needs to be named `XComGameState_*`
* If your class derives from `UIScreenListener` (even if not directly), it needs to be named `UIListener_*`
* If your class is an UI element (screen, panel or some auxiliary class), it needs to be named `UI*`
* Event listeners **templates** should go inside `X2EventListener_Infiltration` and `X2EventListener_Infiltration_UI`, not other classes
* If your class derives from some class that derives from `X2DataSet`, it needs to be named in same manner as base game classes that create same templates

You will find some places which do not follow these guidelines - they are generally remnants of project's early days. We hope to fix them at some point, but it's not a priority. If you have any questions, please ask them in discord chat
