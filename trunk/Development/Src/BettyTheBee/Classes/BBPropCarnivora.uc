class BBPropCarnivora extends BBProp placeable
	classGroup(BBActor);


/** AnimNode used to play custom anims */
var AnimNodePlayCustomAnim customAnimSlot;

var AnimNodeMirror mirrorCustomAnim;

var name attackAnimName;
var name attack2AnimName;

/** Random Time Between attacks.
 *  Time =timeBetweenAttacks + FRand()*randomTimeBetweenAttacks
 */
var(BBCarnivora) float randomTimeBetweenAttacks;
/** Time Between attacks.
 *  Time =timeBetweenAttacks + FRand()*randomTimeBetweenAttacks
 */
var(BBCarnivora) float timeBetweenAttacks;

var(BBCarnivora) float damage;

var(BBCarnivora) const enum EAttackType
{
	AT_Center,
	AT_Left,
	AT_Right,
	AT_DoubleLeft,
	AT_DoubleRight,
	AT_RightLeft,
	AT_LeftRight,
} AttackType;

var class<DamageType> DmgType;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		customAnimSlot = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomAnim'));
		mirrorCustomAnim = AnimNodeMirror(SkelComp.FindAnimNode('AnimNodeMirror'));
	}
	attackAnimName = 'Attack';
	attack2AnimName = 'Attack2';
}

event doDamage(){
	local BBBettyPawn tempPawn;
	local Vector loc;
	local float radius;
	
	Mesh.GetSocketWorldLocationAndRotation('damageSocket',loc);
	radius = 100.0f * DrawScale * (DrawScale3D.X + DrawScale3D.Y + DrawScale3D.Z)/3;
	foreach OverlappingActors( class'BBBettyPawn', tempPawn, radius, loc){
		tempPawn.TakeDamage(damage,none,vect(0,0,0),vect(0,0,0),DmgType,,self);
		
	}
	
}

auto state generalBehaviour{

Begin:
//local int waitingTime;
	switch(AttackType){
	case AT_Center:
		customAnimSlot.PlayCustomAnim(attackAnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
		break;
	case AT_Right:
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
		break;
	case AT_Left:
		mirrorCustomAnim.bEnableMirroring = true;
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
		mirrorCustomAnim.bEnableMirroring = false;
		break;
	case AT_DoubleRight:
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());		
		break;
	case AT_DoubleLeft:
		mirrorCustomAnim.bEnableMirroring = true;
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
		mirrorCustomAnim.bEnableMirroring = false;
		break;
	case AT_RightLeft:		
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
		mirrorCustomAnim.bEnableMirroring = true;
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
		mirrorCustomAnim.bEnableMirroring = false;
		break;
	case AT_LeftRight:
		mirrorCustomAnim.bEnableMirroring = true;
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
		mirrorCustomAnim.bEnableMirroring = false;
		customAnimSlot.PlayCustomAnim(attack2AnimName,1.0f,0.25f,0.25f,false,true);
		FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());		
		break;
	}
	Sleep(timeBetweenAttacks + FRand()*randomTimeBetweenAttacks);
	Goto 'Begin';
}



DefaultProperties
{

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionHeight= +400.0f
		CollisionRadius = +40.0f
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End object
	CollisionComponent = CollisionCylinder
	Components.Add(CollisionCylinder)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		LightShadowMode=LightShadow_Modulate
		ShadowFilterQuality=SFQ_Low
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object class=SkeletalMeshComponent Name=InitialPawnSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true

		LightEnvironment=MyLightEnvironment;

		BlockNonZeroExtent = True
        BlockZeroExtent = True
        BlockActors = True
        CollideActors =True

		AnimSets(0)=AnimSet'Betty_carnivora.SkModels.Carnivora_AnimSet'
		AnimTreeTemplate=AnimTree'Betty_carnivora.SkModels.Carnivora_AnimTree'
		PhysicsAsset=PhysicsAsset'Betty_carnivora.SkModels.Carnivora_Physics'
		SkeletalMesh=SkeletalMesh'Betty_carnivora.SkModels.Carnivora'

	end object
	Mesh = InitialPawnSkeletalMesh
	Components.Add(InitialPawnSkeletalMesh)

	bCollideActors=true
	bBlockActors = true
	bCollideWorld = false
	CollisionType = COLLIDE_BlockAll
	bStatic = False
	bMovable = True

	AttackType = AT_Center
	randomTimeBetweenAttacks = 0
	timeBetweenAttacks = 2
	damage = 30

	DmgType = class'DamageType'

}
