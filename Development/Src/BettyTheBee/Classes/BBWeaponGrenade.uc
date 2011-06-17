class BBWeaponGrenade extends BBWeapon;

var float DelayFireTime;

simulated event vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	
    local SkeletalMeshComponent compo;
	local Vector socket_loc;

	compo = Instigator.Mesh;
    if (compo != none)
    {
		compo.GetSocketWorldLocationAndRotation('grenade_socket',socket_loc);
		return socket_loc;
    }
}

//simulated function calcHitPosition(){
//	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
//	local ImpactInfo	TestImpact;
//	StartTrace = Instigator.GetWeaponStartTraceLocation();
//		AimDir = Vector(GetAdjustedAim( StartTrace ));

//	EndTrace = StartTrace + AimDir * GetTraceRange();
//	TestImpact = CalcWeaponFire( StartTrace, EndTrace );

//	`log(TestImpact.HitLocation);

//}


simulated function Projectile ProjectileFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		AimDir = Vector(GetAdjustedAim( StartTrace ));

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
		}

		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( AimDir );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}


//Shauria de miarar com funciona....
simulated state WeaponFiring
{
	simulated event bool IsFiring()
	{
		return true;
	}

	/**
	 * Timer event, call is set up in Weapon::TimeWeaponFiring().
	 * The weapon is given a chance to evaluate if another shot should be fired.
	 * This event defines the weapon's rate of fire.
	 */
	simulated function RefireCheckTimer()
	{
		// if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			`LogInv("Weapon put down requested during fire, put it down now");
			PutDownWeapon();
			return;
		}

		// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			//Hamad: If we have delay, refire according to our delay logic
			if (DelayFireTime > 0) 
			{
				ClearTimer('DelayFire');
				PlayFireEffects( CurrentFireMode );
			}
			else
				FireAmmunition(); //Else, follow the default implementation

			return;
		}

		// Otherwise we're done firing
		HandleFinishedFiring();
	}

	simulated event BeginState( Name PreviousStateName )
	{
		`LogInv("PreviousStateName:" @ PreviousStateName);

		//If we don't have delays, resume with default implementation
		if (DelayFireTime <= 0) 
		{
			FireAmmunition();
			TimeWeaponFiring( CurrentFireMode );
		}
		else
			PlayFireEffects( CurrentFireMode ); //Otherwise, use ours

	}

	simulated event EndState( Name NextStateName )
	{
		`LogInv("NextStateName:" @ NextStateName);
		// Set weapon as not firing
		ClearFlashCount();
		ClearFlashLocation();
		ClearTimer('RefireCheckTimer');

		NotifyWeaponFinishedFiring( CurrentFireMode );
	}
}


simulated function TimeWeaponFiring( byte FireModeNum )
{
	// if weapon is not firing, then start timer. Firing state is responsible to stopping the timer.
	if( !IsTimerActive('RefireCheckTimer') )
	{
		SetTimer( GetFireInterval(FireModeNum) , true, nameof(RefireCheckTimer) );
	}
}

//Hamad: This is the delay timer function. It'll fire the default implementation and clear itself.
simulated function DelayFire()
{
	FireAmmunition();
	TimeWeaponFiring( CurrentFireMode );
	ClearTimer('DelayFire');
}

//Hamad: Play the animation and activate the delay timer if we are in delay mode
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{

	if (DelayFireTime > 0) // Do we have delay?
	{
		/* Is the timer active already? if yes, don't do anything. This is a tricky part.
		 * We injected this function at the BeginState, which is originally fired by Pawn.WeaponFired()
		 * I wanted to remove this effect without touching the pawn's base code, so I could do it
		 * by checking if the timer is active or not (caused by our BeginState). If it does, then
		 * the second call by Pawn.WeaponFired() will have no effect, this avoid duplication.
		 */

		if( !IsTimerActive('DelayFire') ) 
		{
			SetTimer( DelayFireTime, true, 'DelayFire' );
			super.PlayFireEffects(FireModeNum, HitLocation);
		}

	}
	else
	{
		//No delay. Resume default implementation.
		super.PlayFireEffects(FireModeNum, HitLocation);
	}

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

	DelayFireTime=0.6;
	
	

}
