// TODO: Make this into a template
class X2MissionChainStage extends Object abstract;

/////////////////
/// Interface ///
/////////////////

function InitializeChain();
function InitializeStage();

function CleanupStage();
function CleanupChain();

///////////////
/// Helpers ///
///////////////

function int GetStageIndex()
{
	return X2MissionChainTemplate(Outer).Stages.Find(self);
}