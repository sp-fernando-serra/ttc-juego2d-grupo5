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

	Super.Tick(DeltaTime);
	
	//if attacking do traces to determine hit
	if( animacio_attack )
	{
		if(SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('sword_final',vStartTrace) )
		{
			if( SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('sword_ini',vEndTrace) )
			{
				hitActor = Trace(vHitLoc,vHitNorm,vEndTrace,vStartTrace,true);	
				if(addListaEnemigos(hitActor)){
					//Worldinfo.Game.Broadcast(self, Name $ ": weapon hit "$ hitActor);	
					hitPawn = Pawn(hitActor);
					hitPawn.Health-=20;
					//Worldinfo.Game.Broadcast(self, Name $ ": Health "$hitPawn.Health);
				}	
			}
		}
	}
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


DefaultProperties
{		
	Begin Object class=SkeletalMeshComponent Name=Sword
		SkeletalMesh=SkeletalMesh'Betty_Player.SkModels.BettyClub'					
    end object
    Mesh=Sword
    //Components.Add(Sword)
	
	unequipTime = 3;

}
