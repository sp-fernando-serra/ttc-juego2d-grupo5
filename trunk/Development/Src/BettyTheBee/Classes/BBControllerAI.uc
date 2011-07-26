class BBControllerAI extends AIController;

var BBEnemyPawn MyEnemyTestPawn;
var BBPawn thePlayer;


var array<BBRoutePoint> MyRoutePoints;
var int actual_node;
var int last_node;

var float perceptionDistance;
var float attackDistance;
var int attackDamage;

var float distanceToPlayer;
var Vector lastLocation;


var bool followingPath;
var Float IdleInterval;
var bool bAggressive;

defaultproperties
{
	actual_node = 0
	last_node = 0
	followingPath = true
	IdleInterval = 2.5f

}

function SetPawn(BBEnemyPawn NewPawn)
{
	MyEnemyTestPawn = NewPawn;
	
	Possess(MyEnemyTestPawn, false);
	MyRoutePoints = MyEnemyTestPawn.MyRoutePoints;
	bAggressive = MyEnemyTestPawn.bAggressive;
	AttackDamage = MyEnemyTestPawn.AttackDamage;
	AttackDistance = MyEnemyTestPawn.AttackDistance;
	PerceptionDistance = MyEnemyTestPawn.PerceptionDistance;
	
}

function Possess(Pawn aPawn, bool bVehicleTransition)
{
    if (aPawn.bDeleteMe)
	{
		`Warn(self @ GetHumanReadableName() @ "attempted to possess destroyed Pawn" @ aPawn);
		 ScriptTrace();
		 GotoState('Dead');
    }
	else
	{
		Super.Possess(aPawn, bVehicleTransition);
		Pawn.SetMovementPhysics();
		
		if (Pawn.Physics == PHYS_Walking)
		{
			Pawn.SetPhysics(PHYS_Falling);
		}
    }
}


auto state Idle
{

    event SeePlayer(Pawn SeenPlayer)
	{
		if(bAggressive){
			thePlayer = BBPawn(SeenPlayer);
			distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
			if (distanceToPlayer < perceptionDistance)
			{ 
        		`Log(MyEnemyTestPawn.name@": I can see you!!");
				BBEnemyPawn(Instigator).playParticlesExclamacion();
				GotoState('Chaseplayer');
			}
		}
    }

	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		Enemy = none;
	}

Begin:
    //`log(MyEnemyTestPawn.name @ ": Starting Idle state");
	Pawn.Acceleration = vect(0,0,0);
	MyEnemyTestPawn.GotoState('Idle');

	Sleep(IdleInterval);
	
	if(MyRoutePoints.Length>0){
		//`log(MyEnemyTestPawn.name @ ": Going to follow path");
		followingPath = true;
		actual_node = last_node;
		GotoState('FollowPath');
	}
	//goto 'Begin';

}

state Chaseplayer
{
  Begin:
	
	MyEnemyTestPawn.GotoState('Chaseplayer');
    Pawn.Acceleration = vect(0,0,1);
	
    while (Pawn != none && thePlayer.Health > 0)
	
    {
		//Worldinfo.Game.Broadcast(self, "I can see you!!(chasing)");
		//`log(MyEnemyTestPawn.name @ ": I can see you!!(chasing)");
		
    	
		
		if (ActorReachable(thePlayer)) //si es alcanzable en linea recta
		{
			distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
			if (distanceToPlayer < attackDistance) //si está cerca, atacar
			{
				GotoState('Attacking'); 
				break;
			}
			else //if(distanceToPlayer < 300) // si está lejos, moverse hacia el, y al llegar, atacar
			{
				//Ponemos un factor para que no se quede justo en el rango sino que se acerque un poco
				MoveToward(thePlayer, thePlayer, AttackDistance-25);
				if(Pawn.ReachedDestination(thePlayer))
				{
					GotoState('Attacking');
					break;
				}
			}
		}
		else
		{
			MoveTarget = FindPathToward(thePlayer,,perceptionDistance + (perceptionDistance/2));
			if (MoveTarget != none)
			{
				//Worldinfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": Moving toward Player (findpathtoward)");
				`log(MyEnemyTestPawn.name @ ": Moving toward waypoint (findpathtoward)");

				distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
				if (distanceToPlayer < 100) //if near, move looking to the player
					MoveToward(MoveTarget, thePlayer, 20.0f);
				else //if far, move looking to the destination
					MoveToward(MoveTarget, MoveTarget, 20.0f);				
			}
			else // can't reach player?
			{
				`log(MyEnemyTestPawn.name @ ": going to lastlocation (in chaseplayer)");
				//GotoState('Idle');
				lastLocation=thePlayer.Location;
				GotoState('GoToLastPlayerLocation');
				break;
			}		
		}
		
		Sleep(1);
    }
	GotoState('GoToLastPlayerLocation');
}

state Attacking {

}

state FollowPath
{
	event SeePlayer(Pawn SeenPlayer)
	{
	    if(bAggressive){
			thePlayer = BBPawn(SeenPlayer);
			distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
			if (distanceToPlayer < perceptionDistance)
			{ 
        		Worldinfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": I can see you!! (followpath)");
				GotoState('Chaseplayer');
			}
		}
    }

 Begin:

	while(followingPath)
	{
		MoveTarget = MyRoutePoints[actual_node];
		WorldInfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": Move Target is: " $ MoveTarget.Name);
		if(Pawn.ReachedDestination(MoveTarget))
		{
			WorldInfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": Navigation point Reached");
			
			actual_node++;
			
			if (actual_node >= MyRoutePoints.Length)
			{
				actual_node = 0;
			}
			
			last_node = actual_node;
			
			MoveTarget = MyRoutePoints[actual_node];
		}	
		if (ActorReachable(MoveTarget))
		{
			MoveToward(MoveTarget, MoveTarget);	
		}
		else
		{
			MoveTarget = FindPathToward(MyRoutePoints[actual_node]);
			if (MoveTarget != none)
			{
				MoveToward(MoveTarget, MoveTarget);
			}
		}

		Sleep(1);
	}
}

state GoToLastPlayerLocation
{
	event SeePlayer(Pawn SeenPlayer)
	{
		`log(MyEnemyTestPawn.name @ ": seenplayer event (in gotolastlocation)");

		if(bAggressive){
			thePlayer = BBPawn(SeenPlayer);
			distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
			if (distanceToPlayer < perceptionDistance)
			{ 
        		`Log(MyEnemyTestPawn.name@": I can see you!! (gotolastlocation)");
				BBEnemyPawn(Instigator).playParticlesExclamacion();
				GotoState('Chaseplayer');
			}
		}
    }

	//event BeginState(name PreviousStateName){
	//	super.BeginState(PreviousStateName);
	//	thePlayer = none;
	//}

Begin:
	// `log(MyEnemyTestPawn.name @ ": Starting Idle state");
	Pawn.Acceleration = vect(0,0,1);
	//MyEnemyTestPawn.GotoState('Idle');

	while (Pawn == none){
		`log(MyEnemyTestPawn.name @ ": Moving to lastPlayerLocation");
		FindPathTo(lastLocation);
		`log(MyEnemyTestPawn.name @ ": Moved to lastPlayerLocation");
	}

	
}

