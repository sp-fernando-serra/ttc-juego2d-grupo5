class BBProjectileLocation extends UDKProjectile;


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

//simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
//{
//    if ( Other != Instigator )
//    {
//	WorldInfo.MyDecalManager.SpawnDecal
//	(
//	    DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak',
//	    HitLocation,	 
//	    rotator(-HitNormal),	
//	    128, 128,	                          
//	    256,	                               
//	    false,	                   
//	    FRand() * 360,	        
//	    none        
//	);  

	
//	Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
//	//Worldinfo.Game.Broadcast(self, Name $ ": Health "$Pawn(Other).Health);
//	Worldinfo.Game.Broadcast(self, Name $ ": ProcessTouchhitlocation "$hitlocation);
//	//Worldinfo.Game.Broadcast(self, Name $ ": HitNormal "$HitNormal);
//	Destroy();
//    }
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
	Scale=0.1
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

	LifeSpan=0.0
	
}
