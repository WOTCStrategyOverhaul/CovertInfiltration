//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class is used for various hooks and to add commands to game's
//           debug console
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_CovertInfiltration extends X2DownloadableContentInfo config(GameData);

var config int NORMALARMORINFIL;
var config int HEAVYARMORINFIL;
var config int LIGHTARMORINFIL;

var config int HEAVYWEAPONINFIL;
var config int MIDHEAVYWEAPONINFIL;
var config int MEDIUMWEAPONINFIL;
var config int MIDLIGHTWEAPONINFIL;
var config int LIGHTWEAPONINFIL;

static event OnPostTemplatesCreated()
{
	UpdateItemsWithInfil();
}

static function UpdateItemsWithInfil()
{
	local X2DataTemplate Template;
	local X2ItemTemplateManager TemplateMgr;
	local X2ItemTemplate ItemTemplate;
	local X2ITem_InfiltrationModifier InfilMgr;
	
	TemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	InfilMgr = new class'X2ITem_InfiltrationModifier';

	foreach TemplateMgr.IterateTemplates(Template, none)
	{
		ItemTemplate = X2ItemTemplate(Template);

		if(ItemTemplate != none)
		{
			switch(ItemTemplate.DataName)
			{
			// Armors
			case 'KevlarArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.NORMALARMORINFIL);
			case 'MediumPlatedArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.NORMALARMORINFIL);
			case 'LightPlatedArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTARMORINFIL);
			case 'HeavyPlatedArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.HEAVYARMORINFIL);
			case 'MediumPoweredArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.NORMALARMORINFIL);
			case 'LightPoweredArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTARMORINFIL);
			case 'HeavyPoweredArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.HEAVYARMORINFIL);
			case 'ReaperArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTARMORINFIL);
			case 'PlatedReaperArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTARMORINFIL);
			case 'PoweredReaperArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTARMORINFIL);
			case 'SkirmisherArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.HEAVYARMORINFIL);
			case 'PlatedSkirmisherArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.HEAVYARMORINFIL);
			case 'PoweredSkirmisherArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.HEAVYARMORINFIL);
			case 'TemplarArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.NORMALARMORINFIL);
			case 'PlatedTemplarArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.NORMALARMORINFIL);
			case 'PoweredTemplarArmor':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.NORMALARMORINFIL);
			// Weaponry
			case 'Cannon_CV':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.HEAVYWEAPONINFIL);
			case 'Cannon_MG':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.HEAVYWEAPONINFIL);
			case 'Cannon_BM':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.HEAVYWEAPONINFIL);
			case 'SniperRifle_CV':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MIDHEAVYWEAPONINFIL);
			case 'SniperRifle_MG':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MIDHEAVYWEAPONINFIL);
			case 'SniperRifle_BM':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MIDHEAVYWEAPONINFIL);
			case 'AssaultRifle_CV':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MEDIUMWEAPONINFIL);
			case 'AssaultRifle_MG':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MEDIUMWEAPONINFIL);
			case 'AssaultRifle_BM':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MEDIUMWEAPONINFIL);
			case 'VektorRifle_CV':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MEDIUMWEAPONINFIL);
			case 'VektorRifle_MG':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MEDIUMWEAPONINFIL);
			case 'VektorRifle_BM':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MEDIUMWEAPONINFIL);
			case 'Shotgun_CV':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MIDLIGHTWEAPONINFIL);
			case 'Shotgun_MG':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MIDLIGHTWEAPONINFIL);
			case 'Shotgun_BM':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MIDLIGHTWEAPONINFIL);
			case 'Bullpup_CV':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MIDLIGHTWEAPONINFIL);
			case 'Bullpup_MG':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MIDLIGHTWEAPONINFIL);
			case 'Bullpup_BM':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.MIDLIGHTWEAPONINFIL);
			case 'SMG_CV':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTWEAPONINFIL);
			case 'SMG_MG':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTWEAPONINFIL);
			case 'SMG_BM':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTWEAPONINFIL);
			case 'ShardGauntlet_CV':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTWEAPONINFIL);
			case 'ShardGauntlet_MG':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTWEAPONINFIL);
			case 'ShardGauntlet_BM':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, default.LIGHTWEAPONINFIL);
				/*
			case '':
				InfilMgr.AddInfilMod(ItemTemplate.DataName, 0);
				*/
			}
			InfilMgr.AddInfilMod(ItemTemplate.DataName, 0);
		}
	}
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
