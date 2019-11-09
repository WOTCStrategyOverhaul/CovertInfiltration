//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains all the new Points of Interest
//           used by the mod as part of the POI rework
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_InfiltrationPointsOfInterest extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CreatePOIPrototypeT2Template());
	Templates.AddItem(CreatePOIPrototypeT3Template());
	Templates.AddItem(CreatePOISidegradeT1Template());
	Templates.AddItem(CreatePOISidegradeT2Template());
	Templates.AddItem(CreatePOISidegradeT3Template());

	return Templates;
}

//---------------------------------------------------------------------------------------

static function X2DataTemplate CreatePOIPrototypeT2Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Prototype_T2');

	Template.CanAppearFn = CurrentTierFully1;

	return Template;
}

static function X2DataTemplate CreatePOIPrototypeT3Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Prototype_T3');

	Template.CanAppearFn = CurrentTierFully2;

	return Template;
}

static function X2DataTemplate CreatePOISidegradeT1Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Sidegrade_T1');

	Template.CanAppearFn = CurrentTierFully1;

	return Template;
}

static function X2DataTemplate CreatePOISidegradeT2Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Sidegrade_T2');

	Template.CanAppearFn = CurrentTierPartially2;

	return Template;
}

static function X2DataTemplate CreatePOISidegradeT3Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Sidegrade_T3');

	Template.CanAppearFn = CurrentTierPartially3;

	return Template;
}

//----------------------------------------------------------------------

static function bool CurrentTierPartially1(XComGameState_PointOfInterest POIState)
{
	return (`XCOMHQ.IsTechResearched('MagnetizedWeapons') && `XCOMHQ.IsTechResearched('PlatedArmor')) == false;
}

static function bool CurrentTierFully1(XComGameState_PointOfInterest POIState)
{
	return (`XCOMHQ.IsTechResearched('MagnetizedWeapons') || `XCOMHQ.IsTechResearched('PlatedArmor')) == false;
}

static function bool CurrentTierPartially2(XComGameState_PointOfInterest POIState)
{
	return (`XCOMHQ.IsTechResearched('MagnetizedWeapons') || `XCOMHQ.IsTechResearched('PlatedArmor'));
}

static function bool CurrentTierFully2(XComGameState_PointOfInterest POIState)
{
	return (`XCOMHQ.IsTechResearched('MagnetizedWeapons')
		&& `XCOMHQ.IsTechResearched('GaussWeapons')
		&& `XCOMHQ.IsTechResearched('PlatedArmor')
	);
}

static function bool CurrentTierPartially3(XComGameState_PointOfInterest POIState)
{
	return (`XCOMHQ.IsTechResearched('PlasmaRifle') || `XCOMHQ.IsTechResearched('PoweredArmor'));
}

static function bool CurrentTierFully3(XComGameState_PointOfInterest POIState)
{
	return (`XCOMHQ.IsTechResearched('PlasmaRifle')
		&& `XCOMHQ.IsTechResearched('HeavyPlasma')
		&& `XCOMHQ.IsTechResearched('PlasmaSniper')
		&& `XCOMHQ.IsTechResearched('AlloyCannon')
		&& `XCOMHQ.IsTechResearched('PoweredArmor')
	);
}
