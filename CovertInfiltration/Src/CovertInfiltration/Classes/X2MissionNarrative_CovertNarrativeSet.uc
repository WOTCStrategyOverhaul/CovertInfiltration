
class X2MissionNarrative_CovertNarrativeSet extends X2MissionNarrative;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionNarrativeTemplate> Templates;

	Templates.AddItem(AddDefaultGatecrasherMissionNarrativeTemplate());

    return Templates;
}

static function X2MissionNarrativeTemplate AddDefaultGatecrasherMissionNarrativeTemplate()
{
    local X2MissionNarrativeTemplate Template;

    `CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'DefaultGatecrasher');

    Template.MissionType = "Gatecrasher";

	Template.NarrativeMoments[0]="X2NarrativeMoments.TACTICAL.SabotageCC.SabotageCC_BombDetonated";
    Template.NarrativeMoments[1]="X2NarrativeMoments.TACTICAL.SabotageCC.SabotageCC_HeavyLossesIncurred";
    Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.SabotageCC.SabotageCC_TacIntro";
    Template.NarrativeMoments[3]="X2NarrativeMoments.TACTICAL.SabotageCC.SabotageCC_BombSpotted";
    Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
    Template.NarrativeMoments[5]="X2NarrativeMoments.TACTICAL.SabotageCC.SabotageCC_CompletionNag";
    Template.NarrativeMoments[6]="X2NarrativeMoments.TACTICAL.SabotageCC.SabotageCC_AllEnemiesDefeated";
    Template.NarrativeMoments[7]="X2NarrativeMoments.TACTICAL.SabotageCC.SabotageCC_AreaSecuredMissionEnd";
    Template.NarrativeMoments[8]="X2NarrativeMoments.TACTICAL.SabotageCC.SabotageCC_BombPlantedEnd";
    Template.NarrativeMoments[9]="X2NarrativeMoments.TACTICAL.SabotageCC.SabotageCC_BombPlantedContinue";
	
    return Template;
}
