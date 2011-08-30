class BBControllerAIRhino extends BBControllerAI;

state Attacking
{
 Begin:
	Pawn.ZeroMovementVariables();
	Pawn.GotoState('Attacking');
	while(thePlayer.Health > 0)
	{   
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
        if (distanceToPlayer > attackDistance * 2)
        { 
			Pawn.GotoState('');
			PopState();
			break;
        }
		Sleep(1);
	}
	Pawn.GotoState('');
	PopState();
}

DefaultProperties
{
}