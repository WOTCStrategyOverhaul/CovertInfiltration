
class X2MissionSet_InfiltrationMissionSet extends X2MissionSet;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionTemplate> Templates;

    Templates.AddItem(AddMissionTemplate('GatecrasherCI'));

    return Templates;
}
