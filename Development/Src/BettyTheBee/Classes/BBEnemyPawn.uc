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
var AnimNodeBlendList nodeListAttack;
var AnimNodeSequence MyAnimPlayControl;

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


var ParticleSystem TargetedPawn_PS;
var ParticleSystemComponent TargetedPawn_PSC;


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
		

}

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
		nodeListAttack = AnimNodeBlendList(Mesh.FindAnimNode('listAttack'));
		//attackAnim = AnimNodeSequence(Mesh.FindAnimNode('ATTACK'));
	}
}


function playPariclesFijado()
{
	 local string tipo_enemigo;
	//`log("play");
	//ParticlesComponent_enemigoFijado.SetActive(true);
	TargetedPawn_PSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(TargetedPawn_PS,Mesh,'centro',true);
	//`log(Mesh);
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

state ChasePlayer{

}

state Idle{

}

state Dying{
	event BeginState(Name PreviousStateName)
	{
		stopPariclesFijado();
		nodeListAttack.SetActiveChild(5,0.2f);
		super.BeginState(PreviousStateName);
	}

}

