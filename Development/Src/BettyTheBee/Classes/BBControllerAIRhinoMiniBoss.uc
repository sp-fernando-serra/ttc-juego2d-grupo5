class BBControllerAIRhinoMiniBoss extends BBControllerAI;

var float attackChargeDistance;

var float attackDistanceNear;

var enum ERhinoAttackType
{
	RAT_Normal,
	RAT_Charge,	
} AttackType;


function Possess(Pawn aPawn, bool bVehicleTransition){
	local BBEnemyPawnRhinoMiniBoss NewPawn;

	super.Possess(aPawn, bVehicleTransition);
	NewPawn = BBEnemyPawnRhinoMiniBoss(aPawn);
	if(NewPawn != none){
		attackChargeDistance = NewPawn.attackChargeDistance;
		attackDistance = NewPawn.attackDistance;
	}else{
		`warn(self.GetHumanReadableName() @ "tries to possess" @ aPawn.GetHumanReadableName());
	}
}

function ChangeAttackType(ERhinoAttackType newType){
	local BBEnemyPawnRhinoMiniBoss tempPawn;

	if(AttackType != newType){
		tempPawn = BBEnemyPawnRhinoMiniBoss(Pawn);
		if(newType == RAT_Normal){
			tempPawn.AttackDistance = tempPawn.attackDistanceNear;			
		}else if(newType == RAT_Charge){
			tempPawn.AttackDistance = tempPawn.attackDistanceFar;
		}
		attackDistance = tempPawn.AttackDistance;
		AttackType = newType;
	}
}

function bool IsWithinAttackRange(Actor other){

	local Vector temp;
	local float tempf;
	temp = Pawn.Location - other.Location;
	tempf = VSize(temp) - Pawn.GetCollisionRadius() - Pawn(other).GetCollisionRadius();
	return tempf < attackDistance;

}

function bool IsWithinAttackChargeRange(Actor other){

	local Vector temp;
	local float tempf;
	temp = Pawn.Location - other.Location;
	tempf = VSize(temp) - Pawn.GetCollisionRadius() - Pawn(other).GetCollisionRadius();
	return tempf < attackChargeDistance;	
}

function NotifyChargeFinished(){
	
	//if(IsWithinAttackRange(thePlayer)){
	//	GotoState('Attacking');
	//}else{
	//	GotoState('ChasePlayer');
	//}
	ChangeAttackType(RAT_Normal);
	GotoState('ChasePlayer');
	
}

auto state idle{
	
}

state ChasePlayer{

	ignores SeePlayer,HearNoise;

	event EndState(name NextStateName){		
		ClearTimer('CheckIndirectReachability');
		ClearTimer('CheckDirectReachability');		
	}
	//It's here for overwrite the super.BeginState(). We don't want to perform a CheckVisibility in RhinoMiniBoss
	event BeginState(name PreviousStateName){
		Pawn.GotoState('ChasePlayer');
	}

Begin:
	if(thePlayer != none){
		Target = thePlayer;
		Pawn.GotoState('ChasePlayer');
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
		if(IsWithinAttackRange(Target)){
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
				if(AttackType == RAT_Normal)
					GotoState('Attacking');
				else if(AttackType == RAT_Charge)
					GotoState('Charging');
			}
		}
	}
	else //if we don't have a target, wait a little bit before we check again for another one
		Sleep(0.3);	

	goto 'Targeting';
}

state Charging{

	ignores SeePlayer, HearNoise;


	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		Pawn.GotoState('Charging');
	}
	
	event EndState(name PreviousStateName){
		super.EndState(PreviousStateName);
		ClearTimer('CheckChargeAttackRange');
	}

	function CheckChargeAttackRange(){
		if(IsWithinAttackChargeRange(thePlayer)){
			Pawn.GotoState('Charging','Attack');
			ClearTimer('CheckChargeAttackRange');
			GotoState('Charging','Attacking');
		}
	}

Begin:

	Target = thePlayer;
	//Stop Pawn Movement
	StopLatentExecution();
	Pawn.Acceleration = vect(0,0,0);
	//If in 5 seconds the target continues out of range, finish Charge
	Sleep(5.0f);
	Pawn.GotoState('Charging','Attack');
	ClearTimer('CheckChargeAttackRange');
	GotoState('Charging','Attacking');

Running:
	SetTimer(0.25f, true, 'CheckChargeAttackRange');
	while(true){
		//If path to point exists
		if(GeneratePathToActor(Target)){
			CurrentTargetIsReachable = NavigationHandle.ActorReachable(Target);
			if(CurrentTargetIsReachable){
				//Focus = Target;
				if(Target != none)
					MoveToward(Target, Target);
			}else{  //Actor is NOT directly reachable
				//Focus = Target;
				//If path exists
				if(NavigationHandle.GetNextMoveLocation( NextMoveLocation, Pawn.GetCollisionRadius())){
					MoveTo(NextMoveLocation,Target);
				}else{
					`log(self @ "Can't find next Move Location to" @ Target);
					GotoState('Idle');
				}
			}
		}else{
			`log(self @ "Can't find path to" @ Target);
			GotoState('Idle');
		}
	}	

Attacking:
	Focus = none;
	Target = none;
	StopLatentExecution();	
}

state Stunned{
	ignores SeePlayer, HearNoise;

	simulated event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		StopLatentExecution();
		Pawn.ZeroMovementVariables();
		Pawn.GotoState('Stunned');
	}
}

state Attacking
{
	ignores SeePlayer,HearNoise;

	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		Pawn.GotoState('Attacking');
		Focus = thePlayer;
	}
	
	event EndState(name PreviousStateName){
		super.EndState(PreviousStateName);
		ClearTimer('CheckAttackNearRange');
	}

	function CheckAttackNearRange(){
		if(!IsWithinAttackRange(thePlayer)){
			ClearTimer('CheckAttackNearRange');
			GotoState('ChasePlayer');
		}
	}

 Begin:
	Pawn.ZeroMovementVariables();
	Pawn.GotoState('Attacking');
	while(thePlayer.Health > 0)
	{   
		if (!IsWithinAttackRange(thePlayer))
        { 
			Pawn.GotoState('ChasePlayer');
			GotoState('ChasePlayer');
			break;
        }
		Sleep(1);
	}
	Pawn.GotoState('ChasePlayer');
	PopState();
}


DefaultProperties
{
	MinHitWall = -0.5f;
	AttackType = RAT_Charge;
	
}