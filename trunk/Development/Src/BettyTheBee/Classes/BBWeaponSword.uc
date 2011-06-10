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
				
					if(addListaEnemigos(hitActor) && !BBEnemyPawn(hitActor).bIsDying){
					
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

//simulated state WeaponFiring{

//	event Timer(){
//		Holder.GetUnequipped();
//	}
//	simulated event BeginState( Name PreviousStateName ){
//		SetTimer(unequipTime);
//		super.BeginState(PreviousStateName);
//	}
//}


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
}
