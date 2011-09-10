class BBControllerAIAnt2  extends BBControllerAI;

state Attacking
{

	ignores SeePlayer, HearNoise;

 Begin:
	Pawn.ZeroMovementVariables();
	Pawn.GotoState('Attacking');
	while(thePlayer.Health > 0)
	{   
		if (!IsWithinAttackRange(thePlayer)){ 
			Pawn.GotoState('');
            GotoState('Chaseplayer');
			break;
        }
		Sleep(1);
	}
	Pawn.GotoState('Idle');
	GotoState('Idle');
}

DefaultProperties
{
}
