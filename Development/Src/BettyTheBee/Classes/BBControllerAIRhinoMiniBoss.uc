class BBControllerAIRhinoMiniBoss extends BBControllerAI;

var float attackChargeDistance;

var vector attackChargeDirection;

function SetPawn(BBEnemyPawn NewPawn){

	super.SetPawn(NewPawn);
	attackChargeDistance = BBEnemyPawnRhinoMiniBoss(MyEnemyTestPawn).attackChargeDistance;
	
}

function bool IsWithinAttackChargeRange(Actor other){

	local Vector temp;
	local float tempf;
	temp = Pawn.Location - other.Location;
	tempf = VSize(temp) - Pawn.GetCollisionRadius() - Pawn(other).GetCollisionRadius();
	return tempf < attackChargeDistance;	
}

auto state idle{
	event BeginState(name PreviousStateName){
		local BBBettyPawn playerPawn;
		super.BeginState(PreviousStateName);
		foreach DynamicActors(class'BBBettyPawn',playerPawn){
			thePlayer = playerPawn;
		}
		Enemy = thePlayer;
	}
}

state ChasePlayer{

	ignores SeePlayer;

Begin:
	if(thePlayer != none){
		Target = thePlayer;
		MyEnemyTestPawn.GotoState('ChasePlayer');
	}else{
		GotoState('Idle',,,false);
	}

Targeting:

	Sleep(0);
	while(Pawn.Physics != PHYS_Walking) //delay movement until our feet are solidly on the ground -- helps prevent bad navmesh return values in case we're falling and are not currently on the navmesh.
	{
		Sleep(0);
	}
	//only go somewhere if we have somewhere to go...
	if(Target != none){

		//only bother moving if we're not in attack range or don't have line-of-sight
		if(!IsWithinAttackRange(Target) && GeneratePathToActor(Target)){

			//just in case...
			ClearTimer('CheckIndirectReachability');
			ClearTimer('CheckDirectReachability');

			//If Target is directly Reachable
			CurrentTargetIsReachable = NavigationHandle.ActorReachable(Target);
			if(CurrentTargetIsReachable){
				SetTimer(0.3, true,'CheckDirectReachability'); //keep checking periodically if the target becomes NOT directly reachable
				Focus = Target;
				if(Target != none)
					MoveToward(Target, Target, attackDistance * attackDistanceFactor);
			}else{  //Actor is NOT directly reachable
				SetTimer(0.3, true,'CheckIndirectReachability'); //keep checking periodically if the target becomes directly reachable
				Focus = Target;
				//If path exists
				if(NavigationHandle.GetNextMoveLocation( NextMoveLocation, Pawn.GetCollisionRadius())){
					MoveTo(NextMoveLocation,Target);
				}else{
					`log(self @ "Can't find path to" @ Target);
				}
			}
		}
		//finished or cancelled our movements, so go ahead and clear these timers
		ClearTimer('CheckIndirectReachability');
		ClearTimer('CheckDirectReachability');

		//if the target is now directly reachable AND within line of sight, then let's attack baby attack!
		if(IsWithinAttackRange(Target))
		{
			// if we're within range, attempt to finish rotating towards target...
			//`log("Within attack range, finishing rotation...");
			//if(RotDegreesBetweenYaw(Rotator(Target.Location-Pawn.Location),Rotation) > 14)
			//{
				MoveToward(Target,Target,attackDistance * attackDistanceFactor ,false,false);
				FinishRotation();
			//}
			
			////reset this timer since we have just reached our target, we don't want to time-out on reaching it
			//if(Target != none && !HasReachedNewTarget)
			//{
			//	HasReachedNewTarget=true;
			//	LastReachedNewTargetTime=WorldInfo.TimeSeconds;
			//}

			//and if we're STILL within range (since we have lost range when finishing our latent rotation), then actually attack
			if(IsWithinAttackRange(Target))
			{
				GotoState('Charging');
			}
		}
	}
	else //if we don't have a target, wait a little bit before we check again for another one
		Sleep(0.3);	

	goto 'Targeting';
}

state Charging{

	ignores SeePlayer;


	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		MyEnemyTestPawn.GotoState('Charging');
	}

	function CheckChargeAttackRange(){
		if(IsWithinAttackChargeRange(thePlayer)){
			MyEnemyTestPawn.GotoState('Charging','Attack');
			ClearTimer('CheckChargeAttackRange');
			attackChargeDirection = Pawn.Location + Normal(Vector(Pawn.Rotation))*attackChargeDistance;
			GotoState('Charging','Attacking');
		}
	}

Begin:

	SetTimer(0.25f, true, 'CheckChargeAttackRange');
	Target = thePlayer;
	//Stop Pawn Movement
	StopLatentExecution();
	Pawn.Acceleration = vect(0,0,0);
	Sleep(5.0f);
	GotoState('Idle');

Running:
	CurrentTargetIsReachable = NavigationHandle.ActorReachable(Target);
	if(CurrentTargetIsReachable){
		Focus = Target;
		if(Target != none)
			MoveToward(Target, Target, attackChargeDistance);
	}else{  //Actor is NOT directly reachable
		Focus = Target;
		//If path exists
		if(NavigationHandle.GetNextMoveLocation( NextMoveLocation, Pawn.GetCollisionRadius())){
			MoveTo(NextMoveLocation,Target);
		}else{
			`log(self @ "Can't find path to" @ Target);
			GotoState('Idle');
		}
	}
	goto 'Running';

Attacking:
	Focus = none;
	StopLatentExecution();
	Pawn.Acceleration = vect(0,0,0);
	//CurrentTargetIsReachable = NavigationHandle.PointReachable(attackChargeDirection);
	//if(CurrentTargetIsReachable){
	//	MoveTo(attackChargeDirection);
	//}else{  //Actor is NOT directly reachable
	//	//If path exists
	//	if(NavigationHandle.GetNextMoveLocation( NextMoveLocation, Pawn.GetCollisionRadius())){
	//		MoveTo(NextMoveLocation);
	//	}else{
	//		`log(self @ "Can't find path to" @ Target);
	//	}
	//}
	//goto 'Attacking';
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


DefaultProperties
{
	
}