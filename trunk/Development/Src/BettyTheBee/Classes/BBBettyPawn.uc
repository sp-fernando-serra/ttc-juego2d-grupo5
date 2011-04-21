class BBBettyPawn extends BBPawn;

var int itemsMiel;//contador de items 'Mel'


/** Blend node used for blending attack animations*/
var AnimNodeBlendList node_attack_list;

/** Array containing all the attack animation AnimNodeSlots*/
var array<AnimNodeSequence> attack_list_anims;

simulated function name GetDefaultCameraMode(PlayerController RequestedBy)
{
	return 'ThirdPerson';
}

//event Tick(float DeltaTime){
//	super.Tick(DeltaTime);
//	`log("PawnRotation="@Rotation);
//}


function AddDefaultInventory()
{
	
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
}
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
		}
	}

	
}

simulated function basicSwordAttack()
{
	if(BBWeapon(Weapon).getAnimacioFlag()==false){		
		BBWeapon(Weapon).animAttackStart();
		node_attack_list.SetActiveChild(1,0.2f);
	}
}

simulated function comboSwordAttack()
{
	
	local int i;
	BBWeapon(Weapon).animAttackEnd();//end de l'animacio de l'atac basic. Per posar eliminar els enemics de la taula 'lista_enemigos'
	BBWeapon(Weapon).animAttackStart();
	i = node_attack_list.ActiveChildIndex;
	i++;	
	node_attack_list.SetActiveChild(i,0.2f);
}

simulated function GrenadeAttack()
{
	if(BBWeapon(Weapon).getAnimacioFlag()==false){	
		BBWeapon(Weapon).animAttackStart();
		node_attack_list.SetActiveChild(3,0.2f);
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

simulated function GetSword()
{
	local BBWeaponSword Inv;
	foreach InvManager.InventoryActors( class'BBWeaponSword', Inv )
	{
		InvManager.SetCurrentWeapon( Inv );
		break;
	}
}
simulated function GetGrenade()
{
	local BBWeaponGrenade Inv;
	foreach InvManager.InventoryActors( class'BBWeaponGrenade', Inv )
	{
	InvManager.SetCurrentWeapon( Inv );
	break;
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

		AnimSets(0)=AnimSet'Betty_Player.Betty_AnimSet'
		AnimTreeTemplate=AnimTree'Betty_Player.AnimTree'
		SkeletalMesh=SkeletalMesh'Betty_Player.Betty_Iddle'
	End Object
	//Setting up a proper collision cylinder
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);
	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0025.000000
		CollisionHeight=+0050.000000
	End Object
	CylinderComponent=CollisionCylinder
	GroundSpeed=300.0

	
	itemsMiel=10000;
	bCanPickupInventory=true;
	InventoryManagerClass=class'BettyTheBee.BBInventoryManager';
	
}

