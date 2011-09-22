class BBControllerAIRhinoMiniBoss extends BBControllerAI;

var float attackChargeDistance;

/** AttackDistance used in Melee attacks */
var float attackDistanceNear;
/** AttackDistance used in Charge attacks (at what distance start charging, not charge attack) */
var float attackDistanceFar;
/** Array with points to start a Charge Attack */
var array<PathTargetPoint> chargePoints;
/** Chosen point to start the next Charge Attack */
var PathTargetPoint chosenChargePoint;
/** Used to know how many attacks this pawn has done in Attacking state */
var int attackCount;
/** Max value for attackCount. If reached, Rhino goes to Charge */
var int maxAttackCount;
/** Max time in seconds this pawn can stay in Attacking state */
var float maxAttackTime;
/** Last velocity check for determine if pawn has reached a Wall in Charge state */
var float lastChargeVelocity;


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
		attackDistanceNear = NewPawn.attackDistanceNear;
		attackDistanceFar = NewPawn.attackDistanceFar;
		ChargePoints = NewPawn.ChargePoints;
		bDebug = NewPawn.bDebug;
	}else{
		`warn(self.GetHumanReadableName() @ "tries to possess" @ aPawn.GetHumanReadableName());
	}
}

/**	Handling Toggle event from Kismet. */
simulated function OnToggle(SeqAct_Toggle Action)
{
	// Turn ON
	if (Action.InputLinks[0].bHasImpulse)
	{
		bAggressive = true;
	}
	// Turn OFF
	else if (Action.InputLinks[1].bHasImpulse)
	{
		bAggressive = false;
	}
	// Toggle
	else if (Action.InputLinks[2].bHasImpulse)
	{
		bAggressive = !bAggressive;
	}
}

function ChangeAttackType(ERhinoAttackType newType){
	local BBEnemyPawnRhinoMiniBoss tempPawn;

	if(AttackType != newType){
		tempPawn = BBEnemyPawnRhinoMiniBoss(Pawn);
		if(newType == RAT_Normal){
			attackCount = 0;
			tempPawn.AttackDistance = tempPawn.attackDistanceNear;			
		}else if(newType == RAT_Charge){
			tempPawn.AttackDistance = tempPawn.attackDistanceFar;
		}
		attackDistance = tempPawn.AttackDistance;
		AttackType = newType;
	}
}

/**Used to find the next chargePoint in all chargePoints array
 * Closer points have more chances to be selected
 * @return true if point has found
 */ 
function bool ChooseChargePoint(){
	local PathTargetPoint tempPoint;
	local float totalDistance;
	local float tempDistance, debugDistance;
	local string debugText;
	local int debugIndex;

	if(chargePoints.Length < 1){
		`warn(GetHumanReadableName() @ "Error finding correct ChargePoint, chargePoints is empty!!");
		return false;
	}
	debugIndex = 0;
	debugText = "DistanceDactors: ";
	foreach chargePoints(tempPoint){
		tempDistance = CheckDistanceTo(tempPoint);
		// Invert (1/tempDistance) the distances to use inverse probability instead of direct probability
		// with the distance. Factor 4000 is for avoid errors with very small numbers
		tempDistance = 4000/tempDistance;
		totalDistance += tempDistance;
		if(bDebug){
			debugText @= debugIndex$": "$tempDistance$" || ";
			debugIndex++;
		}
	}
	
	tempDistance = FRand()*totalDistance;
	if(bDebug){
		WorldInfo.Game.Broadcast(self, debugText);
		debugText = "Probabilities: ";
		debugIndex = 0;
		foreach chargePoints(tempPoint){
			debugDistance = CheckDistanceTo(tempPoint);
			// Invert (1/tempDistance) the distances to use inverse probability instead of direct probability
			// with the distance. Factor 4000 is for avoid errors with very small numbers
			debugDistance = (4000/debugDistance)/totalDistance;
			debugText @= debugIndex$": "$debugDistance$" || ";
			debugIndex++;			
		}
		WorldInfo.Game.Broadcast(self, debugText);
		debugIndex = 0;
	}

	
	
	foreach chargePoints(tempPoint){
		
		if(tempDistance < (4000/CheckDistanceTo(tempPoint)) ){
			chosenChargePoint = tempPoint;
			return true;
		}else{
			tempDistance -= (4000/CheckDistanceTo(tempPoint));
		}
	}
	//Si llegamos a este punto ha habido un error
	`warn(GetHumanReadableName() @ "Error finding correct ChargePoint when iterating thru all points");
	chosenChargePoint = chargePoints[0];
	return true;

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

function float CheckDistanceTo(Actor other){

	local Vector temp;
	local float tempf;
	temp = Pawn.Location - other.Location;
	if(Pawn(other) != none)
		tempf = VSize(temp) - Pawn.GetCollisionRadius() - Pawn(other).GetCollisionRadius();
	else
		tempf = VSize(temp); 
	return tempf;
}

function CheckAttackNearRange(){
	if(!IsWithinAttackRange(thePlayer)){
		PopState();
	}
}
/**Event called with a Timer in ChasePlayer.
 * When this timer expires the pawn goes to chargeAttack
 */
event AttackTimeFinished(){
	GotoState('FindChargePosition');
}


/**Called when this pawn ends an attack
 * @param playerHurt TRUE if the player has been hurt
 */ 
event NotifyAttackFinished(bool playerHurt){
	if(playerHurt){
		GotoState('FindChargePosition');
		return;
	}else{
		attackCount++;
		if(attackCount >= maxAttackCount){
			GotoState('FindChargePosition');
			return;
		}
	}
	//If out of range, goto ChasePlayer
	CheckAttackNearRange();
}

/**Called when this pawn ends an charge Attack
 * @param playerHurt TRUE if the player has been hurt
 */ 
event NotifyChargeFinished(bool playerHurt){
	
	//Miramos la distancia con el player;
	//Cuanto mas cerca lo tengamos mas probabilidad de ir a MeleeAttack.
	//Si estamos mas lejos que 10 * attackDistanceNear nunca atacamos
	if(FRand() >= CheckDistanceTo(thePlayer) / (10*attackDistanceNear)){		
		GotoState('ChasePlayer');
	}else{
		GotoState('FindChargePosition');
	}
}

event SeePlayer(Pawn SeenPlayer){
		
	if(bAggressive){
		StopLatentExecution();
		thePlayer = BBPawn(SeenPlayer);
		distanceToPlayer = CheckDistanceTo(thePlayer);
		LastPlayerLocation = thePlayer.Location;
		if (distanceToPlayer < perceptionDistance){ 
        	//Worldinfo.Game.Broadcast(self, Pawn.name $ ": I can see you!! (followpath)");
			GotoState('FindChargePosition');
		}		
	}
}

auto state idle{

}

state ChasePlayer{

	ignores SeePlayer,HearNoise;

	//It's here for overwrite the super.BeginState(). We don't want to perform a CheckVisibility in RhinoMiniBoss
	event BeginState(name PreviousStateName){
		Pawn.GotoState('ChasePlayer');
		ChangeAttackType(RAT_Normal);
		SetTimer(maxAttackTime, false, 'AttackTimeFinished');
	}

	event ContinuedState(){
		Pawn.GotoState('ChasePlayer');
	}

	event EndState(name NextStateName){		
		ClearTimer('CheckIndirectReachability');
		ClearTimer('CheckDirectReachability');
		ClearTimer('AttackTimeFinished');
	}

	event PausedState(){
		ClearTimer('CheckIndirectReachability');
		ClearTimer('CheckDirectReachability');
	}
	

Begin:
	if(thePlayer != none){
		Target = thePlayer;
		Pawn.GotoState('ChasePlayer');
	}else{
		GotoState('Idle',,,false);
	}

	while(Pawn != none){

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
					if(Target != none && NavigationHandle.ActorReachable(Target) ){
						MoveToward(Target, Target, attackDistance * attackDistanceFactor);						
					}else{
						`log(self @ "Target:" @ Target.GetHumanReadableName() @ "is reachable but out of NavMesh");
						break;
					}
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
			
				MoveToward(Target,Target,attackDistance * attackDistanceFactor ,false,false);
				FinishRotation();
			
				//and if we're STILL within range (since we have lost range when finishing our latent rotation), then actually attack
				if(IsWithinAttackRange(Target))
				{
					if(AttackType == RAT_Normal)
						PushState('Attacking');
					else if(AttackType == RAT_Charge)
						GotoState('Charging');
				}
			}
		}
		else{ //if we don't have a target, go to idle state
			`log(self @ "ChasePlayer without Target assigned");
			break;
		}
	}
	GotoState('Idle');
}


state Attacking
{
	ignores SeePlayer,HearNoise;
	
	event PushedState(){
		super.PushedState();
		Pawn.GotoState('Attacking');		
		Focus = thePlayer;		
	}
	
	//event PoppedState(){
	//	super.PoppedState();		
	//}

 Begin:
	Pawn.ZeroMovementVariables();
	Pawn.GotoState('Attacking');
	//while(thePlayer.Health > 0)
	//{   
	//	if (!IsWithinAttackRange(thePlayer))
 //       { 
	//		Pawn.GotoState('ChasePlayer');
	//		GotoState('ChasePlayer');
	//		break;
 //       }
	//	Sleep(1);
	//}	
	//GotoState('Idle');
}

state FindChargePosition{

	ignores SeePlayer, HearNoise;

	event BeginState(name PreviousStateName){
		Pawn.GotoState('ChasePlayer');
		//Si devuelve falso, ha habido un error, no hay puntos de carga.
		if(!ChooseChargePoint()){
			GotoState('Idle');
			return;
		}
		ChangeAttackType(RAT_Normal);
		SetTimer(0.20f, true, 'CheckPlayerProximity');
	}

	event ContinuedState(){
		Pawn.GotoState('ChasePlayer');
		ChangeAttackType(RAT_Normal);
		SetTimer(0.20f, true, 'CheckPlayerProximity');
	}

	event EndState(name NextStateName){		
		ClearTimer('CheckPlayerProximity');
	}

	event PausedState(){
		ClearTimer('CheckPlayerProximity');
	}

	event CheckPlayerProximity(){
		if(IsWithinAttackRange(thePlayer)){
			PushState('Attacking');
		}
	}

	
Begin:
	while( Pawn != None && !Pawn.ReachedDestination(chosenChargePoint) ){
			//If path to point exists
			if(GeneratePathToActor(chosenChargePoint)){
				//If Target is directly Reachable
				CurrentTargetIsReachable = NavigationHandle.ActorReachable(chosenChargePoint);
				if(CurrentTargetIsReachable){
					Focus = none;
					if(chosenChargePoint != none)
						MoveToward(chosenChargePoint, none);
					else{
						`warn(self @ "chosenChargePoint is none. Aborting move:" @ chosenChargePoint);
						break;
					}
				}else{  //Actor is NOT directly reachable
					Focus = none;
					//If path exists
					if(NavigationHandle.GetNextMoveLocation(NextMoveLocation, Pawn.GetCollisionRadius())){
						MoveTo(NextMoveLocation,none);
					}else{
						`log(self @ "Can't find next step in path to Charge Point:" @ chosenChargePoint);
						break;
					}
				}
			}else{
				`log(self @ "Can't find path to ChargePoint:" @ chosenChargePoint);
				break;
			}
		}
		Focus = thePlayer;
		FinishRotation();		
		GotoState('Charging');
}

state Charging{

	ignores SeePlayer, HearNoise;


	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		Pawn.GotoState('Charging');
		ChangeAttackType(RAT_Charge);
	}
	
	event EndState(name PreviousStateName){
		super.EndState(PreviousStateName);

		lastChargeVelocity = -1.0;
		ClearTimer('CheckChargeAttackRange');
		ClearTimer('CheckHitWallCollision');
	}

	function CheckChargeAttackRange(){
		if(IsWithinAttackChargeRange(thePlayer)){
			Pawn.GotoState('Charging','Attack');
			ClearTimer('CheckChargeAttackRange');
			GotoState('Charging','Attacking');
		}
	}

	/**Timer programmed each 0.1 to perform a velocity check.
	 * If velocity is lesser tahn 25% of last Check go to Stunned
	 */
	function CheckHitWallCollision(){
		if(VSize(Pawn.Velocity) < lastChargeVelocity * 0.25f){
			lastChargeVelocity = -1.0;
			ClearTimer('CheckHitWallCollision');
			GotoState('Stunned');
		}
		else{
			lastChargeVelocity = VSize(Pawn.Velocity);
		}
	}
	/**Called when our pawn has collided with a blocking player,
	 * return true to prevent Bump() notification on the pawn.
	 * Used here to desactivate HitWallCollision (avoid stunned when bumping Player)
	 * @return TRUE to prevent event Bump() on Pawn
	 */
	function bool NotifyBump(Actor Other, Vector HitNormal){
		super.NotifyBump(Other, HitNormal);
		ClearTimer('CheckHitWallCollision');
		return false;
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
	SetTimer(0.1f, true, 'CheckHitWallCollision');
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
		
		//Hack: Used to avid strange rotation in stunned state
		Pawn.RotationRate = Rotator(vect(0,0,0));
	}

	event EndState(name PreviousStateName){
		super.EndState(PreviousStateName);
		Pawn.RotationRate = default.RotationRate;
	}


}

DefaultProperties
{
	MinHitWall = -0.5f;
	AttackType = RAT_Charge;

	maxAttackCount = 5;
	maxAttackTime = 10;
	
}