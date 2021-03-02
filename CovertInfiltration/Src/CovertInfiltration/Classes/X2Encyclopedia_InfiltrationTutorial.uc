class X2Encyclopedia_InfiltrationTutorial extends X2Encyclopedia;

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTutorialTemplate(
		'Welcome',
		class'UIUtilities_InfiltrationTutorial'.default.strWelcomeHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strWelcomeBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'GeoscapeEntry',
		class'UIUtilities_InfiltrationTutorial'.default.strGeoscapeEntryHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strGeoscapeEntryBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'CovertActionLoadout',
		class'UIUtilities_InfiltrationTutorial'.default.strCovertActionLoadoutHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strCovertActionLoadoutBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'InfiltrationLoadout',
		class'UIUtilities_InfiltrationTutorial'.default.strInfiltrationLoadoutHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strInfiltrationLoadoutBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'AssaultLoadout',
		class'UIUtilities_InfiltrationTutorial'.default.strAssaultLoadoutHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strAssaultLoadoutBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'OverInfiltration',
		class'UIUtilities_InfiltrationTutorial'.default.strOverInfiltrationHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strOverInfiltrationBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'CovertActionFinished',
		class'UIUtilities_InfiltrationTutorial'.default.strCovertActionFinishedHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strCovertActionFinishedBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'FacilityChanges',
		class'UIUtilities_InfiltrationTutorial'.default.strFacilityRingHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strFacilityRingBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'GuerillaTactics',
		class'UIUtilities_InfiltrationTutorial'.default.strFacilityGTSHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strFacilityGTSBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'ActivityChains',
		class'UIUtilities_InfiltrationTutorial'.default.strActivityChainsHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strActivityChainsBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'ResistanceInformants',
		class'UIUtilities_InfiltrationTutorial'.default.strResistanceInformantsHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strResistanceInformantsBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'AlienFacilityBuilt',
		class'UIUtilities_InfiltrationTutorial'.default.strFacilityAssaultsHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strFacilityAssaultsBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'DarkEventPreview',
		class'UIUtilities_InfiltrationTutorial'.default.strDarkEventsHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strDarkEventsBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'CovertOpsAbort',
		class'UIUtilities_InfiltrationTutorial'.default.strCovertOpsAbortHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strCovertOpsAbortBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'CrewLimit',
		class'UIUtilities_InfiltrationTutorial'.default.strCrewLimitHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strCrewLimitBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'CrewExpansion',
		class'UIUtilities_InfiltrationTutorial'.default.strCrewExpansionHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strCrewExpansionBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'AdvancedChains',
		class'UIUtilities_InfiltrationTutorial'.default.strAdvancedChainsHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strAdvancedChainsBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'IndividualBuiltItems',
		class'UIUtilities_InfiltrationTutorial'.default.strIndividualBuiltItemsHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strIndividualBuiltItemsBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'MindShieldOnTiredNerf',
		class'UIUtilities_InfiltrationTutorial'.default.strMindShieldOnTiredNerfHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strMindShieldOnTiredNerfBody
	));

	// These refer to the current mission, so they are confusing to read in the archives
	/*Templates.AddItem(CreateTutorialTemplate(
		'SupplyExtract',
		class'UIUtilities_InfiltrationTutorial'.default.strSupplyExtractHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strSupplyExtractBody
	));

	Templates.AddItem(CreateTutorialTemplate(
		'AvatarCapture',
		class'UIUtilities_InfiltrationTutorial'.default.strAvatarCaptureHeader,
		class'UIUtilities_InfiltrationTutorial'.default.strAvatarCaptureBody
	));*/

	AssignSortingPriority(Templates);

	return Templates;
}

static protected function X2EncyclopediaTemplate CreateTutorialTemplate (/*int SortingPriority, */name StageName, string Header, string Body)
{
	local X2Encyclopedia_InfiltrationTutorialClosure Closure;
	local X2EncyclopediaTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EncyclopediaTemplate', Template, name('CovertInfiltrationTutorial_' $ StageName));

	Template.ListCategory = 'CovertInfiltration';
	Template.ListTitle = Header;
	Template.DescriptionTitle = Header;
	Template.DescriptionEntry = Body;
	//Template.SortingPriority = SortingPriority;

	Closure = new class'X2Encyclopedia_InfiltrationTutorialClosure';
	Closure.StageName = StageName;
	Template.Requirements.SpecialRequirementsFn = Closure.ShouldShow;

	return Template;
}

static protected function AssignSortingPriority (const out array<X2DataTemplate> Templates)
{
	local X2EncyclopediaTemplate EncyclopediaTemplate;
	local X2DataTemplate DataTemplate;
	local int i;

	foreach Templates(DataTemplate, i)
	{
		EncyclopediaTemplate = X2EncyclopediaTemplate(DataTemplate);
		EncyclopediaTemplate.SortingPriority = i + 1;
	}
}
