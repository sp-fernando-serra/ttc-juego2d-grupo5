class BBEndLevelTrigger extends Trigger placeable;

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal){

	super.Touch(Other,OtherComp,HitLocation,HitNormal);
	Pawn(Other).Controller.GotoState('myLevelEndedMode');
}


DefaultProperties
{
}
