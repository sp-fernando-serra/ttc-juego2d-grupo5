class BBControllerAICaterpillar2 extends BBControllerAI;

/** Constant time between shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var float timeBetweenShots;
/** Random time betweeen shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var float randomTimeBetweenShots;
/** This pawn enters in fear state if player is nearer than this distance  */
var float fearDistance;

function SetPawn(BBEnemyPawn NewPawn){
	local BBEnemyPawnCaterpillar2 tempPawn;

	super.SetPawn(NewPawn);

	tempPawn = BBEnemyPawnCaterpillar2(NewPawn);
	if(tempPawn == none){
		`Warn("Attempting to assign a CaterpillarAI to "@NewPawn.Name);
	}else{
		timeBetweenShots = tempPawn.timeBetweenShots;
		randomTimeBetweenShots = tempPawn.randomTimeBetweenShots;
		fearDistance = tempPawn.fearDistance;
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
			Focus = thePlayer;
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
			Focus = none;
            GotoState('Idle');
			break;
        }else if(distanceToPlayer < fearDistance){
			Focus = none;
            GotoState('Fearing');
        }
		Sleep(0.25);
	}
	MyEnemyTestPawn.GotoState('');
	GotoState('Idle');
}

state Fearing{
	ignores SeePlayer,HearNoise;

Begin:
	Pawn.ZeroMovementVariables();
		MyEnemyTestPawn.GotoState('Attacking','FinishAttack');		

	while(thePlayer.Health > 0)
	{   				
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);		
				
        if (distanceToPlayer > fearDistance )            
        { 
			Focus = thePlayer;
            GotoState('Attacking');
			break;
        }
		Sleep(0.25);
	}
	MyEnemyTestPawn.GotoState('');
	GotoState('Idle');
}


DefaultProperties
{
}
