class X2Encyclopedia_InfiltrationTutorial extends X2Encyclopedia;

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTutorialTemplate(
		1, 'GeoscapeEntry',
		class'UIUtilities_InfiltrationTutorial'.default.strGeoscapeEntryHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strGeoscapeEntryBody
	));

	// TODO

	return Templates;
}

static protected function X2EncyclopediaTemplate CreateTutorialTemplate (int SortingPriority, name StageName, string Header, string Body)
{
	local X2Encyclopedia_InfiltrationTutorialClosure Closure;
	local X2EncyclopediaTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EncyclopediaTemplate', Template, name('CovertInfiltrationTutorial_' $ StageName));

	Template.ListCategory = 'CovertInfiltration';
	Template.ListTitle = Header;
	Template.DescriptionTitle = Header;
	Template.DescriptionEntry = Body;
	Template.SortingPriority = SortingPriority;

	Closure = new class'X2Encyclopedia_InfiltrationTutorialClosure';
	Closure.StageName = StageName;
	Template.Requirements.SpecialRequirementsFn = Closure.ShouldShow;

	return Template;
}
