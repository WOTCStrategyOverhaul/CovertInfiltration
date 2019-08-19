//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Template for an instant mission (no infiltration) as an activity
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ActivityTemplate_Assault extends X2ActivityTemplate_Mission config(Infiltration);

// Expiry in hours
var config bool bExpires;
var config int ExpirationBaseTime;
var config int ExpirationVariance;

static function DefaultAssaultSetup (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	CreateMission(NewGameState, ActivityState);
	QueueCouncilAlert(NewGameState, ActivityState);
}

static function DefaultOnExpire (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	ActivityState = XComGameState_Activity(NewGameState.ModifyStateObject(class'XComGameState_Activity', ActivityState.ObjectID));
	ActivityState.MarkExpired(NewGameState);
}

static function array<name> DefaultGetSitreps (XComGameState_MissionSite MissionState, XComGameState_Activity ActivityState)
{
	return class'X2Helper_Infiltration'.static.GetSitrepsForAssaultMission(MissionState);
}

static function CreateMission (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityTemplate_Assault ActivityTemplate;
	local XComGameState_MissionSite MissionState;
	local X2MissionSourceTemplate MissionSource;
	local XComGameState_WorldRegion Region;

	ActivityTemplate = X2ActivityTemplate_Assault(ActivityState.GetMyTemplate());
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MissionSource = X2MissionSourceTemplate(TemplateManager.FindStrategyElementTemplate(MISSION_SOURCE_NAME));
	Region = ActivityState.GetActivityChain().GetPrimaryRegion();

	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));
	ActivityState.PrimaryObjectRef = MissionState.GetReference();
	
	if (ActivityTemplate.PreMissionSetup != none)
	{
		ActivityTemplate.PreMissionSetup(NewGameState, ActivityState);
	}

	MissionState.BuildMission(
		MissionSource, Region.GetRandom2DLocationInRegion(), Region.GetReference(), InitRewardsStates(NewGameState, ActivityState), true /*bAvailable*/, 
		ActivityTemplate.bExpires /* bExpiring */, ActivityTemplate.RollExpiry() /* iHours */, -1 /* iSeconds */,
		/* bUseSpecifiedLevelSeed */, /* LevelSeedOverride */, false /* bSetMissionData */
	);

	class'X2Helper_Infiltration'.static.InitalizeGeneratedMissionFromActivity(ActivityState);
	class'UIUtilities_Strategy'.static.GetAlienHQ().AddChosenTacticalTagsToMission(MissionState);
	SelectSitrepsAndPlot(MissionState);
}

function int RollExpiry ()
{
	local int Variance;
	local bool bNegVariance;

	Variance = `SYNC_RAND(ExpirationVariance);

	// roll chance for negative variance
	bNegVariance = `SYNC_RAND(2) < 1;
	if (bNegVariance) Variance *= -1;

	return ExpirationBaseTime + Variance;
}

static function array<XComGameState_Reward> InitRewardsStates (XComGameState NewGameState, XComGameState_Activity ActivityState, optional bool SubstituteNone = true)
{
	local array<XComGameState_Reward> RewardStates;
	local array<StateObjectReference> RewardRefs;
	local X2ActivityTemplate_Assault Template;
	local StateObjectReference RewardRef;
	local XComGameStateHistory History;

	Template = X2ActivityTemplate_Assault(ActivityState.GetMyTemplate());
	History = `XCOMHISTORY;

	RewardRefs = Template.InitializeMissionRewards(NewGameState, ActivityState);

	foreach RewardRefs(RewardRef)
	{
		RewardStates.AddItem(XComGameState_Reward(History.GetGameStateForObjectID(RewardRef.ObjectID)));
	}

	if (RewardRefs.Length == 0 && SubstituteNone)
	{
		RewardRefs.AddItem(class'X2Helper_Infiltration'.static.CreateRewardNone(NewGameState));
	}

	return RewardStates;
}

static function SelectSitrepsAndPlot (XComGameState_MissionSite MissionState)
{
	local XComHeadquartersCheatManager CheatManager;
	local XComParcelManager ParcelMgr;
	local string Biome;
	local X2MissionSourceTemplate MissionSource;
	local array<name> SourceSitReps;
	local name SitRepName;
	local PlotTypeDefinition PlotTypeDef;
	local PlotDefinition SelectedDef;
	// Variables for Issue #157
	local array<X2DownloadableContentInfo> DLCInfos; 
	local int i; 
	// Variables for Issue #157

	ParcelMgr = `PARCELMGR;

	// Add Forced SitReps from Cheats
	CheatManager = XComHeadquartersCheatManager(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().CheatManager);
	if(CheatManager != none && CheatManager.ForceSitRepTemplate != '')
	{
		MissionState.GeneratedMission.SitReps.AddItem(CheatManager.ForceSitRepTemplate);
		CheatManager.ForceSitRepTemplate = '';
	}
	else if(!MissionState.bForceNoSitRep)
	{
		// No cheats, add SitReps from the Mission Source
		MissionSource = MissionState.GetMissionSource();

		if (MissionSource.GetSitrepsFn != none)
		{
			SourceSitReps = MissionSource.GetSitrepsFn(MissionState);

			foreach SourceSitReps(SitRepName)
			{
				if (MissionState.GeneratedMission.SitReps.Find(SitRepName) == INDEX_NONE)
				{
					MissionState.GeneratedMission.SitReps.AddItem(SitRepName);
				}
			}
		}
	}

	// find a plot that supports the biome and the mission
	SelectBiomeAndPlotDefinition(MissionState, Biome, SelectedDef, MissionState.GeneratedMission.SitReps);

	// do a weighted selection of our plot
	MissionState.GeneratedMission.Plot = SelectedDef;

	// Add SitReps forced by Plot Type
	PlotTypeDef = ParcelMgr.GetPlotTypeDefinition(MissionState.GeneratedMission.Plot.strType);

	foreach PlotTypeDef.ForcedSitReps(SitRepName)
	{
		if (MissionState.GeneratedMission.SitReps.Find(SitRepName) == INDEX_NONE && 
			(SitRepName != 'TheLost' || MissionState.GeneratedMission.SitReps.Find('TheHorde') == INDEX_NONE))
		{
			MissionState.GeneratedMission.SitReps.AddItem(SitRepName);
		}
	}

	// Start Issue #157
	DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);
	for (i = 0; i < DLCInfos.Length; ++i)
	{
		DLCInfos[i].PostSitRepCreation(MissionState.GeneratedMission, MissionState);
	}
	// End Issue #157

	// Now that all sitreps have been chosen, add any sitrep tactical tags to the mission list
	MissionState.UpdateSitrepTags();

	// the plot we find should either have no defined biomes, or the requested biome type
	//`assert( (GeneratedMission.Plot.ValidBiomes.Length == 0) || (GeneratedMission.Plot.ValidBiomes.Find( Biome ) != -1) );
	if (MissionState.GeneratedMission.Plot.ValidBiomes.Length > 0)
	{
		MissionState.GeneratedMission.Biome = ParcelMgr.GetBiomeDefinition(Biome);
	}
}

////////////////////////////
/// Private from XCGS_MS ///
////////////////////////////

static function SelectBiomeAndPlotDefinition(XComGameState_MissionSite MissionState, out string Biome, out PlotDefinition SelectedDef, optional array<name> SitRepNames)
{
	local MissionDefinition MissionDef;
	local XComParcelManager ParcelMgr;
	local string PrevBiome;
	local array<string> ExcludeBiomes;

	MissionDef = MissionState.GeneratedMission.Mission;
	ParcelMgr = `PARCELMGR;
	ExcludeBiomes.Length = 0;
	
	Biome = SelectBiome(MissionState, ExcludeBiomes);
	PrevBiome = Biome;

	while(!SelectPlotDefinition(MissionDef, Biome, SelectedDef, ExcludeBiomes, SitRepNames))
	{
		Biome = SelectBiome(MissionState, ExcludeBiomes);

		if(Biome == PrevBiome)
		{
			`Redscreen("Could not find valid plot for mission!\n" $ " MissionType: " $ MissionDef.MissionName);
			SelectedDef = ParcelMgr.arrPlots[0];
			return;
		}
	}
}

static function string SelectBiome(XComGameState_MissionSite MissionState, out array<string> ExcludeBiomes)
{
	local MissionDefinition MissionDef;
	local string Biome;
	local int TotalValue, RollValue, CurrentValue, idx, BiomeIndex;
	local array<BiomeChance> BiomeChances;
	local string TestBiome;

	MissionDef = MissionState.GeneratedMission.Mission;
	
	if(MissionDef.ForcedBiome != "")
	{
		return MissionDef.ForcedBiome;
	}

	// Grab Biome from location
	Biome = class'X2StrategyGameRulesetDataStructures'.static.GetBiome(MissionState.Get2DLocation());

	if(ExcludeBiomes.Find(Biome) != INDEX_NONE)
	{
		Biome = "";
	}

	// Grab "extra" biomes which we could potentially swap too (used for Xenoform)
	BiomeChances = class'X2StrategyGameRulesetDataStructures'.default.m_arrBiomeChances;

	// Not all plots support these "extra" biomes, check if excluded
	foreach ExcludeBiomes(TestBiome)
	{
		BiomeIndex = BiomeChances.Find('BiomeName', TestBiome);

		if(BiomeIndex != INDEX_NONE)
		{
			BiomeChances.Remove(BiomeIndex, 1);
		}
	}

	// If no "extra" biomes just return the world map biome
	if(BiomeChances.Length == 0)
	{
		return Biome;
	}

	// Calculate total value of roll to see if we want to swap to another biome
	TotalValue = 0;

	for(idx = 0; idx < BiomeChances.Length; idx++)
	{
		TotalValue += BiomeChances[idx].Chance;
	}

	// Chance to use location biome is remainder of 100
	if(TotalValue < 100)
	{
		TotalValue = 100;
	}

	// Do the roll
	RollValue = `SYNC_RAND_STATIC(TotalValue);
	CurrentValue = 0;

	for(idx = 0; idx < BiomeChances.Length; idx++)
	{
		CurrentValue += BiomeChances[idx].Chance;

		if(RollValue < CurrentValue)
		{
			Biome = BiomeChances[idx].BiomeName;
			break;
		}
	}

	return Biome;
}

static function bool SelectPlotDefinition(MissionDefinition MissionDef, string Biome, out PlotDefinition SelectedDef, out array<string> ExcludeBiomes, optional array<name> SitRepNames)
{
	local XComParcelManager ParcelMgr;
	local array<PlotDefinition> ValidPlots;
	local X2SitRepTemplateManager SitRepMgr;
	local name SitRepName;
	local X2SitRepTemplate SitRep;

	ParcelMgr = `PARCELMGR;
	ParcelMgr.GetValidPlotsForMission(ValidPlots, MissionDef, Biome);
	SitRepMgr = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();

	// pull the first one that isn't excluded from strategy, they are already in order by weight
	foreach ValidPlots(SelectedDef)
	{
		foreach SitRepNames(SitRepName)
		{
			SitRep = SitRepMgr.FindSitRepTemplate(SitRepName);

			if(SitRep != none && SitRep.ExcludePlotTypes.Find(SelectedDef.strType) != INDEX_NONE)
			{
				continue;
			}
		}

		if(!SelectedDef.ExcludeFromStrategy)
		{
			return true;
		}
	}

	ExcludeBiomes.AddItem(Biome);
	return false;
}

/////////////
/// Popup ///
/////////////

static function QueueCouncilAlert (XComGameState NewGameState, XComGameState_Activity ActivityState)
{
	local XComHQPresentationLayer HQPres;
	local DynamicPropertySet PropertySet;

	HQPres = `HQPRES;

	HQPres.BuildUIAlert(PropertySet, 'eAlert_CouncilMission', CouncilAlertCB, 'OnCouncilPopup', "Geoscape_NewResistOpsMissions", false);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicBoolProperty(PropertySet, 'bInstantInterp', false);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicIntProperty(PropertySet, 'ActivityObjectID', ActivityState.ObjectID);
	HQPres.QueueDynamicPopup(PropertySet, NewGameState);
}

simulated function CouncilAlertCB(Name eAction, out DynamicPropertySet AlertData, optional bool bInstant = false)
{
	local X2ActivityTemplate_Assault ActivityTemplate;
	local XComGameState_Activity ActivityState;
	local int ActivityObjectID;

	ActivityObjectID = class'X2StrategyGameRulesetDataStructures'.static.GetDynamicIntProperty(AlertData, 'ActivityObjectID');
	ActivityState = XComGameState_Activity(`XCOMHISTORY.GetGameStateForObjectID(ActivityObjectID));
	ActivityTemplate = X2ActivityTemplate_Assault(ActivityState.GetMyTemplate());

	if (eAction == 'eUIAction_Accept')
	{
		ActivityTemplate.OnStrategyMapSelected(ActivityState);

		if (`GAME.GetGeoscape().IsScanning())
		{
			`HQPRES.StrategyMap2D.ToggleScan();
		}
	}
}

static function string DefaultGetOverviewDescription (XComGameState_Activity ActivityState)
{
	local XComGameState_MissionSite MissionState;

	MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(ActivityState.PrimaryObjectRef.ObjectID));

	return MissionState.GetMissionObjectiveText();
}

defaultproperties
{
	SetupStage = DefaultAssaultSetup
	GetSitreps = DefaultGetSitreps
	GetOverviewDescription = DefaultGetOverviewDescription
}