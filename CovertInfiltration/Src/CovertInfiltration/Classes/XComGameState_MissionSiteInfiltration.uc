//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains the special logic used for
//           infiltration missions, such as autoselecting the
//           mission squad from the infiltration Covert Action
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_MissionSiteInfiltration extends XComGameState_MissionSite;

var() StateObjectReference CovertActionRef;

function bool ShouldBeVisible()
{
	return false;
}

function bool RequiresAvenger()
{
	// Does not require the Avenger at the mission site
	return false;
}

function SetupFromAction(XComGameState_CovertAction Action, XComGameState NewGameState)
{
	local X2CovertMissionInfoTemplateManager InfilMgr;
	local X2CovertMissionInfoTemplate MissionInfo;
	local XComGameState_Reward RewardState;
	local array<X2RewardTemplate> RewardTemplates;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local Vector2D MissionLocation;
	local int i;

	InfilMgr = class'X2CovertMissionInfoTemplateManager'.static.GetCovertMissionInfoTemplateManager();
	MissionInfo = InfilMgr.GetCovertMissionInfoTemplateFromCA(Action.GetMyTemplateName());
	RewardTemplates = class'X2Helper_Infiltration'.static.GetCovertMissionRewards(MissionInfo);
	MissionSource = class'X2Helper_Infiltration'.static.GetCovertMissionSource(MissionInfo);
	
	for (i = 0; i < RewardTemplates.length; i++)
	{
		RewardState = RewardTemplates[i].CreateInstanceFromTemplate(NewGameState);
		MissionRewards.AddItem(RewardState);
	}

	// Set the location - required for camera pan to work properly
	MissionLocation.X = Action.Location.X;
	MissionLocation.Y = Action.Location.Y;

	//ResistanceFaction = Faction;
	CovertActionRef = Action.GetReference();
	BuildMission(MissionSource, MissionLocation, Region, MissionRewards, true);
}

function SelectSquad()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_CovertAction ActionState;
	local XComGameState_StaffSlot SlotState;
	local array<StateObjectReference> MissionSoldiers;
	local int idx, NumSoldiers;
	
	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	ActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(CovertActionRef.ObjectID));

	NumSoldiers = class'X2StrategyGameRulesetDataStructures'.static.GetMaxSoldiersAllowedOnMission(self);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Set up Infiltrating squad");
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	
	for (idx = 0; idx < NumSoldiers; idx++)
	{
		// If the Covert Action has a soldier in one of its staff slots, add them to the Ambush soldier list
		if (idx < ActionState.StaffSlots.Length)
		{
			SlotState = ActionState.GetStaffSlot(idx);
			if (SlotState != none && SlotState.IsSoldierSlot() && SlotState.IsSlotFilled())
			{
				MissionSoldiers.AddItem(SlotState.GetAssignedStaffRef());
			}
		}
	}
	
	// Replace the squad with the soldiers who were on the Covert Action
	XComHQ.Squad = MissionSoldiers;
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

function StartMission()
{
	local XGStrategy StrategyGame;
	
	BeginInteraction();
	
	StrategyGame = `GAME;
	StrategyGame.PrepareTacticalBattle(ObjectID);
	ConfirmMission(); // Transfer directly to the mission, no squad select. Squad is set up based on the covert action soldiers.
}
