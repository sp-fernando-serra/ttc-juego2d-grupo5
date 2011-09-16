class BBMielPickupItem extends PickupFactory placeable; 

/** Amount of Honey this item have. The item will be larger if Honey is bigger */
var() int honey<ClampMin=1 | ClampMax=15>;

var		SoundCue			PickupSound;

/** Degrees to rotate every second */
var float rotationPerSec;

var ParticleSystem destellos_PS;
var ParticleSystemComponent destellos_PSC;

event postBeginPlay(){
	super.PostBeginPlay();
	
	//El item es mas grande cuanta mas miel da
	SetDrawScale(1.0 + honey/10.0);
}

function SpawnCopyFor( Pawn Recipient )
{
	// Give health to recipient
	BBBettyPawn(Recipient).itemsMiel += honey;
	if((BBBettyPawn(Recipient).itemsMiel) > 999) BBBettyPawn(Recipient).itemsMiel=999;
		

	BBHUD(BBPlayerController(Recipient.Controller).myHUD).startAnimacioItem();
	PlaySound( PickupSound );
	//destellos_PSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(destellos_PS,SkeletalMeshComponent(Mesh),'sword_final',true);
	destellos_PSC = WorldInfo.MyEmitterPool.SpawnEmitter(destellos_PS,Location);
	
	//`log(BBMielPickupItem(Instigator).Location);
	/*if ( PlayerController(Recipient.Controller) != None )
	{
		PlayerController(Recipient.Controller).ReceiveLocalizedMessage(MessageClass,,,,class);
	}*/
}



//function Tick( float DeltaTime ){
//	local Rotator newRot;
	
	
//	newRot = Rotation;
//	newRot.Yaw = newRot.Yaw + DeltaTime * rotationPerSec / UnrRotToDeg;
//	if(newRot.Yaw > 65535)
//		newRot.Yaw = 0;
//	SetRotation(newRot);
//}


DefaultProperties
{
	Begin Object class=DynamicLightEnvironmentComponent name=theLightEnvironment
	End Object
	Components.Add(theLightEnvironment)

	 Begin Object class=StaticMeshComponent Name=ItemEsfera
		CastShadow=false
		bAcceptsLights=true
		CollideActors=false
		BlockActors=false
        StaticMesh=StaticMesh'Betty_item.Models.Item'
        bNotifyRigidBodyCollision=true
		LightEnvironment=theLightEnvironment
		Scale3D=(X=1.0f,Y=0.4f,Z=1.0f)
	End Object
	PickupMesh=ItemEsfera
	Components.Add(ItemEsfera)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0040.000000
		CollisionHeight=+0045.000000
	End Object
	CylinderComponent=CollisionCylinder

	bMovable = true;
	bStatic = false;
	/*Begin Object class=CylinderComponent Name=BettyCollision
		CollisionRadius=+5
	End Object
	*/

	InventoryType=class'BettyTheBee.BBInventory'

	PickupSound=SoundCue'Betty_Sounds.Pickup_cue'

	destellos_PS=ParticleSystem'Betty_item.PS.magicMissleImpact_vFX'

	rotationPerSec = 90.0f

	Physics = PHYS_Rotating

	RotationRate = (Pitch=16384, Yaw=8192, Roll=0)


	//Para no considerarlo como punto de ruta para la IA
	bBlocked = true

	honey = 1;
}


