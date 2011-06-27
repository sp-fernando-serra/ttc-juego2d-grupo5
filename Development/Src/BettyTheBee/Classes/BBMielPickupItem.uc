class BBMielPickupItem extends PickupFactory placeable; 

var		SoundCue			PickupSound;

/** Degrees to rotate every second */
var float rotationPerSec;

function SpawnCopyFor( Pawn Recipient )
{
	// Give health to recipient
	BBBettyPawn(Recipient).itemsMiel += 10;
	PlaySound( PickupSound );
	
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

	PickupSound=SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Small_Cue_Modulated'

	rotationPerSec = 90.0f
}


