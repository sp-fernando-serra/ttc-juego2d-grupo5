class BBProjectileCaterpillar extends UDKProjectile;

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
	
}


simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if ( Other != Instigator )
    {
	WorldInfo.MyDecalManager.SpawnDecal
	(
	    DecalMaterial'Betty_caterpillar.Decals.Spittle_Decal',
	    HitLocation,	 
	    rotator(-HitNormal),	
	    128, 128,	                          
	    256,	                               
	    false,	                   
	    FRand() * 360,	        
	    none        
	);  

	
	Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);

	PSC.DeactivateSystem();
	Destroy();
    }
}

simulated event Landed ( vector HitNormal, actor FloorActor ) {
	 
	local vector HitLocation;
	//HitNormal = normal(Velocity * -1);
	Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));	
	//Worldinfo.Game.Broadcast(self, Name $ ": HitNormal "$HitNormal);
	
		WorldInfo.MyDecalManager.SpawnDecal
	(
	    DecalMaterial'Betty_caterpillar.Decals.Spittle_Decal',
	    HitLocation,	 
	    rotator(-HitNormal),	
	    128, 128,	                          
	    256,	                               
	    false,	                   
	    FRand() * 360,	        
	    none        
	);  

	PSC.DeactivateSystem();
	Destroy();
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
		CollisionRadius=12
		CollisionHeight=24
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

    Damage=0
    MomentumTransfer=10

	bWorldGeometry=false
	Speed=1500
	MaxSpeed=0
	Physics=PHYS_Falling;
	CustomGravityScaling=0.5
	TossZ=+0.0
	TerminalVelocity=3500.0	
}
