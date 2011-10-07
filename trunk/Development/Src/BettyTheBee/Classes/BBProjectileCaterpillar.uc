class BBProjectileCaterpillar extends UDKProjectile;

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


function CalcAngle(Vector startPoint, Vector endPoint, Vector Randomness){
	//local float /*IncrZ*/, Dist;
	//local Vector tempVect;
/*
	//IncrZ = endPoint.Z - startPoint.Z;
	tempVect = endPoint - startPoint;
	tempVect.Z = 0;
	Dist = VSize(tempVect);
	if(Dist < 0) Dist = -Dist;
	//El *1.8 del final no tiene sentido, pero sin el no se alcanza el objetivo
	TossZ = (Speed/Dist)*(/*IncrZ */- (GetGravityZ()/2)*Square(Dist/Speed)*1.8);
	//Eliminamos el alcance infinito(mejor hacerlo de otra manera, que ya no dispare si estamos fuera de alcance)
	if (TossZ > Speed) TossZ = Speed;
	//`Log("TossZ = "@ TossZ);
	//`Log("Speed = "@ Speed);
	//`Log("Dist = "@ Dist);
	//`Log("IncrZ = "@ IncrZ);
	//`Log("Gravity = "@ GetGravityZ());
	//`Log("Square(Dist/Speed) = "@ Square(Dist/Speed));
	Init(Normal(tempVect));
	randomize(Randomness);
*/
	//SuggestTossVelocity(tempVect,endPoint,startPoint,2000.0,,,);
	CalculateMinSpeedTrajectory(Velocity,endPoint,startPoint, 2000.0f, 1000.0f);
	randomize(Randomness);
}

function Init(vector Direction)
{
	SetRotation(rotator(Direction));

	Velocity = Speed * Direction;
	Velocity.Z += TossZ;
	//Acceleration = AccelRate * Normal(Velocity);
}

function randomize(Vector Randomness){
	//Calc Randomness
	//`Log("Velocity before random = "@ Velocity);
	Velocity.X += Velocity.X * Randomness.X * RandRange(-1,1);
	Velocity.Y += Velocity.Y * Randomness.Y * RandRange(-1,1);
	Velocity.Z += Velocity.Z * Randomness.Z * RandRange(-1,1);
	//`Log("Velocity after random = "@ Velocity);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	//SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed
	//RandSpin(100000);

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
	morph1Weight.SetNodeWeight((Sin(WorldInfo.TimeSeconds*10)+1)/2);
	morph2Weight.SetNodeWeight((Cos(WorldInfo.TimeSeconds*10)+1)/2);

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


simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local vector tempVector;

	if ( Other != Instigator){
		if(BBPawn(Other) != none){
			if(BBBettypawn(Other) != none){
				Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
			}

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
	//Velocity = MirrorVectorByNormal(Velocity,HitNormal); //That's the bounce
	//SetRotation(Rotator(Velocity));

	//TriggerEventClass(class'SeqEvent_HitWall', Wall);
	Landed(HitNormal,Wall);
}


DefaultProperties
{

	
	Begin Object Name=CollisionCylinder
		CollisionRadius=0
		CollisionHeight=0
    End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
    End Object
    Components.Add(MyLightEnvironment)
   
	begin object class=SkeletalMeshComponent Name=BaseMesh
		SkeletalMesh=SkeletalMesh'Betty_caterpillar.SkModels.SpittleSk'
		MorphSets(0)=MorphTargetSet'Betty_caterpillar.SkModels.Spittle_MorphSet'
		AnimTreeTemplate=AnimTree'Betty_caterpillar.SkModels.Spittle_AnimTree'
		Scale=1
		LightEnvironment=MyLightEnvironment
    end object
    Components.Add(BaseMesh)
	Mesh = BaseMesh;

	RibbonParticleSystem = ParticleSystem'Betty_caterpillar.Particles.Spittle_Particles'

	GrenadeImpact_PS = ParticleSystem'Betty_caterpillar.Particles.SpittleImpact_PS';

	ImpactDecalMaterial = DecalMaterial'Betty_caterpillar.Decals.Spittle_Decal';
	
	//Defined in Projectile.uc
	ImpactSound = SoundCue'Betty_Player.Sounds.FxImpactoGranadaMiel_Cue'
	
	//Damage is set by the pawn when he fires the projectile depending on attackDamage of Pawn
    Damage=0
    MomentumTransfer=0

	MyDamageType=class'BBDamageType_EnemyPawn'

	bWorldGeometry=false
	Speed=3500
	MaxSpeed=0
	Physics=PHYS_Falling;
	CustomGravityScaling=0.5
	TossZ=+0.0
	TerminalVelocity=3500.0

	impactDecalScaleSpeed = 384;
}
