class BBControllerAICaterpillar extends BBControllerAI;

/** Constant time between shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var float timeBetweenShots;
/** Random time betweeen shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var float randomTimeBetweenShots;

DefaultProperties
{
}

function SetPawn(BBEnemyPawn NewPawn){
	super.SetPawn(NewPawn);
	if(BBEnemyPawnCaterpillar(NewPawn) == none){
		`Warn("Attempting to assign a CaterpillarAI to "@NewPawn.Name);
	}else{
		timeBetweenShots = BBEnemyPawnCaterpillar(NewPawn).timeBetweenShots;
		randomTimeBetweenShots = BBEnemyPawnCaterpillar(NewPawn).randomTimeBetweenShots;
	}
}

state Attacking
{
 Begin:
	Pawn.Acceleration = vect(0,0,0);
	MyEnemyTestPawn.GotoState('Attacking');
	while(thePlayer.Health > 0)
	{   
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
        if (distanceToPlayer > attackDistance)
        { 
			MyEnemyTestPawn.GotoState('ChasePlayer');
            GotoState('Chaseplayer');
			break;
        }
		Sleep(1);
	}
	MyEnemyTestPawn.GotoState('Idle');
	GotoState('Idle');
}
