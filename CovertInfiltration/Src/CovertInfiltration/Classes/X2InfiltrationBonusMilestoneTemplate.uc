class X2InfiltrationBonusMilestoneTemplate extends X2DataTemplate;

var int ActivateAtProgress;

var localized string strName;

function bool ValidateTemplate (out string strError)
{
	if (!super.ValidateTemplate(strError))
	{
		return false;
	}

	if (ActivateAtProgress <= 100)
	{
		strError = "only progress above 100 is supported";
		return false;
	}

	return true;
}