//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: Template for a chain of X2ActivityTemplates. Defines the overall behaviour
//           of the chain, such as what region it takes place it, etc
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2ActivityChainTemplate extends X2StrategyElementTemplate;

// For overview UI
var localized string strTitle;
var localized string strDescription;

// For geoscape covert ops UI
var localized string strObjective;

// Names of X2ActivityTemplates that act as stages for this chain
var array<ChainStage> Stages;

var bool SpawnInDeck; // If true, spawned automatically using the deck system
var int NumInDeck; // The larger the number, the more common this chain is

var bool bAllowComplications; // If true, complications can be attached to this chain type

var array<name> ChainRewards; // The chain-wide rewards that will be granted when the activity with Reward_ChainProxy is finished, DO NOT put more proxy rewards than there are chain rewards!

delegate bool DeckReq(XComGameState NewGameState); // Conditions that must be met for the chain to be added to the deck

// For overview UI
delegate string GetOverviewDescription (XComGameState_ActivityChain ChainState);
delegate string GetNarrativeObjective (XComGameState_ActivityChain ChainState);

delegate SetupChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called before stages' callbacks
delegate CleanupChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called after stages' callbacks

delegate RemoveChain(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called before stages' callbacks
delegate RemoveChainLate(XComGameState NewGameState, XComGameState_ActivityChain ChainState); // Called after stages' callbacks

delegate PostStageSetup(XComGameState NewGameState, XComGameState_Activity ActivityState);

delegate ChooseRegions(XComGameState_ActivityChain ChainState, out StateObjectReference PrimaryRegionRef, out StateObjectReference SecondaryRegionRef);
delegate StateObjectReference ChooseFaction(XComGameState_ActivityChain ChainState, XComGameState NewGameState);

// Called when the chain is deemed relevant to the tactical history and enlisted/copied over
// together with all the related states (activities and complications).
// Use/set this delegate when additional states need to be enlisted into tactical.
// Note: the chain/activity/complications states are already copied over when this is called
// Note: the ChainState is already modified (tactical) one
delegate OnEnlistStateIntoTactical(XComGameState StartGameState, XComGameState_ActivityChain ChainState);

delegate OnActivityGeneratedReward(XComGameState NewGameState, XComGameState_Activity ActivityState, XComGameState_Reward RewardState);

function XComGameState_ActivityChain CreateInstanceFromTemplate (XComGameState NewGameState, optional array<StateObjectReference> ChainObjectRefs)
{
	local XComGameState_ActivityChain ActivityState;

	ActivityState = XComGameState_ActivityChain(NewGameState.CreateNewStateObject(class'XComGameState_ActivityChain', self));
	ActivityState.ChainObjectRefs = ChainObjectRefs;
	ActivityState.SetupChain(NewGameState);

	return ActivityState;
}

function bool ValidateTemplate (out string strError)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2ActivityTemplate ActivityTemplate;
	local X2DataTemplate DataTemplate;
	local ChainStage Stage;
	local bool bFoundTag;
	local int i;

	if (Stages.Length == 0)
	{
		strError = "chain has no stages";
		return false;
	}

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	foreach Stages(Stage, i)
	{
		if (Stage.PresetActivity != '')
		{
			ActivityTemplate = X2ActivityTemplate(TemplateManager.FindStrategyElementTemplate(Stage.PresetActivity));

			if (ActivityTemplate == none)
			{
				strError = "preset template for stage" @ i @ "not found";
				return false;
			}
		}
		else
		{
			if (Stage.ActivityTags.Length == 0 || !class'X2Helper_Infiltration'.static.ValidateActivityType(Stage.ActivityType))
			{
				strError = "stage" @ i @ "has no tags or no type";
				return false;
			}
			
			bFoundTag = false;

			foreach TemplateManager.IterateTemplates(DataTemplate)
			{
				ActivityTemplate = X2ActivityTemplate(DataTemplate);

				if (ActivityTemplate != none)
				{
					if (Stage.ActivityTags.Find(ActivityTemplate.ActivityTag) > INDEX_NONE)
					{
						bFoundTag = true;
						break;
					}
				}
			}

			if (!bFoundTag)
			{
				strError = "stage" @ i @ "holds no valid tags";
				return false;
			}
		}
	}

	return true;
}

////////////////
/// Defaults ///
////////////////

static function bool AlwaysAvailable(XComGameState NewGameState)
{
	return true;
}

static function string DefaultGetOverviewDescription (XComGameState_ActivityChain ChainState)
{
	return ChainState.GetMyTemplate().strDescription;
}

static function string DefaultGetNarrativeObjective (XComGameState_ActivityChain ChainState)
{
	return ChainState.GetMyTemplate().strObjective;
}

defaultproperties
{
	DeckReq = AlwaysAvailable
	GetOverviewDescription = DefaultGetOverviewDescription
	GetNarrativeObjective = DefaultGetNarrativeObjective
	bAllowComplications = true;
}