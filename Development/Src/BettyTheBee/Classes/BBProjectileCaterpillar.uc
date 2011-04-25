class BBProjectileCaterpillar extends UDKProjectile;

var float TossZ;

function CalcAngle(Vector startPoint, Vector endPoint){
	local float IncrZ, Dist;
	local Vector tempVect;

	IncrZ = endPoint.Z - startPoint.Z;
	tempVect = endPoint - startPoint;
	tempVect.Z = 0;
	Dist = VSize(tempVect);
	if(Dist < 0) Dist = -Dist;
	//El *2 del final no tiene sentido, pero sin el no se alcanza el objetivo
	TossZ = (Speed/Dist)*(IncrZ - (GetGravityZ()/2)*Square(Dist/Speed))*2;
	//Eliminamos el alcance infinito(mejor hacerlo de otra manera, que ya no dispare si estamos fuera de alcance)
	if (TossZ > Speed) TossZ = Speed;
	//`Log("TossZ = "@ TossZ);
	//`Log("Speed = "@ Speed);
	//`Log("Dist = "@ Dist);
	//`Log("IncrZ = "@ IncrZ);
	//`Log("Gravity = "@ GetGravityZ());
	//`Log("Square(Dist/Speed) = "@ Square(Dist/Speed));
	Init(Normal(tempVect));

}

function Init(vector Direction)
{
	SetRotation(rotator(Direction));

	Velocity = Speed * Direction;
	Velocity.Z += TossZ;
	//`Log("Velocity = "@ Velocity);
	//Acceleration = AccelRate * Normal(Velocity);
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
	Scale=0.05
	LightEnvironment=MyLightEnvironment
    end object
    Components.Add(BaseMesh)

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
