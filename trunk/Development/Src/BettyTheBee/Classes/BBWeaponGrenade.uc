class BBWeaponGrenade extends BBWeapon;



simulated event vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;

   // compo = SkeletalMeshComponent(Mesh);
	compo = Instigator.Mesh;
	//compo = BBBettyPawn(Pawn).getMesh();
    if (compo != none)
    {
	//socket = compo.GetSocketByName('startTrace');
	socket = compo.GetSocketByName('grenade_socket');
	if (socket != none)
	{
	    return compo.GetBoneLocation(socket.BoneName);
	}
    }
}
//simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
//{
//    WorldInfo.MyDecalManager.SpawnDecal
//    (
//	DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak',	// UMaterialInstance used for this decal.
//	Impact.HitLocation,	                            // Decal spawned at the hit location.
//	rotator(-Impact.HitNormal),	                    // Orient decal into the surface.
//	128, 128,	                                    // Decal size in tangent/binormal directions.
//	256,	                                        // Decal size in normal direction.
//	false,	                                        // If TRUE, use "NoClip" codepath.
//	FRand() * 360,	                                // random rotation
//	Impact.HitInfo.HitComponent                     // If non-NULL, consider this component only.
//    );               
//}


DefaultProperties
{

	//Begin Object class=SkeletalMeshComponent Name=GunMesh
	//SkeletalMesh=SkeletalMesh'Betty_Player.Tamashinu_sword2'
	//HiddenGame=FALSE 
	//HiddenEditor=FALSE
 //   end object
 //   Mesh=GunMesh
 //   Components.Add(GunMesh)

	//FiringStatesArray(0)=WeaponFiring //We don't need to define a new state
 //   WeaponFireTypes(0)=EWFT_InstantHit
 //   FireInterval(0)=0.1
 //   Spread(0)=0

	FiringStatesArray(0)=WeaponFiring
    WeaponFireTypes(0)=EWFT_Projectile
    WeaponProjectiles(0)=class'BettyTheBee.BBProjectileGrenade'
    FireInterval(0)=0
    Spread(0) = 0

	FiringStatesArray(1)=WeaponFiring
    WeaponFireTypes(1)=EWFT_Projectile
    WeaponProjectiles(1)=class'BettyTheBee.BBProjectileLocation'
    FireInterval(1)=0.5
    Spread(1) = 0
	
	

}
