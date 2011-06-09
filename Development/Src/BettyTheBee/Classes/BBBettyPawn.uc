class BBBettyPawn extends BBPawn;

var int itemsMiel;//contador de items 'Mel'

var bool bIsRolling;

/** Blend node used for blending attack animations*/
var AnimNodeBlendList node_attack_list;
/** Array containing all the attack animation AnimNodeSlots*/
var array<AnimNodeSequence> attack_list_anims;

var DynamicLightEnvironmentComponent LightEnvironment;


var AnimNodeBlendList node_roll_list;
var array<AnimNodeSequence> roll_list_anims;

///**GroundParticles al andar o correr 
var ParticleSystemComponent ParticlesComponent_humo_correr;
var ParticleSystemComponent ParticlesComponent_ini_correr;
var ParticleSystem ParticlesSystem_humo_correr[5];

var bool bini;
/** ParticleSystem que aparece al equipar la espada */
var ParticleSystem EquipSwordPS;

//Sounds
/** Sound for equipping the Sword */
var SoundCue EquipSwordCue;
 
simulated function name GetDefaultCameraMode(PlayerController RequestedBy)
{
	return 'ThirdPerson';
}

//event Tick(float DeltaTime){
//	super.Tick(DeltaTime);
//	`log("PawnRotation="@Rotation);
//}

event PostBeginPlay()
{
	//local Vector SocketLocation;
	//local Rotator SocketRotation;

	super.PostBeginPlay();


	//Mesh.GetSocketWorldLocationAndRotation('center', SocketLocation, SocketRotation, 0 /* Use 1 if you wish to return this in component space*/ );
	Mesh.AttachComponentToSocket(ParticlesComponent_humo_correr, 'center');
	Mesh.AttachComponentToSocket(ParticlesComponent_ini_correr, 'center');
	ParticlesComponent_ini_correr.SetActive(false);
	//ParticlesComponent_humo_correr.SetActive(false);
	//ParticlesComponent_humo_correr.DeactivateSystem();
	
	
	
	//ParticlesComponent_humo_correr.SetTemplate(ParticlesSystem_humo_correr[0]);
	
		
}

function humo1(){
ParticlesComponent_humo_correr.SetTemplate(ParticlesSystem_humo_correr[0]);
}
function humo2(){
ParticlesComponent_humo_correr.SetTemplate(ParticlesSystem_humo_correr[1]);
}
function humo3(){
ParticlesComponent_humo_correr.SetTemplate(ParticlesSystem_humo_correr[2]);
}
function humo4(){
ParticlesComponent_humo_correr.SetTemplate(ParticlesSystem_humo_correr[3]);
}
function humo5(){
ParticlesComponent_humo_correr.SetTemplate(ParticlesSystem_humo_correr[4]);
}

function play_humo_correr(){
	//ParticlesComponent_humo_correr.SetActive(true);
	ParticlesComponent_ini_correr.ActivateSystem();
}

function stop_humo_correr(){
	//Particles_estrellas_antenas.DeactivateSystem();
	//ParticlesComponent_humo_correr.SetActive(false);
}

function play_ini_correr(){
	ParticlesComponent_ini_correr.ActivateSystem();

}




function AddDefaultInventory()
{	
	//La primera sera el arma con que empecemos. Empezamos sin arma equipada
	InvManager.CreateInventory(class'BettyTheBee.BBWeaponNone');
	InvManager.CreateInventory(class'BettyTheBee.BBWeaponSword');
	InvManager.CreateInventory(class'BettyTheBee.BBWeaponGrenade');
}


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		node_attack_list = AnimNodeBlendList(Mesh.FindAnimNode('attack_list'));
		attack_list_anims.AddItem(AnimNodeSequence(Mesh.FindAnimNode('Atacar')));
		attack_list_anims.AddItem(AnimNodeSequence(Mesh.FindAnimNode('Atacar2')));
		attack_list_anims.AddItem(AnimNodeSequence(Mesh.FindAnimNode('Atacar3')));
		attack_list_anims.AddItem(AnimNodeSequence(Mesh.FindAnimNode('LanzarGranada')));

		node_roll_list = AnimNodeBlendList(Mesh.FindAnimNode('roll_list'));
		roll_list_anims.AddItem(AnimNodeSequence(Mesh.FindAnimNode('roll_left')));
		roll_list_anims.AddItem(AnimNodeSequence(Mesh.FindAnimNode('roll_right')));
	}
}




function  animRollLeft(){

	bIsRolling=true;
	node_roll_list.setactivechild(1,0.1f);

}
function  animRollRight(){

	bIsRolling=true;
	node_roll_list.setactivechild(2,0.1f);

}


function bool isRolling(){
	return bIsRolling;
}

simulated function StartFire(byte FireModeNum)
{

	//if(BBWeapon(Weapon).getAnimacioFlag()==false){
	//	switch (Weapon.Class){

	//	case (class'BBWeaponSword'):
			
	//		break;

	//	case  (class'BBWeaponGrenade'):
	//		Worldinfo.Game.Broadcast(self, Name $ ": itemsMiel "$itemsMiel);
	//		if(FireModeNum==0){
	//			if(itemsMiel-5>=0){
	//				itemsMiel-=5;
	//				BBWeapon(Weapon).animAattackStart();
	//				super.StartFire(FireModeNum);
	//				node_attack_list.SetActiveChild(3,0.2f);
	//			}
	//		}else{
	//			BBWeaponGrenade(Weapon).calcHitPosition();
	//		}
	//		break;
	//	}
	//}

		if(BBWeapon(Weapon).getAnimacioFlag()==false){
		switch (Weapon.Class){		
			//case (class'BBWeaponNone'):
			//	GetSword();
			//	break;
			case (class'BBWeaponSword'):
				super.StartFire(FireModeNum);
				break;
			case  (class'BBWeaponGrenade'):
				//Worldinfo.Game.Broadcast(self, Name $ ": itemsMiel "$itemsMiel);
				//if(FireModeNum==0){
					//if(itemsMiel-5>=0){
						itemsMiel-=5;
						//BBWeapon(Weapon).animAattackStart();
						super.StartFire(FireModeNum);
						//node_attack_list.SetActiveChild(3,0.2f);
					//}
				//}else{
					//BBWeaponGrenade(Weapon).calcHitPosition();
				//}
				break;
			default:
				break;
		}
	}

	
}

simulated function basicSwordAttack()
{
	if(BBWeapon(Weapon).getAnimacioFlag()==false){
		BBWeaponSword(Weapon).ResetUnequipTimer();
		BBWeapon(Weapon).animAttackStart();
		node_attack_list.SetActiveChild(1,0.2f);
	}
}

simulated function comboSwordAttack()
{
	
	local int i;
	i = node_attack_list.ActiveChildIndex;
	BBWeaponSword(Weapon).ResetUnequipTimer();
	BBWeapon(Weapon).animAttackEnd();//end de l'animacio de l'atac basic. Per posar eliminar els enemics de la taula 'lista_enemigos'
	BBWeapon(Weapon).animAttackStart();
	if(i<3)	i++;
	else i = 1;
	node_attack_list.SetActiveChild(i,0.2f);
}

simulated function GrenadeAttack()
{
	if(BBWeapon(Weapon).getAnimacioFlag()==false){	
		BBWeapon(Weapon).animAttackStart();
		node_attack_list.SetActiveChild(4,0.2f);
	}
}

function bool canStartCombo()
{
	local AnimNodeSequence a;
	local float animCompletion;
	
	a = getAttackAnimNode();
	if(a!=None)
	{
		animCompletion = a.GetNormalizedPosition();
		//`log("normallized position is"@animCompletion);
		//Worldinfo.Game.Broadcast(self, Name $ ":animCompletion "$animCompletion);
		if(animCompletion > 0.65 && animCompletion < 1.0)
		{
			return true;
		}
	}
	return false;
}


simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	// Tell mesh to stop using root motion
	if(SeqNode == getAttackAnimNode())
	{
		//Mesh.RootMotionMode = RMM_Ignore;
		node_attack_list.SetActiveChild(0,0.2f);
		BBWeapon(Weapon).animAttackEnd();
	}else if (SeqNode == getRollAnimNode()){
		bIsRolling=false;
		node_roll_list.SetActiveChild(0,0.2f);
	}
}


function AnimNodeSequence getAttackAnimNode()
{
	local int i;
	i = node_attack_list.ActiveChildIndex;
	if(i > 0)
	{
		i = i-1;
		return attack_list_anims[i];
	}
	return None;
}
function AnimNodeSequence getRollAnimNode()
{
	local int i;
	i = node_roll_list.ActiveChildIndex;
	if(i > 0)
	{
		i = i-1;
		return roll_list_anims[i];
	}
	return None;
}
simulated function GetUnequipped()
{
	local BBWeaponNone Inv;
	local BBWeaponSword Sword;
	local BBWeaponGrenade Grenade;

	Sword = BBWeaponSword(Weapon);
	Grenade = BBWeaponGrenade(Weapon);

	//Miramos si el arma anterior no estaba atacando
	if((Sword != none && Sword.animacio_attack == false) || (Grenade != none && Grenade.animacio_attack == false)){
		foreach InvManager.InventoryActors( class'BBWeaponNone', Inv )
		{
			InvManager.SetCurrentWeapon( Inv );
			//Si antes teniamos la espada lanzamos particulas y sonido
			if(Sword != none){
				WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(EquipSwordPS,Mesh,'sword_socket',true);
				PlaySound(EquipSwordCue);
			}
			break;
		}
	}
}
simulated function GetSword()
{
	local BBWeaponSword Inv;
	local BBWeaponGrenade Grenade;

	Grenade = BBWeaponGrenade(Weapon);

	//Miramos si el arma anterior no estaba atacando
	if((Grenade != none && Grenade.animacio_attack == false) || Weapon.Class == class'BBWeaponNone'){		
		foreach InvManager.InventoryActors( class'BBWeaponSword', Inv )
		{
			InvManager.SetCurrentWeapon( Inv );
			WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(EquipSwordPS,Mesh,'sword_socket',true);
			PlaySound(EquipSwordCue);
			break;
		}
	}
}
simulated function GetGrenade()
{
	local BBWeaponGrenade Inv;
	local BBWeaponSword Sword;

	Sword = BBWeaponSword(Weapon);

	//Miramos si el arma anterior no estaba atacando
	if((Sword != none && Sword.animacio_attack == false) || Weapon.Class == class'BBWeaponNone'){
		foreach InvManager.InventoryActors( class'BBWeaponGrenade', Inv )
		{
			InvManager.SetCurrentWeapon( Inv );
			//Si antes teniamos la espada lanzamos particulas y sonido
			if(Sword != none){
				WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(EquipSwordPS,Mesh,'sword_socket',true);
				PlaySound(EquipSwordCue);
			}
			break;
		}
	}
}



DefaultProperties
{

	Components.Remove(Sprite)
	//Setting up the light environment
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		//AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		//AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment = MyLightEnvironment
	//Setting up the mesh and animset components
	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
		BlockRigidBody=true;
		CollideActors=true;
		BlockZeroExtent=true;
		//What to change if you'd like to use your own meshes and animations
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		//AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
		//AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		//AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		//SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'

		AnimSets(0)=AnimSet'Betty_Player.SkModels.Betty_AnimSet'
		AnimTreeTemplate=AnimTree'Betty_Player.SkModels.Betty_AnimTree'
		SkeletalMesh=SkeletalMesh'Betty_Player.SkModels.Betty_SkMesh'
		//SkeletalMesh=SkeletalMesh'Betty_PlayerAITOR.SkModels.Betty_SkMesh'
	End Object
	//Setting up a proper collision cylinder
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);
	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0025.000000
		CollisionHeight=+0045.000000
	End Object
	CylinderComponent=CollisionCylinder

	EquipSwordPS = ParticleSystem'Betty_Player.Particles.EquipSword_PS'

	GroundSpeed=400
	//Default is 420
	JumpZ=550
	//Default is 0.05
	AirControl=0.5

	itemsMiel=10000;
	bCanPickupInventory=true;
	InventoryManagerClass=class'BettyTheBee.BBInventoryManager';


	bIsRolling=false;


	
	//begin object Class=ParticleSystemComponent Name=ParticleSystemComponent0
 //              // Template=ParticleSystem'Betty_Particles.Betty.PS_walking'
 //     end object
	//	ParticlesComponent_humo_correr=ParticleSystemComponent0
 //       Components.Add(ParticleSystemComponent0)

	EquipSwordCue=SoundCue'Betty_Sounds.SoundCues.EquippingSword01_Cue';


	//	begin object Class=ParticleSystemComponent Name=ParticleSystemComponent1
 //             Template=ParticleSystem'Betty_Particles.Betty.PS_ini_walking'
 //       end object
 //       ParticlesComponent_ini_correr=ParticleSystemComponent1
 //       Components.Add(ParticleSystemComponent1)

	
bini=true;
	

	
	
}
