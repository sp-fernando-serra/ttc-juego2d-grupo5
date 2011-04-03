class BBMielPickupItem extends PickupFactory; 

var		SoundCue			PickupSound;

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
        StaticMesh=StaticMesh'EngineMeshes.Sphere'
        bNotifyRigidBodyCollision=true
	End Object
	PickupMesh=ItemEsfera
	Components.Add(ItemEsfera)

	/*Begin Object class=CylinderComponent Name=BettyCollision
		CollisionRadius=+5
	End Object
	*/

	InventoryType=class'BettyTheBee.BBInventory'

	PickupSound=SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Small_Cue_Modulated'
}


