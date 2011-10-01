class BBSeqCond_IsAlive extends SequenceCondition;

var Actor Target;

event Activated()
{
	if(Target != none && BBPawn(Target) != none && BBpawn(target).Health > 0){
		OutputLinks[0].bHasImpulse = true;
	}else{
		OutputLinks[1].bHasImpulse = true;
	}
}

defaultproperties
{
	ObjName="BB Is Alive"
	//ObjCategory="Pawn"

	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=Target,MinVars=1,MaxVars=1)
}
