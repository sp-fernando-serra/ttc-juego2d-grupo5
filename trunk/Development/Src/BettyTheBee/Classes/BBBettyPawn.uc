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
}
}

//simulated function StartFire(byte FireModeNum)
//{
//	if( bNoWeaponFIring )
//	{
//		return;
//	}

//	if( Weapon != None )
//	{
//		Weapon.StartFire(FireModeNum);
//	}
//}

//simulated function StopFire(byte FireModeNum)
//{
//	if( Weapon != None )
//	{
//		Weapon.StopFire(FireModeNum);
//	}
//}
simulated function StartFire(byte FireModeNum)
{
	//switch (Weapon.Class){
	//case (class'BBWeaponSword'):
	//	if(BBWeapon(Weapon).getAnimacioFlag()==false){
	//	BBWeapon(Weapon).attackStart();
	//	node_attack_list.SetActiveChild(1,0.2f);
	//break;
	//}
	//case  (class'BBWeaponGrenade'):
	//	super.StartFire(FireModeNum);
	//	if(FireModeNum==0)	node_attack_list.SetActiveChild(2,0.2f);
	//	break;
	//}
	if(BBWeapon(Weapon).getAnimacioFlag()==false){
		BBWeapon(Weapon).attackStart();
		switch (Weapon.Class){

		case (class'BBWeaponSword'):
			node_attack_list.SetActiveChild(1,0.2f);
			break;

		case  (class'BBWeaponGrenade'):
			super.StartFire(FireModeNum);
			node_attack_list.SetActiveChild(2,0.2f);
			break;
		}
	}

	
}

//simulated function StopFire(byte firemodenum)
//{
//	if(Weapon != None)
//	{
//		super.StopFire(FireModeNum);
//		//BBWeapon(Weapon).attackEnd();
//	}
//}

simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	//`log("anim end"@SeqNode@"IN PAWN");
	// Tell mesh to stop using root motion
	if(SeqNode == getAttackAnimNode())
	{
		//Worldinfo.Game.Broadcast(self, Name $ ": 2 ");
		//Mesh.RootMotionMode = RMM_Ignore;
		attackAnimEnd();
		BBWeapon(Weapon).attackEnd();
	}
}

simulated function attackAnimEnd()
{
	//`log("resetting attack animation back to movement anims");
	node_attack_list.SetActiveChild(0,0.2f);
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

	
	itemsMiel=0;
	bCanPickupInventory=true;
	InventoryManagerClass=class'BettyTheBee.BBInventoryManager';
	
}

