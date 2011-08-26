class BBControllerAIAnt2  extends BBControllerAI;

DefaultProperties
{
}

state Attacking
{

	ignores SeePlayer, HearNoise;

 Begin:
	Pawn.ZeroMovementVariables();
	MyEnemyTestPawn.GotoState('Attacking');
	while(thePlayer.Health > 0)
	{   
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
        if (distanceToPlayer > attackDistance * 2)
        { 
			MyEnemyTestPawn.GotoState('Chaseplayer');
            GotoState('Chaseplayer');
			break;
        }
		Sleep(1);
	}
	MyEnemyTestPawn.GotoState('Idle');
	GotoState('Idle');
}