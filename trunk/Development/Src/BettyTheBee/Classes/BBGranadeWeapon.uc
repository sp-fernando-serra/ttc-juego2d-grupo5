class BBGranadeWeapon extends UDKWeapon;

simulated function TimeWeaponEquipping()
{
    AttachWeaponTo( Instigator.Mesh,'WeaponPoint' );
    super.TimeWeaponEquipping();
}

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
    MeshCpnt.AttachComponentToSocket(Mesh,SocketName);
}
simulated event SetPosition(UDKPawn Holder)
{
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;
    local Vector FinalLocation;

    compo = Holder.Mesh;
    if (compo != none)
    {
	socket = compo.GetSocketByName('WeaponPoint');
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
	DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak',	// UMaterialInstance used for this decal.
	Impact.HitLocation,	                            // Decal spawned at the hit location.
	rotator(-Impact.HitNormal),	                    // Orient decal into the surface.
	128, 128,	                                    // Decal size in tangent/binormal directions.
	256,	                                        // Decal size in normal direction.
	false,	                                        // If TRUE, use "NoClip" codepath.
	FRand() * 360,	                                // random rotation
	Impact.HitInfo.HitComponent                     // If non-NULL, consider this component only.
    );               
}

DefaultProperties
{

	Begin Object class=SkeletalMeshComponent Name=GunMesh
	SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_3P'
	HiddenGame=FALSE 
	HiddenEditor=FALSE
    end object
    Mesh=GunMesh
    Components.Add(GunMesh)

	FiringStatesArray(0)=WeaponFiring //We don't need to define a new state
    WeaponFireTypes(0)=EWFT_InstantHit
    FireInterval(0)=0.1
    Spread(0)=0
}
