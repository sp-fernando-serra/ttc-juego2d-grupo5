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
	
	InvManager.CreateInventory(class'BettyTheBee.BBSwordWeapon');
	InvManager.CreateInventory(class'BettyTheBee.BBGranadeWeapon');
}


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		node_attack_list = AnimNodeBlendList(Mesh.FindAnimNode('attack_list'));
		attack_list_anims.AddItem(AnimNodeSequence(Mesh.FindAnimNode('Atacar')));
}
}

simulated function StartFire(byte FireModeNum)
{

	if(BBSwordWeapon(Weapon).getAnimacioFlag()==false){
		BBSwordWeapon(Weapon).attackStart();
		super.StartFire(FireModeNum);
		`log("StartFire");
		itemsMiel=itemsMiel+10;
		node_attack_list.SetActiveChild(1,0.2f);
	}
}



simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	`log("anim end"@SeqNode@"IN PAWN");
	// Tell mesh to stop using root motion	
	if(SeqNode == getAttackAnimNode())
	{
		//Mesh.RootMotionMode = RMM_Ignore;
		attackAnimEnd();
		BBSwordWeapon(Weapon).attackEnd();
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
		itemsMiel=itemsMiel+500;
		i = i-1;
		return attack_list_anims[i];
	}
	return None;
}



simulated function GetSword()
{
	local BBSwordWeapon Inv;
	foreach InvManager.InventoryActors( class'BBSwordWeapon', Inv )
	{
		InvManager.SetCurrentWeapon( Inv );
		break;
	}
}
simulated function GetGranade()
{
	local BBGranadeWeapon Inv;
	foreach InvManager.InventoryActors( class'BBGranadeWeapon', Inv )
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
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
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

		AnimSets(0)=AnimSet'Betty_Player.Betty_walk_Anims'
		AnimTreeTemplate=AnimTree'Betty_Player.AnimTree'
		SkeletalMesh=SkeletalMesh'Betty_Player.Betty_walk'
	End Object
	//Setting up a proper collision cylinder
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);
	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0023.000000
		CollisionHeight=+0050.000000
	End Object
	CylinderComponent=CollisionCylinder


	
	itemsMiel=0;
	bCanPickupInventory=true;
	InventoryManagerClass=class'BettyTheBee.BBInventoryManager';
	
}

