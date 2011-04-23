class BBProjectileGrenade  extends UDKProjectile;


var float TossZ;

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
	SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed
	RandSpin(100000);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{


    if ( Other != Instigator )
    {
	WorldInfo.MyDecalManager.SpawnDecal
	(
	    DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak',
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
	//HitNormal = normal(Velocity * -1);
	Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));
	Worldinfo.Game.Broadcast(self, Name $ ": HitLocation "$HitLocation);
	//Worldinfo.Game.Broadcast(self, Name $ ": HitNormal "$HitNormal);
	
		WorldInfo.MyDecalManager.SpawnDecal
	(
	    DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak',
	    HitLocation,	 
	    rotator(-HitNormal),	
	    128, 128,	                          
	    256,	                               
	    false,	                   
	    FRand() * 360,	        
	    none        
	);  


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
   
	begin object class=StaticMeshComponent Name=BaseMesh
	StaticMesh=StaticMesh'EngineMeshes.Sphere'
	Scale=0.3
	LightEnvironment=MyLightEnvironment
    end object
    Components.Add(BaseMesh)

    Damage=25
    MomentumTransfer=10

	bWorldGeometry=false
	Speed=500
	MaxSpeed=1000.0
	Physics=PHYS_Falling;
	CustomGravityScaling=1
	TossZ=+400.0
	TerminalVelocity=3500.0
	
}
