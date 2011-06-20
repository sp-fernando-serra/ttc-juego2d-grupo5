class BBMushroom extends BBProp placeable
	classGroup(BBActor);

var SkeletalMeshComponent Mesh;

var AnimNodeSequence BoingAnim;
var AnimNodeBlendList AnimList;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetCollisionType(COLLIDE_BlockAll);

}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	//if (SkelComp == Mesh)
	//{
		AnimList = AnimNodeBlendList(SkelComp.FindAnimNode('AnimList'));
		boingAnim = AnimNodeSequence(SkelComp.FindAnimNode('Boing'));
		
	//}
}


// Called when something touches this actor.
simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	//Log( "I was touched!");
	`log("touched");
    // si es tocado por el player, mientras este cae de un salto, sobre la zona superior
	//if(HitLocation.Z>20){
		//`log("HitLocation.Y>20");
		GotoState('BoingState');
	//}
	

}

State BoingState {
	// reproducir animacion boing, impulsar player
//simulated event dojump(){

//	Other.DoJump(true);
//}

	simulated event BeginState(name NextStateName){
		super.BeginState(NextStateName);
		AnimList.SetActiveChild(1,0.2f);
	}
	
	simulated event EndState(name NextStateName){
		super.EndState(NextStateName);
		AnimList.SetActiveChild(0,0.2f);
	}



Begin:	
	AnimList.SetActiveChild(1,0.2f);
	FinishAnim(boingAnim);
	`log("finished boingAnim");
	//goto 'Begin';
}

DefaultProperties
{

	bCollideActors=true
	bBlockActors=true
	//bPushesRigidBodies=true
	//bStatic=True
	bMovable=False

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	bEnabled=TRUE		
    End Object
    Components.Add(MyLightEnvironment)
   
	Begin object class=SkeletalMeshComponent Name=Mesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=true
		CollideActors=true
		BlockZeroExtent=true;
		BlockNonZeroExtent = True
        BlockActors = True
		
		AnimSets(0)=AnimSet'Betty_setas.SkModels.Seta04anim_AnimSet'
		SkeletalMesh=SkeletalMesh'Betty_setas.SkModels.Seta04anim'
		AnimTreeTemplate=AnimTree'Betty_setas.SkModels.Seta04anim_AnimTree'
		PhysicsAsset=PhysicsAsset'Betty_setas.SkModels.Seta04anim_Physics'
		HiddenGame=FALSE 
		HiddenEditor=FALSE

	End object
    Components.Add(Mesh)
}

