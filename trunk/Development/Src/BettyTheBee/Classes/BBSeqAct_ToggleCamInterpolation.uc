// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class BBSeqAct_ToggleCamInterpolation extends SequenceAction;

var BBPlayerController Target;

event Activated()
{
	local BBMainCamera tempCam;

	tempCam = BBMainCamera(Target.PlayerCamera);
	if(tempCam != none){
		// Turn ON
		if (InputLinks[0].bHasImpulse)
		{
			tempCam.bInterpolateCam = true;
		}
		// Turn OFF
		else if (InputLinks[1].bHasImpulse)
		{
			tempCam.bInterpolateCam = false;
		}
		// Toggle
		else if (InputLinks[2].bHasImpulse)
		{
			tempCam.bInterpolateCam = !tempCam.bInterpolateCam;
		}
	}else{
		`warn("Toggling interpolation to" @ Target.PlayerCamera @ "This isn't a BBMainCamera");
	}
}

defaultproperties
{
	ObjName="Toggle Cam Interpolation"
	ObjCategory="BB Actions"

	InputLinks(0)=(LinkDesc="Turn On")
	InputLinks(1)=(LinkDesc="Turn Off")
	InputLinks(2)=(LinkDesc="Toggle")

	VariableLinks(0)=(bModifiesLinkedObject=true,ExpectedType=class'SeqVar_Object',LinkDesc="Player",PropertyName=Target,MinVars=1)
	//VariableLinks(1)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Bool",MinVars=0)
	EventLinks(0)=(LinkDesc="Event")
}
