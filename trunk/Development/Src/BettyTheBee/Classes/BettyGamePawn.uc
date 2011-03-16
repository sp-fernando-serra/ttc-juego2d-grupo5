class BettyGamePawn extends Pawn; //Again, naming conventions apply here. Your script is extending the UDK script
//This lets the pawn tell the PlayerController what Camera Style to set the camera in initially (more on this later).


simulated function name GetDefaultCameraMode(PlayerController RequestedBy)
{
	return 'ThirdPerson';
}

//event Tick(float DeltaTime){
//	super.Tick(DeltaTime);
//	`log("PawnRotation="@Rotation);
//}

DefaultProperties
{

	//Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	//	bSynthesizeSHLight=TRUE
	//	bIsCharacterLightEnvironment=TRUE
	//End Object
	//Components.Add(MyLightEnvironment)

	//begin object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
	//	SkeletalMesh=SkeletalMesh'MyPawn.Meshes.Pawn_SKMesh'
	//	PhysicsASset=PhysicsAsset'MyPawn.Meshes.Pawn_Physics'
	//	AnimTreeTemplate=AnimTree'MyPawn.Anims.Pawn_AnimTree'
	//	LightEnvironment=MyLightEnvironment
	//	bHasPhysicsAssetInstance=true
	//end object
	//Mesh=SkeletalMeshComponent0
	//Components.Add(SkeletalMeshComponent0)

	//Begin Object Name=CollisionCylinder
	//	CollisionRadius=+32.000000
	//	CollisionHeight=+80.000000
	//End Object
	//CylinderComponent=CollisionCylinder

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
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
		AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'
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
}