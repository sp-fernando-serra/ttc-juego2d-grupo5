class BBControllerAICaterpillar extends BBControllerAI;

/** Constant time between shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var float timeBetweenShots;
/** Random time betweeen shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var float randomTimeBetweenShots;

var float orientation, orientation2;
var float  angle_degrees;
var Vector lateral;

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
		angle_degrees = Acos(thePlayer.Location dot Pawn.Location) * 180/pi;
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
		orientation = Vector(Pawn.GetViewRotation()) dot Normal(thePlayer.Location - Pawn.Location);


		lateral=vector(Pawn.GetViewRotation());
		// Rotate 90 degrees in XZ, I'm going to assume (probably wrongly) that this lateral vector will point to the left of the facing, but it COULD be facing to the right
		// in which case the answers below are the wrong way round...
		lateral=lateral cross vect(0,0,1);
 
		orientation2 = lateral dot Normal(thePlayer.Location - Pawn.Location);
		  // > 0.0  A sits to the left of B
		  // = 0.0  A is in front of/behind B (exactly 90° between A and B)
		  // < 0.0  A sits to the right of B
				
        if (distanceToPlayer > attackDistance || orientation < 0)            
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
