class BBWeaponSword extends BBWeapon;



//Temp vars for use with traces
var Vector vStartTrace, vEndTrace;
var vector  vHitLoc, vHitNorm;
var Actor lastHitActor, hitActor;
var Pawn hitPawn;

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

simulated event SetPosition(UDKPawn Holder)
{
    local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;
    local Vector FinalLocation;

    compo = Holder.Mesh;
    if (compo != none)
    {
	socket = compo.GetSocketByName('sword_socket');
	if (socket != none)
	{
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
	if(enemigo!=none && lista_enemigos.Find(enemigo)==-1){
		lista_enemigos.AddItem(enemigo);
		return true;
	}
	return false;
}


DefaultProperties
{


//WeaponRange=110.0

//InstantHitDamageTypes(0)=class'DmgType_Crushed'
//InstantHitDamage(0)=10


//bMeleeWeapon=true
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=true
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)
		
	Begin Object class=StaticMeshComponent Name=Sword
		StaticMesh=StaticMesh'Betty_Player.SkModels.BettyClub'
		LightEnvironment=MyLightEnvironment;			
    end object
    Mesh=Sword
    //Components.Add(Sword)
	//FiringStatesArray(0)=WeaponFiring //We don't need to define a new state
 //   WeaponFireTypes(0)=EWFT_InstantHit
   //FireInterval(0)=1
 //   Spread(0)=0
}
