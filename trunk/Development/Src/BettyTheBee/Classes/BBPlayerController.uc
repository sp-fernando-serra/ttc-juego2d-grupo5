class BBPlayerController extends PlayerController;

simulated event PostBeginPlay() //This event is triggered when play begins
{
	super.PostBeginPlay();
	`Log("I am alive!"); //This sends the message "I am alive!" to thelog (to see the log, you need to run UDK with the -log switch)	
}

//Functions for zooming in and out
exec function NextWeapon() /*The "exec" command tells UDK that this function can be called by the console or keybind.
We'll go over how to change the function of keys later (if, for instance, you didn't want you use the scroll wheel, but page up and down for zooming instead.)*/
{
	if (PlayerCamera.FreeCamDistance < 512) //Checks that the the value FreeCamDistance, which tells the camera how far to offset from the view target, isn't further than we want the camera to go. Change this to your liking.
	{
		`Log("MouseScrollDown"); //Another log message to tell us what's happening in the code
		PlayerCamera.FreeCamDistance += 64*(PlayerCamera.FreeCamDistance/256); /*This portion increases the camera distance.
By taking a base zoom increment (64) and multiplying it by the current distance (d) over 256, we decrease the zoom increment for when the camera is close,
(d < 256), and increase it for when it's far away (d > 256).
Just a little feature to make the zoom feel better. You can tweak the values or take out the scaling altogether and just use the base zoom increment if you like */
	}
}

exec function PrevWeapon()
{
	if (PlayerCamera.FreeCamDistance > 64) //Checking if the distance is at our minimum distance
	{
		`Log("MouseScrollUp");
		PlayerCamera.FreeCamDistance -= 64*(PlayerCamera.FreeCamDistance/256); //Once again scaling the zoom for distance
	}
}

//event PlayerTick(float DeltaTime){
//	super.PlayerTick(DeltaTime);
//	`log("Player in state: "$GetStateName());
//}

exec function ThirdPersonCam(){
	local BBBettyPawn P;
	Camera('ThirdPersonCam');
	foreach AllActors( class 'BBBettyPawn',P){
		Possess(P,false);
		break;
	}
	
}

exec function ExecSpectatorMode()
{   
	GoToState('mySpectatorMode');
}

exec function StaticCam (int camNum){
	local CameraActor Cam;
	local string s1,s2;
	
	s1 = "CameraActor_"$camNum;
	GotoState('myStaticCamMode');	
	foreach AllActors( class 'CameraActor',Cam){
		s2 = string(Cam.Name);		
		if(s2 ~= s1){
			myMoveto(Cam.Location,Cam.Rotation);
			break;
		}
	}	
}

exec function myMoveto(Vector Loc, Rotator Rot)
{   
	SetLocation(Loc);
	SetRotation(Rot);
}

state mySpectatorMode extends Spectating
{
	event BeginState(name PreviousStateName){
		Camera('FirstPersonCam');		
		super.BeginState(PreviousStateName);
	}
}

state myStaticCamMode extends Spectating
{
	event BeginState(name PreviousStateName){
		Camera('FirstPersonCam');		
		super.BeginState(PreviousStateName);
	}
	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);
		Acceleration = 0*X + 0*Y + 0*vect(0,0,1);
		UpdateRotation(DeltaTime);

		if (Role < ROLE_Authority) // then save this move and replicate it
		{
			ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		}
		else
		{
			ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		}
	}	
}

state myLevelEndedMode extends Spectating{
	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);
		Acceleration = 0*X + 0*Y + 0*vect(0,0,1);
		UpdateRotation(DeltaTime);

		if (Role < ROLE_Authority) // then save this move and replicate it
		{
			ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		}
		else
		{
			ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		}
	}
Begin:
	WorldInfo.Game.Broadcast(self,"Level Completed!");
	WorldInfo.Game.Broadcast(self,"Restarting level in...");
	WorldInfo.Game.Broadcast(self,"3");
	Sleep(1);
	WorldInfo.Game.Broadcast(self,"2");
	Sleep(1);
	WorldInfo.Game.Broadcast(self,"1");
	Sleep(1);
	WorldInfo.SeamlessTravel("BB-BettyLevelMenu");
}

state Dead{
Begin:
	`log("Player Muerto");
	WorldInfo.Game.Broadcast(self,"You are Dead!");
	WorldInfo.Game.Broadcast(self,"Restarting level in...");
	WorldInfo.Game.Broadcast(self,"3");
	Sleep(1);
	WorldInfo.Game.Broadcast(self,"2");
	Sleep(1);
	WorldInfo.Game.Broadcast(self,"1");
	Sleep(1);
	WorldInfo.SeamlessTravel("BB-BettyLevelMenu");
}

state PlayerWalking{

	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local bool				bSaveJump;

		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Pawn.Rotation,X,Y,Z);

			// Update acceleration.
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			
			OldRotation = Rotation;
			UpdateRotation2( DeltaTime , VSize(NewAccel) != 0);
			bDoubleJump = false;
			

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			bPressedJump = bSaveJump;
		}
	}

	function UpdateRotation2( float DeltaTime, bool updatePawnRot)
	{
		local Rotator	DeltaRot, newRotation, ViewRotation;

		ViewRotation = Rotation;
		if (Pawn!=none && updatePawnRot)
		{
			Pawn.SetDesiredRotation(ViewRotation);
		}

		// Calculate Delta to be applied on ViewRotation
		DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aLookUp;

		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		SetRotation(ViewRotation);

		ViewShake( deltaTime );

		NewRotation = ViewRotation;
		NewRotation.Roll = Rotation.Roll;

		if ( Pawn != None && updatePawnRot)
			Pawn.FaceRotation(NewRotation, deltatime);
	}
}


exec function GetSword(){
	BBBettyPawn(Pawn).GetSword();
}


exec function GetGrenade(){
	BBBettyPawn(Pawn).GetGrenade();
}



exec function StartFire( optional byte FireModeNum )
{	
	if ( BBBettyPawn(Pawn) != None && !bCinematicMode && !WorldInfo.bPlayersOnly )
	{
		if( BBBettyPawn(Pawn).Weapon.Class == class'BBWeaponSword'){			
			BBBettyPawn(Pawn).StartFire( FireModeNum );			
		}
		startAttack();
	}

}


exec function StopFire( optional byte FireModeNum )
{	
	if ( BBBettyPawn(Pawn) != None )
	{
		BBBettyPawn(Pawn).StopFire( FireModeNum );
	}
	
}

function startAttack()
{
	if( BBBettyPawn(Pawn).Weapon.Class == class'BBWeaponSword'){	
		PushState('Sword_Attack');
	}
	else PushState('Grenade_Attack');
}

function AnimNodeSequence getActiveAnimNode()
{
	local AnimNodeSequence animSeq;
	animSeq = BBBettyPawn(Pawn).getAttackAnimNode();
	if(animSeq==None)
	{
		return None;
	}
	return animSeq;
}

state Sword_Attack
{
	event PushedState()
	{	
	}
	
	event PoppedState()
	{
	}
	
	function startAttack()
	{
		if(canCombo())	GotoState('Sword_Attack','Combo');
	}
	
	function initialAttack()
	{
		BBBettyPawn(Pawn).basicSwordAttack();
   	}
   	
   	function comboAttack()
   	{
   		BBBettyPawn(Pawn).comboSwordAttack();
   	}
Begin:
initialAttack();
FinishAnim(getActiveAnimNode());
PopState();

Combo:
comboAttack();
FinishAnim(getActiveAnimNode());
PopState();

}

state Grenade_Attack
{
	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);
		Acceleration = 0*X + 0*Y + 0*vect(0,0,1);
		UpdateRotation(DeltaTime);

		if (Role < ROLE_Authority) // then save this move and replicate it
		{
			ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		}
		else
		{
			ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		}
	}	
 

	function prepararAttack()
	{
		//aqui calcularem on impactara la granada
   	}

	function lanzarAttack()
	{
		Worldinfo.Game.Broadcast(self, Name $ ": lanzarAttack ");
		BBBettyPawn(Pawn).GrenadeAttack();
   	}
	   	
	exec function StopFire( optional byte FireModeNum )
	{	
		if(BBBettyPawn(Pawn).itemsMiel-5>=0){
			GotoState('Grenade_Attack','Lanzar');
			if ( BBBettyPawn(Pawn) != None )
			{
			BBBettyPawn(Pawn).StartFire( FireModeNum );
			BBBettyPawn(Pawn).StopFire( FireModeNum );
			}
		}else PopState();

	}

Lanzar:
lanzarAttack();
FinishAnim(getActiveAnimNode());
PopState();

Begin:
}

function bool canCombo()
{
	local BBBettyPawn p;
	
	p = BBBettyPawn(Pawn);
	if(p!=None)
	{
		return p.canStartCombo();
	}
	return false;
}

DefaultProperties
{
	CameraClass=class 'BBMainCamera' //Telling the player controller to use your custom camera script
	DefaultFOV=90.f //Telling the player controller what the default field of view (FOV) should be
}