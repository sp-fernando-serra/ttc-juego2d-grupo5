class BBEnemyPawn extends BBPawn placeable;

//// members for the custom mesh
//var SkeletalMesh defaultMesh;
////var MaterialInterface defaultMaterial0;
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

var bool AttAcking;

var () float PerceptionDistance<DisplayName=Perception Distance>;
var () float AttackDistance<DisplayName=Attack Distance>;
var () int AttackDamage<DisplayName=Attack Damage>;

var () array<NavigationPoint> MyNavigationPoints;

defaultproperties
{
    Speed=80
	AnimSetName="ATTACK"
	AttAcking=false

	bCollideActors=true
	bPushesRigidBodies=true
	bStatic=False
	bMovable=True

	bAvoidLedges=true
	bStopAtLedges=true

	LedgeCheckThreshold=0.5f

	Begin Object Name=CollisionCylinder
		CollisionHeight=+44.000000
    end object
	Begin Object class=SkeletalMeshComponent Name=SandboxPawnSkeletalMesh
 		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		//AnimTreeTemplate=AnimTree'SandboxContent.Animations.AT_CH_Human'
		HiddenGame=FALSE 
		HiddenEditor=FALSE
    End Object
    Mesh=SandboxPawnSkeletalMesh
    Components.Add(SandboxPawnSkeletalMesh)
    ControllerClass=class'BettyTheBee.BBAIController'
    //InventoryManagerClass=class'Sandbox.SandboxInventoryManager'
    bJumpCapable=false
    bCanJump=false
    GroundSpeed=200.0 //Making the bot slower than the player
	
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	//if (Controller == none)
	//	SpawnDefaultController();
	SetPhysics(PHYS_Walking);
	if (MyController == none)
	{
		MyController = Spawn(class'BBAIController', self);
		MyController.SetPawn(self);		
	}

    //I am not using this
	//MyAnimPlayControl = AnimNodeSequence(MyMesh.Animations.FindAnimNode('AnimAttack'));
}

function SetAttacking(bool atacar)
{
	AttAcking = atacar;
}



simulated event Tick(float DeltaTime)
{
	local BBPawn playerPawn;

	super.Tick(DeltaTime);
	//MyController.Tick(DeltaTime);

	
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

//simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
//{
//	Mesh.SetSkeletalMesh(defaultMesh);
//	//Mesh.SetMaterial(0,defaultMaterial0);
//	Mesh.SetPhysicsAsset(defaultPhysicsAsset);
//	Mesh.AnimSets=defaultAnimSet;
//	Mesh.SetAnimTreeTemplate(defaultAnimTree);

//}