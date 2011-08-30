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
        	//Worldinfo.Game.Broadcast(self, Pawn.name $ ": I can see you!! (followpath)");
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

	simulated function CheckVisibility(){
		if(Pawn(Target) == none || !CanSee(Pawn(Target))){
			StopLatentExecution();
			Pawn.GotoState('');
			GotoState('Idle');
		}		
	}
	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		BBEnemyPawn(Pawn).playParticlesExclamacion();
		SetTimer(0.5,true,'CheckVisibility');
	}
	event EndState(name NextStateName){
		super.EndState(NextStateName);
		Focus = none;
		Target = none;
		ClearTimer('CheckVisibility');
	}
	

 Begin:
	Pawn.ZeroMovementVariables();
	Pawn.GotoState('Attacking');	
	Target = thePlayer;
	while(Target != none && thePlayer.Health > 0)
	{   				
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);		
				
        if (distanceToPlayer > attackDistance )            
        { 
			Pawn.GotoState('');
			GotoState('Idle');
			break;
        }else if(distanceToPlayer < fearDistance){
			 GotoState('Fearing');
        }
		Sleep(0.25);
	}
	Pawn.GotoState('');	
	GotoState('Idle');
}

state Fearing{
	ignores SeePlayer,HearNoise;

Begin:
	Pawn.ZeroMovementVariables();
	Pawn.GotoState('Attacking','FinishAttack');		

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
	Pawn.GotoState('');
	GotoState('Idle');
}


DefaultProperties
{
}
