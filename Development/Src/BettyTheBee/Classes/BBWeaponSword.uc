class BBWeaponSword extends BBWeapon;



//Temp vars for use with traces
var Vector vStartTrace, vEndTrace;
var vector  vHitLoc, vHitNorm;
var Actor lastHitActor, hitActor;
var Pawn hitPawn;
/** Pawn holding this weapon */
var BBBettyPawn Holder;
/** Seconds to unequip Sword when inactive */
var int unequipTime;
/** Damage done with each attack */
var int attackDamage;
/** Damage type done by this sword */
var class<DamageType> myDamageType;

var ParticleSystem DamagePawn_PS;
var ParticleSystemComponent DamagePawn_PSC;


var bool bDoDamage;

var array<float> DelayFireTime; 

simulated function TimeWeaponEquipping()
{
	AttachWeaponTo( Instigator.Mesh,'sword_socket' );
	Holder = BBBettyPawn(Instigator);
	super.TimeWeaponEquipping();
}

simulated event SetPosition(UDKPawn Holder2)
{
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;
    local Vector FinalLocation;

    compo = Holder2.Mesh;
    if (compo != none){
		socket = compo.GetSocketByName('sword_socket');
		if (socket != none){
			FinalLocation = compo.GetBoneLocation(socket.BoneName);
			}
    }
    //And we probably should do something similar for the rotation :)
    SetLocation(FinalLocation); 
}
	


event Tick(float DeltaTime){

	local Vector momentum;
	Super.Tick(DeltaTime);
	
	//if attacking do traces to determine hit
	if( animacio_attack )
	{
		if(bDoDamage){
			if(SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('sword_final',vStartTrace) )
			{
				if( SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('sword_ini',vEndTrace) )
				{
					hitActor = Trace(vHitLoc,vHitNorm,vEndTrace,vStartTrace,true);	
				
					if(addListaEnemigos(hitActor) && !BBEnemyPawn(hitActor).bPlayedDeath){
					
						//Worldinfo.Game.Broadcast(self, Name $ ": weapon hit "$ hitActor);	
						hitPawn = Pawn(hitActor);
						momentum = vect(0,0,0);
						hitPawn.TakeDamage(attackDamage, Holder.Controller,vHitLoc,momentum,MyDamageType);
						//BBEnemyPawnRhino(hitPawn).isAtacked();					
						playPariclesDamage(vHitLoc);
						//Worldinfo.Game.Broadcast(self, Name $ ": Health "$hitPawn.Health);
					}	
				}
			}
		}
	}
}

function playPariclesDamage(Vector HitLoc)
{
	
	//DamagePawn_PSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(DamagePawn_PS,SkeletalMeshComponent(Mesh),'sword_final',true);
	DamagePawn_PSC = WorldInfo.MyEmitterPool.SpawnEmitter(DamagePawn_PS,HitLoc);

}

simulated function bool addListaEnemigos(Actor enemigo){
	if(BBEnemyPawn(enemigo) != none && lista_enemigos.Find(enemigo)==-1){
		lista_enemigos.AddItem(enemigo);
		return true;
	}
	return false;
}

simulated function resetUnequipTimer(){
	SetTimer(unequipTime);
}

event Timer(){
	Holder.GetUnequipped();
}

/**
 * Modificamos el estado para desequiapr el arma pasado un tiempo = unequipTime
 */
simulated state Active{
	
	simulated event BeginState(name PreviousStateName){
		SetTimer(unequipTime);
		super.BeginState(PreviousStateName);
	}
}

auto state Inactive{
	simulated event BeginState( Name PreviousStateName )
		{
			ClearTimer();
		}
}


//--------------GRENADE

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
			if (DelayFireTime[CurrentFireMode] > 0) 
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
		if (DelayFireTime[CurrentFireMode] <= 0) 
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

	if (DelayFireTime[CurrentFireMode] > 0) // Do we have delay?
	{
		/* Is the timer active already? if yes, don't do anything. This is a tricky part.
		 * We injected this function at the BeginState, which is originally fired by Pawn.WeaponFired()
		 * I wanted to remove this effect without touching the pawn's base code, so I could do it
		 * by checking if the timer is active or not (caused by our BeginState). If it does, then
		 * the second call by Pawn.WeaponFired() will have no effect, this avoid duplication.
		 */

		if( !IsTimerActive('DelayFire') ) 
		{
			SetTimer( DelayFireTime[CurrentFireMode], true, 'DelayFire' );
			super.PlayFireEffects(FireModeNum, HitLocation);
		}

	}
	else
	{
		//No delay. Resume default implementation.
		super.PlayFireEffects(FireModeNum, HitLocation);
	}

}


simulated event ToggleAttack(){
	bDoDamage=!bDoDamage;
}

DefaultProperties
{		
	Begin Object class=SkeletalMeshComponent Name=Sword
		SkeletalMesh=SkeletalMesh'Betty_Player.SkModels.BettyClub'		
    end object
    Mesh=Sword
    //Components.Add(Sword)

	
	unequipTime = 3;

	attackDamage = 25;
	myDamageType = class'DamageType'

	DamagePawn_PS=ParticleSystem'Betty_Particles.Damage.Rhino_Damage'

	bDoDamage=false;


	FiringStatesArray(1)=WeaponFiring
    WeaponFireTypes(1)=EWFT_Projectile
    WeaponProjectiles(1)=class'BettyTheBee.BBProjectileGrenade'
    FireInterval(1)=0
    Spread(1)=0


	DelayFireTime(0) = 0;
	DelayFireTime(1) = 0.6;
}
