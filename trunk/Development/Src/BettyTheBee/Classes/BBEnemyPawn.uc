class BBEnemyPawn extends BBPawn
	classGroup(BBActor);

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

	bAggressive = true;

}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SightRadius = PerceptionDistance;
	SetPhysics(PHYS_Walking);	    
}


state ChasePlayer{

}

state Idle{

}

