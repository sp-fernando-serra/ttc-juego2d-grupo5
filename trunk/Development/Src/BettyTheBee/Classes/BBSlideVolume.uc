class BBSlideVolume extends Volume placeable classGroup(BBActor);

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
	bColored=true
	BrushColor=(B=225,G=255,R=0,A=255)

	//GroundFriction=0.8; 
	//bPhysicsOnContact=true;
}
