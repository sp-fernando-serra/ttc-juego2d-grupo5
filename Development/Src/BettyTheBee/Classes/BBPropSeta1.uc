class BBPropSeta1 extends BBProp placeable
	classGroup(BBActor);


var SkeletalMeshComponent Mesh;
var BBBettyPawn tempPawn;

var name boingAnimName;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	boingAnimName = 'Boing';	
}

event bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal){
	if(HitNormal.Z > HitNormal.X && HitNormal.Z > HitNormal.Y && BBBettyPawn(Other) != none){
		Mesh.PlayAnim(boingAnimName,0.5);
		tempPawn = BBBettyPawn(Other);
	}
}

event doJump(){
	tempPawn.ForceJump();	
}

simulated event endAnim(){
	tempPawn.EndJump();
	tempPawn = none;
}


DefaultProperties
{

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

		AnimSets(0)=AnimSet'Betty_setas.SkModels.Seta04anim_AnimSet'
		AnimTreeTemplate=AnimTree'Betty_setas.SkModels.Seta04anim_AnimTree'
		PhysicsAsset=PhysicsAsset'Betty_setas.SkModels.Seta04anim_Physics'
		SkeletalMesh=SkeletalMesh'Betty_setas.SkModels.Seta04anim'

	end object
	Mesh = InitialPawnSkeletalMesh
	Components.Add(InitialPawnSkeletalMesh)

	bCollideActors=true
	bBlockActors = true
	bCollideWorld = false
	CollisionType = COLLIDE_BlockAll
	bStatic = False
	bMovable = false

}
