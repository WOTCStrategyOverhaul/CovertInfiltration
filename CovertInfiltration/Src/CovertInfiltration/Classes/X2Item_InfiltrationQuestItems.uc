//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: Quest items for infltration missions
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2Item_InfiltrationQuestItems extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;
	
	Items.AddItem(CreateQuestItemActivityLeadItem());
	Items.AddItem(CreateQuestItemPersonnelLeadItem());
	Items.AddItem(CreateQuestItemTargetLeadItem());

	Items.AddItem(CreateQuestItemActivityLeadHack());
	Items.AddItem(CreateQuestItemPersonnelLeadHack());
	Items.AddItem(CreateQuestItemTargetLeadHack());

	return Items;
}

static function X2DataTemplate CreateQuestItemActivityLeadItem()
{
	local X2QuestItemTemplate Item;

	`CREATE_X2TEMPLATE(class'X2QuestItemTemplate', Item, 'ActivityLeadItem');
	Item.ItemCat = 'quest';

	Item.MissionType.AddItem("Recover");
	Item.MissionType.AddItem("Recover_ADV");
	Item.MissionType.AddItem("Recover_Train");
	Item.MissionType.AddItem("Recover_Vehicle");
	
	Item.RewardType.AddItem('Reward_GatherLeadActivity');

	Item.MissionSource.AddItem('MissionSource_GatherLead');

	return Item;
}

static function X2DataTemplate CreateQuestItemPersonnelLeadItem()
{
	local X2QuestItemTemplate Item;

	`CREATE_X2TEMPLATE(class'X2QuestItemTemplate', Item, 'PersonnelLeadItem');
	Item.ItemCat = 'quest';

	Item.MissionType.AddItem("Recover");
	Item.MissionType.AddItem("Recover_ADV");
	Item.MissionType.AddItem("Recover_Train");
	Item.MissionType.AddItem("Recover_Vehicle");
	
	Item.RewardType.AddItem('Reward_GatherLeadPersonnel');

	Item.MissionSource.AddItem('MissionSource_GatherLead');

	return Item;
}

static function X2DataTemplate CreateQuestItemTargetLeadItem()
{
	local X2QuestItemTemplate Item;

	`CREATE_X2TEMPLATE(class'X2QuestItemTemplate', Item, 'TargetLeadItem');
	Item.ItemCat = 'quest';

	Item.MissionType.AddItem("Recover");
	Item.MissionType.AddItem("Recover_ADV");
	Item.MissionType.AddItem("Recover_Train");
	Item.MissionType.AddItem("Recover_Vehicle");
	
	Item.RewardType.AddItem('Reward_GatherLeadTarget');

	Item.MissionSource.AddItem('MissionSource_GatherLead');

	return Item;
}

static function X2DataTemplate CreateQuestItemActivityLeadHack()
{
	local X2QuestItemTemplate Item;

	`CREATE_X2TEMPLATE(class'X2QuestItemTemplate', Item, 'ActivityLeadHack');
	Item.ItemCat = 'quest';
	
	Item.MissionType.AddItem("Hack");
	Item.MissionType.AddItem("Hack_ADV");
	Item.MissionType.AddItem("Hack_Train");
	Item.MissionType.AddItem("ProtectDevice");
	
	Item.RewardType.AddItem('Reward_GatherLeadActivity');

	Item.MissionSource.AddItem('MissionSource_GatherLead');
	
	Item.IsElectronicReward = true;

	return Item;
}

static function X2DataTemplate CreateQuestItemPersonnelLeadHack()
{
	local X2QuestItemTemplate Item;

	`CREATE_X2TEMPLATE(class'X2QuestItemTemplate', Item, 'PersonnelLeadHack');
	Item.ItemCat = 'quest';
	
	Item.MissionType.AddItem("Hack");
	Item.MissionType.AddItem("Hack_ADV");
	Item.MissionType.AddItem("Hack_Train");
	Item.MissionType.AddItem("ProtectDevice");

	Item.RewardType.AddItem('Reward_GatherLeadPersonnel');

	Item.MissionSource.AddItem('MissionSource_GatherLead');
	
	Item.IsElectronicReward = true;

	return Item;
}

static function X2DataTemplate CreateQuestItemTargetLeadHack()
{
	local X2QuestItemTemplate Item;

	`CREATE_X2TEMPLATE(class'X2QuestItemTemplate', Item, 'TargetLeadHack');
	Item.ItemCat = 'quest';
	
	Item.MissionType.AddItem("Hack");
	Item.MissionType.AddItem("Hack_ADV");
	Item.MissionType.AddItem("Hack_Train");
	Item.MissionType.AddItem("ProtectDevice");
	
	Item.RewardType.AddItem('Reward_GatherLeadTarget');

	Item.MissionSource.AddItem('MissionSource_GatherLead');
	
	Item.IsElectronicReward = true;

	return Item;
}
