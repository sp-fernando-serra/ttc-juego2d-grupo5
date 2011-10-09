class BBProjectileGrenade  extends UDKProjectile;

/** True if Projectile has impacted. To controll the Impactdecal Drawscale */
var bool bImpacted;
/** Amount to increment the scale of decal each second */
var float impactDecalScaleSpeed;

var float TossZ;
/** Plantilla del ParticleSystem a generar */
var ParticleSystem RibbonParticleSystem;
/** Referencia al ParticleSystemComponent generado */
var ParticleSystemComponent PSC;
/** PS al impactar contra algo */
var particleSystem GrenadeImpact_PS;
/** Mesh de la granada */
var SkeletalMeshComponent Mesh;

var DecalMaterial ImpactDecalMaterial;

var DecalComponent SpawnedImpactDecal;

/** Morph1 para hacer el SkeletalMesh dinamico */
var MorphNodeWeight morph1Weight;
/** Morph1 para hacer el SkeletalMesh dinamico */
var MorphNodeWeight morph2Weight;

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

	if(bImpacted){
		SpawnedImpactDecal.Width += impactDecalScaleSpeed * DeltaTime;
		SpawnedImpactDecal.Height += impactDecalScaleSpeed * DeltaTime;
		SpawnedImpactDecal.ForceUpdate(false);
		if(SpawnedImpactDecal.Width >= 150){
			SpawnedImpactDecal = none;
			bImpacted = false;
			Destroy();
		}
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal){

	local vector tempVector;

	if ( Other != Instigator){
		if(BBEnemyPawn(Other) != none){
			Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);

			tempVector = HitLocation;
			tempVector.Z += Pawn(Other).GetCollisionHeight();
			SpawnedImpactDecal = WorldInfo.MyDecalManager.SpawnDecal
			(
				ImpactDecalMaterial,
				tempVector,	 
				OrthoRotation(vect(0,0,-1), vect(0,1,0), vect(1,0,0)),
				1, 1,
				256,
				false,
				FRand() * 360,
				none
			);			
			//Substract 2 * CollisionHeight because before we added 1 * CollisionHeight
			tempVector.Z -= Pawn(Other).GetCollisionHeight() * 2;
			//Spawn the Impact particles
			WorldInfo.MyEmitterPool.SpawnEmitter(GrenadeImpact_PS, tempVector, OrthoRotation(vect(0,0,1), vect(0,1,0), vect(-1,0,0))).SetScale(0.75);
		}else{
			SpawnedImpactDecal = WorldInfo.MyDecalManager.SpawnDecal
			(
				ImpactDecalMaterial,
				HitLocation + 64 * HitNormal,
				rotator(-HitNormal),
				1, 1,
				256,
				false,
				FRand() * 360,
				none,
				true,
				true
			);
			//Spawn the Impact particles
			WorldInfo.MyEmitterPool.SpawnEmitter(GrenadeImpact_PS, HitLocation, rotator(HitNormal)).SetScale(0.75);
		}
		SpawnedImpactDecal.bMovableDecal = true;
		BBGameInfo(WorldInfo.Game).depthBiasLastDecal -= 0.000010;
		SpawnedImpactDecal.DepthBias = BBGameInfo(WorldInfo.Game).depthBiasLastDecal;

		PlaySound(ImpactSound);
		PSC.DeactivateSystem();
		bImpacted = true;
		Mesh.SetHidden(true);
		SetPhysics(PHYS_None);
		SetCollision(false, false);
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
	 
	//Do not use trace, use Actor Location modified by HitNormal
	//Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));
	
	//Location + 64 * HitNormal for spawning decal at 64 distance of the hit wall
	SpawnedImpactDecal = WorldInfo.MyDecalManager.SpawnDecal
	(
		ImpactDecalMaterial,
		Location + 64 * HitNormal,
		rotator(-HitNormal),
		1, 1,
		256,
		false,
		FRand() * 360,
		none
	);
	WorldInfo.MyEmitterPool.SpawnEmitter(GrenadeImpact_PS, Location, rotator(HitNormal)).SetScale(0.75);

	SpawnedImpactDecal.bMovableDecal = true;
	BBGameInfo(WorldInfo.Game).depthBiasLastDecal -= 0.000010;
	SpawnedImpactDecal.DepthBias = BBGameInfo(WorldInfo.Game).depthBiasLastDecal;
	
	PlaySound(ImpactSound);
	PSC.DeactivateSystem();
	//Preparamos la destruccion del proyectil
	bImpacted = true;
	Mesh.SetHidden(true);
	SetPhysics(PHYS_None);
	SetCollision(false, false);
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
		CollisionRadius=0
		CollisionHeight=0
    End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE		
    End Object
    Components.Add(MyLightEnvironment)
   
	begin object class=SkeletalMeshComponent Name=BaseMesh
		SkeletalMesh=SkeletalMesh'Betty_Player.SkModels.GrenadeSk'
		MorphSets(0)=MorphTargetSet'Betty_Player.SkModels.Grenade_MorphSet'
		AnimTreeTemplate=AnimTree'Betty_Player.SkModels.Grenade_AnimTree'
		Scale=1
		LightEnvironment=MyLightEnvironment
    end object
    Components.Add(BaseMesh)
	Mesh = BaseMesh;

	//Enough to stun a ant 
    Damage=50
    //MomentumTransfer=0

	//bWorldGeometry=false
	Speed=500
	MaxSpeed=1000.0
	Physics=PHYS_Falling;
	CustomGravityScaling=1
	TossZ=+400.0
	TerminalVelocity=3500.0

	impactDecalScaleSpeed = 384;

	RibbonParticleSystem = ParticleSystem'Betty_Player.Particles.Grenade_Particles'
	GrenadeImpact_PS = ParticleSystem'Betty_Player.Particles.GrenadeImpact_PS';

	ImpactDecalMaterial = DecalMaterial'Betty_Player.Decals.Honey_Decal';
	
	//Defined in Projectile.uc
	ImpactSound = SoundCue'Betty_Player.Sounds.FxImpactoGranadaMiel_Cue'


	
}
