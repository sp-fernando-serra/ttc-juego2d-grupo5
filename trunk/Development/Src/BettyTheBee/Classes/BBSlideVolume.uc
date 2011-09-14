class BBSlideVolume extends PhysicsVolume placeable classGroup(BBActor);

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		BBBettyPawn(Other).Controller.GotoState('PlayerSlide');
	}

simulated event UnTouch( Actor Other )
	{
		if(BBBettyPawn(Other)!=none)
			BBBettyPawn(Other).Controller.GotoState('PlayerWalking');
	}

DefaultProperties
{
	GroundFriction=-5; 
	bPhysicsOnContact=true;
}
