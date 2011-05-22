class BBWeaponGrenade extends BBWeapon;



simulated event vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;

   // compo = SkeletalMeshComponent(Mesh);
	compo = Instigator.Mesh;
    if (compo != none)
    {
	socket = compo.GetSocketByName('grenade_socket');
	if (socket != none)
	{
	    return compo.GetBoneLocation(socket.BoneName);
	}
    }
}

simulated function calcHitPosition(){
	local vector HitLocation,HitNormal;
	HitNormal = normal(Velocity * -1);
	HitNormal=vect(0,0,-1);
	//Worldinfo.Game.Broadcast(self, Name $ ": Location "$Location);
	//Worldinfo.Game.Broadcast(self, Name $ ": HitNormal "$HitNormal);
	//Worldinfo.Game.Broadcast(self, Name $ ": Velocity "$Velocity);
	Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));
	//Worldinfo.Game.Broadcast(self, Name $ ": calcHitPosition "$HitLocation);
}


DefaultProperties
{

	//FiringStatesArray(0)=WeaponFiring //We don't need to define a new state
 //   WeaponFireTypes(0)=EWFT_InstantHit
 //   FireInterval(0)=0.1
 //   Spread(0)=0

	FiringStatesArray(0)=WeaponFiring
    WeaponFireTypes(0)=EWFT_Projectile
    WeaponProjectiles(0)=class'BettyTheBee.BBProjectileGrenade'
    FireInterval(0)=0
    Spread(0)=0
	//Comentado porque no sire para lo que queremos (retrasar el lanzamiento de granada)
	//FireOffset(0)=(X=1,Y=1,Z=1)
	

	FiringStatesArray(1)=WeaponFiring
    WeaponFireTypes(1)=EWFT_Projectile
    WeaponProjectiles(1)=class'BettyTheBee.BBProjectileLocation'
    FireInterval(1)=0.5
    Spread(1) = 0
	
	

}
