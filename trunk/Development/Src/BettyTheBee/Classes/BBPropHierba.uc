class BBPropHierba extends BBProp placeable classGroup(BBActor);

var SkeletalMeshComponent Mesh;
var BBBettyPawn tempPawn;

var name windAnimName;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	windAnimName = 'wind';	
}

state movedByPlayer
{
Begin:
Mesh.PlayAnim(windAnimName,0.5,true); // se agita 1 segundo
Sleep(1);
gotoState('idle');
}

auto state idle
{
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		gotoState('movedByPlayer');
	}
	
	event UnTouch( Actor Other )
	{
		gotoState('idle');
	}
	
	function MovedByWind ()
	{
		Mesh.PlayAnim(windAnimName,2,true);
	}

Begin:
	Mesh.PlayAnim(windAnimName,4,true);

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
        BlockActors = False
        CollideActors =True

		AnimSets(0)=AnimSet'Betty_plantas.SkModels.Hierba_anim_Anims'
		AnimTreeTemplate=AnimTree'Betty_plantas.SkModels.Hierba_anim_AnimTree'
		PhysicsAsset=PhysicsAsset'Betty_plantas.SkModels.Hierba_anim_Physics'
		SkeletalMesh=SkeletalMesh'Betty_plantas.SkModels.Hierba_anim'

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