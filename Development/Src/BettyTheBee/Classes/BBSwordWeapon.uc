class BBSwordWeapon extends UDKWeapon;

//flag que ens diu si hi ha l'animacio d'atac
var bool animacio_attack;

simulated function TimeWeaponEquipping()
{
   // AttachWeaponTo( Instigator.Mesh,'mano_izquierda' );
	AttachWeaponTo( Instigator.Mesh,'sword_socket' );
    super.TimeWeaponEquipping();
}

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
    MeshCpnt.AttachComponentToSocket(Mesh,SocketName);
}

simulated function DetachWeapon()
{
	Instigator.Mesh.DetachComponent( Mesh );
	SetBase(None);
	//Mesh.SetHidden(True);
	//Mesh.SetLightEnvironment(None);
}

//simulated function CustomFire()
//{
//	`log("in ur custom fire!");
//	animacio_attack = true;
//	//hitActor = None;
//	//lastHitActor = None;

//}
simulated function attackStart()
{
	`log("attackStart");
	animacio_attack = true;
}
simulated function attackEnd()
{
	`log("attackEnd");
	animacio_attack = false;
}

simulated function bool getAnimacioFlag(){
	return animacio_attack;
}

simulated event SetPosition(UDKPawn Holder)
{
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;
    local Vector FinalLocation;

    compo = Holder.Mesh;
    if (compo != none)
    {
	//socket = compo.GetSocketByName('WeaponPoint');sword_socket
	socket = compo.GetSocketByName('sword_socket');
	if (socket != none)
	{
	    FinalLocation = compo.GetBoneLocation(socket.BoneName);
	}
    }
    //And we probably should do something similar for the rotation :)
    SetLocation(FinalLocation); 
}
simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
    WorldInfo.MyDecalManager.SpawnDecal
    (
	MaterialInstanceTimeVarying'CH_Gibs.Decals.BloodSplatter',	// UMaterialInstance used for this decal.
	Impact.HitLocation,	                            // Decal spawned at the hit location.
	rotator(-Impact.HitNormal),	                    // Orient decal into the surface.
	128, 128,	                                    // Decal size in tangent/binormal directions.
	256,	                                        // Decal size in normal direction.
	false,	                                        // If TRUE, use "NoClip" codepath.
	FRand() * 360,	                                // random rotation
	Impact.HitInfo.HitComponent                     // If non-NULL, consider this component only.
    );               
}

//function ConsumeAmmo( byte FireModeNum )
//{
//	//UTPawn(Instigator).PlayEmote('(The name of the EmoteTag that should be played)', -1); 
//	UTPawn(Instigator).PlayEmote('Atacar', -1); 
//}

DefaultProperties
{

animacio_attack=false;

WeaponRange=110.0

InstantHitDamageTypes(0)=class'DmgType_Crushed'
InstantHitDamage(0)=10


bMeleeWeapon=true
	Begin Object class=SkeletalMeshComponent Name=Sword
	SkeletalMesh=SkeletalMesh'Betty_Player.Sword'
	HiddenGame=FALSE 
	HiddenEditor=FALSE
    end object
    Mesh=Sword
    Components.Add(Sword)

	FiringStatesArray(0)=WeaponFiring //We don't need to define a new state
    WeaponFireTypes(0)=EWFT_InstantHit
    FireInterval(0)=0.1
    Spread(0)=0

}
