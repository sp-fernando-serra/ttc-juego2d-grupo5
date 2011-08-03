class BBEnemyPawnRhino extends BBEnemyPawn placeable;

/** Damage done by Charge Attack */
var int ChargeDamage;

var AnimNodeBlendList animStateList;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (MyController == none)
	{
		MyController = Spawn(class'BettyTheBee.BBControllerAIRhino');
		MyController.SetPawn(self);		
	}
    
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		//Name of diferent animations for playing in custom node (esta aqui porque en defaultProperties no funciona)
		attackAnimName = 'Attack';
		dyingAnimName = 'Dead';
		animStateList = AnimNodeBlendList(SkelComp.FindAnimNode('listState'));
	}
}

state ChasePlayer{
	simulated event BeginState(name NextStateName){		
		super.BeginState(NextStateName);
		//Going to animations of state 1 (Chase player)
		animStateList.SetActiveChild(1,0.25);
	}

	simulated event EndState(name NextStateName){		
		super.EndState(NextStateName);
		//Going to animations of state 0 (Patrol)
		animStateList.SetActiveChild(0,0.25);
	}
}

state Attacking{

	simulated event doDamage(){
		local Vector CuernoDown, CuernoUp;
		local Vector HitLocation, HitNormal;
		local Actor HitActor;

		//Worldinfo.Game.Broadcast(self, Name $ ": Calculating Attack Collision");

		
		Mesh.GetSocketWorldLocationAndRotation('CuernoDown' , CuernoDown);
		Mesh.GetSocketWorldLocationAndRotation('CuernoUp', CuernoUp);
		HitActor = Trace(HitLocation, HitNormal, CuernoUp, CuernoDown, true);
		
		if(HitActor != none){
			//Worldinfo.Game.Broadcast(self, Name $ ": Hit actor "$HitActor.Name);
			if(HitActor.Class == class'BBBettyPawn'){
				BBBettyPawn(HitActor).TakeDamage(AttackDamage,Controller,HitLocation,vect(0,0,0),MyDamageType,,self);
			}
		}
	}
	
	simulated event BeginState(name NextStateName){
		
		super.BeginState(NextStateName);
		customAnimSlot.PlayCustomAnim(attackAnimName,1.0f,0.25f,0.25f,true);
	}

	simulated event EndState(name NextStateName){
		
		super.EndState(NextStateName);
		customAnimSlot.StopCustomAnim(0.25f);
	}
}


//function isAtacked(){
//PushState('Attacked');
//nodelistAttack.SetActiveChild(4,0.2f);
//}

//state Attacked{


//	event PoppedState(){
//		nodeListAttack.SetActiveChild(1,0.4f);
//	}
//Begin:	
//	FinishAnim(AnimNodeSequence(Mesh.FindAnimNode('Attacked')));
//	PopState();
//}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+70.000000
		CollisionRadius=+65.000000
	End object

	Begin Object class=SkeletalMeshComponent Name=InitialPawnSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
			bAllowAmbientOcclusion=false
		BlockRigidBody=true;
		CollideActors=true;
		BlockZeroExtent=true;
			BlockNonZeroExtent = True
			BlockActors = True

        AnimSets(0)=AnimSet'Betty_rhino.SkModels.rhinoAnimSet'
		AnimTreeTemplate=AnimTree'Betty_rhino.SkModels.rhinoAnimTree'
		SkeletalMesh=SkeletalMesh'Betty_rhino.SkModels.rhino'
		HiddenGame=FALSE 
		HiddenEditor=FALSE
    End Object

	Mesh=InitialPawnSkeletalMesh
    Components.Add(InitialPawnSkeletalMesh)

	bJumpCapable=false
    bCanJump=false
    GroundSpeed=80.0 //Making the bot slower than the player

	PerceptionDistance = 1000;
	AttackDistance = 75;
	//AttackDistanceNear = 70;
	AttackDamage = 3;
	ChargeDamage = 50;

}