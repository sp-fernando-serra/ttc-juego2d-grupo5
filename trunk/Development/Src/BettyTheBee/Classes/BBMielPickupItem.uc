class BBMielPickupItem extends PickupFactory placeable; 

var		SoundCue			PickupSound;

/** Degrees to rotate every second */
var float rotationPerSec;

var ParticleSystem destellos_PS;
var ParticleSystemComponent destellos_PSC;

function SpawnCopyFor( Pawn Recipient )
{
	// Give health to recipient
	if((BBBettyPawn(Recipient).itemsMiel + 10)>999) BBBettyPawn(Recipient).itemsMiel=999;
	else BBBettyPawn(Recipient).itemsMiel += 10;
	
	PlaySound( PickupSound );
	//destellos_PSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(destellos_PS,SkeletalMeshComponent(Mesh),'sword_final',true);
	destellos_PSC = WorldInfo.MyEmitterPool.SpawnEmitter(destellos_PS,Location);
	
	//`log(BBMielPickupItem(Instigator).Location);
	/*if ( PlayerController(Recipient.Controller) != None )
	{
		PlayerController(Recipient.Controller).ReceiveLocalizedMessage(MessageClass,,,,class);
	}*/
}

function Tick( float DeltaTime ){
	local Rotator newRot;
	
	
	newRot = Rotation;
	newRot.Yaw = newRot.Yaw + DeltaTime * rotationPerSec / UnrRotToDeg;
	if(newRot.Yaw > 65535)
		newRot.Yaw = 0;
	SetRotation(newRot);
}


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
	End Object
	PickupMesh=ItemEsfera
	Components.Add(ItemEsfera)

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
}


