class BBBettyPawn extends BBPawn;

var int itemsMiel;//contador de items 'Mel'
var int collectableItems;
var int maxCollectableItems;

var bool bIsRolling;
var bool bIsInvulnerable;

var float invulnerableTime;
var float invulnerableMaxTime;

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

var bool bSlideJump;

/** Amount to modify the normal height jump in a mushroom jump if mushroomJumpZ in mushroom class is 0.0 */
var float mushroomJumpZModifier;

/** AnimNode used to play custom fullbody anims */
var AnimNodeSlot fullBodySlot;
/** AnimNode used to play custom upperbody anims */
var AnimNodeSlot upperBodySlot;

var name preJumpAnimName;
var name attackAnimNames[3];
/** Indicates the index of next attack anim (0, 1 or 2) */
var int nextAttackIndex;
var name grenadeAnimName;
var name airAttackAnimName;
var name airAttackEndAnimName;
var name failedAttackAnimName;
/** Name of default death anim played if DamageType doesn't have deathAnim or is none */
var name defaultDeathAnimName;

/** World time that we started the death animation */
var				float	StartDeathAnimTime;
/** Type of damage that started the death anim */
var				class<BBDamageType> DeathAnimDamageType;
/** Time that we took damage of type DeathAnimDamageType. */
var				float	TimeLastTookDeathAnimDamage;

var class<BBDamageType> airAttackDamageType;

var MaterialInterface DefaultMaterial;
var MaterialInterface DamageMaterial;

const ROLL_LEFT = 0;
const ROLL_RIGHT = 1;
var name rollAnimNames[2];

const SLIDING_START = 0;
const SLIDING       = 1;
const SLIDING_END   = 2;
const SLIDING_LEFT  = 3;
const SLIDING_RIGHT = 4;
const SLIDING_JUMP  = 5;
var name slideAnimNames[6];

//Particle Systems
/** ParticleSystem que aparece al equipar la espada */
var ParticleSystem EquipSwordPS;
/** ParticleSystem used in Heal hability */
var ParticleSystem HealPS;
/** ParticleSystem used in Frenesi hability */
var ParticleSystem FrenesiPS;
/** ParticleSystem used in Frenesi hability */
var ParticleSystem Frenesi2PS;

/**ParticleSystem used in footsteps*/
var ParticleSystem FootstepPS;
/** ParticleSystem used when landed*/
var ParticleSystem LandedPS;
/** ParticleSystem used when sliding */
var ParticleSystem SlidingPS;
/** ParticleSystemComponent used to save the slidingPS */
var ParticleSystemComponent SlidingPSC;

var ParticleSystem AirAttackPS;

//Sounds
/** Sound for equipping the Sword */
var SoundCue EquipSwordCue;
/** Sound for left footstep */
var SoundCue LeftFootStepCue;
/** Sound for right footstep */
var SoundCue RightFootStepCue;
/** Sound for jumping attack */
var SoundCue JumpingAttackCue;
/** Sound for Jump */
var SoundCue JumpCue;
/** Sound for double jump */
var SoundCue DoubleJumpCue;
/** Sound for Heal hability */
var	SoundCue HealSound;
/** Sound played when betty gets damage*/
var SoundCue HitSound;
/** Sound played when betty slides*/
var AudioComponent SlideSound;
var SoundCue SlideCue;
var SoundCue AirAttackFinishCue;


var() SkeletalMeshComponent grenadeMesh;

var() SkeletalMeshComponent hojaSlide;

var int lastSlideRollJumping;

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
	//return 'default';
	return 'thirdperson';
	//return none;
}


event Tick(float DeltaTime){
	//if(bIsRolling) SetPhysics(PHYS_Walking);
	if(isInvulnerable()){
		invulnerableTime -= DeltaTime;
		if(invulnerableTime <= 0){
			SetInvulnerable(false);
		}
	}

}

event PostBeginPlay()
{
	local BBPickupCollectable tempCollectable;
	//local Vector SocketLocation;
	//local Rotator SocketRotation;

	super.PostBeginPlay();

	//Mesh.GetSocketWorldLocationAndRotation('center', SocketLocation, SocketRotation, 0 /* Use 1 if you wish to return this in component space*/ );
	//Mesh.AttachComponentToSocket(ParticlesComponent_humo_correr, 'center');
	//Mesh.AttachComponentToSocket(ParticlesComponent_ini_correr, 'center');
	//ParticlesComponent_ini_correr.SetActive(false);
	//ParticlesComponent_humo_correr.SetActive(false);
	//ParticlesComponent_humo_correr.DeactivateSystem();
	
	
	
	//ParticlesComponent_humo_correr.SetTemplate(ParticlesSystem_humo_correr[0]);
	maxCollectableItems = 0;
	foreach DynamicActors(class'BBPickupCollectable', tempCollectable){
		maxCollectableItems++;
	}
	
		
}


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

function bool isInvulnerable(){
	return bIsInvulnerable;
}

function SetInvulnerable(bool flag){
	if(flag){		
		//Mesh.SetMaterial(0,DamageMaterial);
		invulnerableTime = invulnerableMaxTime;
	}else{
		//Mesh.SetMaterial(0,DefaultMaterial);
	}
	bIsInvulnerable = flag;
}

simulated function prepareJump(bool bUpdating){
	if(!bPreparingJump && Physics != PHYS_Falling){
		bPreparingJump = true;
		//When this animation ends it activates a notify called StartJump for jumping
		fullBodySlot.PlayCustomAnim(preJumpAnimName,2.0f,0.0f,0.0f,false,true);
		fullBodySlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Default,RBA_Default,RBA_Default);
	}
	else if ( !bUpdating && CanDoubleJump()&& (Velocity.Z < DoubleJumpThreshold) && IsLocallyControlled() )
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
	// This extra jump allows a jumping or dodging pawn to jump again mid-air
	// (via thrusters). The pawn must be within +/- DoubleJumpThreshold velocity units of the
	// apex of the jump to do this special move.
	if ( !bUpdating && CanDoubleJump()&& (Velocity.Z < DoubleJumpThreshold) && IsLocallyControlled() )
	{
		if ( PlayerController(Controller) != None )
			PlayerController(Controller).bDoubleJump = true;
		DoDoubleJump(bUpdating);
		MultiJumpRemaining -= 1;
		return true;
	}
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
		PlayLandedPS();
		PlaySound(JumpCue);
		bReadyToDoubleJump = true;
		//bDodging = false;
		return true;
	}
	return false;
}

function DoDoubleJump( bool bUpdating )
{
	local Vector tempLocation;
	if ( !bIsCrouched && !bWantsToCrouch )
	{
		if ( !IsLocallyControlled() || AIController(Controller) != None )
		{
			MultiJumpRemaining -= 1;
		}
		Velocity.Z = JumpZ + MultiJumpBoost;
		//UTInventoryManager(InvManager).OwnerEvent('MultiJump');
		SetPhysics(PHYS_Falling);
		
		tempLocation = Location;
		tempLocation.Z -= GetCollisionHeight();
		WorldInfo.MyEmitterPool.SpawnEmitter(AirAttackPS, tempLocation);
		PlayLandedPS();
		PlaySound(DoubleJumpCue);
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
	PlayLandedPS();
	MakeNoise(1.0);
	SetBaseEyeheight();
}

simulated function CollectableCaught(BBPickupCollectable collectableItem){
	collectableItems++;
	BBHUD(PlayerController(Controller).myHUD).startCollectableCaughtAnimation(collectableItem);	
}

simulated function healUsed(){
	//WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(HealPS,Mesh,'Bip01',false,vect(0.0f,0.0f,50.0f));
	local Vector SpawnLocation;

	SpawnLocation = Location;
	SpawnLocation.Z -= GetCollisionHeight() + 2.0f;
	WorldInfo.MyEmitterPool.SpawnEmitter(HealPS,SpawnLocation,,self);
	PlaySound(HealSound);
	
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
/**This function is called from Kismet, used to draw text in screen
 * 
 */ 
function DrawText(BBSeqAct_DrawText myActionDrawText){
	BBHUD(PlayerController(Controller).myHUD).texto_ayuda(  myActionDrawText.text1,
															myActionDrawText.text2,
															myActionDrawText.size,
															myActionDrawText.posX * 1024,
															myActionDrawText.posY * 768);
}


/*
 * This function is called from Kismet. per cridar a la funcio LoadGameCheckpoint desde el menu principal del joc
 */
function playFromCheckpoint(BBSeqAct_Continue myActionContinue){
	BBGameInfo(WorldInfo.Game).LoadGameCheckpoint();
}

simulated function StartFire(byte FireModeNum)
{
	

		if(BBWeapon(Weapon).getAnimacioFlag()==false){
			
			switch (Weapon.Class){		
			case (class'BBWeaponSword'):
					super.StartFire(FireModeNum);
				break;
			case (class'BBWeaponNone'):
					if(FireModeNum==1){
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

function ForceJump(float mushroomJumpZ)
{
	//JumpZ *= mushroomJumpZModifier;
	JumpZ = mushroomJumpZModifier;
	if(mushroomJumpZ <= 0)
		JumpZ = mushroomJumpZModifier;
	else
		JumpZ = mushroomJumpZ;
 	DoJump(false);
	bMushroomJump = true;	
}


function EndJump(){
	if(bMushroomJump){
		bMushroomJump = false;
		JumpZ=Default.JumpZ;
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
	
	if(fullBodySlot.bIsPlayingCustomAnim) fullBodySlot.StopCustomAnim(0.15f);
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
	
	if(!isInvulnerable()){
		if(bIsRolling)
			EndRoll();
		super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
		SetInvulnerable(true);
		//Worldinfo.Game.Broadcast(self,Name$": "$Damage$ " done by "$DamageCauser.Name $ " Life: "$Health);
	}
}

/**Function called by HandleMomentum (called by TakeDamage) and used to change te velocity of Pawn.
 * Only used with Rhino Charges.
 */
function AddVelocity( vector NewVelocity, vector HitLocation, class<DamageType> damageType, optional TraceHitInfo HitInfo )
{
	if ( bIgnoreForces || (NewVelocity == vect(0,0,0)) )
		return;
	if ( (Physics == PHYS_Walking)
		|| (((Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) && (NewVelocity.Z > Default.JumpZ)) )
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > Default.JumpZ) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity = NewVelocity;
}

/**
  * Event called after actor's base changes.
 */
singular event BaseChange(){
	local DynamicSMActor Dyn;

	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise we do some damage and jump off.
	if (Pawn(Base) != None)
	{
		if( !Pawn(Base).CanBeBaseForPawn(Self) )
		{
			//Pawn(Base).CrushedBy(self);
			JumpOffPawn();
		}
	}

	// If it's a KActor, see if we can stand on it.
	Dyn = DynamicSMActor(Base);
	if( Dyn != None && !Dyn.CanBasePawn(self) )

	{
		JumpOffPawn();
	}
}

//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
	Velocity += VRand();
	Velocity.Z = 0;
	Velocity = (400 + CylinderComponent.CollisionRadius) * Normal(Velocity);
	Velocity.Z = 600 + CylinderComponent.CollisionHeight;
	SetPhysics(PHYS_Falling);
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

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> MyDamageType, vector Momentum, TraceHitInfo HitInfo){
	local class<BBDamageType> MyBBDamageType;

	super.PlayHit(Damage,InstigatedBy,HitLocation,MyDamageType,Momentum, HitInfo);

	MyBBDamageType = class<BBDamageType>(MyDamageType);

	if(MyBBDamageType != none && MyBBDamageType.default.HitAnim != ''){
		if(!fullBodySlot.bIsPlayingCustomAnim && !upperBodySlot.bIsPlayingCustomAnim){
			fullBodySlot.PlayCustomAnim(MyBBDamageType.default.HitAnim,MyBBDamageType.default.HitAnimRate,0.1,0.1,false,true);
		}
	}
	PlaySound(HitSound);
}

function playFailedAttack(){	
	fullBodySlot.PlayCustomAnim(failedAttackAnimName, 1.0f, 0.15f, 0.1f, false, true);
}



function PlayLandedPS(){
	local Vector tempLocation;
	tempLocation = Location;
	tempLocation.Z -= GetCollisionHeight();
	WorldInfo.MyEmitterPool.SpawnEmitter(LandedPS, tempLocation);
}

/** Function called by Died(). Used to play death anim
 * 
 */ 
simulated function PlayDying(class<DamageType> MyDamageType, vector HitLoc){
	local class<BBDamageType> MyBBDamageType;
	//local vector ApplyImpulse, ShotDir;
	//local TraceHitInfo HitInfo;

	super.PlayDying(MyDamageType, HitLoc);

	MyBBDamageType = class<BBDamageType>(MyDamageType);
	//PreRagdollCollisionComponent = CollisionComponent;
	//CollisionComponent = Mesh;

	if(MyBBDamageType != None && MyBBDamageType.default.DeathAnim != ''){
			//SetPhysics(PHYS_RigidBody);
			// We only want to turn on 'ragdoll' collision when we are not using a hip spring, otherwise we could push stuff around.
			//SetPawnRBChannels(TRUE);
			
			//Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);

			// Turn on angular motors on skeleton.
			//Mesh.bUpdateJointsFromAnimation = TRUE;
			//Mesh.PhysicsAssetInstance.SetNamedMotorsAngularPositionDrive(false, false, NoDriveBodies, Mesh, true);
			//Mesh.PhysicsAssetInstance.SetAngularDriveScale(1.0f, 1.0f, 0.0f);

			fullBodySlot.PlayCustomAnim(MyBBDamageType.default.DeathAnim, MyBBDamageType.default.DeathAnimRate, 0.05, -1.0, false, false);
			//Descomentar para pasar a Ragdoll al finalizar animacion
			//SetTimer(0.1, true, 'DoingDeathAnim');
			StartDeathAnimTime = WorldInfo.TimeSeconds;
			TimeLastTookDeathAnimDamage = WorldInfo.TimeSeconds;
			DeathAnimDamageType = MyBBDamageType;
	}
	else
	{
		//Playing default DeathAnim
		fullBodySlot.PlayCustomAnim(defaultDeathAnimName, 1.0f, 0.05, -1.0, false, false);

		StartDeathAnimTime = WorldInfo.TimeSeconds;
		TimeLastTookDeathAnimDamage = WorldInfo.TimeSeconds;
		DeathAnimDamageType = MyBBDamageType;
		//SetPhysics(PHYS_RigidBody);
		//Mesh.PhysicsWeight=1.0f;
		//Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
		//SetPawnRBChannels(TRUE);

		//if( TearOffMomentum != vect(0,0,0) )
		//{
		//	ShotDir = normal(TearOffMomentum);
		//	ApplyImpulse = ShotDir * MyBBDamageType.default.KDamageImpulse;

		//	// If not moving downwards - give extra upward kick
		//	if ( Velocity.Z > -10 )
		//	{
		//		ApplyImpulse += Vect(0,0,1)*MyBBDamageType.default.KDeathUpKick;
		//	}
		//	CheckHitInfo( HitInfo, Mesh, Normal(TearOffMomentum), TakeHitLocation );
		//	Mesh.AddImpulse(ApplyImpulse, TakeHitLocation, HitInfo.BoneName, true);
		//}
	}	
}
/**Timer set to this function when pawn dies
 * Used to change to ragdoll mode at the end of the anim
 */
//simulated function DoingDeathAnim(){
//	local AnimNodeSequence SlotSeqNode;
//	local bool bStopAnim;

//	// If we want to stop animation after a certain
//	if( DeathAnimDamageType != None &&
//		DeathAnimDamageType.default.StopAnimAfterDamageInterval != 0.0 &&
//		(WorldInfo.TimeSeconds - TimeLastTookDeathAnimDamage) > DeathAnimDamageType.default.StopAnimAfterDamageInterval )
//	{
//		bStopAnim = TRUE;
//	}

//	SlotSeqNode = fullBodySlot.GetCustomAnimNodeSeq();
//	if(!SlotSeqNode.bPlaying || bStopAnim)
//	{
//		SetPhysics(PHYS_RigidBody);
//		Mesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(false, false);
//		//HipBodyInst = Mesh.PhysicsAssetInstance.FindBodyInstance('b_Hips', Mesh.PhysicsAsset);
//		//HipBodyInst.EnableBoneSpring(FALSE, FALSE, DummyMatrix);

//		// Ensure we have ragdoll collision on at this point
//		SetPawnRBChannels(TRUE);
//		Mesh.PhysicsWeight=1.0f;
//		ClearTimer('DoingDeathAnim');
//		DeathAnimDamageType = None;
//	}
//}

/** Use to change RBChannels when entering or exiting RagdollMode
 * @param bRagdollMode  true if entering in RagdollMode
 */ 
//simulated function SetPawnRBChannels(bool bRagdollMode)
//{
//	if(bRagdollMode)
//	{
//		Mesh.SetRBChannel(RBCC_Pawn);
//		Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
//		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
//		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
//		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
//		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
//	}
//	else
//	{
//		Mesh.SetRBChannel(RBCC_Untitled3);
//		Mesh.SetRBCollidesWithChannel(RBCC_Default,FALSE);
//		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
//		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
//		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
//		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
//	}
//}

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


auto state idle
{
Begin:
	fullBodySlot.StopCustomAnim(0);
}

state AirAttack{
	
	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		
	}

	event EndState(name NextStateName){
		super.EndState(NextStateName);
		// Discard root motion. So mesh stays locked in place.
		// We need this to properly blend out to another animation
		//fullBodySlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Discard,RBA_Discard,RBA_Discard);
		// Tell mesh to stop using root motion
		Mesh.RootMotionMode = RMM_Ignore;
		SetPhysics(PHYS_Walking);
		CustomGravityScaling = default.CustomGravityScaling;
		PlayLandedPS();
		Controller.GoToState('PlayerWalking');
	}

	event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal ){
		super.Bump(Other, OtherComp, HitNormal);
		if(BBEnemyPawn(Other) != none){
			Other.TakeDamage(0,Controller, vect(0,0,0), vect(0,0,0), airAttackDamageType);
		}
		if(BBEnemyPawn(Other) == none || !BBEnemyPawn(Other).IsInState('Stunned')){
			GotoState('Idle');
		}
	}

	event Landed(vector HitNormal, actor FloorActor){
		local vector tempLocation;
		super.Landed(HitNormal, FloorActor);
		tempLocation = Location;
		tempLocation.Z -= GetCollisionHeight() - 10;
		WorldInfo.MyEmitterPool.SpawnEmitter(AirAttackPS, tempLocation);
		PlaySound(AirAttackFinishCue);
		GotoState('AirAttack', 'Landing');
	}

Begin:
	fullBodySlot.PlayCustomAnim(airAttackAnimName, 0.75f, 0.15f, 0.0f, false, true);
	fullBodySlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Translate,RBA_Translate,RBA_Translate);
	Mesh.RootMotionMode = RMM_Accel;
	//Paramos todo el movimiento para no seguir subiendo o bajando
	ZeroMovementVariables();
	CustomGravityScaling = 0.0f;
	//Esperamos un rato parados en el aire
	Sleep(0.35f);
	CustomGravityScaling = 10.0f;	
	
	FinishAnim(fullBodySlot.GetCustomAnimNodeSeq());
	
	GotoState('Idle');
Landing:
	fullBodySlot.PlayCustomAnim(airAttackEndAnimName, 1.0f, 0.0f, 0.15f, false, true);
	fullBodySlot.GetCustomAnimNodeSeq().SetRootBoneAxisOption(RBA_Discard,RBA_Discard,RBA_Default);

	Mesh.RootMotionMode = RMM_Ignore;
	FinishAnim(fullBodySlot.GetCustomAnimNodeSeq());
	GotoState('Idle');
}


state playerSlide{

	event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);

		bPreparingJump=false;
		hojaSlide.SetScale(0.65);
		Mesh.AttachComponentToSocket(hojaSlide, 'HojaSlide');
		
		SlideSound = CreateAudioComponent(SlideCue);
		SlideSound.Play();
		fullBodySlot.PlayCustomAnim(slideAnimNames[SLIDING_START],1.0f,0.0f,0.0f,false,true);

		SlidingPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(SlidingPS,Mesh, 'HojaSlide', true);
	}

	event EndState(name NextStateName){
		super.EndState(NextStateName);
		fullBodySlot.PlayCustomAnim(slideAnimNames[SLIDING_END],1.0f,0.0f,0.0f,false,true);
		bPreparingJump=false;
		bSlideJump = false;
		lastSlideRollJumping = 0;
		hojaSlide.SetRotation(rot(0,0,0));
		Mesh.DetachComponent(hojaSlide);
		SlideSound.Stop();
		SlidingPSC.SetActive(false);
		SlidingPSC = none;
		//gotoState('idle');
	}

	event Tick(float DeltaTime){
		super.Tick(DeltaTime);
		hojaSlideAdjust(DeltaTime);
	}

	simulated event StartJump(){
		Super.StartJump();
		SlideSound.Stop();
		bSlideJump=true;
		SlidingPSC.SetActive(false);
		SlidingPSC = none;
	}

	event Landed(vector HitNormal, actor FloorActor){
		Super.Landed(HitNormal, FloorActor);

		bSlideJump=false;
		lastSlideRollJumping = 0;
		SlideSound.Play();
		hojaSlide.SetRotation(rot(0,0,0));
		if(SlidingPSC == none || !SlidingPSC.bIsActive){
			SlidingPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(SlidingPS,Mesh, 'HojaSlide', true);
		}

		GotoState('PlayerSlide');
	}

	function hojaSlideAdjust(float DeltaTime){

		local Vector tempVector, tempNormal, traceEnd, traceStart, hojaLocation;
		local Rotator desiredHojaRotation, tempRotator;
		local Vector hojaTranslation;
		local int RotSpeed;
		local float VelSpeed;
		local LinearColor tempColor;

		local Vector X, Y, Z;
		
		Mesh.GetSocketWorldLocationAndRotation('HojaSlide', hojaLocation);

		tempColor.R = 1.0;
		tempColor.G = 0.0;
		tempColor.B = 0.0;

			
		//Calculamos el desfase de altura de la hoja al estar en pendiente
		hojaTranslation.Z -= GetCollisionRadius() * Tan(Acos(Floor dot vect(0,0,1)));
		//A�adimos un peque�o desfase para no atravesar el suelo
		hojaTranslation.Z += 3;

		//Calculamos posicion de hoja en el salto (la hoja baja al saltar)		
		if(bSlideJump){
			traceStart = hojaLocation;
			traceEnd = traceStart;
			traceEnd.Z -= 1000;
			Trace(tempVector, tempNormal, traceEnd, traceStart);
			if(bDebug){ //Pintamos una linea representando el Trace y un punto donde colisiona
				DrawDebugLine(traceStart, traceEnd, 255, 0, 0, false);
				DrawDebugPoint(tempVector, 20.0, tempColor);
			}
			tempVector -= hojaLocation;
			if(tempVector.Z < -80){
				hojaTranslation.Z = -70;
			}else{
				hojaTranslation = tempVector;
				hojaTranslation.Z += 10;
			}
			//Not use FInterp
			VelSpeed = 0;
		}else{
			VelSpeed = 25.0f;
		}

		//Modificamos la rotacion, Primero creamos el sistema de coordenadas en global, haciendo 3 ejes perpendiculares
		tempVector = vect(0,-1,0) >> Rotation;
		X = Floor cross tempVector;
		tempVector = vect(1,0,0) >> Rotation;
		Y = Floor cross tempVector;
		Z = Floor;

		//Despues lo transformamos a local (la hoja ya gira en global al estar attachada a Betty)
		X = X << Rotation;
		Y = Y << Rotation;
		Z = Z << Rotation;

		//Si saltamos corregimos el fallo en el vector X y hacemos que los vectores Y y Z giren para simular un giro de la hoja
		if(bSlideJump){
			//Para no realizar la animacion de sliding mientras saltamos, sino la del jump
			if(fullBodySlot.bIsPlayingCustomAnim)
				fullBodySlot.StopCustomAnim(0.1f);
			//Hacemos girar la hoja 500� cada segundo
 			tempRotator.Roll = lastSlideRollJumping + 500 * DegToRad * RadToUnrRot * DeltaTime;
			tempRotator.Pitch = 0;
			tempRotator.Yaw = 0;

			lastSlideRollJumping = tempRotator.Roll;
			Z = Z << tempRotator;
			Y = Y << tempRotator;

			//Corregimos el error en la rotacion de la hoja del salto por el movimiento del socket (a�adimos 30� al Yaw)
			tempRotator.Roll = 0;
			tempRotator.Pitch = 0;
			tempRotator.Yaw = 30 * DegToRad * RadToUnrRot;

			X = X << tempRotator;
			//Not use RInterp
			RotSpeed = 0;
		}else{
			RotSpeed = 180 * DegToRad * RadToUnrRot;
		}

		//Obtenemos el Rotator a partir de los tres ejes Ortogonales
		desiredHojaRotation = OrthoRotation(X, Y, Z);

		//Pintamos un sistema de coordenadas para comprobar la orientacion de la hoja
		if(bDebug){
			DrawDebugCoordinateSystem(hojaLocation + hojaTranslation, desiredHojaRotation + Rotation, 250);
		}

		//`log("R:" @ desiredHojaRotation.Roll @ " P:" @ desiredHojaRotation.Pitch @ " Y:" @ desiredHojaRotation.Yaw);

		if(VelSpeed > 0)
			hojaSlide.SetTranslation(VInterpTo(hojaslide.Translation, hojaTranslation, DeltaTime, VelSpeed)); //trasladar hoja
		else
			hojaSlide.SetTranslation(hojaTranslation);
		if(RotSpeed > 0){
			hojaSlide.SetRotation(RInterpTo(hojaSlide.Rotation, desiredHojaRotation, DeltaTime, RotSpeed, true));
			if(SlidingPSC != none)
				SlidingPSC.SetRotation(RInterpTo(SlidingPSC.Rotation, desiredHojaRotation, DeltaTime, RotSpeed, true));
		}
		else
			hojaSlide.SetRotation(desiredHojaRotation);

	}
	
	


Begin:	
	FinishAnim(fullBodySlot.GetCustomAnimNodeSeq());

	//if(PlayerController.PlayerInput.aStrafe > 0)
	//{
	//	fullBodySlot.PlayCustomAnim(slideAnimNames[SLIDING_LEFT],1.0f,0.0f,0.0f,false);
	//}
	//else if (PlayerController.PlayerInput.aStraf<0)
	//{
	//	fullBodySlot.PlayCustomAnim(slideAnimNames[SLIDING_RIGHT],1.0f,0.0f,0.0f,false);
	//}
	//if(bSlideJump) fullBodySlot.PlayCustomAnim(slideAnimNames[SLIDING_JUMP],1.0f,0.0f,0.0f,true);	

	fullBodySlot.PlayCustomAnim(slideAnimNames[SLIDING],1.0f,0.0f,0.0f,true);	
Jumping:

}

State Dying
{
ignores Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;

	simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon) {}
	simulated function PlayNextAnimation() {}
	singular event BaseChange() {}
	event Landed(vector HitNormal, Actor FloorActor) {}

	function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation);

	  simulated singular event OutsideWorldBounds()
	  {
		  SetPhysics(PHYS_None);
		  SetHidden(True);
		  LifeSpan = FMin(LifeSpan, 1.0);
	  }

	event Timer()
	{
		if ( !PlayerCanSeeMe() )
		{
			Destroy();
		}
		else
		{
			SetTimer(2.0, false);
		}
	}

	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		SetPhysics(PHYS_Falling);

		if ( (Physics == PHYS_None) && (Momentum.Z < 0) )
			Momentum.Z *= -1;

		Velocity += 3 * momentum/(Mass + 200);

		if ( damagetype == None )
		{
			// `warn("No damagetype for damage by "$instigatedby.pawn$" with weapon "$InstigatedBy.Pawn.Weapon);
			DamageType = class'DamageType';
		}

		Health -= Damage;
	}

	event BeginState(Name PreviousStateName)
	{
		local Actor A;
		local array<SequenceEvent> TouchEvents;
		local int i;

		//if ( bTearOff && (WorldInfo.NetMode == NM_DedicatedServer) )
		//{
		//	LifeSpan = 2.0;
		//}
		//else
		//{
		//	SetTimer(5.0, false);
		//	// add a failsafe termination
		//	LifeSpan = 25.f;
		//}

		SetDyingPhysics();

		SetCollision(true, false);

		Controller.GotoState('Dead');

		//if ( Controller != None )
		//{
		//	if ( Controller.bIsPlayer )
		//	{
		//		DetachFromController();
		//	}
		//	else
		//	{
		//		Controller.Destroy();
		//	}
		//}

		foreach TouchingActors(class'Actor', A)
		{
			if (A.FindEventsOfClass(class'SeqEvent_Touch', TouchEvents))
			{
				for (i = 0; i < TouchEvents.length; i++)
				{
					SeqEvent_Touch(TouchEvents[i]).NotifyTouchingPawnDied(self);
				}
				// clear array for next iteration
				TouchEvents.length = 0;
			}
		}
		foreach BasedActors(class'Actor', A)
		{
			A.PawnBaseDied();
		}
	}

Begin:
	Sleep(0.2);
	PlayDyingSound();
}

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
	
		AnimSets(0)=AnimSet'Betty_Player.SkModels.Betty_AnimSet'
		AnimTreeTemplate=AnimTree'Betty_Player.SkModels.Betty_AnimTree'
		SkeletalMesh=SkeletalMesh'Betty_Player.SkModels.Betty_SkMesh'
		PhysicsAsset=PhysicsAsset'Betty_Player.SkModels.Betty_Physics'
		bHasPhysicsAssetInstance=true
		//SkeletalMesh=SkeletalMesh'Betty_PlayerAITOR.SkModels.Betty_SkMesh'
	End Object
	
	Begin Object Class=SkeletalMeshComponent Name=MyHojaSlide
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
		SkeletalMesh=SkeletalMesh'Betty_slide.SkModels.hojaSlide'
	End Object

	hojaSlide=MyHojaSlide


	//Setting up a proper collision cylinder
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);
	//CollisionComponent=InitialSkeletalMesh
	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0025.000000
		CollisionHeight=+0045.000000
	End Object
	CylinderComponent=CollisionCylinder
	CollisionComponent=CollisionCylinder

	EquipSwordPS = ParticleSystem'Betty_Player.Particles.EquipSword_PS'
	HealPS = ParticleSystem'Betty_Player.Particles.Heal_PS'
	FrenesiPS = ParticleSystem'Betty_Player.Particles.Frenesi_PS'
	Frenesi2PS = ParticleSystem'Betty_Player.Particles.Frenesi2_PS'

	FootstepPS = ParticleSystem'Betty_Particles.PSWalkingGround'
	LandedPS = ParticleSystem'Betty_Player.Particles.Landed_PS';

	SlidingPS = ParticleSystem'Betty_slide.ParticleSystems.Sliding_PS';

	AirAttackPS = ParticleSystem'Betty_Player.Particles.AirAttack_PS';

	GroundSpeed = 400.0f;

	//Default +02048.000000
	//AccelRate = 512.0f

	AirSpeed = 1200.0f;

	//Default is 420
	JumpZ=900
	//JumpZ=800
	MaxFallSpeed=999999

	//Default is 0.05
	AirControl=+0.35

	MaxMultiJump = 1
	MultiJumpRemaining = 1
	MultiJumpBoost = -100;
	//Default is 160.0
	DoubleJumpThreshold=320.0

	CustomGravityScaling = 2.5
	//Buoyancy = 1.0
	Mass = 1.0f;    //Used for handle momentum (in case of takeDamage of Rhino's Charge)


	Health = 5;
	itemsMiel = 0;

	collectableItems = 0;

	bCanPickupInventory = true;
	InventoryManagerClass = class'BettyTheBee.BBInventoryManager';


	bIsRolling = false;
	RollingSpeedModifier = 1.0f;

	//mushroomJumpZModifier = 1.5f;
	mushroomJumpZModifier=1350.0f;

	// FOV / Sight
	ViewPitchMin=-6000
	ViewPitchMax=5000
	//aquets parametres no me mirat perque funcionen
	RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
	MaxPitchLimit=3072

	DefaultMaterial = Material'Betty_Player.Materials.Betty_texture_Mat';
	DamageMaterial = Material'Betty_Player.Materials.Betty_translucent_Mat';

	invulnerableMaxTime = 1.5f;

	//Anim Names
	preJumpAnimName = "Betty_Jump_Preup";
	attackAnimNames[0] = "B_attack_seq";
	attackAnimNames[1] = "Betty_attack_2_seq";
	attackAnimNames[2] = "Betty_attack_3_seq";
	grenadeAnimName = "Betty_grenade_seq";

	rollAnimNames[ROLL_LEFT] = "Betty_roll Left_2";
	rollAnimNames[ROLL_RIGHT] = "Betty_roll Right_2";

	slideAnimNames[SLIDING_START] = "Betty_Slide_Start";
	slideAnimNames[SLIDING] = "Betty_Slide_Loop";
	slideAnimNames[SLIDING_END] = "Betty_Slide_End";
	slideAnimNames[SLIDING_LEFT] = "Betty_Slide_Left";
	slideAnimNames[SLIDING_RIGHT] = "Betty_Slide_Right";
	slideAnimNames[SLIDING_JUMP] = "Betty_Slide_Jump";

	airAttackAnimName = "Betty_Attack_4_start_seq";
	airAttackEndAnimName = "Betty_Attack_4_end_seq";
	failedAttackAnimName = "Betty_Attack_Failed_seq";

	defaultDeathAnimName = "Betty_Die_seq";

	airAttackDamageType = class'BBDamageType_AirAttack';


	EquipSwordCue=SoundCue'Betty_Player.Sounds.FxSacarArma0_Cue';
	RightFootStepCue=SoundCue'Betty_Player.Sounds.FxPasoPiedraDcho_Cue'
	LeftFootStepCue=SoundCue'Betty_Player.Sounds.FxPasoPiedraIzq_Cue'

	JumpCue=SoundCue'Betty_Player.Sounds.FxSaltoBetty1_Cue';
	DoubleJumpCue=SoundCue'Betty_Player.Sounds.FxSaltoBetty2_Cue'

	HealSound=SoundCue'Betty_Player.Sounds.FxHechizoCura_Cue'

	HitSound=SoundCue'Betty_Player.Sounds.FxGolpeBetty_Cue'

	SlideCue=SoundCue'Betty_slide.Sounds.FxSlide2_Cue'

	AirAttackFinishCue = SoundCue'Betty_Player.Sounds.FxAirAttackFinish_Cue';
	
	
	
	Begin Object Class=SkeletalMeshComponent Name=grenade
		SkeletalMesh=SkeletalMesh'Betty_Player.SkModels.GrenadeSk'
	End Object
	grenadeMesh=grenade

}

