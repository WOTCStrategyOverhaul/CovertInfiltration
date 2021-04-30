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

try {
    $builder = [BuildProject]::new("CovertInfiltration", $srcDirectory, $sdkPath, $gamePath)

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

    # TODO: This dumps the companion package into the SDK's Src
    $builder.IncludeSrc("$srcDirectory\X2WOTCCommunityHighlander\X2WOTCCommunityHighlander\Src")
    $builder.IncludeSrc("$srcDirectory\X2WOTCCommunityHighlander\Components\DLC2CommunityHighlander\DLC2CommunityHighlander\Src")

    $builder.IncludeSrc("$srcDirectory\SquadSelectAnyTime\SquadSelectAtAnyTime\Src")
    $builder.AddToClean("SquadSelectAtAnyTime")
    
    $builder.SetContentOptionsJsonPath("$srcDirectory/ContentOptions.json")

    $builder.AddPreMakeHook({
        Write-Host "Updating version and commit..."
        & "$srcDirectory\X2WOTCCommunityHighlander\.scripts\update_version.ps1" -ps "$srcDirectory\X2WOTCCommunityHighlander\VERSION.ps1" -srcDirectory "$sdkPath\Development\Src\" -use_commit

        Write-Host "Updated."
    })

    $builder.InvokeBuild()
   
    # we made it!
    SuccessMessage "*** SUCCESS! ***" "CovertInfiltration"
} catch {
    FailureMessage $_
    exit
}
