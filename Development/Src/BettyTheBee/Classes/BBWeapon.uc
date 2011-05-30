class BBWeapon extends UDKWeapon;

//flag que ens diu si hi ha l'animacio d'atac
var bool animacio_attack;

var array<Actor> lista_enemigos;

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	local BBBettyPawn Betty;

	Betty = BBBettyPawn(Instigator);
	if(Mesh != none){
		MeshCpnt.AttachComponentToSocket(Mesh,SocketName);
		Mesh.SetLightEnvironment(Betty.LightEnvironment);
	}
}

simulated function DetachWeapon()
{
	if(Mesh != none){
		Instigator.Mesh.DetachComponent( Mesh );
		SetBase(None);
		Mesh.SetLightEnvironment(None);
	}
}


simulated function animAttackStart()
{
	//`log("attackStart");
	animacio_attack = true;
}
simulated function animAttackEnd()
{
	//local int i;

	//`log("attackEnd");
	animacio_attack = false;
	//borrem tots els enemics de larray	
	lista_enemigos.Remove(0, lista_enemigos.length);

}


simulated function bool getAnimacioFlag(){
	return animacio_attack;
}

DefaultProperties
{
	animacio_attack=false;
	EquipTime = 0;
	PutDownTime = 0;
}
