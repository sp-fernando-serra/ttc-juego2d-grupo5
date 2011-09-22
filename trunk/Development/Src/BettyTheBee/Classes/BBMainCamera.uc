class BBMainCamera extends Camera;

//Initializing static variables
var float Dist;

var float z_anterior;
var vector loc_anterior,loc_actual;
/** Used to interpolate cam or use direct translation */
var bool bInterpolateCam;
/** Interpolate cam in X if bInterpolateCam = true && bInterpolateDirection[X] = true */
var bool bInterpolateCamX;
/** Interpolate cam in Y if bInterpolateCam = true && bInterpolateDirection[Y] = true */
var bool bInterpolateCamY;
/** Interpolate cam in Z if bInterpolateCam = true && bInterpolateDirection[Z] = true */
var bool bInterpolateCamZ;
/** Speed to interpolate between camera positions if bInterpolateCam */
var float InterpolationSpeed;


function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{

	//Declaring local variables
	local vector			Loc, Pos, HitLocation, HitNormal;
	local rotator			Rot;
	local Actor			HitActor;
	local CameraActor		CamActor;
	local bool			bDoNotApplyModifiers;
	//local TPOV			OrigPOV;

	// store previous POV, in case we need it later
	//OrigPOV = OutVT.POV;

	// Default FOV on viewtarget
	OutVT.POV.FOV = DefaultFOV;

	// Viewing through a camera actor.
	CamActor = CameraActor(OutVT.Target);
	if( CamActor != None )
	{
		CamActor.GetCameraView(DeltaTime, OutVT.POV);

		// Grab aspect ratio from the CameraActor.
		bConstrainAspectRatio = bConstrainAspectRatio || CamActor.bConstrainAspectRatio;
		OutVT.AspectRatio = CamActor.AspectRatio;

		// See if the CameraActor wants to override the PostProcess settings used.
		CamOverridePostProcessAlpha = CamActor.CamOverridePostProcessAlpha;
		//bCamOverridePostProcess = CamActor.bCamOverridePostProcess;
		CamPostProcessSettings = CamActor.CamOverridePostProcess;
	} else
	{
		// Give Pawn Viewtarget a chance to dictate the camera position.
		// If Pawn doesn't override the camera view, then we proceed with our own defaults
		if( Pawn(OutVT.Target) == None || !Pawn(OutVT.Target).CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV) )
			
		{
			// don't apply modifiers when using these debug camera modes.
			bDoNotApplyModifiers = TRUE;

			switch(CameraStyle)
			{
				case 'ThirdPerson' : //Enters here as long as CameraStyle is still set to ThirdPerson
				case 'FreeCam' :

					
					//Loc = OutVT.Target.Location; // Setting the camera location and rotation to the viewtarget's
					//Rot = OutVT.Target.Rotation;

					if (CameraStyle == 'ThirdPerson')
					{
						Rot = PCOwner.Rotation; //setting the rotation of the camera to the rotation of the pawn				
					}

					OutVT.Target.GetActorEyesViewPoint(Loc, Rot);
					loc_actual=Loc;
					//If bInterpolateCam and the las position is different from (0,0,0); that's to avoid interpolation at the beginning of the game
					if(bInterpolateCam && VSize(loc_anterior) != 0){
						Loc = VInterpTo(loc_anterior, Loc, DeltaTime, InterpolationSpeed);
						if(!bInterpolateCamX){
							Loc.X=loc_actual.X;
						}
						if(!bInterpolateCamY){
							Loc.Y=loc_actual.Y;
						}
						if(!bInterpolateCamZ){
							Loc.Z=loc_actual.Z;
						}
					}
					//Add offset to put the cam away from the player
					Loc += FreeCamOffset >> Rot;
					//Save location to use with Interpolation in next frame
					loc_anterior = Loc;

					Pos = Loc - Vector(Rot) * Dist; /*Instead of using FreeCamDistance here, which would cause the camera to jump by the entire increment, we use Dist, which increments in small steps to the desired value of FreeCamDistance using the Lerp function below*/


					if (CameraStyle == 'FreeCam')
					{
						//ViewTarget.Target = none;
						Rot = PCOwner.Rotation;
					}

					
					if (Dist != FreeCamDistance)
					{
						Dist = Lerp(Dist,FreeCamDistance,0.15); //Increment Dist towards FreeCamDistance, which is where you want your camera to be. Increments a percentage of the distance between them according to the third term, in this case, 0.15 or 15%
					}
					
					HitActor = Trace(HitLocation, HitNormal, Pos, Loc, FALSE, vect(12,12,12));
	

						
					OutVT.POV.Location = (HitActor == None) ? Pos : HitLocation;

					OutVT.POV.Rotation = Rot;
					

				break; //This is where our code leaves the switch-case statement, preventing it from executing the commands intended for the FirstPerson case.

				case 'FirstPerson' : // Simple first person, view through viewtarget's 'eyes'
					
				default : OutVT.Target.GetActorEyesViewPoint(OutVT.POV.Location, OutVT.POV.Rotation);
				break;
			}
		}
	}

	if( !bDoNotApplyModifiers )
	{
		ApplyCameraModifiers(DeltaTime, OutVT.POV);
	}

	//`log( WorldInfo.TimeSeconds  @ GetFuncName() @ OutVT.Target @ OutVT.POV.Location @ OutVT.POV.Rotation @ OutVT.POV.FOV );
}



DefaultProperties
{
	FreeCamDistance = 370.0f //Distance of the camera to the player


	bInterpolateCam = true;

	bInterpolateCamX = true;
	bInterpolateCamY = true;
	bInterpolateCamZ = true;

	InterpolationSpeed = 7.5f;
}