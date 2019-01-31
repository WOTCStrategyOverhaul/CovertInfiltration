Param(
    [string]$sdkPath # the path to your XCOM 2 SDK installation ending in "SDK"
)

& "$sdkPath/Binaries/Win64/XComGame.exe" editor -noscriptcompile -nogadwarning