
class X2MissionNarrative_InfiltrationNarrativeSet extends X2MissionNarrative;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionNarrativeTemplate> Templates;

	Templates.AddItem(AddDefaultGatecrasherMissionNarrativeTemplate());

    return Templates;
}

static function X2MissionNarrativeTemplate AddDefaultGatecrasherMissionNarrativeTemplate()
{
    local X2MissionNarrativeTemplate Template;

    `CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'DefaultGatecrasherCI');

    Template.MissionType = "GatecrasherCI";
    Template.NarrativeMoments[0]="XPACK_NarrativeMoments.X2_XP_CEN_T_Comp_Rescue_Transport_Inbound";
    Template.NarrativeMoments[1]="XPACK_NarrativeMoments.X2_XP_CEN_T_Comp_Rescue_Squad_Wipe";
    Template.NarrativeMoments[2]="XPACK_NarrativeMoments.X2_XP_CEN_T_Comp_Rescue_Operative_Recovered_Squad_Wipe";
    Template.NarrativeMoments[3]="XPACK_NarrativeMoments.X2_XP_CEN_T_Comp_Rescue_Operative_Recovered_Heavy_Losses";
    Template.NarrativeMoments[4]="XPACK_NarrativeMoments.X2_XP_CEN_T_Comp_Rescue_Operative_Not_Recovered";
    Template.NarrativeMoments[5]="X2NarrativeMoments.TACTICAL.RescueVIP.CEN_RescVEH_Intro";
    Template.NarrativeMoments[6]="XPACK_NarrativeMoments.X2_XP_CEN_T_Comp_Rescue_Mission_Accomplished";
	
    return Template;
}
