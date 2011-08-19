class BBEnemyPawnRhinoMiniBoss extends BBEnemyPawn placeable;

/** Damage done by Charge Attack */
var() int ChargeDamage;

var() float chargeSpeed;
var() float attackChargeDistance;
var() float attackChargeSpeedModifier;

var() float attackDistanceNear;

var AnimNodeBlendList animStateList;

var name chargePrepareAnimName;
var name chargeRunAnimName;
var name chargeAttackAnimName;

event Tick(float DeltaTime){
	local Color col;

	super.Tick(DeltaTime);
	//if(bDebug){
		col.B=0.0f;
		col.G=0.0f;
		col.R=255.0f;
		col.A=255.0f;

		DrawDebugSphere(Location,attackChargeDistance,16,col.R,col.G,col.B,false);
	//}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (MyController == none)
	{
		MyController = Spawn(class'BettyTheBee.BBControllerAIRhinoMiniBoss');
		MyController.SetPawn(self);
	}
    
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		
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

state Charging{
	
Begin:
	customAnimSlot.PlayCustomAnim(chargePrepareAnimName,1.0f,0.25,0.25,false,true);
	FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
Running:
	customAnimSlot.PlayCustomAnim(chargeRunAnimName,2.0f,0.25,0.25,true,true);
	GroundSpeed = chargeSpeed;
	Controller.GotoState('Charging','Running');	
	Sleep(4.0f);
Attack:
	customAnimSlot.PlayCustomAnim(chargeAttackAnimName,1.5f,0.25,0.25,false,true);
	customAnimSlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Discard,RBA_Discard,RBA_Discard);
	//Mesh.RootMotionMode = RMM_Accel;
	//Mesh.RootMotionAccelScale.X = attackChargeSpeedModifier;
	//Mesh.RootMotionAccelScale.Y = attackChargeSpeedModifier;
	//Mesh.RootMotionAccelScale.Z = attackChargeSpeedModifier;
	GroundSpeed = chargeSpeed;
	FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());

	// Discard root motion. So mesh stays locked in place.
	// We need this to properly blend out to another animation
	//customAnimSlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Discard,RBA_Discard,RBA_Discard);
	// Tell mesh to stop using root motion
	//Mesh.RootMotionMode = RMM_Ignore;

	GroundSpeed = default.GroundSpeed;	
	Controller.GotoState('ChasePlayer');
	GotoState('ChasePlayer');
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

	PerceptionDistance = 2500;
	AttackDistance = 2000;
	AttackDistanceNear = 75;
	AttackDamage = 3;
	ChargeDamage = 3;
	chargeSpeed = 750;
	attackChargeDistance = 600.0f;
	attackChargeSpeedModifier = 1.0f;

	//Name of diferent animations for playing in custom node
	attackAnimName = "Attack";
	dyingAnimName = "Dead";

	chargePrepareAnimName = "charge0_prepare";
	chargeRunAnimName = "charge1_run";
	chargeAttackAnimName = "charge2_attack_move";

}
