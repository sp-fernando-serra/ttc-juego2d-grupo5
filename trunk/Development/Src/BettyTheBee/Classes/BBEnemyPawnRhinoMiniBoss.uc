class BBEnemyPawnRhinoMiniBoss extends BBEnemyPawn placeable;

/** Damage done by Charge Attack */
var() int ChargeDamage;

var() float chargeSpeed;
var() float attackChargeDistance;
var() float attackChargeSpeedModifier;

var() float attackDistanceNear;
/** Used for pushing player when hitted by charge attack */
var() Vector attackChargeMomentum;

var class<BBDamageType> myChargeDamageType;

var AnimNodeBlendList animStateList;

var bool bDamageTakenInThisStun;
var bool bDoDamage;

var name chargePrepareAnimName;
var name chargeRunAnimName;
var name chargeAttackAnimName;
var name chargeHitWallAnimName;
var name chargeStunnedAnimName;
var name chargeAwakeAnimName;

/**ParticleSystem used in footsteps*/
var ParticleSystem FootstepPS;

/** Sound for left footstep */
var SoundCue LeftFootStepCue;
/** Sound for right footstep */
var SoundCue RightFootStepCue;

event Tick(float DeltaTime){
	super.Tick(DeltaTime);
	if(bDebug && !isDying() && !isDead()){
		//Red sphere is attackcharge range
		DrawDebugSphere(Location,attackChargeDistance,16,100.0,0.0,0.0,false);
	}
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

/**
 * PlayFootStepSound()
 * called by AnimNotify_Footstep
 *
 * FootDown specifies which foot hit
 */
event PlayFootStepSound(int FootDown){
	local Vector socketLocation;
	local Rotator socketRotation;
	if(FootDown == 0){  //Left Footstep
		PlaySound(LeftFootStepCue);
		Mesh.GetSocketWorldLocationAndRotation('FootRight',socketLocation, socketRotation);
		WorldInfo.MyEmitterPool.SpawnEmitter(FootstepPS, socketLocation);
	}else{              //Right Footstep
		PlaySound(RightFootStepCue);
		Mesh.GetSocketWorldLocationAndRotation('FootLeft',socketLocation, socketRotation);
		WorldInfo.MyEmitterPool.SpawnEmitter(FootstepPS, socketLocation);
	}
	MakeNoise(1.0);
}
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){
	//Do not take damage unless Stunned (overrided in Stunned state)

	//Inform player of failed attack (playanimation)
	if(BBPlayerController(InstigatedBy) != none){
		BBPlayerController(InstigatedBy).NotifyFailedAttack();
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

	simulated event EndState(name NextStateName){
		super.EndState(NextStateName);
		// Discard root motion. So mesh stays locked in place.
		// We need this to properly blend out to another animation
		customAnimSlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Discard,RBA_Discard,RBA_Discard);
		// Tell mesh to stop using root motion
		Mesh.RootMotionMode = RMM_Ignore;

		GroundSpeed = default.GroundSpeed;
		RotationRate = default.RotationRate;

		bDoDamage = false;
	}

	event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp ){
		super.HitWall(HitNormal, Wall, WallComp);
		GotoState('Stunned');
	}
	event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal){
		local Vector tempMomentum;
		super.Bump(Other, OtherComp, HitNormal);
		if(bDoDamage && BBBettyPawn(Other) != none){
			HitNormal.Z = 1.0;
			tempMomentum = attackChargeMomentum * HitNormal;			
			Other.TakeDamage(ChargeDamage, Controller, Location, tempMomentum, myChargeDamageType, , self);
			bDoDamage = false;
		}
	}
	
Begin:
	customAnimSlot.PlayCustomAnim(chargePrepareAnimName,1.0f,0.25,0.25,false,true);
	FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
Running:
	customAnimSlot.PlayCustomAnim(chargeRunAnimName,2.0f,0.25,0.25,true,true);
	bDoDamage = true;
	GroundSpeed = chargeSpeed;
	Controller.GotoState('Charging','Running');	
	Sleep(4.0f);
Attack:
	customAnimSlot.PlayCustomAnim(chargeAttackAnimName,1.5f,0.25,0.25,false,true);
	customAnimSlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Translate,RBA_Translate,RBA_Default);

	Mesh.RootMotionMode = RMM_Accel;	
	Mesh.RootMotionAccelScale.X = attackChargeSpeedModifier;
	Mesh.RootMotionAccelScale.Y = attackChargeSpeedModifier;
	Mesh.RootMotionAccelScale.Z = attackChargeSpeedModifier;

	GroundSpeed = chargeSpeed;
	RotationRate = Rotator(vect(0,0,0));
	FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());

	bDoDamage = false;

	
	Controller.GotoState('ChasePlayer');
	GotoState('ChasePlayer');
}

simulated state Stunned{
	simulated event BeginState(name PreviousStateName){		
		Controller.GotoState('Stunned');
		bDamageTakenInThisStun = false;
		stunnedPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(stunnedPS, Mesh, 'exclamacion', true, , rot(90,0,0));
		customAnimSlot.PlayCustomAnim(chargeHitWallAnimName,1.0f,0.25f,0.0f,false,true);
		customAnimSlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Translate,RBA_Translate,RBA_Default);

		Mesh.RootMotionMode = RMM_Translate;
	}

	simulated event EndState(name NextStateName){
		stunnedPSC.SetActive(false);
		bDamageTakenInThisStun = false;
	}

	event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){
		local PlayerController PC;
		local Controller Killer;
		
		//Take damage because we are stunned only if bDamageTakenInThisStun == false
		if(!bDamageTakenInThisStun){
			Damage = Max(Damage, 0);
			if(Damage > 0){
				playDamaged();
				if(Health > 0){
					Health -= Damage;
				}
				if(Health <= 0){    //Pawn is dead (not stunned like defautl pawns)
					PC = PlayerController(Controller);
					// play force feedback for death
					if (PC != None)
					{
						PC.ClientPlayForceFeedbackWaveform(damageType.default.KilledFFWaveform);
					}
					// pawn died
					Killer = SetKillInstigator(InstigatedBy, DamageType);
					TearOffMomentum = momentum;
					Died(Killer, damageType, HitLocation);
					return;
				}
			}
			bDamageTakenInThisStun = true;
			Controller.StopLatentExecution();
			GotoState('Stunned', 'Awake');
		}
	}

Begin:
	FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
	
	// Discard root motion. So mesh stays locked in place.
	// We need this to properly blend out to another animation
	customAnimSlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Discard,RBA_Discard,RBA_Discard);
	// Tell mesh to stop using root motion
	Mesh.RootMotionMode = RMM_Ignore;

	customAnimSlot.PlayCustomAnim(chargeStunnedAnimName, 1.0f, 0.0f, 0.0f, true, true);
	Sleep(timeStunned);
Awake:
	stunnedPSC.SetActive(false);
	customAnimSlot.PlayCustomAnim(chargeAwakeAnimName, 1.0f, 0.0f, 0.0f, false, true);
	FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());	

	Controller.GotoState('ChasePlayer');
	GotoState('');
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
		CollisionHeight=+105.0  //That's original 70 with DrawScale of 1.5
		CollisionRadius=+97.5   //That's original 65 with DrawScale of 1.5
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

	DrawScale = 1.5;
	FootstepPS = ParticleSystem'Betty_Particles.PSWalkingGround'

	RightFootStepCue=SoundCue'Betty_rhino.Sounds.FxRhinoPaw0_Cue'
	LeftFootStepCue=SoundCue'Betty_rhino.Sounds.FxRhinoPaw1_Cue'

	bJumpCapable=false
    bCanJump=false
    GroundSpeed=80.0 //Making the bot slower than the player

	PerceptionDistance = 2500;
	AttackDistance = 2000;
	AttackDistanceNear = 75;
	AttackDamage = 3;
	ChargeDamage = 3;
	chargeSpeed = 750;
	attackChargeDistance = 500.0f;
	attackChargeSpeedModifier = 1.0f;
	attackChargeMomentum = (X = -1500.0, Y = -1500.0, Z = 1000.0);

	timeStunned = 3.0f;

	myChargeDamageType = class'BBDamageType_RhinoCharge';

	//Name of diferent animations for playing in custom node
	attackAnimName = "Attack";
	dyingAnimName = "Dead";

	chargePrepareAnimName = "charge0_prepare";
	chargeRunAnimName = "charge1_run";
	chargeAttackAnimName = "charge2_attack_move";
	chargeHitWallAnimName = "charge3_stepback";
	chargeStunnedAnimName = "charge4_stun";
	chargeAwakeAnimName = "charge5_awake";

}
