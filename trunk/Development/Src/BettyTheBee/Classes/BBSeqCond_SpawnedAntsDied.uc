class BBSeqCond_SpawnedAntsDied extends SequenceCondition;

var Actor Target;

event Activated()
{
	if(Target != none && BBAntHill(Target) != none){
		if(BBAntHill(target).SpawnedAnt1 != none && BBAntHill(target).SpawnedAnt2 != none){
			if(BBAntHill(target).SpawnedAnt1.Health > 0 && BBAntHill(target).SpawnedAnt2.Health > 0){
				OutputLinks[1].bHasImpulse = true;
				return;
			}
		}
	}
	OutputLinks[0].bHasImpulse = true;
}

defaultproperties
{
	ObjName="BB Spawned Ants Died"
	ObjCategory="BB Conditions"

	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="BB AntHill",PropertyName=Target,MinVars=1,MaxVars=1)
}
