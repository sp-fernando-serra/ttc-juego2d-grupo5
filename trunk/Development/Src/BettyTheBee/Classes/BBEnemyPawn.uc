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
var AnimNodeSequence MyAnimPlayControl;

var () float PerceptionDistance<DisplayName=Perception Distance>;
var () float AttackDistance<DisplayName=Attack Distance>;
var () int AttackDamage<DisplayName=Attack Damage>;
var () bool bAggressive<DisplayName = Is Aggressive?>;

var () array<BBRoutePoint> MyRoutePoints;


var ParticleSystemComponent ParticlesComponent_enemigoFijado;
//var ParticleSystem Particles_enemigoFijado_Emitter;

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

	begin object class=particlesystemcomponent name=particlesystemcomponent0
		Template=ParticleSystem'Betty_Particles.enemigos.enemigo_fijado'
		bAutoActivate=false
           //secondsbeforeinactive=10
    end object
	ParticlesComponent_enemigoFijado=particlesystemcomponent0
     components.add(particlesystemcomponent0)

	//Particles_enemigoFijado_Emitter=ParticleSystem'Betty_Particles.enemigos.enemigo_fijado'

}

simulated function PostBeginPlay()
{
	local Vector SocketLocation;
	local Rotator SocketRotation;

	super.PostBeginPlay();
	SightRadius = PerceptionDistance;
	SetPhysics(PHYS_Walking);	


	Mesh.GetSocketWorldLocationAndRotation('centro', SocketLocation, SocketRotation, 0 /* Use 1 if you wish to return this in component space*/ );
	//ParticlesComponent_enemigoFijado.SetTemplate(Particles_enemigoFijado_Emitter);
}

function playPariclesFijado()
{
	//`log("play");
	//ParticlesComponent_enemigoFijado.ActivateSystem();
	ParticlesComponent_enemigoFijado.SetActive(true);

}

function stopPariclesFijado(){
	//`log("stop");
	//ParticlesComponent_enemigoFijado.DeactivateSystem();
	ParticlesComponent_enemigoFijado.SetActive(false);
}

state ChasePlayer{

}

state Idle{

}

