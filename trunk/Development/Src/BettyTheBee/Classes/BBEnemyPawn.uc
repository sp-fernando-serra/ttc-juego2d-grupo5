class BBEnemyPawn extends BBPawn abstract
	classGroup(BBActor);

var BBControllerAI MyController;

var float Speed;


/** Distance to see player */
var () float PerceptionDistance<DisplayName=Perception Distance>;
/** Radius to determine wich pawns alert of Player presence */
var () float alertRadius<DisplayName=Alertness Radius>;
/** Attack distance */
var () float AttackDistance<DisplayName=Attack Distance>;
/** Float between 0.0 and 1.0 used to determine the percentage of attackDistance to start attacking.
 *  Used to move Enemy closer than AttackDistance when following the player
 */
var () float AttackDistanceFactor<DisplayName=Attack Distance Factor>;
/** Attack Damage */
var () int AttackDamage<DisplayName=Attack Damage>;
/** If TRUE the pawn will attack the player when he enter in Range of View */
var () bool bAggressive<DisplayName = Is Aggressive?>;
/** Array of BBRoutePoints to patroll */
var () Route MyRoutePoints;

/** Time this pawn remains stunned*/
var () float timeStunned;
/** Reference to AntHill if this enemy has spawned by a AntHill */
var BBAntHill antHill;

var bool bIsDying;
var class<BBDamageType> MyDamageType;

/** AnimNode used to play custom anims */
var AnimNodePlayCustomAnim customAnimSlot;

var name attackAnimName;
var name searchingAnimName;
var name dyingAnimName;
var name stunnedAnimName;

var ParticleSystem TargetedPawn_PS;
var ParticleSystemComponent TargetedPawn_PSC;

var ParticleSystem stunnedPS;
var ParticleSystemComponent stunnedPSC;

//var ParticleSystem DamagePawn_PS;
//var ParticleSystemComponent DamagePawn_PSC;

var ParticleSystem Exclamacion_PS;
var ParticleSystemComponent Exclamacion_PSC;

var ParticleSystem DeadPS;

var(Debug) bool bDrawVision;
var(Debug) bool bDrawHearing;
var(Debug) bool bDrawAttackRange;


simulated function PostBeginPlay()
{
	//local Vector SocketLocation;
	//local Rotator SocketRotation;

	super.PostBeginPlay();
	SightRadius = PerceptionDistance;
	SetPhysics(PHYS_Walking);
	
	//Mesh.GetSocketWorldLocationAndRotation('centro', SocketLocation, SocketRotation, 0 /* Use 1 if you wish to return this in component space*/ );
	//Mesh.AttachComponentToSocket(ParticlesComponent_enemigoFijado, 'centro');
	//ParticlesComponent_enemigoFijado.SetTemplate(Particles_enemigoFijado_Emitter);
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		customAnimSlot = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomAnim'));
	}
}

event Tick(float DeltaTime){
	local Color col;

	super.Tick(DeltaTime);
	if(bDebug && !isDying() && !isDead()){
		col.B=100.0f;
		col.G=20.0f;
		col.R=0.0f;
		col.A=255.0f;
		//Blue cone is vision
		if(bDrawVision)
			DrawDebugCone(Location,Vector(Rotation),SightRadius,(1-Square(PeripheralVision)),0.15,32,col,false);
		//Green sphere attack range
		if(bDrawAttackRange)
			DrawDebugSphere(Location,AttackDistance + GetCollisionRadius(),16,0.0,100.0,25.0,false);
		//Light blue sphere hearing range
		if(bDrawHearing)
			DrawDebugSphere(Location,HearingThreshold,16,0.0,100.0,150.0,false);
	}
}

simulated event Destroyed(){
	super.Destroyed();
	if(antHill != none)
		antHill.DestroyedAnt(self);
}

/**	Handling Toggle event from Kismet. */
simulated function OnToggle(SeqAct_Toggle Action)
{
	// Turn ON
	if (Action.InputLinks[0].bHasImpulse)
	{
		bAggressive = true;
	}
	// Turn OFF
	else if (Action.InputLinks[1].bHasImpulse)
	{
		bAggressive = false;
	}
	// Toggle
	else if (Action.InputLinks[2].bHasImpulse)
	{
		bAggressive = !bAggressive;
	}
	BBControllerAI(Controller).OnToggle(Action);
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

function playPariclesFijado()
{
	 local string tipo_enemigo;
	//ParticlesComponent_enemigoFijado.SetActive(true);
	TargetedPawn_PSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(TargetedPawn_PS,Mesh,'centro',true);
	
	tipo_enemigo=string(Instigator.Class);

	switch(tipo_enemigo)
			{
				case "BBEnemyPawnAnt" : 
					TargetedPawn_PSC.SetScale(1);
					break;
				case "BBEnemyPawnCaterpillar" :
					TargetedPawn_PSC.SetScale(1.5);
					break;
				case "BBEnemyPawnRhino" : 
					TargetedPawn_PSC.SetScale(1.3);
					break;
			}

}

function stopPariclesFijado(){
	//`log("stop");
	//ParticlesComponent_enemigoFijado.SetActive(false);
	if(TargetedPawn_PSC != none) TargetedPawn_PSC.SetActive(false);
}

function playParticlesExclamacion(){
	Exclamacion_PSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(Exclamacion_PS,Mesh,'exclamacion',true);
}

function PlaySearchingAnim(){
	if(searchingAnimName != '')
		customAnimSlot.PlayCustomAnim(searchingAnimName, 1.0f, 0.25f, 0.25f, true, true);
}

function StopSearchingAnim(){
	customAnimSlot.StopCustomAnim(0.25f);
}

function bool Died(Controller Killer, class<DamageType> tempDamageType, Vector HitLocation){
	local SeqAct_Latent Action;

	// ensure a valid damagetype
	if ( tempDamageType == None )
	{
		tempDamageType = class'DamageType';
	}
	// if already destroyed or level transition is occuring then ignore
	if ( bDeleteMe || WorldInfo.Game == None || WorldInfo.Game.bLevelChange )
	{
		return FALSE;
	}
	// if this is an environmental death then refer to the previous killer so that they receive credit (knocked into lava pits, etc)
	if ( tempDamageType.default.bCausedByWorld && (Killer == None || Killer == Controller) && LastHitBy != None )
	{
		Killer = LastHitBy;
	}
	// gameinfo hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( WorldInfo.Game.PreventDeath(self, Killer, tempDamageType, HitLocation) )
	{
		Health = max(Health, 1);
		return false;
	}
	Health = Min(0, Health);
	
	// activate death events
	if( default.KismetDeathDelayTime > 0 )
	{
		DelayTriggerDeath();
	}
	else
	{
		TriggerEventClass( class'SeqEvent_Death', self );
	}

	KismetDeathDelayTime = default.KismetDeathDelayTime + WorldInfo.TimeSeconds;

	// and abort any latent actions
	foreach LatentActions(Action)
	{
		Action.AbortFor(self);
	}
	LatentActions.Length = 0;
	// notify the vehicle we are currently driving
	//if ( DrivenVehicle != None )
	//{
	//	Velocity = DrivenVehicle.Velocity;
	//	DrivenVehicle.DriverDied(DamageType);
	//}
	//else if ( Weapon != None )
	//{
	//	Weapon.HolderDied();
	//	ThrowWeaponOnDeath();
	//}
	// notify the gameinfo of the death
	//if ( Controller != None )
	//{
	//	WorldInfo.Game.Killed(Killer, Controller, self, damageType);
	//}
	//else
	//{
	//	WorldInfo.Game.Killed(Killer, Controller(Owner), self, damageType);
	//}
	//DrivenVehicle = None;
	// notify inventory manager
	//if ( InvManager != None )
	//{
	//	InvManager.OwnerDied();
	//}
	// push the corpse upward (@fixme - somebody please remove this?)
	//Velocity.Z *= 1.3;
	// if this is a human player then force a replication update
	//if ( IsHumanControlled() )
	//{
	//	PlayerController(Controller).ForceDeathUpdate();
	//}
	//NetUpdateFrequency = Default.NetUpdateFrequency;
	PlayDying(tempDamageType, HitLocation);
	return TRUE;
}

//=============================================================================
// Animation interface for controllers

/* PlayXXX() function called by controller to play transient animation actions
*/
/* PlayDying() is called on server/standalone game when killed
and also on net client when pawn gets bTearOff set to true (and bPlayedDeath is false)
*/
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	super.PlayDying(DamageType, HitLoc);

	customAnimSlot.PlayCustomAnim(dyingAnimName,1.0f,0.25,-1.0f,false,true);
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){
	Damage = Max(Damage, 0);
	if(Damage > 0){
		playDamaged();
		if(Health > 0){
			Health -= Damage;
		}
		if(Health <= 0){
			Health = 0;
			Controller.GotoState('Stunned');
		}
	}
}

function playDamaged(){

}

function bool isDying(){
	return IsInState('Dying');
}

function bool isDead(){
	return IsInState('Dead');
}

simulated state Stunned{
	simulated event BeginState(name PreviousStateName){		
		super.BeginState(PreviousStateName);
		//Controller.GotoState('Stunned');
		stunnedPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(stunnedPS, Mesh, 'exclamacion', true, , rot(90,0,0));
		customAnimSlot.PlayCustomAnim(stunnedAnimName,1.0f,0.25f,0.0f,true,true);		
	}

	simulated event EndState(name NextStateName){
		super.EndState(NextStateName);
		stunnedPSC.SetActive(false);
		Health = HealthMax;
	}

	event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){
		if(class<BBDamageType_AirAttack>(DamageType) != none){
			WorldInfo.MyEmitterPool.SpawnEmitter(DeadPS, Location, Rotation);
			if(controller != none)
				Controller.Destroy();
			//Activamos todos los eneventos de Pawn Dead
			TriggerGlobalEventClass(class'SeqEvent_Death', self);
			Destroy();
		}
	}

Begin:
	Sleep(timeStunned);
	Controller.GotoState('Idle');
}

simulated state Dying{
	simulated event BeginState(Name PreviousStateName){
		super.BeginState(PreviousStateName);
		stopPariclesFijado();
	}
}

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

	AttackDistanceFactor = 0.6f;


	//PeripheralVision is Cos of desired vision angle cos(45) = 0.707106
	PeripheralVision = 0.707106;

	alertRadius = +800.0
	
	//Pawn can hear through walls
	bMuffledHearing = false
	//Max distance to hear a 1.0 noise
	HearingThreshold = +600.0

	timeStunned = 8.0f;

	RotationRate=(Pitch=40000,Yaw=40000,Roll=20000)

	TargetedPawn_PS=ParticleSystem'Betty_Particles.enemigos.enemigo_fijado'

	Exclamacion_PS=ParticleSystem'Betty_ant.PS.PS_exclamacion'

	stunnedPS = ParticleSystem'Betty_ant.PS.StunnedStars_PS';

	MyDamageType = class'BBDamageType_EnemyPawn'

}