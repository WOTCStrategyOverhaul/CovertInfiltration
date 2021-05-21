# X2ModBuildCommon
An improved XCOM 2 mod build system. The following (in no praticular order) are its features/improvements over the default one:

* Path rewriting for script errors/warnings so that they no longer point to the temporary copies of files in SDK/Developement/Src
* Automated including of compile-time dependencies (including CHL) so that you no longer need to pollute your SrcOrig with them
* Caching of `ModShaderCache` and invoking the shader precompiler only when the mod content files have changed
* Proper cancelling of the build mid-way (instead of waiting until it completes)
* Configurable mod workshop ID
* Automated including of SDK's content packages (for those which are missing in the cooked game) so that you don't need to store them in your project
* Full HL building: final release compiling and cooking of native script packages
* Scriptable hooks in the build process
* Conversion of localization file(s) encoding (UTF8 in the project for correct git merging and UTF16 for correct game loading)
* Validation of `.x2proj` for cases when devs are using both ModBuddy and VSCode
* Mod asset cooking (experimental)
* Correct removal of files from the steamapps/XCOM2/WOTC/XComGame/Mods (built mod) when they are deleted from the project
* Most features are configurable!

# Getting started
Foreword: the build system was designed to be flexible in how you want to set it up. This section describes
the most common/basic setup that should work for 95% of mods out there. If you want to customize it, read the next section

## Getting the files
First, create a `.scripts` folder in the root of your mod project (next to the `.XCOM_sln` file) - from now on referred
to as `[modRoot]`. The next step depends on whether you are using git or not. Git is preferable but the build system
will work just fine without it.

### Your mod uses git
Open a command line prompt (cmd or powershell, does not matter) in the `[modRoot]`. Ensure that
your working tree is clean and run the following command:

```
git subtree add --prefix .scripts/X2ModBuildCommon https://github.com/X2CommunityCore/X2ModBuildCommon main --squash
```

Note that you also need to add `BuildCache/` to your `.gitignore`

### Your mod does not use git
Download the source code of this repository from GitHub. Unzip it and place so that `build_commom.ps1` resides at
`[modRoot]\.scripts\X2ModBuildCommon\build_common.ps1`.

## Setting up the build entrypoint
Create `[modRoot]\.scripts\build.ps1` with the following content:

```ps1
Param(
    [string] $srcDirectory, # the path that contains your mod's .XCOM_sln
    [string] $sdkPath, # the path to your SDK installation ending in "XCOM 2 War of the Chosen SDK"
    [string] $gamePath, # the path to your XCOM 2 installation ending in "XCOM2-WaroftheChosen"
    [string] $config # build configuration
)

$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
$common = Join-Path -Path $ScriptDirectory "X2ModBuildCommon\build_common.ps1"
Write-Host "Sourcing $common"
. ($common)

$builder = [BuildProject]::new("YourProjectName", $srcDirectory, $sdkPath, $gamePath)

switch ($config)
{
    "debug" {
        $builder.EnableDebug()
    }
    "default" {
        # Nothing special
    }
    "" { ThrowFailure "Missing build configuration" }
    default { ThrowFailure "Unknown build configuration $config" }
}

$builder.InvokeBuild()
```

Replace `YourProjectName` with the internal mod name (e.g. the name of your `.XCOM_sln` file without the extension)

## IDE integration
At this point your mod is actually ready for building but invoking the powershell script with all the arguments each time manually
is not convinient. Instead, we would like it to be invoked automatically when we press the build button in our IDE

### ModBuddy
Close Modbuddy (or at least the solution) if you have it open. Open your `.x2proj` (in something like notepad++) and find the follwing line:

```xml
<Import Project="$(MSBuildLocalExtensionPath)\XCOM2.targets" />
```

Replace it with following:

```xml
  <PropertyGroup>
    <SolutionRoot>$(MSBuildProjectDirectory)\..\</SolutionRoot>
    <ScriptsDir>$(SolutionRoot).scripts\</ScriptsDir>
    <BuildCommonRoot>$(ScriptsDir)X2ModBuildCommon\</BuildCommonRoot>
  </PropertyGroup>
  <Import Project="$(BuildCommonRoot)XCOM2.targets" />
```

### VSCode
TODO: to be filled by someone who uses it on daily basis. For now you check [this](https://github.com/WOTCStrategyOverhaul/CovertInfiltration/blob/9ef28ef1bb79bc7bad7e391fb79caf15b2429161/.vscode/tasks.json) and [this](https://github.com/X2CommunityCore/X2WOTCCommunityHighlander/blob/1304cb8bae4ce403a2ee12db4805a6776f1c32af/.vscode/tasks.json) for inspiration

## Ready!
You can now successfully build your mod from your IDE using X2ModBuildCommon. Keep reading on to find about what you can configure

# Configuration options
TODO
