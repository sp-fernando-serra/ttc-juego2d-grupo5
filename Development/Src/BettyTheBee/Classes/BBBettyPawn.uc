class BBBettyPawn extends BBPawn;

var int itemsMiel;//contador de items 'Mel'

var bool bIsRolling;

/** Speed whe rolling = 
 *  NormalSpeed * RollingSpeedModifier
 */
var float RollingSpeedModifier;

/** Bool to know when player wants to jump
 *  First we have to play PreJump animation and later do the jump.
 */
var bool bPreparingJump;

/**Threshold in Pawn Z velocity to do a DoubleJump*/
var		float	DoubleJumpThreshold;

/** Bool to know it next jump is a mushroom jump
 *  Mushroom jump is higher than normal jump. Using mushroomJumpZModifier
 */
var bool bMushroomJump;
/** Amount to modify the normal height jump ina mushroom jump */
var float mushroomJumpZModifier;

//var DynamicLightEnvironmentComponent LightEnvironment;

/** AnimNode used to play custom fullbody anims */
var AnimNodeSlot fullBodySlot;
/** AnimNode used to play custom upperbody anims */
var AnimNodeSlot upperBodySlot;

var name preJumpAnimName;
var name attackAnimNames[3];
/** Indicates the index of next attack anim (0, 1 or 2) */
var int nextAttackIndex;
var name grenadeAnimName;
const ROLL_LEFT = 0;
const ROLL_RIGHT = 1;
var name rollAnimNames[2];

///**GroundParticles al andar o correr 
//var ParticleSystemComponent ParticlesComponent_humo_correr;
//var ParticleSystemComponent ParticlesComponent_ini_correr;
//var ParticleSystem ParticlesSystem_humo_correr[5];

/** ParticleSystem que aparece al equipar la espada */
var ParticleSystem EquipSwordPS;
/** ParticleSystem used in Heal hability */
var ParticleSystem HealPS;
/** ParticleSystem used in Frenesi hability */
var ParticleSystem FrenesiPS;
/** ParticleSystem used in Frenesi hability */
var ParticleSystem Frenesi2PS;

//Sounds
/** Sound for equipping the Sword */
var SoundCue EquipSwordCue;

var() SkeletalMeshComponent grenadeMesh;

//-----------------------------------------------------------------------------------------------
//-----------------------------------NOTIFYS-----------------------------------------------------


//animacion lanzar granada
simulated event lanzaGranada(){

//	local Projectile	SpawnedProjectile;
//	local Vector grenade_socket;

//		local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
//	local ImpactInfo	TestImpact;

//// This is where we would start an instant trace. (what CalcWeaponFire uses)
//		StartTrace = Instigator.GetWeaponStartTraceLocation();
//		//AimDir = Vector(GetAdjustedAim( StartTrace ));
//		AimDir =Normal( StartTrace );

//		// this is the location where the projectile is spawned.
//		Mesh.GetSocketWorldLocationAndRotation('grenade_socket' , RealStartLoc);
//		//RealStartLoc = GetPhysicalFireStartLoc(AimDir);
	
//		if( StartTrace != RealStartLoc )
//		{
//			// if projectile is spawned at different location of crosshair,
//			// then simulate an instant trace where crosshair is aiming at, Get hit info.

//			//WeaponRange=16384
//			EndTrace = StartTrace + AimDir * 16384;
//			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

//			// Then we realign projectile aim direction to match where the crosshair did hit.
//			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
//		}

//		// Spawn projectile
//		SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
//		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
//		{
//			SpawnedProjectile.Init( AimDir );
//		}
	
//	itemsMiel-=5;
//	Mesh.GetSocketWorldLocationAndRotation('grenade_socket' , grenade_socket);
//	SpawnedProjectile = Spawn(class 'BBProjectileGrenade',self,, grenade_socket);


////`log("Direction"@Direction);
//		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
//		{
//			//SpawnedProjectile.Init( Vector(GetAdjustedAim( grenade_socket )) );
//			SpawnedProjectile.Init(  Normal(grenade_socket)  );
//		}
}

//-----------------------------------NOTIFYS-----------------------------------------------------
//-----------------------------------------------------------------------------------------------
//simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
//{
//super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV );

//}


simulated function name GetDefaultCameraMode(PlayerController RequestedBy)
{
	return 'ThirdPerson';
	//return 'third';
	//return none;
}


event Tick(float DeltaTime){
	//if(bIsRolling) SetPhysics(PHYS_Walking);
}

//event PostBeginPlay()
//{
//	//local Vector SocketLocation;
//	//local Rotator SocketRotation;

//	super.PostBeginPlay();

//	//Mesh.GetSocketWorldLocationAndRotation('center', SocketLocation, SocketRotation, 0 /* Use 1 if you wish to return this in component space*/ );
//	Mesh.AttachComponentToSocket(ParticlesComponent_humo_correr, 'center');
//	Mesh.AttachComponentToSocket(ParticlesComponent_ini_correr, 'center');
//	ParticlesComponent_ini_correr.SetActive(false);
//	//ParticlesComponent_humo_correr.SetActive(false);
//	//ParticlesComponent_humo_correr.DeactivateSystem();
	
	
	
//	//ParticlesComponent_humo_correr.SetTemplate(ParticlesSystem_humo_correr[0]);
	
		
//}


//function play_humo_correr(){
//	//ParticlesComponent_humo_correr.SetActive(true);
//	ParticlesComponent_ini_correr.ActivateSystem();
//}

//function stop_humo_correr(){
//	//Particles_estrellas_antenas.DeactivateSystem();
//	//ParticlesComponent_humo_correr.SetActive(false);
//}

//function play_ini_correr(){
//	ParticlesComponent_ini_correr.ActivateSystem();

//}




function AddDefaultInventory()
{	
	//La primera sera el arma con que empecemos. Empezamos sin arma equipada
	InvManager.CreateInventory(class'BettyTheBee.BBWeaponNone');
	InvManager.CreateInventory(class'BettyTheBee.BBWeaponSword');
	//InvManager.CreateInventory(class'BettyTheBee.BBWeaponGrenade');
}


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		fullBodySlot = AnimNodeSlot(SkelComp.FindAnimNode('FullBodySlot'));
		upperBodySlot = AnimNodeSlot(SkelComp.FindAnimNode('UpperBodySlot'));

		preJumpAnimName = 'Betty_Jump_Preup';
		attackAnimNames[0] = 'B_attack_seq';
		attackAnimNames[1] = 'Betty_attack_2_seq';
		attackAnimNames[2] = 'Betty_attack_3_seq';
		grenadeAnimName = 'Betty_grenade_seq';

		rollAnimNames[ROLL_LEFT] = 'Betty_roll Left_2';
		rollAnimNames[ROLL_RIGHT] = 'Betty_roll Right_2';
	}
}




function  animRollLeft(){
	
	bIsRolling=true;
	fullBodySlot.PlayCustomAnim(rollAnimNames[ROLL_LEFT],1.0f,0.0f,0.0f);
	fullBodySlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Translate,RBA_Translate,RBA_Default);
	Mesh.RootMotionMode = RMM_Accel;
	Mesh.RootMotionAccelScale.X = RollingSpeedModifier;
	Mesh.RootMotionAccelScale.Y = RollingSpeedModifier;
	Mesh.RootMotionAccelScale.Z = RollingSpeedModifier;

	// Tell mesh to notify us when root motion will be applied,
	// so we can seamlessly transition from physics movement to animation movement
	//ONLY used with RMM_Translate
	//Mesh.bRootMotionModeChangeNotify = true;
}
function  animRollRight(){
	
	bIsRolling=true;
	fullBodySlot.PlayCustomAnim(rollAnimNames[ROLL_RIGHT],1.0f,0.0f,0.0f);
	fullBodySlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Translate,RBA_Translate,RBA_Default);
	Mesh.RootMotionMode = RMM_Accel;
	Mesh.RootMotionAccelScale.X = RollingSpeedModifier;
	Mesh.RootMotionAccelScale.Y = RollingSpeedModifier;
	Mesh.RootMotionAccelScale.Z = RollingSpeedModifier;
}

//Only used with RMM_Translate
//simulated event RootMotionModeChanged(SkeletalMeshComponent SkelComp)
//{
//   /**
//    * Root motion will kick-in on next frame.
//    * So we can kill Pawn movement, and let root motion take over.
//    */
//   if( SkelComp.RootMotionMode == RMM_Translate )
//   {
//      Velocity = Vect(0,0,0);
//      Acceleration = Vect(0,0,0);
//   }

//   // disable notification
//   Mesh.bRootMotionModeChangeNotify = FALSE;
//}


function bool isRolling(){
	return bIsRolling;
}

simulated function prepareJump(bool bUpdating){
	if(!bPreparingJump && Physics != PHYS_Falling){
		bPreparingJump = true;
		//When this animation ends it activates a notify called StartJump for jumping
		fullBodySlot.PlayCustomAnim(preJumpAnimName,1.0f,0.0f,0.0f,false,true);
	}
	else if ( !bUpdating && CanDoubleJump()&& (Abs(Velocity.Z) < DoubleJumpThreshold) && IsLocallyControlled() )
	{
 		if ( PlayerController(Controller) != None )
			PlayerController(Controller).bDoubleJump = true;
		DoDoubleJump(bUpdating);
		MultiJumpRemaining -= 1;
	}
}

function bool CanDoubleJump()
{
	return ( (MultiJumpRemaining > 0) && (Physics == PHYS_Falling) && bReadyToDoubleJump );
}



function bool DoJump( bool bUpdating )
{
	if (bJumpCapable && !bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider))
	{
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
		{
			if ( (WorldInfo.WorldGravityZ != WorldInfo.DefaultGravityZ) && (GetGravityZ() == WorldInfo.WorldGravityZ) )
			{
				Velocity.Z += Base.Velocity.Z * sqrt(GetGravityZ()/WorldInfo.DefaultGravityZ);
			}
			else
			{
				Velocity.Z += Base.Velocity.Z;
			}
		}
		
		SetPhysics(PHYS_Falling);
		bReadyToDoubleJump = true;
		//bDodging = false;
		return true;
	}
	return false;
}

function DoDoubleJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch )
	{
		if ( !IsLocallyControlled() || AIController(Controller) != None )
		{
			MultiJumpRemaining -= 1;
		}
		Velocity.Z = JumpZ + MultiJumpBoost;
		//UTInventoryManager(InvManager).OwnerEvent('MultiJump');
		SetPhysics(PHYS_Falling);
		//BaseEyeHeight = DoubleJumpEyeHeight;
		//if (!bUpdating)
		//{
		//	SoundGroupClass.Static.PlayDoubleJumpSound(self);
		//}
	}
}

event Landed(vector HitNormal, actor FloorActor)
{
	local vector Impulse;

	Super.Landed(HitNormal, FloorActor);

	// adds impulses to vehicles and dynamicSMActors (e.g. KActors)
	Impulse.Z = Velocity.Z * 4.0f; // 4.0f works well for landing on a Scorpion
	if (DynamicSMActor(FloorActor) != None)
	{
		DynamicSMActor(FloorActor).StaticMeshComponent.AddImpulse(Impulse, Location);
	}

	//if ( Velocity.Z < -200 )
	//{
	//	OldZ = Location.Z;
	//	bJustLanded = bUpdateEyeHeight && (Controller != None) && Controller.LandingShake();
	//}

	if (UTInventoryManager(InvManager) != None)
	{
		UTInventoryManager(InvManager).OwnerEvent('Landed');
	}
	if ((MultiJumpRemaining < MaxMultiJump) || Velocity.Z < -2 * JumpZ)
	{
		// slow player down if double jump landing
		Velocity.X *= 0.1;
		Velocity.Y *= 0.1;
	}

	//AirControl = DefaultAirControl;
	MultiJumpRemaining = MaxMultiJump;
	//bDodging = false;
	bReadyToDoubleJump = false;
	if (UTBot(Controller) != None)
	{
		UTBot(Controller).ImpactVelocity = vect(0,0,0);
	}

	//if(!bHidden)
	//{
	//	PlayLandingSound();
	//}
	//if (Velocity.Z < -MaxFallSpeed)
	//{
	//	SoundGroupClass.Static.PlayFallingDamageLandSound(self);
	//}
	//else if (Velocity.Z < MaxFallSpeed * -0.5)
	//{
	//	SoundGroupClass.Static.PlayLandSound(self);
	//}

	SetBaseEyeheight();
}

simulated function healUsed(){
	//WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(HealPS,Mesh,'Bip01',false,vect(0.0f,0.0f,50.0f));
	local Vector SpawnLocation;

	SpawnLocation = Location;
	SpawnLocation.Z -= GetCollisionHeight() + 2.0f;
	WorldInfo.MyEmitterPool.SpawnEmitter(HealPS,SpawnLocation,,self);
	
}

simulated function array<ParticleSystemComponent> frenesiUsed(){
	local array<ParticleSystemComponent> PSCArray;
	PSCArray.AddItem(WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(FrenesiPS, Mesh, 'Frenesi_UpperSocket', true));
	PSCArray.AddItem(WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(FrenesiPS, Mesh, 'Frenesi_LeftSocket', true));
	PSCArray.AddItem(WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(FrenesiPS, Mesh, 'Frenesi_RightSocket', true));
	PSCArray.AddItem(WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(FrenesiPS, Mesh, 'Frenesi_BotomSocket', true));
	PSCArray.AddItem(WorldInfo.MyEmitterPool.SpawnEmitter(Frenesi2PS, Location, Rotation, self));
	return PSCArray;
}

simulated function calcHitLocation()
{
	BBWeapon(Weapon).calcHitPosition();
}

simulated function StartFire(byte FireModeNum)
{

		if(BBWeapon(Weapon).getAnimacioFlag()==false){
			
			switch (Weapon.Class){		
			case (class'BBWeaponSword'):
					if(FireModeNum==0)super.StartFire(FireModeNum);
					else{
						itemsMiel-=5;
						super.StartFire(FireModeNum);
					}
				break;
			case (class'BBWeaponNone'):
					if(FireModeNum==1){
						itemsMiel-=5;
						super.StartFire(FireModeNum);
					}
				break;
			default:
				break;
			}
		}

	
}

simulated function basicSwordAttack()
{
	BBWeaponSword(Weapon).ResetUnequipTimer();
	BBWeapon(Weapon).animAttackStart();
	upperBodySlot.PlayCustomAnim(attackAnimNames[0],1.5f,0.15f,0.15f);
	upperBodySlot.SetActorAnimEndNotification(true);
	nextAttackIndex = 1;
	
}

simulated function comboSwordAttack()
{
	
	BBWeaponSword(Weapon).ResetUnequipTimer();
	BBWeapon(Weapon).animAttackEnd();//end de l'animacio de l'atac basic. Per posar eliminar els enemics de la taula 'lista_enemigos'
	BBWeapon(Weapon).animAttackStart();
	if(nextAttackIndex < 2){
		upperBodySlot.PlayCustomAnim(attackAnimNames[nextAttackIndex],1.5f,0.15f,0.15f);
		upperBodySlot.SetActorAnimEndNotification(true);
		nextAttackIndex++;
	}else{
		fullBodySlot.PlayCustomAnim(attackAnimNames[nextAttackIndex],1.0f,0.15f,0.15f);
		fullBodySlot.SetActorAnimEndNotification(true);
		nextAttackIndex = 0;
	}
}

simulated function GrenadeAttack()
{
	if(BBWeapon(Weapon).getAnimacioFlag()==false){	

		BBWeapon(Weapon).animAttackStart();
		upperBodySlot.PlayCustomAnim(grenadeAnimName,1.0f,0.15f,0.15f);
		upperBodySlot.SetActorAnimEndNotification(true);
	}
}


simulated event attachMeshGrenade(){
	Mesh.AttachComponentToSocket(grenadeMesh, 'grenade_socket');
}

simulated event removeMeshGrenade(){

	Mesh.DetachComponent(grenadeMesh);
}

function bool canStartCombo()
{
	local AnimNodeSequence a;
	local float animCompletion;
	
	a = getAttackAnimNode();
	if(a!=None)
	{
		animCompletion = a.GetNormalizedPosition();
		//`log("normallized position is"@animCompletion);
		//Worldinfo.Game.Broadcast(self, Name $ ":animCompletion "$animCompletion);
		if(animCompletion > 0.65 && animCompletion < 1.0)
		{
			return true;
		}
	}
	return false;
}

function ForceJump()
{
 	PrepareJump(false);
	bMushroomJump = true;
	//JumpZ *= mushroomJumpZModifier;
	JumpZ = mushroomJumpZModifier;
	
}


function EndJump(){
	if(bMushroomJump){
		bMushroomJump = false;
		//JumpZ /= mushroomJumpZModifier;
		JumpZ=550;
	}
}

simulated event StartJump(){
	bPreparingJump = false;
	DoJump(false);
	//if(bMushroomJump){
	//	bMushroomJump = false;
	//	//JumpZ /= mushroomJumpZModifier;
	//}
}

simulated event EndRoll(){
	bIsRolling = false;

	// Discard root motion. So mesh stays locked in place.
	// We need this to properly blend out to another animation
	fullBodySlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Discard,RBA_Discard,RBA_Discard);

	// Tell mesh to stop using root motion
	Mesh.RootMotionMode = RMM_Ignore;
}

simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	//Only attack anims have OnAnimEnd event
	BBWeapon(Weapon).animAttackEnd();	
	
}


function AnimNodeSequence getAttackAnimNode()
{
	local AnimNodeSequence currentPlay;
	currentPlay = upperBodySlot.GetCustomAnimNodeSeq();
	if(currentPlay == none) currentPlay = fullBodySlot.GetCustomAnimNodeSeq();
	return currentPlay;
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	Worldinfo.Game.Broadcast(self,Name$": "$Damage$ " done by "$DamageCauser.Name $ " Life: "$Health);
}

simulated function GetUnequipped()
{
	local BBWeaponNone Inv;
	local BBWeaponSword Sword;
	local BBWeaponGrenade Grenade;

	Sword = BBWeaponSword(Weapon);
	Grenade = BBWeaponGrenade(Weapon);

	//Miramos si el arma anterior no estaba atacando
	if((Sword != none && Sword.animacio_attack == false) || (Grenade != none && Grenade.animacio_attack == false)){
		foreach InvManager.InventoryActors( class'BBWeaponNone', Inv )
		{
			InvManager.SetCurrentWeapon( Inv );
			//Si antes teniamos la espada lanzamos particulas y sonido
			if(Sword != none){
				WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(EquipSwordPS,Mesh,'sword_socket',true);
				PlaySound(EquipSwordCue);
			}
			break;
		}
	}
}
simulated function GetSword()
{
	local BBWeaponSword Inv;
	local BBWeaponGrenade Grenade;

	Grenade = BBWeaponGrenade(Weapon);

	//Miramos si el arma anterior no estaba atacando
	if((Grenade != none && Grenade.animacio_attack == false) || Weapon.Class == class'BBWeaponNone'){		
		foreach InvManager.InventoryActors( class'BBWeaponSword', Inv )
		{
			InvManager.SetCurrentWeapon( Inv );
			WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(EquipSwordPS,Mesh,'sword_socket',true);
			PlaySound(EquipSwordCue);
			break;
		}
	}
}
simulated function GetGrenade()
{
	local BBWeaponGrenade Inv;
	local BBWeaponSword Sword;


	Sword = BBWeaponSword(Weapon);

	//Miramos si el arma anterior no estaba atacando
	if((Sword != none && Sword.animacio_attack == false) || Weapon.Class == class'BBWeaponNone'){
		foreach InvManager.InventoryActors( class'BBWeaponGrenade', Inv )
		{
			InvManager.SetCurrentWeapon( Inv );
			//Si antes teniamos la espada lanzamos particulas y sonido
			if(Sword != none){
				WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(EquipSwordPS,Mesh,'sword_socket',true);
				PlaySound(EquipSwordCue);
			}
			break;
		}
	}
}

simulated event ToggleAttack(){
	BBWeaponSword(Weapon).ToggleAttack();
}



//simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
//{
//  local vector ApplyImpulse, ShotDir;
  
//  bReplicateMovement = false;
//  bTearOff = true;
//  Velocity += TearOffMomentum;
//  SetDyingPhysics();
//  bPlayedDeath = true;
//  HitDamageType = DamageType; // these are replicated to other clients
//  TakeHitLocation = HitLoc;



//  if ( WorldInfo.NetMode == NM_DedicatedServer )
//  {
//    GotoState('Dying');
//    return;
//  }
//  InitRagdoll();
//  mesh.MinDistFactorForKinematicUpdate = 0.f;
  
//  if (Physics == PHYS_RigidBody)
//  {

//    setPhysics(PHYS_Falling);
//  }
//  PreRagdollCollisionComponent = CollisionComponent;
//  CollisionComponent = Mesh;
//  if( Mesh.bNotUpdatingKinematicDueToDistance )
//  {
//    Mesh.ForceSkelUpdate();
//    Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
//  }
//  if( Mesh.PhysicsAssetInstance != None )
//    Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
//  Mesh.SetRBChannel(RBCC_Pawn);
//  Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
//  Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
//  Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
//  Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
//  Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
//  Mesh.ForceSkelUpdate();
//  Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
//  Mesh.PhysicsWeight = 1.0;
//  Mesh.bUpdateKinematicBonesFromAnimation=false;
//  // mesh.bPauseAnims=True;
//  Mesh.SetRBLinearVelocity(Velocity, false);
//  mesh.SetTranslation(vect(0,0,1) * 6);
//  Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
//  Mesh.SetNotifyRigidBodyCollision(true);
//  Mesh.WakeRigidBody();

 
//  if( TearOffMomentum != vect(0,0,0) )
//  {
//    ShotDir = normal(TearOffMomentum);
//    ApplyImpulse = ShotDir * DamageType.default.KDamageImpulse;
//    // If not moving downwards - give extra upward kick
//    if ( Velocity.Z > -10 )
//    {
//      ApplyImpulse += Vect(0,0,1)*2;
//    }
//    Mesh.AddImpulse(ApplyImpulse, TakeHitLocation,, true);
//  }
//  GotoState('Dying');
//}


DefaultProperties
{

	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
		BlockRigidBody=true;
		CollideActors=true;
		BlockZeroExtent=true;
		//What to change if you'd like to use your own meshes and animations
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		//AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
		//AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		//AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		//SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'

		AnimSets(0)=AnimSet'Betty_Player.SkModels.Betty_AnimSet'
		AnimTreeTemplate=AnimTree'Betty_Player.SkModels.Betty_AnimTree'
		SkeletalMesh=SkeletalMesh'Betty_Player.SkModels.Betty_SkMesh'
		//SkeletalMesh=SkeletalMesh'Betty_PlayerAITOR.SkModels.Betty_SkMesh'
	End Object
	//Setting up a proper collision cylinder
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);
	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0025.000000
		CollisionHeight=+0045.000000
	End Object
	CylinderComponent=CollisionCylinder

	EquipSwordPS = ParticleSystem'Betty_Player.Particles.EquipSword_PS'
	HealPS = ParticleSystem'Betty_Player.Particles.Heal_PS'
	FrenesiPS = ParticleSystem'Betty_Player.Particles.Frenesi_PS'
	Frenesi2PS = ParticleSystem'Betty_Player.Particles.Frenesi2_PS'

	GroundSpeed = 400.0f;

	AirSpeed = 1200.0f;

	//Default is 420
	JumpZ=800
	//JumpZ=1000
	MaxFallSpeed=999999

	//Default is 0.05
	AirControl=+0.35

	MaxMultiJump = 1
	//Default is 160.0
	DoubleJumpThreshold=320.0

	CustomGravityScaling = 2.5


	Health = 5;
	itemsMiel = 1000;
	bCanPickupInventory = true;
	InventoryManagerClass = class'BettyTheBee.BBInventoryManager';


	bIsRolling = false;
	RollingSpeedModifier = 1.0f;

	//mushroomJumpZModifier = 1.5f;
	mushroomJumpZModifier=825.0f;

	// FOV / Sight
	ViewPitchMin=-6000
	ViewPitchMax=5000
	//aquets parametres no me mirat perque funcionen
	RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
	MaxPitchLimit=3072


	EquipSwordCue=SoundCue'Betty_Sounds.SoundCues.EquippingSword01_Cue';
	
	Begin Object Class=SkeletalMeshComponent Name=grenade
	SkeletalMesh=SkeletalMesh'Betty_Player.SkModels.GrenadeSk'
	End Object
	grenadeMesh=grenade


	
}

