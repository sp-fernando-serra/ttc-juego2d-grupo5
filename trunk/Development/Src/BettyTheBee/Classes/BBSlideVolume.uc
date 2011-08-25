class BBSlideVolume extends TriggerVolume placeable classGroup(BBActor);

var BBBettyPawn tempPawn;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	
}

state playerInside
{
	event UnTouch( Actor Other )
	{
		gotoState('idle');
		tempPawn.GotoState('idle');
		tempPawn.Controller.GotoState('PlayerWalking');
	}

	event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		tempPawn.Controller.GotoState('PlayerSlide');
		
	}

	event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		tempPawn.GotoState('idle');
		tempPawn.Controller.GotoState('PlayerWalking');
	}

Begin:
	


}

auto state idle
{
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		tempPawn = BBBettyPawn(Other);
		gotoState('playerInside');
		
	}
	
Begin:

}

DefaultProperties
{

}
