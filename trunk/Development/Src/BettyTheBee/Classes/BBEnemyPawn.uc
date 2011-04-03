class BBEnemyPawn extends BBPawn;

//// members for the custom mesh

//var AnimTree defaultAnimTree;
//var array<AnimSet> defaultAnimSet;
//var AnimNodeSequence defaultAnimSeq;
//var PhysicsAsset defaultPhysicsAsset;

var BBControllerAI MyController;

var float Speed;

//var SkeletalMeshComponent MyMesh;
//var bool bplayed;
var Name AnimSetName;
var AnimNodeSequence MyAnimPlayControl;

var () float PerceptionDistance<DisplayName=Perception Distance>;
var () float AttackDistance<DisplayName=Attack Distance>;
var () int AttackDamage<DisplayName=Attack Damage>;
var () bool bAggressive<DisplayName = Is Aggressive?>;

var () array<BBRoutePoint> MyRoutePoints;

defaultproperties
{
    bCollideActors=true
	bPushesRigidBodies=true
	bStatic=False
	bMovable=True

	bAvoidLedges=true
	bStopAtLedges=true

	LedgeCheckThreshold=0.5f	
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetPhysics(PHYS_Walking);	    
}

simulated event Tick(float DeltaTime)
{
	//local BBPawn playerPawn;

	//super.Tick(DeltaTime);
	
	
	////foreach CollidingActors(class'UTPawn', gv, 200) 
	//foreach VisibleCollidingActors(class'BBPawn', playerPawn, AttackDistance)
	//{
	//	if(AttAcking && playerPawn != none)
	//	{
	//		if(playerPawn.Health > 0)
	//		{
	//			Worldinfo.Game.Broadcast(self, "Colliding with player : " @ playerPawn.Name);
	//			playerPawn.Health -= AttackDamage;
	//			playerPawn.IsInPain();
	//		}
	//	}
	//}
}

state ChasePlayer{

}

state Idle{

}

