Param(
    [string]$mod, # your mod's name - this shouldn't have spaces or special characters, and it's usually the name of the first directory inside your mod's source dir
    [string]$srcDirectory, # the path that contains your mod's .XCOM_sln
    [string]$sdkPath, # the path to your SDK installation ending in "XCOM 2 War of the Chosen SDK"
    [string]$gamePath, # the path to your XCOM 2 installation ending in "XCOM 2"
    [string[]]$includes, # any additional source files to include in the build
    [string[]]$clean, # mods to remove from SDK/XComGame/Mods because they throw the compiler out of whack
    [string]$cookOptionsPs, # path to the script containing the cooking options
    [switch]$debug
)

$ErrorActionPreference = "Stop"
$selfScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

function WriteModMetadata([string]$mod, [string]$sdkPath, [int]$publishedId, [string]$title, [string]$description) {
    Set-Content "$sdkPath/XComGame/Mods/$mod/$mod.XComMod" "[mod]`npublishedFileId=$publishedId`nTitle=$title`nDescription=$description`nRequiresXPACK=true"
}


function StageDirectory ([string]$directoryName, [string]$srcDirectory, [string]$targetDirectory) {
    Write-Host "Staging mod $directoryName from source ($srcDirectory/$directoryName) to staging ($targetDirectory/$directoryName)..."

    if (Test-Path "$srcDirectory/$directoryName") {
        Copy-Item "$srcDirectory/$directoryName" "$targetDirectory/$directoryName" -Recurse -WarningAction SilentlyContinue
        Write-Host "Staged."
    }
    else {
        Write-Host "Mod doesn't have any $directoryName."
    }
}

# Helper for invoking the make cmdlet. Captures stdout/stderr and rewrites error and warning lines to fix up the
# source paths. Since make operates on a copy of the sources copied to the SDK folder, diagnostics print the paths
# to the copies. If you try to jump to these files (e.g. by tying this output to the build commands in your editor)
# you'll be editting the copies, which will then be overwritten the next time you build with the sources in your mod folder
# that haven't been changed.
function Invoke-Make([string] $makeCmd, [string] $makeFlags, [string] $sdkPath, [string] $modSrcRoot) {
    # Create a ProcessStartInfo object to hold the details of the make command, its arguments, and set up
    # stdout/stderr redirection.
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $makeCmd
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $makeFlags

    # Create an object to hold the paths we want to rewrite: the path to the SDK 'Development' folder
    # and the 'modSrcRoot' (the directory that holds the .x2proj file). This is needed because the output
    # is read in an action block that is a separate scope and has no access to local vars/parameters of this
    # function.
    $developmentDirectory = Join-Path -Path $sdkPath 'Development'
    $messageData = New-Object psobject -property @{
        developmentDirectory = $developmentDirectory
        modSrcRoot = $modSrcRoot
    }

    # We need another object for the Exited event to set a flag we can monitor from this function.
    $exitData = New-Object psobject -property @{ exited = $false }

    # An action for handling data written to stdout. The make cmdlet writes all warning and error info to
    # stdout, so we look for it here.
    $outAction = {
        $outTxt = $Event.SourceEventArgs.Data
        # Match warning/error lines
        $messagePattern = "^(.*)[\\/](.*)\(([0-9]*)\) : (.*)$"
        if (($outTxt -Match "Error|Warning") -And ($outTxt -Match $messagePattern)) {
            # And just do a regex replace on the sdk Development directory with the mod src directory.
            # The pattern needs escaping to avoid backslashes in the path being interpreted as regex escapes, etc.
            $pattern = [regex]::Escape($event.MessageData.developmentDirectory)
            # n.b. -Replace is case insensitive
            $replacementTxt = $outtxt -Replace $pattern, $event.MessageData.modSrcRoot
            $outTxt = "$replacementTxt"
        }

        $summPattern = "^(Success|Failure) - ([0-9]+) error\(s\), ([0-9]+) warning\(s\) \(([0-9]+) Unique Errors, ([0-9]+) Unique Warnings\)"
        if (-Not ($outTxt -Match "Warning/Error Summary") -And $outTxt -Match "Warning|Error") {
            if ($outTxt -Match $summPattern) {
                $numErr = $outTxt -Replace $summPattern, '$2'
                $numWarn = $outTxt -Replace $summPattern, '$3'
                if (([int]$numErr) -gt 0) {
                    $clr = "Red"
                } elseif (([int]$numWarn) -gt 0) {
                    $clr = "Yellow"
                } else {
                    $clr = "Green"
                }
            } else {
                if ($outTxt -Match "Error") {
                    $clr = "Red"
                } else {
                    $clr = "Yellow"
                }
            }
            Write-Host $outTxt -ForegroundColor $clr
        } else {
            Write-Host $outTxt
        }
    }

    # An action for handling data written to stderr. The make cmdlet doesn't seem to write anything here,
    # or at least not diagnostics, so we can just pass it through.
    $errAction = {
        $errTxt = $Event.SourceEventArgs.Data
        Write-Host $errTxt
    }

    # Set the exited flag on our exit object on process exit.
    $exitAction = {
        $event.MessageData.exited = $true
    }

    # Create the process and register for the various events we care about.
    $process = New-Object System.Diagnostics.Process
    Register-ObjectEvent -InputObject $process -EventName OutputDataReceived -Action $outAction -MessageData $messageData | Out-Null
    Register-ObjectEvent -InputObject $process -EventName ErrorDataReceived -Action $errAction | Out-Null
    Register-ObjectEvent -InputObject $process -EventName Exited -Action $exitAction -MessageData $exitData | Out-Null
    $process.StartInfo = $pinfo

    # All systems go!
    $process.Start() | Out-Null
    $process.BeginOutputReadLine()
    $process.BeginErrorReadLine()

    # Wait for the process to exit. This is horrible, but using $process.WaitForExit() blocks
    # the powershell thread so we get no output from make echoed to the screen until the process finishes.
    # By polling we get regular output as it goes.
    while (!$exitData.exited) {
        Start-Sleep -m 50
    }

    # Explicitly set LASTEXITCODE from the process exit code so the rest of the script
    # doesn't need to care if we launched the process in the background or via "&".
    $global:LASTEXITCODE = $process.ExitCode
}

# This doesn't work yet, but it might at some point
Clear-Host

if (![string]::IsNullOrEmpty($cookOptionsPs))
{
    Write-Host "Cooking options are specified in script params"
} else {
    Write-Host "Cooking options are not specified in script params, trying to detect"

    $testPath = [io.path]::Combine($selfScriptPath, "..", "cooking_options.ps1")

    if (Test-Path $testPath)
    {
        $cookOptionsPs = $testPath
        Write-Host "Auto detected cooking_options.ps1"
    } else {
        Write-Host "Failed to auto detect cooking_options.ps1"
    }
}

if (![string]::IsNullOrEmpty($cookOptionsPs) -And (Test-Path $cookOptionsPs))
{
	. ($cookOptionsPs)
} else {
	$enableAssetCooking = $false
    [string[]]$missingUncooked = @()
	Write-Host "Disabling asset cooking as no options file specified"
}

# list of all native script packages
[System.String[]]$basegamescriptpackages = "XComGame", "Core", "Engine", "GFxUI", "AkAudio", "GameFramework", "UnrealEd", "GFxUIEditor", "IpDrv", "OnlineSubsystemPC", "OnlineSubsystemLive", "OnlineSubsystemSteamworks", "OnlineSubsystemPSN"

# alias params for clarity in the script (we don't want the person invoking this script to have to type the name -modNameCanonical)
$modNameCanonical = $mod
# we're going to ask that people specify the folder that has their .XCOM_sln in it as the -srcDirectory argument, but a lot of the time all we care about is
# the folder below that that contains Config, Localization, Src, etc...
$modSrcRoot = "$srcDirectory\$modNameCanonical"

# clean
$stagingPath = "{0}\XComGame\Mods\{1}" -f $sdkPath, $modNameCanonical
Write-Host "Cleaning mod project at $stagingPath...";
if (Test-Path $stagingPath) {
    Remove-Item $stagingPath -Force -Recurse -WarningAction SilentlyContinue;
}
Write-Host "Cleaned."

# copy source to staging
#StageDirectory "Config" $modSrcRoot $stagingPath
#StageDirectory "Content" $modSrcRoot $stagingPath
#StageDirectory "Localization" $modSrcRoot $stagingPath
#StageDirectory "Src" $modSrcRoot $stagingPath
#Copy-Item "$modSrcRoot" "$sdkPath\XComGame\Mods" -Force -Recurse -WarningAction SilentlyContinue

Robocopy.exe "$modSrcRoot" "$sdkPath\XComGame\Mods\$modNameCanonical" *.* /S /E /DCOPY:DA /COPY:DAT /PURGE /MIR /NP /R:1000000 /W:30
if (Test-Path "$stagingPath\$modNameCanonical.x2proj") {
    Remove-Item "$stagingPath\$modNameCanonical.x2proj"
}

Write-Host "Converting the localization file enconding";
Get-ChildItem "$stagingPath\Localization" -Recurse -File | 
Foreach-Object {
	$content = Get-Content $_.FullName -Encoding UTF8
	$content | Out-File $_.FullName -Encoding Unicode
}

New-Item "$stagingPath/Script" -ItemType Directory

# read mod metadata from the x2proj file
Write-Host "Reading mod metadata from $modSrcRoot\$modNameCanonical.x2proj..."
[xml]$x2projXml = Get-Content -Path "$modSrcRoot\$modNameCanonical.x2proj"
$modProperties = $x2projXml.Project.PropertyGroup[0]
$modPublishedId = $modProperties.SteamPublishID
$modTitle = $modProperties.Name
$modDescription = $modProperties.Description
Write-Host "Read."

# write mod metadata - used by Firaxis' "make" tooling
Write-Host "Writing mod metadata..."
WriteModMetadata -mod $modNameCanonical -sdkPath $sdkPath -publishedId $modPublishedId -title $modTitle -description $modDescription
Write-Host "Written."

# mirror the SDK's SrcOrig to its Src
Write-Host "Mirroring SrcOrig to Src..."
Robocopy.exe "$sdkPath\Development\SrcOrig" "$sdkPath\Development\Src" *.uc *.uci /S /E /DCOPY:DA /COPY:DAT /PURGE /MIR /NP /R:1000000 /W:30 2>&1>$null
Write-Host "Mirrored."

# mirror Highlander's source files to Src so that the mod can use them
Write-Host "Copying Highlander files to Src..."
Robocopy.exe "$srcDirectory\X2WOTCCommunityHighlander\Components\DLC2CommunityHighlander\DLC2CommunityHighlander\Src" "$sdkPath\Development\Src" *.uc *.uci /S /E /DCOPY:DA /COPY:DAT /NP /R:1000000 /W:30 2>&1>$null
Robocopy.exe "$srcDirectory\X2WOTCCommunityHighlander\X2WOTCCommunityHighlander\Src" "$sdkPath\Development\Src" *.uc *.uci /XD X2WOTCCommunityHighlander /S /E /DCOPY:DA /COPY:DAT /NP /R:1000000 /W:30 2>&1>$null
Write-Host "Copied."

Write-Host "Updating CHL version and commit..."
& "$srcDirectory\X2WOTCCommunityHighlander\.scripts\update_version.ps1" -ps "$srcDirectory\X2WOTCCommunityHighlander\VERSION.ps1" -srcDirectory "$sdkPath\Development\Src\" -use_commit

for ($i=0; $i -lt $includes.length; $i++)
{
    $includeDir = $includes[$i]
    $folderName = Split-Path -Path "$includeDir" -Leaf
    Write-Host "Including $includeDir"
    Robocopy.exe "$srcDirectory\$includeDir" "$sdkPath\Development\Src\$folderName" *.uc *.uci /S /E /DCOPY:DA /COPY:DAT /NP /R:1000000 /W:30 2>&1>$null
    Write-Host "Copied."
}

for ($i=0; $i -lt $clean.length; $i++)
{
    $cleanDir = $clean[$i]
    if (Test-Path "$sdkPath/XComGame/Mods/$cleanDir") {
        Write-Host "Cleaning $cleanDir"
        Remove-Item -Recurse -Force "$sdkPath/XComGame/Mods/$cleanDir"
        Write-Host "Cleaned."
    }
}

# copying the mod's scripts to the script staging location
Write-Host "Copying the mod's scripts to Src..."
Copy-Item "$stagingPath\Src\*" "$sdkPath\Development\Src\" -Force -Recurse -WarningAction SilentlyContinue
Write-Host "Copied."

# build package lists we'll need later and delete as appropriate
# all packages we are about to compile
[System.String[]]$allpackages = Get-ChildItem "$sdkPath/Development/Src" -Directory
# the mod's packages, only those .u files will be copied to the output
[System.String[]]$thismodpackages = Get-ChildItem "$modSrcRoot/Src" -Directory

# append extra_globals.uci to globals.uci
if (Test-Path "$sdkPath/Development/Src/extra_globals.uci") {
    Get-Content "$sdkPath/Development/Src/extra_globals.uci" | Add-Content "$sdkPath/Development/Src/Core/Globals.uci"
}

if ($forceFullBuild) {
    # if a full build was requested, clean all compiled scripts too
    Write-Host "Full build requested. Cleaning all compiled scripts from $sdkPath/XComGame/Script..."
    Remove-Item "$sdkPath/XComGame/Script/*.u"
    Write-Host "Cleaned."
} else {
    # clean mod's compiled script
    Write-Host "Cleaning existing mod's compiled script from $sdkPath/XComGame/Script..."
    for ($i=0; $i -lt $thismodpackages.length; $i++) {
	    if (Test-Path "$sdkPath/XComGame/Script/$thismodpackages[$i].u") {
            Remove-Item "$sdkPath/XComGame/Script/$thismodpackages[$i].u"
        }
    }
    Write-Host "Cleaned."
}

# build the base game scripts
Write-Host "Compiling base game scripts..."
if ($debug -eq $true)
{
    Invoke-Make "$sdkPath/binaries/Win64/XComGame.com" "make -debug -nopause -unattended" $sdkPath $modSrcRoot
} else {
    Invoke-Make "$sdkPath/binaries/Win64/XComGame.com" "make -nopause -unattended" $sdkPath $modSrcRoot
}
if ($LASTEXITCODE -ne 0)
{
    throw "Failed to compile base game scripts!"
}
Write-Host "Compiled base game scripts."

# build the mod's scripts
Write-Host "Compiling mod scripts..."
if ($debug -eq $true)
{
    Invoke-Make "$sdkPath/binaries/Win64/XComGame.com" "make -debug -nopause -mods $modNameCanonical $stagingPath" $sdkPath $modSrcRoot
} else {
    Invoke-Make "$sdkPath/binaries/Win64/XComGame.com" "make -nopause -mods $modNameCanonical $stagingPath" $sdkPath $modSrcRoot
}
if ($LASTEXITCODE -ne 0)
{
    throw "Failed to compile mod scripts!"
}
Write-Host "Compiled mod scripts."

# copy compiled mod scripts to the staging area
Write-Host "Copying the compiled mod scripts to staging..."
for ($i=0; $i -lt $thismodpackages.length; $i++) {
    $name = $thismodpackages[$i]
    Copy-Item "$sdkPath/XComGame/Script/$name.u" "$stagingPath/Script" -Force -WarningAction SilentlyContinue
    Write-Host "$sdkPath/XComGame/Script/$name.u"
}
Write-Host "Copied compiled script packages."

if ($missingUncooked.Length -gt 0)
{
    Write-Host "Including MissingUncooked"

    $missingUncookedPath = [io.path]::Combine($stagingPath, "Content", "MissingUncooked")
    $sdkContentPath = [io.path]::Combine($sdkPath, "XComGame", "Content")

    if (!(Test-Path $missingUncookedPath))
    {
        New-Item -ItemType "directory" -Path $missingUncookedPath
    }

    foreach ($fileName in $missingUncooked)
    {
        (Get-ChildItem -Path $sdkContentPath -Filter $fileName -Recurse).FullName | Copy-Item -Destination $missingUncookedPath
    }
}

# TODO: Optimize this. One could skip recompiling shader caches if the shader cache is newer than any other content file.
Write-Host "Testing $modSrcRoot/Content"
if(Test-Path "$modSrcRoot/Content")
{
    Write-Host "Exists"
    $contentfiles = Get-ChildItem "$modSrcRoot/Content\*"  -Include *.upk, *.umap -Recurse -File
	$shader_cache_path = "$gamePath/XComGame/Mods/$modNameCanonical/Content/$($modNameCanonical)_ModShaderCache.upk";
	$need_shader_precompile = $false;
	
	# Try to find a reason to precompile the shaders
	if (!(Test-Path -Path $shader_cache_path))
	{
		$need_shader_precompile = $true;
	} 
	elseif ($contentfiles.length -gt 0)
    {
		$shader_cache = Get-Item $shader_cache_path;
		
		for ($i = 0; $i -lt $contentfiles.Length; $i++) 
		{
			$file = $contentfiles[$i];
			
			if ($file.LastWriteTime -gt $shader_cache.LastWriteTime -Or $file.CreationTime -gt $shader_cache.LastWriteTime)
			{
				$need_shader_precompile = $true;
				break;
			}
		}
    }
	
	if ($need_shader_precompile)
	{
		# build the mod's shader cache
        Write-Host "Precompiling Shaders..."
        &"$sdkPath/binaries/Win64/XComGame.com" precompileshaders -nopause platform=pc_sm4 DLC=$modNameCanonical
        if ($LASTEXITCODE -ne 0)
        {
            throw "Failed to compile mod shader cache!"
        }
        Write-Host "Generated Shader Cache."
	}
	else
	{
		Write-Host "No reason to precompile shaders, skipping"
	}
}

# Cook assets if we need to
# TODO: Decide what to do with normal content upks
# For testing, I just deleted everything except for shader cache
if ($enableAssetCooking -eq $true)
{
	Write-Host "Entered asset cooking"
	
	if (!(Test-Path "$modSrcRoot/Content"))
	{
		Write-Host "Nothing to cook"
	} else {
		# Step 0. Basic preparation
		
		$tfcSuffix = "_${modNameCanonical}_"
		$projectCookCacheDir = [io.path]::combine($srcDirectory, 'BuildCache', 'PublishedCookedPCConsole')
		
		$defaultEnginePath = "$sdkPath/XComGame/Config/DefaultEngine.ini"
		$defaultEngineContentOriginal = Get-Content "$sdkPath/XComGame/Config/DefaultEngine.ini" | Out-String
		
		$cookOutputDir = [io.path]::combine($sdkPath, 'XComGame', 'Published', 'CookedPCConsole')
		$sdkModsContentDir = [io.path]::combine($sdkPath, 'XComGame', 'Content', 'Mods')
		
		# First, we need to check that everything is ready for us to do these shenanigans
		# This doesn't use locks, so it can break if multiple builds are running at the same time,
		# so let's hope that mod devs are smart enough to not run simultanoues builds
		
		if ($defaultEngineContentOriginal.Contains("HACKS FOR MOD ASSETS COOKING"))
		{
			throw "Another cook is already in progress (DefaultEngine.ini)"
		}
		
		if (Test-Path "$sdkModsContentDir\*")
		{
			throw "$sdkModsContentDir is not empty"
		}
		
		# Prepare the cook output folder
		$previousCookOutputDirPath = $null
		if (Test-Path $cookOutputDir)
		{
			$previousCookOutputDirName = "Pre_${modNameCanonical}_Cook_CookedPCConsole"
			$previousCookOutputDirPath = [io.path]::combine($sdkPath, 'XComGame', 'Published', $previousCookOutputDirName)
			
			Rename-Item $cookOutputDir $previousCookOutputDirName
		} 

		# Make sure our local cache folder exists
        $firstModCook = $false
		if (!(Test-Path $projectCookCacheDir))
		{
			New-Item -ItemType "directory" -Path $projectCookCacheDir
            $firstModCook = $true
		}
		
		# Redirect all the cook output to our local cache
		# This allows us to not recook everything when switching between projects (e.g. CHL)
		&"$selfScriptPath\junction.exe" -nobanner -accepteula "$cookOutputDir" "$projectCookCacheDir"
		
		# "Inject" our assets into the SDK
		Remove-Item $sdkModsContentDir
		&"$selfScriptPath\junction.exe" -nobanner -accepteula "$sdkModsContentDir" "$modSrcRoot\Content"
		
		# TODO: ini edits
		$defaultEngineContentNew = $defaultEngineContentOriginal
		$defaultEngineContentNew = "$defaultEngineContentNew`n; HACKS FOR MOD ASSETS COOKING - $modNameCanonical"
		# Remove various default always seek free packages
		# This will trump the rest of file content as it's all the way at the bottom
		$defaultEngineContentNew = "$defaultEngineContentNew`n[Engine.ScriptPackages]`n!EngineNativePackages=Empty`n!NetNativePackages=Empty`n!NativePackages=Empty"
		$defaultEngineContentNew = "$defaultEngineContentNew`n[Engine.StartupPackages]`n!Package=Empty"
		$defaultEngineContentNew = "$defaultEngineContentNew`n[Engine.PackagesToAlwaysCook]`n!SeekFreePackage=Empty"

        if ($firstModCook)
        {
            # First do a cook without our assets since some base game assets still get included in the cook, depsite the hacks above

            Write-Host "Running first time mod cook"
            $defaultEngineContentNew | Set-Content $defaultEnginePath -NoNewline;

            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "$sdkPath\binaries\Win64\XComGame.com"
            #$pinfo.RedirectStandardOutput = $true
            $pinfo.UseShellExecute = $false
            $pinfo.Arguments = "CookPackages -platform=pcconsole -skipmaps -modcook -TFCSUFFIX=$tfcSuffix -singlethread -unattended -usermode"
            $pinfo.WorkingDirectory = "$sdkPath/binaries/Win64"
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start() | Out-Null
            $p.WaitForExit()

            # Now delete the polluted TFCs
            Get-ChildItem -Path $projectCookCacheDir -Filter "*$tfcSuffix.tfc" | Remove-Item

            Write-Host "First time cook done, proceeding with normal"
        }

		# Add our standalone seek free packages
		for ($i = 0; $i -lt $packagesToMakeSF.Length; $i++) 
		{
			$package = $packagesToMakeSF[$i];
			$defaultEngineContentNew = "$defaultEngineContentNew`n+SeekFreePackage=$package"
		}
		# Write to file
		$defaultEngineContentNew | Set-Content $defaultEnginePath -NoNewline;
		
		# Invoke cooker
		
		$mapsString = ""
		for ($i = 0; $i -lt $umapsToCook.Length; $i++) 
		{
			$umap = $umapsToCook[$i];
			$mapsString = "$mapsString $umap.umap "
		}
		
		#&"$sdkPath/binaries/Win64/XComGame.com" CookPackages $mapsString -platform=pcconsole -skipmaps -modcook -TFCSUFFIX="$tfcSuffix" -singlethread -unattended
		# Powershell inserts qoutes around $mapsString which breaks UE's parser. So, we call manually
		
		$pinfo = New-Object System.Diagnostics.ProcessStartInfo
		$pinfo.FileName = "$sdkPath\binaries\Win64\XComGame.com"
		#$pinfo.RedirectStandardOutput = $true
		$pinfo.UseShellExecute = $false
		$pinfo.Arguments = "CookPackages $mapsString -platform=pcconsole -skipmaps -modcook -TFCSUFFIX=$tfcSuffix -singlethread -unattended -usermode"
		$pinfo.WorkingDirectory = "$sdkPath/binaries/Win64"
		$p = New-Object System.Diagnostics.Process
		$p.StartInfo = $pinfo
		$p.Start() | Out-Null
		$p.WaitForExit()
		
		# Revert ini
		$defaultEngineContentOriginal | Set-Content $defaultEnginePath -NoNewline;
		
		# Revert junctions
		&"$selfScriptPath\junction.exe" -nobanner -accepteula -d "$cookOutputDir"
		if (![string]::IsNullOrEmpty($previousCookOutputDirPath))
		{
			Rename-Item $previousCookOutputDirPath "CookedPCConsole"
		}
		
		&"$selfScriptPath\junction.exe" -nobanner -accepteula -d "$sdkModsContentDir"
		New-Item -Path $sdkModsContentDir -ItemType Directory
		
		# Prepare the folder for cooked stuff
		$stagingCookedDir = [io.path]::combine($stagingPath, 'CookedPCConsole')
		New-Item -ItemType "directory" -Path $stagingCookedDir
		
		# Copy over the TFC files
		Get-ChildItem -Path $projectCookCacheDir -Filter "*$tfcSuffix.tfc" | Copy-Item -Destination $stagingCookedDir
		
		# Copy over the maps
		for ($i = 0; $i -lt $umapsToCook.Length; $i++) 
		{
			$umap = $umapsToCook[$i];
			Copy-Item "$projectCookCacheDir\$umap.upk" -Destination $stagingCookedDir
		}
		
		# Copy over the SF packages
		for ($i = 0; $i -lt $packagesToMakeSF.Length; $i++) 
		{
			$package = $packagesToMakeSF[$i];
            $dest = [io.path]::Combine($stagingCookedDir, "${package}.upk");
			
			# Mod assets for some reason refuse to load with the _SF suffix
			Copy-Item "$projectCookCacheDir\${package}_SF.upk" -Destination $dest
		}
	}
}

# copy all staged files to the actual game's mods folder
Write-Host "Copying all staging files to production..."
Copy-Item $stagingPath "$gamePath/XComGame/Mods/" -Force -Recurse -WarningAction SilentlyContinue
Write-Host "Copied mod to game directory."

# we made it!
Write-Host "*** SUCCESS! ***"
Write-Host "$modNameCanonical ready to run."