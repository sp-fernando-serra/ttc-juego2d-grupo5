class BBProjectileGrenade  extends UDKProjectile;


var float TossZ;
/** Plantilla del ParticleSystem a generar */
var ParticleSystem RibbonParticleSystem;
/** Referencia al ParticleSystemComponent generado */
var ParticleSystemComponent PSC;
/** Mesh de la granada */
var SkeletalMeshComponent Mesh;

/** Morph1 para hacer el SkeletalMesh dinamico */
var MorphNodeWeight morph1Weight;
/** Morph1 para hacer el SkeletalMesh dinamico */
var MorphNodeWeight morph2Weight;

///** Sound used when grenade impacts on something */
//var SoundCue impactSound;


function Init(vector Direction)
{
	local vector newVecDirection;

	local BBBettyPawn UTP;

	UTP = BBBettyPawn(Instigator);

	newVecDirection=vector(UTP.Rotation);
	newVecDirection.Z=Direction.Z;

	//SetRotation(rotator(Direction));
	
	
	//`log("GetFOVAngle"@camera.GetFOVAngle());
	

	Velocity = Speed * newVecDirection;
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
			
	//Obtenemos los dos WeightMorphNodes
	morph1Weight = MorphNodeWeight(Mesh.FindMorphNode('morph1'));
	morph2Weight = MorphNodeWeight(Mesh.FindMorphNode('morph2'));	
	
	//Spawneamos el sistema de particulas y lo atachamos guardando una referencia en PSC
	PSC = WorldInfo.MyEmitterPool.SpawnEmitter(RibbonParticleSystem,Location,, self,);
}

function Tick( float DeltaTime ){
	//local float incr;
	//incr = 0.1;

	//Cada tick cambiamos los pesos de los Morphs para conseguir un comportamiento como de miel
	morph1Weight.SetNodeWeight((Sin(WorldInfo.TimeSeconds*15)+1));
	morph2Weight.SetNodeWeight((Cos(WorldInfo.TimeSeconds*15)+1));
	
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{

    if ( Other != Instigator )
    {
	WorldInfo.MyDecalManager.SpawnDecal
	(
	    DecalMaterial'Betty_Player.Decals.Honey_Decal',
	    HitLocation,	 
	    rotator(-HitNormal),	
	    128, 128,	                          
	    256,	                               
	    false,	                   
	    FRand() * 360,	        
	    none        
	);  

	if(BBEnemyPawn(Other) != none)
		Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);

	PlaySound(ImpactSound);
	PSC.DeactivateSystem();
	Destroy();
    }
}

//simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
//{
//    WorldInfo.MyDecalManager.SpawnDecal
//    (
//	MaterialInstanceTimeVarying'CH_Gibs.Decals.BloodSplatter',	// UMaterialInstance used for this decal.
//	Impact.HitLocation,	                            // Decal spawned at the hit location.
//	rotator(-Impact.HitNormal),	                    // Orient decal into the surface.
//	128, 128,	                                    // Decal size in tangent/binormal directions.
//	256,	                                        // Decal size in normal direction.
//	false,	                                        // If TRUE, use "NoClip" codepath.
//	FRand() * 360,	                                // random rotation
//	Impact.HitInfo.HitComponent                     // If non-NULL, consider this component only.
//    );          
//	Destroy();
//}

simulated event Landed ( vector HitNormal, actor FloorActor ) {
	 
	local vector HitLocation;	
	Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));
	
	WorldInfo.MyDecalManager.SpawnDecal
	(
	    DecalMaterial'Betty_Player.Decals.Honey_Decal',
	    HitLocation,	 
	    rotator(-HitNormal),	
	    128, 128,	                          
	    256,	                               
	    false,	                   
	    FRand() * 360,	        
	    none        
	);
	
	//Desactivamos la instancia del PSC
	//HitLocation.Z = HitLocation.Z - 60;
	//PSC.SetTranslation(HitLocation);
	PlaySound(ImpactSound);
	PSC.DeactivateSystem();
	//Destruimos el projectil
	Destroy();
}

simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
//   Velocity = MirrorVectorByNormal(Velocity,HitNormal); //That's the bounce
//    SetRotation(Rotator(Velocity));

//    TriggerEventClass(class'SeqEvent_HitWall', Wall);
	Landed(HitNormal,Wall);

}


DefaultProperties
{	
	Begin Object Name=CollisionCylinder
		CollisionRadius=12
		CollisionHeight=24
    End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	bEnabled=TRUE		
    End Object
    Components.Add(MyLightEnvironment)
   
	begin object class=SkeletalMeshComponent Name=BaseMesh
		SkeletalMesh=SkeletalMesh'Betty_Player.SkModels.GrenadeSk'
		MorphSets(0)=MorphTargetSet'Betty_Player.SkModels.Grenade_MorphSet'
		AnimTreeTemplate=AnimTree'Betty_Player.SkModels.Grenade_AnimTree'
		//PhysicsAsset=PhysicsAsset'Betty_Player.SkModels.Grenade_Physics'
		Scale=1
		LightEnvironment=MyLightEnvironment
    end object
    Components.Add(BaseMesh)
	Mesh = BaseMesh;

    Damage=25
    MomentumTransfer=10

	bWorldGeometry=false
	Speed=500
	MaxSpeed=1000.0
	Physics=PHYS_Falling;
	CustomGravityScaling=1
	TossZ=+400.0
	TerminalVelocity=3500.0

	RibbonParticleSystem = ParticleSystem'Betty_Player.Particles.Grenade_Particles'
	
	//Defined in Projectile.uc
	ImpactSound = SoundCue'Betty_Player.Sounds.FxImpactoGranadaMiel_Cue'


	
}
