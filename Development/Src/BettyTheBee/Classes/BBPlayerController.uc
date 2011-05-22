class BBPlayerController extends PlayerController;

var bool bBettyMovement;
var float speed, sideSpeed, backSpeed;
var BBEnemyPawn targetedPawn;
var bool bCombatStance;

var rotator myRotation,myDesiredRotation;
var bool bLastStrafe, bLastForward,bLastBackward;
var bool bUpdateRot;

var bool broll;

//array de enemigos para la funcion lock-on(encarar enemigo)
var array<BBEnemyPawn> array_enemigos;
//radio de seleccion de enemigos
var float radioLockon;

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
	else{
		PushState('Grenade_Attack');
	}
}

function AnimNodeSequence getActiveAnimNode()
{
	local AnimNodeSequence animSeq;
	if(IsInState('PlayerRolling')) animSeq = BBBettyPawn(Pawn).getRollAnimNode();	
	if(IsInState('Sword_Attack')) animSeq = BBBettyPawn(Pawn).getAttackAnimNode();	
	if(animSeq==None)
	{
		return None;
	}
	return animSeq;
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


exec function LockOn()
{

	// local Actor HitActor;
  //local Vector HitLocation, HitNormal, EyeLocation;
  //local Rotator EyeRotation;


	local BBEnemyPawn A;
	local int i;

	foreach WorldInfo.AllPawns( class 'BBEnemyPawn', A , BBBettyPawn(Pawn).Location, radioLockon)
	//foreach   VisibleActors(class 'BBEnemyPawn', A , radioLockon)	
	//GetPlayerViewPoint(EyeLocation, EyeRotation);

	//ForEach TraceActors
 //   (
 //     class'BBEnemyPawn', 
 //     A, 
 //     HitLocation, 
 //     HitNormal, 
 //     //EyeLocation + Vector(EyeRotation) * PlayerOwner.InteractDistance, 
	//  EyeLocation + Vector(EyeRotation) * 500, 
 //     EyeLocation, 
 //     Vect(1.f, 1.f, 1.f),, 
 //      TRACEFLAG_PhysicsVolumes
 //   )
	{

			//`log("A"@A);
			//`log("distancia"@Vsize( BBBettyPawn(Pawn).Location - A.Location ));
			//`log("------");
			

		if ( array_enemigos.Length>0 )
			{
				// Find it's place and put it there.

				for (i=0;i<array_enemigos.Length;i++)
				{
	
					if( Vsize( BBBettyPawn(Pawn).Location - array_enemigos[i].Location ) > Vsize( BBBettyPawn(Pawn).Location - A.Location))
					{
						array_enemigos.Insert(i,1);
						array_enemigos[i] = A;
						break;
					}
				}
				if (i==array_enemigos.Length)
				{
					array_enemigos.Length = array_enemigos.Length+1;
					array_enemigos[i] = A;
				}
			}
			else
			{
				array_enemigos.Length = 1;
				array_enemigos[0] = A;
			}
    
		
	}

		//`log("----");
	if(array_enemigos.length>0){
		TargetedPawn=array_enemigos[0];	
		array_enemigos[0].playPariclesFijado();
	}

	if(bcombatstance == false && TargetedPawn!=none)
	{
		gotostate('combatstance');
	}else{
		TargetedPawn=none;
		gotostate('playerwalking');
	}


	//for (i = 0; i < array_enemigos.length; ++i) {
	//	`log("enemigo"@array_enemigos[i]);
	//}

	//`log("******");


}

exec function LockOff()
{
	array_enemigos.Remove(0,array_enemigos.length);
	TargetedPawn.stopPariclesFijado();
	TargetedPawn=none;
	gotostate('playerwalking');
}

exec function changeLockOn()
{

	if(IsInState('combatstance')){
		if(array_enemigos.Find(TargetedPawn)+1==array_enemigos.Length){	
			TargetedPawn.stopPariclesFijado();
			TargetedPawn=array_enemigos[0];	
			TargetedPawn.playPariclesFijado();

		}
		else{
			TargetedPawn.stopPariclesFijado();
			TargetedPawn=array_enemigos[array_enemigos.Find(TargetedPawn)+1];
			TargetedPawn.playPariclesFijado();

		}

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

	function UpdateRotationSword( float DeltaTime)
	{
		local Rotator	DeltaRot, /*NewRotation,*/ ViewRotation;

		ViewRotation = Rotation;
		if (Pawn!=none )
		{
			Pawn.SetDesiredRotation(ViewRotation);
		}

		// Calculate Delta to be applied on ViewRotation
		DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aLookUp;

		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		SetRotation(ViewRotation);

		ViewShake( deltaTime );

		//NewRotation = ViewRotation;
		//NewRotation.Roll = Rotation.Roll;

		//if ( Pawn != None && updatePawnRot)
		//	Pawn.FaceRotation(NewRotation, deltatime);
	}

	exec function shiftButtonDown()
	{
			broll = true;
	}

	exec function shiftButtonUp()
	{
			broll = false;
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


exec function BettyMovement( ){
	bBettyMovement=!bBettyMovement;
}

state PlayerWalking{
	
	function PlayerMove( float DeltaTime )
	{
		

		//local vector			X,Y,Z, NewAccel;
		//local eDoubleClickDir	DoubleClickMove;
		//local rotator			OldRotation;
		//local bool				bSaveJump;

		local vector	 X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local bool	 bSaveJump;
		local Rotator DeltaRot, ViewRotation, OldRotation, NewRot;

		
		if (PlayerInput.aForward > 0)
				pawn.GroundSpeed = speed;
			else if (PlayerInput.aForward <=0 && PlayerInput.aStrafe!=0)
				pawn.GroundSpeed = sideSpeed;
			else 
				pawn.GroundSpeed = backSpeed;



	if(bBettyMovement){
		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			

			GetAxes(Pawn.Rotation,X,Y,Z);


			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			//`log("NewAccel X"@NewAccel.x);
			//`log("NewAccel Y"@NewAccel.y);
			//`log("NewAccel Z"@NewAccel.z);

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			
			OldRotation = Rotation;
			UpdateRotation2( DeltaTime , VSize(NewAccel) != 0);
			//UpdateRotation( DeltaTime);
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
				if(!BBBettyPawn(Pawn).IsRolling()){
					if(broll  && PlayerInput.aStrafe>0){
						BBBettyPawn(Pawn).animRollRight();	
					}
					else if (broll  && PlayerInput.aStrafe<0){
						BBBettyPawn(Pawn).animRollLeft();	
						//`log("Acceleration: "@NewAccel);
					}
					//PushState('PlayerRolling');	
					//`log("Acceleration: ");
					ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
				}
				
				
			}
			bPressedJump = bSaveJump;
		}
		
	}else{
		
			if( Pawn == None )
			{
			GotoState('Dead');
			}
			else
			{
			GetAxes(Rotation,X,Y,Z);

			//update viewrotation

			ViewRotation = Rotation;

			// Calculate Delta to be applied on ViewRotation
			DeltaRot.Yaw	= PlayerInput.aTurn;
			DeltaRot.Pitch	= PlayerInput.aLookUp;
			ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
			SetRotation(ViewRotation);

			// Update acceleration.
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;



			// pawn face newaccel direction // 

			OldRotation = Pawn.Rotation;

			if( Pawn != None )

			{ if( NewAccel.X > 0.0 || NewAccel.X < 0.0 || NewAccel.Y > 0.0 || NewAccel.Y < 0.0 )

			NewRot = Rotator(NewAccel);
			else
			NewRot = Pawn.Rotation;	

			}
			Pawn.FaceRotation(RInterpTo(OldRotation,NewRot,Deltatime,90000,true),Deltatime);



			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
			bSaveJump = true;
			bPressedJump = false;
			}
			else
			{
			bSaveJump = false;
			}

			ProcessMove(DeltaTime, NewAccel, DoubleClickMove,Rotation);


			bPressedJump = bSaveJump;
			}
		}
	
	}

	
}

//state PlayerRolling // extends PlayerWalking
//{

//function animRollLeft(){
//	BBBettyPawn(Pawn).animRollLeft();
//}
//Begin:
//animRollLeft();
//FinishAnim(getActiveAnimNode());
//PopState();
//}

state CombatStance
{
ignores SeePlayer, HearNoise, Bump;

	//event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	//{
	//	if ( NewVolume.bWaterVolume && Pawn.bCollideWorld )
	//	{
	//		GotoState(Pawn.WaterMovementState);
	//	}
	//}
	
	function UpdateRotation( float DeltaTime )
	{
		local Rotator	DeltaRot, newRotation, ViewRotation;

		ViewRotation = Rotation;
		if(Pawn!=None)
			Pawn.SetDesiredRotation(ViewRotation);

		// Calculate Delta to be applied on ViewRotation
		DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aLookUp;

		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		SetRotation(ViewRotation);

		ViewShake( deltaTime );

		NewRotation = ViewRotation;
		NewRotation.Roll = Rotation.Roll;

		if ( Pawn != None )
			Pawn.FaceRotation(NewRotation, deltatime);
		SetRotation(rotator(TargetedPawn.GetTargetLocation() - Pawn.GetPawnViewLocation()));
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

		CheckJumpOrDuck();
	}

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
			UpdateRotation( DeltaTime );
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
				if(!BBBettyPawn(Pawn).IsRolling()){
					if(broll  && PlayerInput.aStrafe>0){
						BBBettyPawn(Pawn).animRollRight();	
					}
					else if (broll  && PlayerInput.aStrafe<0){
						BBBettyPawn(Pawn).animRollLeft();	
						//`log("Acceleration: "@NewAccel);
					}
					//PushState('PlayerRolling');	
					//`log("Acceleration: ");
					ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
				}
			}
			bPressedJump = bSaveJump;
		}
	}

	event BeginState(Name PreviousStateName)
	{
		DoubleClickDir = DCLICK_None;
		bPressedJump = false;
		bCombatStance = true;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.ShouldCrouch(false);
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody) // FIXME HACK!!!
				Pawn.SetPhysics(PHYS_Walking);
		}
	}

	event EndState(Name NextStateName)
	{
		GroundPitch = 0;
		bCombatStance = false;
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			if ( bDuck == 0 )
			{
				Pawn.ShouldCrouch(false);
			}
		}
		TargetedPawn = None;
	}
	
	event PoppedState()
	{
		TargetedPawn = None;
	}
	
	event PlayerTick(float DeltaTime)
	{
		Super.PlayerTick(DeltaTime);
		if(TargetedPawn!=None)
		{
			if(TargetedPawn.Health <=0)
				GotoState('PlayerWalking');
		}else{
			GotoState('PlayerWalking');
		}
	}

Begin:
}



state Sword_Attack
{

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z;
		//local vector NewAccel;

		GetAxes(Rotation,X,Y,Z);
		Acceleration = 0*X + 0*Y + 0*vect(0,0,1);

		UpdateRotationSword(DeltaTime);

		if (Role < ROLE_Authority) // then save this move and replicate it
		{
			ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		}
		else
		{
			//`log("AccelerationAttack: "@Velocity);
			Velocity.Y=1000;
			
			ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		}
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
	//function PlayerMove( float DeltaTime )
	//{
	//	local vector X,Y,Z;

	//	GetAxes(Rotation,X,Y,Z);
	//	Acceleration = 0*X + 0*Y + 0*vect(0,0,1);
	//	UpdateRotation(DeltaTime);

	//	if (Role < ROLE_Authority) // then save this move and replicate it
	//	{
	//		ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
	//	}
	//	else
	//	{
	//		ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
	//	}
	//}	
 

	function prepararAttack()
	{
		//aqui calcularem on impactara la granada
   	}

	function lanzarAttack()
	{
		//Worldinfo.Game.Broadcast(self, Name $ ": lanzarAttack ");
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



DefaultProperties
{
	CameraClass=class 'BBMainCamera' //Telling the player controller to use your custom camera script
	DefaultFOV=90.f //Telling the player controller what the default field of view (FOV) should be

	bBettyMovement=true;
	speed = 400;
	sideSpeed = 300;
	backSpeed = 250;

	radioLockon=600.0;

	broll=false;

}