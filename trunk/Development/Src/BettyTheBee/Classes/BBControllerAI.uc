class BBControllerAI extends AIController;

var BBPawn thePlayer;


var float perceptionDistance;
var float attackDistance;
/** Float between 0.0 and 1.0 used to determine the percentage of attackDistance to start attacking.
 *  Used to move Enemy closer than AttackDistance when following the player
 */
var float attackDistanceFactor;
var int attackDamage;

var float distanceToPlayer;
var Vector lastLocation;
/** Bool to know if this pawn has seen/heard the player or other pawn alerted this of player's presence */
var bool bAlertedByOtherPawn;
/** Radius to determine wich pawns alert of Player presence */
var float alertRadius;


var bool followingPath;
var Float IdleInterval;
var bool bAggressive;

/** Enemy's current target */
var Actor Target;
/** Whether the current target is directly reachable, last we checked */
var bool CurrentTargetIsReachable;
/** Next point while in a path generated by NavMesh */
var Vector NextMoveLocation;
/** Vector with las player location */
var Vector LastPlayerLocation;
/** Vector with the start location of the pawn.
 *  Used to return here if player has been lost
 */
var Vector StartLocation;
/** Rotator with the start rotation of the pawn.
 *  Used to return here if player has been lost
 */
var Rotator StartRotation;

function Possess(Pawn aPawn, bool bVehicleTransition){
	local BBEnemyPawn NewPawn;

	super.Possess(aPawn, bVehicleTransition);
	NewPawn = BBEnemyPawn(aPawn);

	if(NewPawn != none){
		ScriptedRoute = NewPawn.MyRoutePoints;
		bAggressive = NewPawn.bAggressive;
		AttackDamage = NewPawn.AttackDamage;
		AttackDistance = NewPawn.AttackDistance;
		attackDistanceFactor = NewPawn.AttackDistanceFactor;
		PerceptionDistance = NewPawn.PerceptionDistance;
		alertRadius = NewPawn.alertRadius;

		StartLocation = NewPawn.Location;
		StartRotation = NewPawn.Rotation;
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
	if(!bAggressive){
		GotoState('Idle');
	}
}

function bool IsWithinLineOfSight(Actor other){
	local Vector hitLoc, hitNorm;
	return Trace(hitLoc,hitNorm,other.Location,Pawn.Location,false) == none;
}

/** Checks whether an Actor -- usually our Target -- is within our immediate attack range. */
function bool IsWithinAttackRange(Actor other){

	local Vector temp;
	local float tempf;
	temp = Pawn.Location - other.Location;
	tempf = VSize(temp) - Pawn.GetCollisionRadius() - Pawn(other).GetCollisionRadius();
	return tempf < attackDistance;
	//local Vector ClosestPoint;
	//local Vector PawnLocation,BoxExtent,ClosestPointOnBox,ClosestPointOnPrimitive;

	//if(other == none)
	//	return false;

	////if we and the target haven't moved at all, just return the last closest point that we calculated (so to avoid the expensive closest-point-on-primitive check when we're say, 
	//// simply standing still melee-attacking the target
	//if(Pawn.Location == LastCheckAttackRangePawnLocation && other == LastCheckAttackRangeTarget && other.Location == LastCheckAttackRangeTargetLocation)
	//	ClosestPoint = LastCheckAttackRangeClosestPoint;
	//else
	//{
	//	//so either we or the target have moved, start off just using the target's direct location as the closest point on it
	//	ClosestPoint = other.Location;

	//	if(other.CollisionComponent != none)
	//	{
	//		// now if we're within the target bounds, actually calculate the closest point on its collision primitive, so that we still get appropriately close to
	//		// targerts with skewed shapes or rotations.
	//		if(VSize(other.Location - Pawn.Location) < other.CollisionComponent.Bounds.SphereRadius + Pawn.CollisionComponent.Bounds.SphereRadius)
	//		{
	//			PawnLocation = Pawn.Location;
	//			BoxExtent = other.CollisionComponent.Bounds.BoxExtent;
	//			//warning: can be slow depending on collision complexity. minimize the usage of this function!
	//			if(other.CollisionComponent.ClosestPointOnComponentToPoint(PawnLocation,BoxExtent,ClosestPointOnBox,ClosestPointOnPrimitive) != GJK_Intersect)
	//				ClosestPoint = ClosestPointOnPrimitive;
	//		}
	//	}

	//	//since we calculated the closest point, store these values in case we don't have to do it again next time
	//	LastCheckAttackRangeClosestPoint = ClosestPoint;
	//	LastCheckAttackRangeTargetLocation = other.Location;
	//	LastCheckAttackRangeTarget = other;
	//	LastCheckAttackRangePawnLocation = Pawn.Location;
	//}
	
	////simply return the distance to the closest point, minus an attack-range offset specified by the target, and see if that's within our attack range
	//return VSize(ClosestPoint - Pawn.Location) < attackDistance;
}

/** this is called every 0.3 seconds when doing an indirect (pathfinding) move-to-target, to check if the target has dynamically come into view 
 *  and thus stop latent movement activity, so that we can start a Direct move-to. 
 */
function CheckIndirectReachability(){	

		//if the target has become directly reachable, cancel our pathfinding.
		if(NavActorReachable(Target))
		{
			CurrentTargetIsReachable = true;
			//`log("Target has come into direct view, stopping latent movement!");
			StopLatentExecution();
		}
}

/** this is called every 0.3 seconds when doing an direct (non-pathfinding) move-to-target, to check if the target has dynamically gone out of view 
	*  and thus stop latent movement activity, so that we can start a pathfinding move-to. */
function CheckDirectReachability()
{
		//if the target is no longer directly reachable...
		if(!NavActorReachable(Target))
		{
			CurrentTargetIsReachable = false;
			//`log("Target has left direct view, stopping latent movement!");
			StopLatentExecution();
		}
		//otherwise if the target is still in direct view, and if we've got into attack range, 
		//then go ahead and cancel the move anyway because we're gonna get ready to ATTACK
		else if(IsWithinAttackRange(Target)) 
		{
			//`log("Target is within attack range, stopping latent movement!");
			StopLatentExecution();
		}
}
/** epic ===============================================
* ::NotifyKilled
*
* Notification from game that a pawn has been killed.
*
* =====================================================
*/
function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn, class<DamageType> damageTyp){
	super.NotifyKilled(Killer, Killed, KilledPawn, damageTyp);

	if(BBBettyPawn(KilledPawn) != none){
		GotoState('Idle');
	}
}

event SeePlayer(Pawn SeenPlayer){
	local BBEnemyPawn pawnToAlert;
	
	if(bAggressive){
		StopLatentExecution();
		thePlayer = BBPawn(SeenPlayer);
		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
		LastPlayerLocation = thePlayer.Location;
		if (distanceToPlayer < perceptionDistance)
		{ 
        	//Worldinfo.Game.Broadcast(self, Pawn.name $ ": I can see you!! (followpath)");
			GotoState('Chaseplayer');
		}
		if(!bAlertedByOtherPawn){
			foreach VisibleActors(class'BBEnemyPawn', pawnToAlert, alertRadius, Pawn.Location){
				BBControllerAI(pawnToAlert.Controller).alertPawnPresence(SeenPlayer);
			}
		}
		bAlertedByOtherPawn = false;
	}
}


event HearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType ){
	if(BBBettyPawn(NoiseMaker) != none){
		SeePlayer(BBBettyPawn(NoiseMaker));
	}
}

function alertPawnPresence(Pawn SeenPlayer){
	bAlertedByOtherPawn = true;
	SeePlayer(SeenPlayer);
}


auto state Idle{
	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		if(Pawn != none){
			BBEnemyPawn(Pawn).customAnimSlot.StopCustomAnim(0.15f);
			Pawn.GotoState('');
		}
		Enemy = none;
	}

Begin:
	Pawn.ZeroMovementVariables();
	
	if(ScriptedRoute != none){
		//`log(Pawn.name @ ": Going to follow path");
		GotoState('ScriptedRouteMove');
	}else if(StartLocation != Pawn.Location){
		while( Pawn != None && !Pawn.ReachedPoint(StartLocation,none) ){
			//If path to point exists
			if(GeneratePathToLocation(StartLocation)){
				//If Target is directly Reachable
				CurrentTargetIsReachable = NavigationHandle.PointReachable(StartLocation);
				if(CurrentTargetIsReachable){
					Focus = none;
					if(!IsZero(StartLocation))
						MoveTo(StartLocation, none);
				}else{  //Actor is NOT directly reachable
					Focus = none;
					//If path exists
					if(NavigationHandle.GetNextMoveLocation(NextMoveLocation, Pawn.GetCollisionRadius())){
						MoveTo(NextMoveLocation,none);
					}else{
						`log(self @ "Can't find next step in path to Las player location:" @ LastPlayerLocation);
						break;
					}
				}
			}else{
				`log(self @ "Can't find path to last player location:" @ StartLocation);
				break;
			}
		}
		Pawn.SetDesiredRotation(StartRotation, false, false, -1.0f ,true);
		FinishRotation();
		SetFocalPoint(vect(0,0,0));
			
	}
	//Esperamos 2 segundos antes de volver a comprobar si podemos llegar a la start location
	Sleep(2.0f);
	goto 'Begin';

}

state Chaseplayer{

	ignores SeePlayer, HearNoise;

	simulated function CheckVisibility(){
		if(Pawn(Target) == none){
			StopLatentExecution();
			Target = none;
			GotoState('Idle');
		}else if(!CanSee(Pawn(Target))){
			StopLatentExecution();
			Target = none;
			GotoState('GoToLastPlayerLocation',,,true);
		}else{
			LastPlayerLocation = Target.Location;
		}
		
	}

	event EndState(name NextStateName)
	{
		super.EndState(NextStateName);
		ClearTimer('CheckIndirectReachability');
		ClearTimer('CheckDirectReachability');
		ClearTimer('CheckVisibility');
	}
	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		if(PreviousStateName != 'Attacking')
			BBEnemyPawn(Pawn).playParticlesExclamacion();
		SetTimer(0.5,true,'CheckVisibility');
	}

	//event PoppedState(){
	//	super.PoppedState();
	//	ClearTimer('CheckIndirectReachability');
	//	ClearTimer('CheckDirectReachability');
	//	ClearTimer('CheckVisibility');
	//}

	//event PushedState(){
	//	super.PushedState();
	//	SetTimer(0.5,true,'CheckVisibility');
	//}

	//event PausedState(){
	//	super.PoppedState();
	//	ClearTimer('CheckIndirectReachability');
	//	ClearTimer('CheckDirectReachability');
	//	ClearTimer('CheckVisibility');
	//}

	//event ContinuedState(){
	//	super.PushedState();
	//	SetTimer(0.5,true,'CheckVisibility');
	//}

Begin:

	if(thePlayer != none){
		Target = thePlayer;
		Pawn.GotoState('');
		SetTimer(0.5,true,'CheckVisibility');
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
						`log(self @ "Can't find next step in path to chase" @ Target.GetHumanReadableName() @ "at" @ NextMoveLocation);
						break;
					}
				}
			}else if(!IsWithinAttackRange(Target)){ //Si no estamos en attack range y no hemos encontrado ruta (si la encuentra entra arriba y no aqui)
				`log(self @ "Can't find path to chase" @ Target.GetHumanReadableName());
				break;
			}
			//finished or cancelled our movements, so go ahead and clear these timers
			ClearTimer('CheckIndirectReachability');
			ClearTimer('CheckDirectReachability');

			//if the target is now directly reachable AND within line of sight, then let's attack baby attack!
			if(IsWithinAttackRange(Target)){
				MoveToward(Target,Target,attackDistance * attackDistanceFactor ,false,false);
				FinishRotation();			

				//and if we're STILL within range (since we have lost range when finishing our latent rotation), then actually attack
				if(IsWithinAttackRange(Target)){
					GotoState('Attacking');
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

state Attacking {

}

state GoToLastPlayerLocation{

	event EndState(Name NextStateName){
		super.EndState(NextStateName);
		Pawn.PeripheralVision = Pawn.default.PeripheralVision;
		BBEnemyPawn(Pawn).StopSearchingAnim();
	}

Begin:

	while( Pawn != None && !Pawn.ReachedPoint(LastPlayerLocation,none) ){
		//If path to point exists
		if(GeneratePathToLocation(LastPlayerLocation)){
			//If Target is directly Reachable
			CurrentTargetIsReachable = NavigationHandle.PointReachable(LastPlayerLocation);
			if(CurrentTargetIsReachable){
				Focus = none;
				if(!IsZero(LastPlayerLocation))
					MoveTo(LastPlayerLocation, none, 40.0); //No vamos exactamente al punto sino a 40 UU de distancia, para evitar que dos pawn intenten ir a la misma location
			}else{  //Actor is NOT directly reachable
				Focus = none;
				//If path exists
				if(NavigationHandle.GetNextMoveLocation(NextMoveLocation, Pawn.GetCollisionRadius())){
					MoveTo(NextMoveLocation,none);
				}else{
					`log(self @ "Can't find next step in path to Last player location:" @ LastPlayerLocation);
					break;
				}
			}
		}else{
			`log(self @ "Can't find path to last player location:" @ LastPlayerLocation);
			break;
		}
	}
	//Vision of 180�
	Pawn.PeripheralVision = 0.0f;
	BBEnemyPawn(Pawn).PlaySearchingAnim();
	Sleep(3.0f);

	GotoState('Idle',,,true);

}

state Stunned{
	ignores SeePlayer, HearNoise;

	simulated event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		StopLatentExecution();
		Focus = none;
		Pawn.ZeroMovementVariables();
		Pawn.GotoState('Stunned');
	}
}


/**
 * Simple scripted movement state, attempts to pathfind to ScriptedMoveTarget and
 * returns execution to previous state upon either success/failure.
 */
state ScriptedMove
{	
	event PoppedState()
	{
		if (ScriptedRoute == None)
		{
			// if we still have the move target, then finish the latent move
			// otherwise consider it aborted
			ClearLatentAction(class'SeqAct_AIMoveToActor', (ScriptedMoveTarget == None));
		}
		// and clear the scripted move target
		ScriptedMoveTarget = None;
	}

	event PushedState()
	{
		if (Pawn != None)
		{
			// make sure the pawn physics are initialized
			Pawn.SetMovementPhysics();
		}
	}
	Begin:
    // while we have a valid pawn and move target, and
    // we haven't reached the target yet

    while( Pawn != None && ScriptedMoveTarget != None && !Pawn.ReachedDestination(ScriptedMoveTarget) )
    {
      if( GeneratePathToActor(ScriptedMoveTarget) )
      {
        //NavigationHandle.DrawPathCache(,TRUE);

        // check to see if it is directly reachable
        if( NavigationHandle.ActorReachable( ScriptedMoveTarget ) )
        {
          // then move directly to the actor
          MoveToward( ScriptedMoveTarget, ScriptedFocus );
        }
        else
        {
          // move to the first node on the path
          if( NavigationHandle.GetNextMoveLocation( NextMoveLocation, Pawn.GetCollisionRadius()) )
          {
            //DrawDebugCoordinateSystem(NextMoveLocation, rot(0,0,0),25.f,TRUE);
            MoveTo( NextMoveLocation, ScriptedFocus );
          }
          else
          {
            //give up because the nav mesh did not have anything for you in the path
            `warn("NavigationHandle.GetNextMoveLocation failed to find a destination for to"@ScriptedMoveTarget);
            ScriptedMoveTarget = None;
            break;
          }
        }
      }
      else
      {
        //give up because the nav mesh failed to find a path
        `warn("FindNavMeshPath failed to find a path to"@ScriptedMoveTarget);
        ScriptedMoveTarget = None;
      } 
    }  

    // return to the previous state
    PopState();
}

/** scripted route movement state, pushes ScriptedMove for each point along the route */
state ScriptedRouteMove
{
	event PoppedState()
	{
		// if we still have the move target, then finish the latent move
		// otherwise consider it aborted
		ClearLatentAction(class'SeqAct_AIMoveToActor', (ScriptedRoute == None));
		//ScriptedRoute = None;
	}

Begin:
	while (Pawn != None && ScriptedRoute != None && ScriptedRouteIndex < ScriptedRoute.RouteList.length && ScriptedRouteIndex >= 0)
	{
		ScriptedMoveTarget = ScriptedRoute.RouteList[ScriptedRouteIndex].Actor;
		if (ScriptedMoveTarget != None)
		{
			PushState('ScriptedMove');
		}
		if (Pawn != None && Pawn.ReachedDestination(ScriptedRoute.RouteList[ScriptedRouteIndex].Actor))
		{
			if (bReverseScriptedRoute)
			{
				ScriptedRouteIndex--;
			}
			else
			{
				ScriptedRouteIndex++;
			}
		}
		else
		{
			`warn("Aborting scripted route");
			//ScriptedRoute = None;
			GotoState('Idle');
		}
	}

	if (Pawn != None && ScriptedRoute != None && ScriptedRoute.RouteList.length > 0)
	{
		switch (ScriptedRoute.RouteType)
		{
			case ERT_Linear:
				GotoState('Idle');
				break;
			case ERT_Loop:
				bReverseScriptedRoute = !bReverseScriptedRoute;
				// advance index by one to get back into valid range
				if (bReverseScriptedRoute)
				{
					ScriptedRouteIndex--;
				}
				else
				{
					ScriptedRouteIndex++;
				}
				Goto('Begin');
				break;
			case ERT_Circle:
				ScriptedRouteIndex = 0;
				Goto('Begin');
				break;
			default:
				`warn("Unknown route type");
				//ScriptedRoute = None;
				GotoState('Idle');
				break;
		}
	}
	else
	{
		//ScriptedRoute = None;
		GotoState('Idle');
	}

	// should never get here
	`warn("Reached end of state execution");
	//ScriptedRoute = None;
	GotoState('Idle');
}

function bool NavActorReachable(Actor a)
{
	if ( NavigationHandle == None )
		InitNavigationHandle();

	return NavigationHandle.ActorReachable(a);
}

function bool NavPointReachable(Vector a)
{
	if ( NavigationHandle == None )
		InitNavigationHandle();

	return NavigationHandle.PointReachable(a);
}

/** Uses our NavigationHandle to find a path to Goal. Use GetNextMoveLocation() to obtain the next step in the path
 *  @param Goal Actor to use as Destination
 *  @param WithinDistance Only search Goal in this given radius
 *  @param bAllowPartialPath Should keep track of cheapest path even if don't reach goal
 *  @return true if a path has been found
 */
event bool GeneratePathToActor( Actor Goal, optional float WithinDistance, optional bool bAllowPartialPath )
{
	// Clear cache and constraints (ignore recycling for the moment)
  NavigationHandle.PathConstraintList = none;
  NavigationHandle.PathGoalList = none;

  // Create constraints
  class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, Goal );
  class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Goal );

  // Find path
  return NavigationHandle.FindPath();
}

/** Uses our NavigationHandle to find a path to Goal. Use GetNextMoveLocation() to obtain the next step in the path
 *  @param Goal Point to use as Destination
 *  @param WithinDistance Only search Goal in this given radius
 *  @param bAllowPartialPath Should keep track of cheapest path even if don't reach goal
 *  @return true if a path has been found
 */
event bool GeneratePathToLocation( Vector Goal, optional float WithinDistance, optional bool bAllowPartialPath )
{
	// Clear cache and constraints (ignore recycling for the moment)
  NavigationHandle.PathConstraintList = none;
  NavigationHandle.PathGoalList = none;

  // Create constraints
  class'NavMeshPath_Toward'.static.TowardPoint( NavigationHandle, Goal );
  class'NavMeshGoal_At'.static.AtLocation( NavigationHandle, Goal );

  // Find path
  return NavigationHandle.FindPath();
}


defaultproperties
{
	NavigationHandleClass=class'NavigationHandle'

	//actual_node = 0
	//last_node = 0
	followingPath = true
	IdleInterval = 2.5f

}
