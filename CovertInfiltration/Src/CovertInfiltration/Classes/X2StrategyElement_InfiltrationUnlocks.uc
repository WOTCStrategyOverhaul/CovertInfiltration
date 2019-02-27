class X2StrategyElement_InfiltrationUnlocks extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateInfilSize1Unlock());
	Templates.AddItem(CreateInfilSize2Unlock());

	return Templates;
}

static function X2SoldierUnlockTemplate CreateInfilSize1Unlock()
{
	local X2SoldierUnlockTemplate Template;

	`CREATE_X2TEMPLATE(class'X2SoldierUnlockTemplate', Template, 'InfiltrationSize1');

	Template.bAllClasses = true;
	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_SquadSize1";

	return Template;
}

static function X2SoldierUnlockTemplate CreateInfilSize2Unlock()
{
	local X2SoldierUnlockTemplate Template;

	`CREATE_X2TEMPLATE(class'X2SoldierUnlockTemplate', Template, 'InfiltrationSize2');

	Template.bAllClasses = true;
	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_SquadSize2";

	return Template;
}
