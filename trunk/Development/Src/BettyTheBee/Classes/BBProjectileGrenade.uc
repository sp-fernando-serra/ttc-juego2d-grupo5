class BBProjectileGrenade  extends UDKProjectile;


var float TossZ;
var ParticleSystemComponent RibbonParticleSystem;

var SkeletalMeshComponent Mesh;

var MorphNodeWeight morph1Weight;
var MorphNodeWeight morph2Weight;



function Init(vector Direction)
{
	SetRotation(rotator(Direction));
	Velocity = Speed * Direction;
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	//SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed
	//RandSpin(100000);
		
	//Obtenemos los dos WeightMorphNodes
	morph1Weight = MorphNodeWeight(Mesh.FindMorphNode('morph1'));
	morph2Weight = MorphNodeWeight(Mesh.FindMorphNode('morph2'));
	
	
	
	WorldInfo.MyEmitterPool.SpawnEmitter(RibbonParticleSystem.Template,Location,, self,);
	//RibbonParticleSystem.ActivateSystem(true);
	//AttachComponent(RibbonParticleSystem);
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
	    DecalMaterial'Betty_Player.Decals.Honey_Decal',
	    HitLocation,	 
	    rotator(-HitNormal),	
	    128, 128,	                          
	    256,	                               
	    false,	                   
	    FRand() * 360,	        
	    none        
	);  

	
	Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
	//Worldinfo.Game.Broadcast(self, Name $ ": Health "$Pawn(Other).Health);
	//Worldinfo.Game.Broadcast(self, Name $ ": Grenadehitlocation "$hitlocation);
	//Worldinfo.Game.Broadcast(self, Name $ ": location "$PC);
	//Worldinfo.Game.Broadcast(self, Name $ ": HitNormal "$HitNormal);
	RibbonParticleSystem.DetachFromAny();
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
	local int i;
	//HitNormal = normal(Velocity * -1);
	Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));
	Worldinfo.Game.Broadcast(self, Name $ ": HitLocation "$HitLocation);
	//Worldinfo.Game.Broadcast(self, Name $ ": HitNormal "$HitNormal);
	
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
	//i = WorldInfo.MyEmitterPool.ActiveComponents.Find(RibbonParticleSystem);
	//if(i > -1)
	//	WorldInfo.MyEmitterPool.ActiveComponents[i].DeactivateSystem();
	RibbonParticleSystem.DetachFromAny();
	Destroy();
}

//simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
//{
//   Velocity = MirrorVectorByNormal(Velocity,HitNormal); //That's the bounce
//    SetRotation(Rotator(Velocity));

//    TriggerEventClass(class'SeqEvent_HitWall', Wall);

//}


DefaultProperties
{	
	Begin Object Name=CollisionCylinder
	CollisionRadius=8
	CollisionHeight=16
    End Object

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

    Damage=25
    MomentumTransfer=10

	bWorldGeometry=false
	Speed=500
	MaxSpeed=1000.0
	Physics=PHYS_Falling;
	CustomGravityScaling=1
	TossZ=+400.0
	TerminalVelocity=3500.0

	begin object class=ParticleSystemComponent Name=Particles
		Template=ParticleSystem'Betty_Player.Particles.Grenade_Particles'
	end object
	Components.Add(Particles)
	RibbonParticleSystem = Particles
	
}
