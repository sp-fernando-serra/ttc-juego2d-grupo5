class BBControllerAICaterpillar extends BBControllerAI;

/** Constant time between shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var float timeBetweenShots;
/** Random time betweeen shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var float randomTimeBetweenShots;

function SetPawn(BBEnemyPawn NewPawn){
	super.SetPawn(NewPawn);
	if(BBEnemyPawnCaterpillar(NewPawn) == none){
		`Warn("Attempting to assign a CaterpillarAI to "@NewPawn.Name);
	}else{
		timeBetweenShots = BBEnemyPawnCaterpillar(NewPawn).timeBetweenShots;
		randomTimeBetweenShots = BBEnemyPawnCaterpillar(NewPawn).randomTimeBetweenShots;
	}
}

event SeePlayer(Pawn SeenPlayer){
	local BBEnemyPawn pawnToAlert;
	
	if(bAggressive){
		StopLatentExecution();
		thePlayer = BBPawn(SeenPlayer);
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
		if (distanceToPlayer < attackDistance)
		{ 
        	//Worldinfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": I can see you!! (followpath)");
			GotoState('Attacking');
		}
		if(!bAlertedByOtherPawn){
			foreach VisibleActors(class'BBEnemyPawn', pawnToAlert, alertRadius, Pawn.Location){
				BBControllerAI(pawnToAlert.Controller).alertPawnPresence(SeenPlayer);
			}
		}
		bAlertedByOtherPawn = false;
	}
}

state Attacking{

	ignores SeePlayer, HearNoise;
 Begin:
	Pawn.ZeroMovementVariables();
	MyEnemyTestPawn.GotoState('Attacking');	

	while(thePlayer.Health > 0)
	{   				
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);		
				
        if (distanceToPlayer > attackDistance )            
        { 
			MyEnemyTestPawn.GotoState('');
            GotoState('Idle');
			break;
        }
		Sleep(1);
	}
	MyEnemyTestPawn.GotoState('');
	GotoState('Idle');
}


DefaultProperties
{
}
