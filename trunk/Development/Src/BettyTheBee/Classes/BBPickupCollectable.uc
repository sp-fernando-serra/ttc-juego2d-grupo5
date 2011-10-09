class BBPickupCollectable extends PickupFactory placeable; 

var		SoundCue			PickupSound;

/** Degrees to rotate every second */
var float rotationPerSec;

var ParticleSystem destellos_PS;
var ParticleSystemComponent destellos_PSC;

//event postBeginPlay(){
//	super.PostBeginPlay();
//}

function SpawnCopyFor( Pawn Recipient )
{
	local BBBettyPawn tempPawn;

	tempPawn = BBBettyPawn(Recipient);
	if(tempPawn != none){
		tempPawn.CollectableCaught(self);
		BBHUD(BBPlayerController(tempPawn.Controller).myHUD).startAnimacioColeccionable();
		PlaySound( PickupSound );
		destellos_PSC = WorldInfo.MyEmitterPool.SpawnEmitter(destellos_PS,Location);		
	}else{
		`warn("Honey Item caught by:" @ Recipient.GetHumanReadableName());
	}
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
        StaticMesh=StaticMesh'Betty_item.Models.SpecialItem'
        bNotifyRigidBodyCollision=true
		LightEnvironment=theLightEnvironment
		Scale = 3;
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
	
	InventoryType=class'BettyTheBee.BBInventory'

	PickupSound=SoundCue'Betty_Sounds.Pickup_cue'

	destellos_PS=ParticleSystem'Betty_item.PS.magicMissleImpact_vFX'

	rotationPerSec = 90.0f

	Physics = PHYS_Rotating

	RotationRate = (Pitch=0, Yaw=8192, Roll=0)


	//Para no considerarlo como punto de ruta para la IA
	bBlocked = true
}