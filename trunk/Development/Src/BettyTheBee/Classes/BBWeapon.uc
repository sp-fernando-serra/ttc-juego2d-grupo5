class BBWeapon extends UDKWeapon;

//flag que ens diu si hi ha l'animacio d'atac
var bool animacio_attack;

var array<Actor> lista_enemigos;

simulated function TimeWeaponEquipping()
{
    AttachWeaponTo( Instigator.Mesh,'mano_izquierda' );
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


simulated function animAttackStart()
{
	//`log("attackStart");
	animacio_attack = true;
}
simulated function animAttackEnd()
{
	local int i;

	//`log("attackEnd");
	animacio_attack = false;
	//borrem tots els enemics de larray	
	for (i = 0; i < lista_enemigos.length; ++i) {
		lista_enemigos.Remove(i, 1);
	}
}


simulated function bool getAnimacioFlag(){
	return animacio_attack;
}

DefaultProperties
{
	animacio_attack=false;
}
