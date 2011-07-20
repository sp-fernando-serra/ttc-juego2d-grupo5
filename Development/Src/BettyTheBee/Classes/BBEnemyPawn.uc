class BBEnemyPawn extends BBPawn abstract
	classGroup(BBActor);

var BBControllerAI MyController;

var float Speed;


/** Distance to see player */
var () float PerceptionDistance<DisplayName=Perception Distance>;
/** Attack distance */
var () float AttackDistance<DisplayName=Attack Distance>;
/** Attack Damage */
var () int AttackDamage<DisplayName=Attack Damage>;
/** If TRUE the pawn will attack the player when he enter in Range of View */
var () bool bAggressive<DisplayName = Is Aggressive?>;
/** Array of BBRoutePoints to patroll */
var () array<BBRoutePoint> MyRoutePoints;

var bool bIsDying;
var class<DamageType> MyDamageType;

/** AnimNode used to play custom anims */
var AnimNodePlayCustomAnim customAnimSlot;

var name attackAnimName;
var name dyingAnimName;

var ParticleSystem TargetedPawn_PS;
var ParticleSystemComponent TargetedPawn_PSC;

//var ParticleSystem DamagePawn_PS;
//var ParticleSystemComponent DamagePawn_PSC;

var ParticleSystem Exclamacion_PS;
var ParticleSystemComponent Exclamacion_PSC;


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

state ChasePlayer{

}

state Idle{

}

function bool isDying();

state Dying{
	event BeginState(Name PreviousStateName)
	{
		stopPariclesFijado();
		customAnimSlot.PlayCustomAnim(dyingAnimName,1.0f,0.25,0.0f,false,true);		
		super.BeginState(PreviousStateName);
	}

begin:
	Sleep(customAnimSlot.GetCustomAnimNodeSeq().GetTimeLeft() - 0.05f);
	//customAnimSlot.GetCustomAnimNodeSeq().SetPosition(1.0f,false);
	customAnimSlot.StopAnim();
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

	//PeripheralVision is Cos of desired vision angle cos(45) = 0.707106
	PeripheralVision = 0.707106;

	TargetedPawn_PS=ParticleSystem'Betty_Particles.enemigos.enemigo_fijado'

	Exclamacion_PS=ParticleSystem'Betty_ant.PS.PS_exclamacion'

	MyDamageType = class'DamageType'

}

