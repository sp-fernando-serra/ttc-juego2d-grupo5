class BBEnemyPawn extends BBPawn placeable;

//// members for the custom mesh

//var AnimTree defaultAnimTree;
//var array<AnimSet> defaultAnimSet;
//var AnimNodeSequence defaultAnimSeq;
//var PhysicsAsset defaultPhysicsAsset;

var BBAIController MyController;

var float Speed;

//var SkeletalMeshComponent MyMesh;
//var bool bplayed;
var Name AnimSetName;
var AnimNodeSequence MyAnimPlayControl;

var bool Attacking;

var () float PerceptionDistance<DisplayName=Perception Distance>;
var () float AttackDistance<DisplayName=Attack Distance>;
var () int AttackDamage<DisplayName=Attack Damage>;
var () bool bAggressive<DisplayName = Is Aggressive?>;

var () array<BBRoutePoint> MyRoutePoints;

defaultproperties
{
    Attacking=false

	bCollideActors=true
	bPushesRigidBodies=true
	bStatic=False
	bMovable=True

	bAvoidLedges=true
	bStopAtLedges=true

	LedgeCheckThreshold=0.5f

	//Setting up the light environment
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+20.000000
    end object
	Begin Object class=SkeletalMeshComponent Name=InitialPawnSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
		BlockRigidBody=true;
		CollideActors=true;
		BlockZeroExtent=true;

 		AnimSets(0)=AnimSet'Betty_ant.SkModels.AntAnimSet'
		AnimTreeTemplate=AnimTree'Betty_ant.SkModels.AntAnimTree'
		SkeletalMesh=SkeletalMesh'Betty_ant.SkModels.Ant'
		HiddenGame=FALSE 
		HiddenEditor=FALSE
    End Object
    Mesh=InitialPawnSkeletalMesh
    Components.Add(InitialPawnSkeletalMesh)
  //  ControllerClass=class'BettyTheBee.BBAIController'
    
    bJumpCapable=false
    bCanJump=false
    GroundSpeed=200.0 //Making the bot slower than the player
	
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetPhysics(PHYS_Walking);
	if (MyController == none)
	{
		MyController = Spawn(class'BBAIController', self);
		MyController.SetPawn(self);		
	}
    
}

function SetAttacking(bool atacar)
{
	Attacking = atacar;
}



simulated event Tick(float DeltaTime)
{
	local BBPawn playerPawn;

	super.Tick(DeltaTime);
	
	
	//foreach CollidingActors(class'UTPawn', gv, 200) 
	foreach VisibleCollidingActors(class'BBPawn', playerPawn, AttackDistance)
	{
		if(AttAcking && playerPawn != none)
		{
			if(playerPawn.Health > 0)
			{
				Worldinfo.Game.Broadcast(self, "Colliding with player : " @ playerPawn.Name);
				playerPawn.Health -= AttackDamage;
				playerPawn.IsInPain();
			}
		}
	}
}

