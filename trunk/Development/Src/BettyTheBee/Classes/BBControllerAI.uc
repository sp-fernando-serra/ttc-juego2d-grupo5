class BBControllerAI extends AIController;

var BBEnemyPawn MyEnemyTestPawn;
var BBPawn thePlayer;


var () array<BBRoutePoint> MyRoutePoints;

var int actual_node;
var int last_node;

var float perceptionDistance;
var float attackDistance;
var int attackDamage;

var float distanceToPlayer;


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
        		Worldinfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": I can see you!!");
				GotoState('Chaseplayer');
			}
		}
    }

Begin:
    Worldinfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": Starting Idle state");
	Pawn.Acceleration = vect(0,0,0);
	MyEnemyTestPawn.GotoState('Idle');

	Sleep(IdleInterval);

	Worldinfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": Going to follow path");
	followingPath = true;
	actual_node = last_node;
	GotoState('FollowPath');

}

state Chaseplayer
{
  Begin:
	
	MyEnemyTestPawn.GotoState('ChasePlayer');
    Pawn.Acceleration = vect(0,0,1);
	
    while (Pawn != none && thePlayer.Health > 0)
    {
		Worldinfo.Game.Broadcast(self, "I can see you!!");
		
		if (ActorReachable(thePlayer))
		{
			distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
			if (distanceToPlayer < attackDistance)
			{
				GotoState('Attacking');
				break;
			}
			else //if(distanceToPlayer < 300)
			{
				MoveToward(thePlayer, thePlayer, 20.0f);
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
				Worldinfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": Moving toward Player");

				distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
				if (distanceToPlayer < 100)
					MoveToward(MoveTarget, thePlayer, 20.0f);
				else
					MoveToward(MoveTarget, MoveTarget, 20.0f);				
			}
			else
			{
				GotoState('Idle');
				break;
			}		
		}

		Sleep(1);
    }
}

state Attacking {
Begin:
	Worldinfo.Game.Broadcast(self, MyEnemyTestPawn.Name $ ": Bad State");
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
        		Worldinfo.Game.Broadcast(self, MyEnemyTestPawn.name $ ": I can see you!!");
				GotoState('Chaseplayer');
			}
		}
    }

 Begin:

	while(followingPath)
	{
		MoveTarget = MyRoutePoints[actual_node];
		
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
