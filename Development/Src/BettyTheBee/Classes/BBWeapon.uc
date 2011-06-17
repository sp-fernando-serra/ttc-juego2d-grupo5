class BBWeapon extends UDKWeapon;

//flag que ens diu si hi ha l'animacio d'atac
var bool animacio_attack;

var array<Actor> lista_enemigos;


var ParticleSystem TargetedPawn_PS;
var ParticleSystemComponent TargetedPawn_PSC;


simulated function calcHitPosition(){
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	//local vector newVecDirection,SimulatedLocation;

	local BBBettyPawn UTP;

	UTP = BBBettyPawn(Instigator);

	newVecDirection=vector(UTP.Rotation);


	StartTrace = Instigator.GetWeaponStartTraceLocation();
	AimDir = Vector(GetAdjustedAim( StartTrace ));
	RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		//AimDir=newVecDirection;

	EndTrace = StartTrace + AimDir * GetTraceRange();
	TestImpact = CalcWeaponFire( StartTrace, EndTrace );

	AimDir = Normal(TestImpact.HitLocation - RealStartLoc);

	//TargetedPawn_PSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(TargetedPawn_PS,Mesh,'centro',true);
	//TargetedPawn_PSC = WorldInfo.MyEmitterPool.SpawnEmitter(TargetedPawn_PS,TestImpact.HitLocation);
	
	
	//TargetedPawn_PSC = WorldInfo.MyEmitterPool.SpawnEmitter(TargetedPawn_PS,AimDir);


	//SimulatedLocation = (Projectile.StartLocation * Projectile.StartRotation * Projectile.Speed)*vect(0,0,1) * (-0.5*WorldInfo.WorldGravityZ);
	//SimulatedLocation = (StartTrace *500)*vect(0,0,1) * (-0.5*WorldInfo.WorldGravityZ);
	//TargetedPawn_PSC = WorldInfo.MyEmitterPool.SpawnEmitter(TargetedPawn_PS,SimulatedLocation);

	//`log(SimulatedLocation);


}

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


	TargetedPawn_PS=ParticleSystem'Betty_Particles.enemigos.enemigo_fijado'	
}
