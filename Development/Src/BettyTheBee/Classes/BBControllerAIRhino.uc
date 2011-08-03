class BBControllerAIRhino extends BBControllerAI;

DefaultProperties
{
}

state Attacking
{
 Begin:
	Pawn.Acceleration = vect(0,0,0);
	MyEnemyTestPawn.GotoState('Attacking');
	while(thePlayer.Health > 0)
	{   
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
        if (distanceToPlayer > attackDistance * 2)
        { 
			MyEnemyTestPawn.GotoState('');
			PopState();
			break;
        }
		Sleep(1);
	}
	MyEnemyTestPawn.GotoState('');
	PopState();
}