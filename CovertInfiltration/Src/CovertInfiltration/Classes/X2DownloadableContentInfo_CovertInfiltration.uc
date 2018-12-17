//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class is used for various hooks and to add commands to game's
//           debug console
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_CovertInfiltration extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
	PatchResistanceRing();
}

static protected function PatchResistanceRing()
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate RingTemplate;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RingTemplate = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('ResistanceRing'));

	if (RingTemplate == none)
	{
		`REDSCREEN("CI: Failed to find resistance ring template");
		return;
	}

	RingTemplate.NeedsAttentionFn = ResistanceRingNeedsAttention;
}

static protected function bool ResistanceRingNeedsAttention(StateObjectReference FacilityRef)
{	
	return false;
}

/// /////// ///
/// HELPERS ///
/// /////// ///

exec function GetRingModifier()
{
	local TDialogueBoxData DialogData;
	DialogData.eType = eDialog_Normal;
	DialogData.strTitle = "Resistance Ring Info:";
	DialogData.strText = "Modifier:" @ class'UIUtilities_Strategy'.static.GetResistanceHQ().CovertActionDurationModifier;
	`HQPRES.UIRaiseDialog(DialogData);
}