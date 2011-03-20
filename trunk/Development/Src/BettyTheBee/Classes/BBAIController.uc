class BBAIController extends AIController;

var BBEnemyPawn MyEnemyTestPawn;
var BBPawn thePlayer;
//var Actor theNoiseMaker;
//var Vector noisePos;

var () array<NavigationPoint> MyNavigationPoints;
var NavigationPoint MyNextNavigationPoint;

var int actual_node;
var int last_node;

var float perceptionDistance;
//var float hearingDistance;
var float attackDistance;
var int attackDamage;

var float distanceToPlayer;
//var float distanceToTargetNodeNearPlayer;

//var Name AnimSetName;

//var bool AttAcking;
var bool followingPath;
//var bool noiseHeard;
//var bool bAggressive;
var Float IdleInterval;

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
	MyNavigationPoints = MyEnemyTestPawn.MyNavigationPoints;
	//bAggressive = MyEnemyTestPawn.bAggressive;
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


state Idle
{

    event SeePlayer(Pawn SeenPlayer)
	{
	    thePlayer = BBPawn(SeenPlayer);
        distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
        if (distanceToPlayer < perceptionDistance)
        { 
        	Worldinfo.Game.Broadcast(self, "I can see you!!");
            GotoState('Chaseplayer');
        }
    }

Begin:
    Worldinfo.Game.Broadcast(self, "!!!!!!!  idle  !!!!!!!!");

	Pawn.Acceleration = vect(0,0,0);
	MyEnemyTestPawn.SetAttacking(false);

	Sleep(IdleInterval);

	//Worldinfo.Game.Broadcast(self, "!!!!!!!  Going to FollowPath  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
	followingPath = true;
	actual_node = last_node;
	GotoState('FollowPath');

}

state Chaseplayer
{
  Begin:
	
	MyEnemyTestPawn.SetAttacking(false);
    Pawn.Acceleration = vect(0,0,1);
	
    while (Pawn != none && thePlayer.Health > 0)
    {
		Worldinfo.Game.Broadcast(self, "I can see you!!");
		
		if (ActorReachable(thePlayer))
		{
			distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
			if (distanceToPlayer < attackDistance)
			{
				GotoState('Attack');
				break;
			}
			else //if(distanceToPlayer < 300)
			{
				MoveToward(thePlayer, thePlayer, 20.0f);
				if(Pawn.ReachedDestination(thePlayer))
				{
					GotoState('Attack');
					break;
				}
			}
		}
		else
		{
			MoveTarget = FindPathToward(thePlayer,,perceptionDistance + (perceptionDistance/2));
			if (MoveTarget != none)
			{
				Worldinfo.Game.Broadcast(self, "Moving toward Player");

				distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
				if (distanceToPlayer < 100)
					MoveToward(MoveTarget, thePlayer, 20.0f);
				else
					MoveToward(MoveTarget, MoveTarget, 20.0f);	
		
				//MoveToward(MoveTarget, MoveTarget);
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

state Attack
{
 Begin:
	Pawn.Acceleration = vect(0,0,0);
	MyEnemyTestPawn.SetAttacking(true);
	while(true && thePlayer.Health > 0)
	{   
		//Worldinfo.Game.Broadcast(self, "Attacking Player");

		distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
        if (distanceToPlayer > attackDistance * 2)
        { 
			MyEnemyTestPawn.SetAttacking(false);
            GotoState('Chaseplayer');
			break;
        }
		Sleep(1);
	}
	MyEnemyTestPawn.SetAttacking(false);
}


auto state FollowPath
{
	event SeePlayer(Pawn SeenPlayer)
	{
	    thePlayer = BBBettyPawn(SeenPlayer);
        distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
        if (distanceToPlayer < perceptionDistance)
        { 
        	Worldinfo.Game.Broadcast(self, "I can see you!!");
			followingPath = false;
            GotoState('Chaseplayer');
        }
    }

 Begin:

	while(followingPath)
	{
		MoveTarget = MyNavigationPoints[actual_node];
		
		if(Pawn.ReachedDestination(MoveTarget))
		{
			WorldInfo.Game.Broadcast(self, "Navigation point Reached");
			actual_node++;
			
			if (actual_node >= MyNavigationPoints.Length)
			{
				actual_node = 0;
			}
			last_node = actual_node;
			
			MoveTarget = MyNavigationPoints[actual_node];
		}	

		if (ActorReachable(MoveTarget))
		{
			//distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
			//if (distanceToPlayer < perceptionDistance / 3)
			//	MoveToward(MoveTarget, MyNavigationPoints[actual_node + 1]);	
			//else
				MoveToward(MoveTarget, MoveTarget);	
		}
		else
		{
			MoveTarget = FindPathToward(MyNavigationPoints[actual_node]);
			if (MoveTarget != none)
			{
				
				//SetRotation(RInterpTo(Rotation,Rotator(MoveTarget.Location),Delta,90000,true));
				
				MoveToward(MoveTarget, MoveTarget);
			}
		}

		Sleep(1);
	}
}
