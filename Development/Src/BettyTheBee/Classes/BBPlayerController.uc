class BBPlayerController extends UDKPlayerController;

/** Used to determine what type of movement yo use. TRUE = Strafing movement; FALSE = No-strafing movement */
var bool bBettyMovement;
/** Speed when moving forward */
var float speed;
/** Speed for strafing moves */
var float sideSpeed;
/** Speed for back movement */
var float backSpeed;
/** Speed in sliding state. This will change over the time */
var float slideSpeed;
/** Max value for slideSpeed */
var float maxSlideSpeed;
/** Amount to add/substract every second to slideSpeed */
var float slideSpeedIncrement, slideSpeedDecrement;


var BBEnemyPawn targetedPawn;
var bool bCombatStance;

//var BBBettyPawn MyBettyPawn;

var rotator myRotation,myDesiredRotation;
var bool bLastStrafe, bLastForward,bLastBackward;
var bool bUpdateRot;

/** Indicates if Pawn is Rolling */
var bool broll;

//var bool bPlay_humo_correr;

//array de enemigos para la funcion lock-on(encarar enemigo)
var array<BBEnemyPawn> array_enemigos;

//radio de seleccion de enemigos
var float radioLockon;

//velocidad de rotacion de betty para giros mas suaves(en modo normal...no mario64)
var float RotationSpeed;

var bool block;
var bool bSliding;

/** Honey cost of Heal */
var int costHeal;
/** Amount of hearts Healed*/
var int amountHealed;
/** DamageType of Heal Hability. NOT USED*/
var class<DamageType> HealDamageType;
/** Honey cost of Frenesi */
var int costFrenesi;
/** Duration in seconds of Frenesi */
var float frenesiMaxDuration;
/** Time left in seconds of Frenesi */
var float frenesiDuration;
/** Multiplying factor for Speed in Frenesi Mode */
var float frenesiSpeedFactor;
/** Slow Motion factor in Frenesi Mode */
var float frenesiSlomoFactor;
/** Honey cost of Grenade */
var int costGrenade;

/** Used for deactivate emitter when frenesi finishes */
var array<ParticleSystemComponent> frenesiPSCS;

/** Shows when the pawn is Stopped by an enemy hit */
var bool bStoppedByHit;
/** When get hitted the pawn stops his movement "hitStopTime" seconds */
var float hitStopTime;
/** Only can do a AirAttack if Velocity.Z < AirAttackThreshold */
var float AirAttackThreshold;

var SoundCue FrenesiSound;
enum EHabilityNames
{
	HN_Heal,
	HN_Frenesi,
	HN_Roll,
	HN_Grenade
};
/** Coldowns in seconds for each hability */
var float coldDowns[EHabilityNames];
/** Time until coldown refresh */
var float reactivateTime[EHabilityNames];

/** cached result of GetPlayerViewPoint() */
//var Actor CalcViewActor;

simulated event PostBeginPlay() //This event is triggered when play begins
{
	//local BBGamePlayerCamera tempCamera;
	super.PostBeginPlay();
	//tempCamera = BBGamePlayerCamera(PlayerCamera);
	//BBGameThirdPersonCamera(tempCamera.CurrentCamera).SetFocusOnActor(Pawn, '', vect2d(90,90), vect2d(100, 100),,,,, 5000);
}

//-----------------------------------------------------------------------------------------------
//--------------------------------FUNCIONES EXEC-------------------------------------------------


//RUEDA RATON
exec function NextWeapon() /*The "exec" command tells UDK that this function can be called by the console or keybind.
We'll go over how to change the function of keys later (if, for instance, you didn't want you use the scroll wheel, but page up and down for zooming instead.)*/
{
	if (PlayerCamera.FreeCamDistance < 370) //Checks that the the value FreeCamDistance, which tells the camera how far to offset from the view target, isn't further than we want the camera to go. Change this to your liking.
	{
		//`Log("MouseScrollDown"); //Another log message to tell us what's happening in the code
		PlayerCamera.FreeCamDistance += 64*(PlayerCamera.FreeCamDistance/256); 
		if(PlayerCamera.FreeCamDistance > 370) PlayerCamera.FreeCamDistance = 370;
		/*This portion increases the camera distance.
By taking a base zoom increment (64) and multiplying it by the current distance (d) over 256, we decrease the zoom increment for when the camera is close,
(d < 256), and increase it for when it's far away (d > 256).
Just a little feature to make the zoom feel better. You can tweak the values or take out the scaling altogether and just use the base zoom increment if you like */
	}
}

//RUEDA RATON
exec function PrevWeapon()
{
	if (PlayerCamera.FreeCamDistance > 180) //Checking if the distance is at our minimum distance
	{
		//`Log("MouseScrollUp");
		PlayerCamera.FreeCamDistance -= 64*(PlayerCamera.FreeCamDistance/256); //Once again scaling the zoom for distance
		if(PlayerCamera.FreeCamDistance < 180) PlayerCamera.FreeCamDistance = 180;
	}
}


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
	BBBettyPawn(Pawn).GetUnequipped();
}


exec function GetGrenade(){
	BBBettyPawn(Pawn).GetGrenade();
}




//BOTON IZQUIERDO RATON (DOWN)
exec function StartFire( optional byte FireModeNum )
{	
	//if ( BBBettyPawn(Pawn) != None && !bCinematicMode && !WorldInfo.bPlayersOnly )
	//{
	//	if( BBBettyPawn(Pawn).Weapon.Class == class'BBWeaponSword'){			
	//		BBBettyPawn(Pawn).StartFire( FireModeNum );			
	//	}
	//	startAttack();
	//}

	if ( BBBettyPawn(Pawn) != None && !bCinematicMode && !WorldInfo.bPlayersOnly )
	{
		
		if( BBBettyPawn(Pawn).Weapon.Class == class'BBWeaponSword'){			
			if(FireModeNum==0) BBBettyPawn(Pawn).StartFire( FireModeNum );			
		}
		startAttack(FireModeNum);
	}

}

//BOTON IZQUIERDO RATON (UP)
exec function StopFire( optional byte FireModeNum )
{	
	if ( BBBettyPawn(Pawn) != None )
	{
		BBBettyPawn(Pawn).StopFire( FireModeNum );
	}
	
}



//BOTON DERECHO RATON (DOWN)
exec function LockOn()
{

  //local Actor HitActor;
  //local Vector HitLocation, HitNormal, EyeLocation;
  //local Rotator EyeRotation;


	local BBEnemyPawn A;//,B;
	local int i;

	BBHUD(myHUD).texto_ayudaOFF();
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
if (!bSliding)
{

	foreach WorldInfo.AllPawns( class 'BBEnemyPawn', A , BBBettyPawn(Pawn).Location, radioLockon)
	{
		if(!A.bPlayedDeath){
			
			if ( array_enemigos.Length>0 )
				{

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
		
	}


		
	if(array_enemigos.length>0){
		TargetedPawn=array_enemigos[0];	
		array_enemigos[0].playPariclesFijado();
	}

	if(bcombatstance == false && TargetedPawn!=none)
	{
		gotostate('combatstance');
	}else{
		TargetedPawn=none;
		gotostate('PlayerWalking');
	}

}

}


//BOTON DERECHO RATON (UP)
exec function LockOff()
{
	if (!bSliding)
	{

	if(TargetedPawn != none){
		array_enemigos.Remove(0,array_enemigos.length);
		TargetedPawn.stopPariclesFijado();
		TargetedPawn=none;
	}
	gotostate('PlayerWalking');
	}
}


//LETRA 'Q'
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

//LETRA 'SHIFT_IZQ' (DOWN)
exec function shiftButtonDown(){
	broll = true;
}

//LETRA 'SHIFT_IZQ' (UP)
exec function shiftButtonUp(){
	broll = false;
}

//LETRA 'M' (cambio de movimento normal a mario64)
exec function BettyMovement( ){
	bBettyMovement=!bBettyMovement;
}


//LETRA 'E' (DOWN) (escojemos 'granada' como weapon)
exec function EButtonDown(){
	startAttack(1);
	//if(BBBettyPawn(Pawn).itemsMiel-5>=0){
	//	BBBettyPawn(Pawn).GrenadeAttack();
	//}
}


exec function GetVida(){
	
	if(canUseHeal()){
		//Returns true only if healing has been sucessfull
		if(Pawn.HealDamage(amountHealed,self,HealDamageType)){
			BBBettyPawn(Pawn).itemsMiel -= costHeal;
			BBBettyPawn(Pawn).healUsed();
			reactivateTime[HN_Heal] = coldDowns[HN_Heal];			
		}
	}
}

exec function UseFrenesi(){

	if(canUseFrenesi()){
		frenesiDuration = frenesiMaxDuration;
		Pawn.MovementSpeedModifier = frenesiSpeedFactor;
		//WorldInfo.Game.SetGameSpeed(frenesiSlomoFactor);
		ChangePPSettings(Pawn);
		BBBettyPawn(Pawn).itemsMiel -= costFrenesi;
		frenesiPSCS = BBBettyPawn(Pawn).frenesiUsed();
		reactivateTime[HN_Frenesi] = coldDowns[HN_Frenesi];
	}
}

function ChangePPSettings(Pawn inPawn){

	local LocalPlayer LocalPlayer;
	local PostProcessSettings DarkSettings;

	LocalPlayer = LocalPlayer( PlayerController(inPawn.Controller).Player );

	//LocalPlayer.bOverridePostProcessSettings = true;
	DarkSettings = LocalPlayer.CurrentPPInfo.LastSettings;

	DarkSettings.bEnableMotionBlur = true;
	DarkSettings.bOverride_MotionBlur_Amount = true;
	DarkSettings.MotionBlur_Amount = 2.0f;
	DarkSettings.bOverride_MotionBlur_MaxVelocity = true;
	DarkSettings.MotionBlur_MaxVelocity = 1.0f;	
	DarkSettings.bAllowAmbientOcclusion = true;

	LocalPlayer.OverridePostProcessSettings(DarkSettings, 0.5f);
}

function ResetPPSettings(Pawn inPawn){
	local LocalPlayer LocalPlayer;

	LocalPlayer = LocalPlayer( PlayerController(inPawn.Controller).Player );
	LocalPlayer.ClearPostProcessSettingsOverride(0.5f);
}

//--------------------------------FUNCIONES EXEC-------------------------------------------------
//-----------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------
//--------------------------------FUNCIONES ROTACION CAMARA Y PLAYER-----------------------------


function UpdateRotationCustom( float DeltaTime, bool updatePawnRot){
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
	ViewShake( deltaTime );
	//`log(TargetedPawn);
	switch(GetStateName()){
		case 'PlayerWalking' : 

			NewRotation = ViewRotation;
			NewRotation.Roll = Rotation.Roll;
			if ( Pawn != None && updatePawnRot)						
				Pawn.FaceRotation(RInterpTo(Pawn.Rotation, NewRotation, DeltaTime, RotationSpeed, true), DeltaTime);

			break;

		default: //CombatStance, Grenade_attack y Sword_Attack

			if(TargetedPawn!=none){ //estamos fijados a un enemigo
				NewRotation=rotator(TargetedPawn.GetTargetLocation() - Pawn.GetTargetLocation());
				if ( Pawn != None )
					Pawn.FaceRotation(NewRotation, deltatime);
				ViewRotation.Yaw=NewRotation.Yaw;
			}
			else{ //no estamos fijados a un enemigo
				NewRotation = ViewRotation;
				NewRotation.Roll = Rotation.Roll;
				if ( Pawn != None && updatePawnRot)						
					Pawn.FaceRotation(RInterpTo(Pawn.Rotation, NewRotation, DeltaTime, RotationSpeed, true), DeltaTime);
			}
			break;
		}	

	SetRotation(ViewRotation);	

}


function PlayerMove( float DeltaTime ){

	local vector	 X,Y,Z, NewAccel;
	local eDoubleClickDir	DoubleClickMove;
	local bool	 bSaveJump;
	local Rotator DeltaRot, ViewRotation, OldRotation, NewRot;

	if(bBettyMovement){
		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{

			if (PlayerInput.aForward > 0){
				pawn.GroundSpeed = speed;
			}
			else if (PlayerInput.aForward <=0 && PlayerInput.aStrafe!=0)
				pawn.GroundSpeed = sideSpeed;
			else 
				pawn.GroundSpeed = backSpeed;

			//if(PlayerInput.aForward!=0) BBBettyPawn(Pawn).play_humo_correr();
			//else BBBettyPawn(Pawn).stop_humo_correr();

			//if(PlayerInput.aForward!=0 && bPlay_humo_correr) {
			//	bPlay_humo_correr=false;
			//	BBBettyPawn(Pawn).play_humo_correr();
			//}else if (PlayerInput.aForward==0) bPlay_humo_correr=true;
			
			GetAxes(Pawn.Rotation,X,Y,Z);

			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			
			OldRotation = Rotation;
			UpdateRotationCustom( DeltaTime , VSize(NewAccel) != 0);
			
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
					if(canUseRoll()  && PlayerInput.aStrafe>0 && PlayerInput.aForward == 0){
						BBBettyPawn(Pawn).animRollRight();
						reactivateTime[HN_Roll] = coldDowns[HN_Roll];
					}
					else if (canUseRoll()  && PlayerInput.aStrafe<0 && PlayerInput.aForward == 0){
						BBBettyPawn(Pawn).animRollLeft();
						reactivateTime[HN_Roll] = coldDowns[HN_Roll];
					}
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
			
			if(PlayerInput.aForward!=0 || PlayerInput.aStrafe!=0){
				speed = 400;
			}
			pawn.GroundSpeed = speed;

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
			Pawn.FaceRotation(RInterpTo(OldRotation,NewRot,Deltatime,100000,true),Deltatime);



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

//--------------------------------FUNCIONES ROTACION CAMARA Y PLAYER-----------------------------
//-----------------------------------------------------------------------------------------------


function startAttack(optional byte FireModeNum )
{
	if(BBBettyPawn(Pawn).Weapon.Class == class'BBWeaponSword'){	
		if(FireModeNum==0 && canAttack())PushState('Sword_Attack');
		if(FireModeNum==0 && canAirAttack()) PushState('Air_Attack');
		if(FireModeNum==1 && canThrowGrenade())PushState('Grenade_Attack');
	}
	else{
		//Pasamos al estado de equipar la espada si no tenemos arma equipada
		
		if(FireModeNum==0 && canAttack())PushState('Equipping_Sword');
		if(FireModeNum==0 && canAirAttack()) PushState('Air_Attack');
		if(FireModeNum==1 && canThrowGrenade())PushState('Grenade_Attack');
	}
}


function AnimNodeSequence getActiveAnimNode()
{
	local AnimNodeSequence animSeq;	
	if(IsInState('Sword_Attack') || IsInState('Grenade_Attack')) animSeq = BBBettyPawn(Pawn).getAttackAnimNode();	
	if(animSeq==None)
	{
		return None;
	}
	return animSeq;
}

function bool canAttack(){
	local BBBettyPawn tempPawn;
	tempPawn = BBBettyPawn(Pawn);
	if(Pawn.Physics != PHYS_Falling && !IsInState('Grenade_Attack') && !bStoppedByHit && !bSliding && !tempPawn.bPreparingJump) return true;	
	return false;
}

function bool canAirAttack(){
	
	if(Pawn.Physics == PHYS_Falling && (Pawn.Velocity.Z < AirAttackThreshold) && !IsInState('Air_Attack') && !IsInState('Grenade_Attack') && !bSliding) return true;	
	return false;
}

function bool canCombo()
{
	local BBBettyPawn tempPawn;
	
	tempPawn = BBBettyPawn(Pawn);
	if(tempPawn!=None)
	{
		if(tempPawn.canStartCombo() && IsInState('Sword_Attack') && !bStoppedByHit &&  Pawn.Physics != PHYS_Falling  && !bSliding) return true;
	}
	return false;
}

simulated function bool canThrowGrenade(){
	
	if(reactivateTime[HN_Grenade] == 0 && (IsInState('PlayerWalking') || IsInState('CombatStance')) && !bStoppedByHit &&  Pawn.Physics != PHYS_Falling && BBBettyPawn(Pawn).itemsMiel >= costGrenade  && !bSliding) return true;
	else return false;
}

simulated function bool canUseHeal(){
	if(reactivateTime[HN_Heal] == 0 && (IsInState('PlayerWalking') || IsInState('PlayerSlide') || IsInState('CombatStance')) && !bStoppedByHit &&  Pawn.Physics != PHYS_Falling && BBBettyPawn(Pawn).itemsMiel >= costHeal) return true;
	else return false;
}

simulated function bool canUseFrenesi(){
	if(reactivateTime[HN_Frenesi] == 0 && frenesiDuration == 0 && (IsInState('PlayerWalking') || IsInState('PlayerSlide')  || IsInState('CombatStance')) && !bStoppedByHit &&  Pawn.Physics != PHYS_Falling && BBBettyPawn(Pawn).itemsMiel >= costFrenesi) return true;
	else return false;
}

simulated function bool canUseRoll(){
	if(broll && reactivateTime[HN_Roll] == 0 && (IsInState('PlayerWalking') || IsInState('CombatStance')) && !bStoppedByHit &&  Pawn.Physics != PHYS_Falling  && !bSliding) return true;
	else return false;
}
simulated function bool canJump(){
	if(!bStoppedByHit) return true;
	else return false;
}

function CheckJumpOrDuck()
{
	if ( Pawn == None )
	{
		return;
	}
	//Nunca entraba en este codigo. El doubleJump esta implementado en el prepareJump
	//if ( bDoubleJump && (bUpdating || ((BBBettyPawn(Pawn) != None) && BBBettyPawn(Pawn).CanDoubleJump())) )
	//{
	//	BBBettyPawn(Pawn).DoDoubleJump( bUpdating );
	//	BBBettyPawn(Pawn).MultiJumpRemaining -= 1;
	//}
    if ( bPressedJump && canJump() )
	{
   		BBBettyPawn(Pawn).prepareJump(bUpdating);
		//Pawn.DoJump(bUpdating);
	}
	//if ( Pawn.Physics != PHYS_Falling && Pawn.bCanCrouch )
	//{
	//	// crouch if pressing duck
	//	Pawn.ShouldCrouch(bDuck != 0);
	//}
}

function NotifyTakeHit(Controller InstigatedBy, Vector HitLocation, int Damage, class<DamageType> myDamageType, Vector Momentum){
	local class<BBDamageType> myBBDamageType;

	myBBDamageType = class<BBDamageType>(MyDamageType);

	if(myBBDamageType.default.hitStopTime > 0.0){
		bStoppedByHit = true;
		hitStopTime = myBBDamageType.default.hitStopTime;
	}
}

function NotifyFailedAttack(){
	//Use the Hit Stop method for stopping player when realiced a failed attack
	bStoppedByHit = true;
	hitStopTime = 0.5f;
	BBBettyPawn(Pawn).playFailedAttack();
}

event PlayerTick(float DeltaTime){
	local int i;
	super.PlayerTick(DeltaTime);

	//Uptade all remaining times
	for( i = 0; i < ArrayCount(reactivateTime); i++){
		if(reactivateTime[i] > 0)
			reactivateTime[i] -= DeltaTime;
		else if(reactivateTime[i] < 0)
		reactivateTime[i] = 0;
	}
	//Update frenesi duration
	if(frenesiDuration > 0)
		frenesiDuration -= DeltaTime;
	else if(frenesiDuration < 0){
		frenesiDuration = 0;
		for(i = 0; i < frenesiPSCS.Length; i++){
			if(frenesiPSCS[i].bIsActive){
				frenesiPSCS[i].SetActive(false);
				frenesiPSCS[i] = none;
			}
		}
		ResetPPSettings(Pawn);
		Pawn.MovementSpeedModifier = 1.0f;
		//WorldInfo.Game.SetGameSpeed(1.0f);
	}
	//Updated time stopped by enemy hit
	if(bStoppedByHit){
		hitStopTime -= DeltaTime;
		Pawn.ZeroMovementVariables();
		if(hitStopTime <=0){
			bStoppedByHit = false;
		}
	}
}





state mySpectatorMode extends Spectating
{
	event BeginState(name PreviousStateName){
		Camera('FirstPersonCam');		
		super.BeginState(PreviousStateName);
	}
}

state myStaticCamMode extends Spectating{
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

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local rotator DeltaRot, ViewRotation;

		if ( !bFrozen )
		{
			if ( bPressedJump )
			{
				StartFire( 0 );
				bPressedJump = false;
			}
			GetAxes(Rotation,X,Y,Z);
			// Update view rotation.
			ViewRotation = Rotation;
			// Calculate Delta to be applied on ViewRotation
			DeltaRot.Yaw	= PlayerInput.aTurn;
			DeltaRot.Pitch	= PlayerInput.aLookUp;
			ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
			SetRotation(ViewRotation);
			if ( Role < ROLE_Authority ) // then save this move and replicate it
					ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
		else if ( !IsTimerActive() || GetTimerCount() > MinRespawnDelay )
		{
			bFrozen = false;
		}

		ViewShake(DeltaTime);
	}

//function FindGoodView()
//	{
		
//	}

Begin:
	BBHUD(myHUD).ASvida(String(BBBettyPawn(Pawn).Health));
	`log("Player Muerto");
	//WorldInfo.Game.Broadcast(self,"You are Dead!");
	//WorldInfo.Game.Broadcast(self,"Restarting level in...");
	//WorldInfo.Game.Broadcast(self,"3");
	//Sleep(1);
	//WorldInfo.Game.Broadcast(self,"2");
	//Sleep(1);
	//WorldInfo.Game.Broadcast(self,"1");
	//Sleep(1);
	//WorldInfo.SeamlessTravel("BB-BettyLevelMenu");
}






state PlayerWalking{
	
	//NANDO: Aqui estaba la funcion PlayerMove() que ahora esta fuera de cualquier estado ya que este era el estado por defecto
	//       Si se quiere modificar el comportameinto de PlayerMove en algun estado basta con sobreescribir esta funcion.
	function PlayerMove(float DeltaTime){
		global.PlayerMove(DeltaTime);
	}
}


//Letra 'H'
exec function gotoSlide()
{
	bSliding=!bSliding;
	if(bSliding){
		GotoState('PlayerSlide');
	}
	else
	{
		GotoState('PlayerWalking');
	}
}

State PlayerSlide{

	event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		bSliding=true;
		Pawn.GotoState('PlayerSlide');
		slideSpeed = VSize(Pawn.Velocity);
	}

	event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		Pawn.GroundSpeed=speed;
		Pawn.GotoState('idle');
		bSliding=false;
		Pawn.AccelRate = Pawn.default.AccelRate;
	}

	function PlayerMove( float DeltaTime ){

		local vector	 X,Y,Z, NewAccel, localFloor;
		local eDoubleClickDir	DoubleClickMove;
		local bool	 bSaveJump;
		local Rotator OldRotation;
		local float inclination, tempXAccel;
	
		localFloor= Pawn.Floor << Pawn.Rotation;
		
		//Scalar product between Floor and Pawn face direcction
		inclination = localFloor dot vect(1,0,0);
		if(!BBBettyPawn(Pawn).bSlideJump){

			//Modificamos la velocidad segun la inclinacion del suelo
			if ( inclination < 0 ) //subiendo
			{
				slideSpeedIncrement = 0;

				slideSpeed -= (slideSpeedDecrement + 300) * DeltaTime;
				slideSpeedDecrement += -inclination * 100 * DeltaTime;
				
			}
			else if (inclination > 0)
			{
				slideSpeedDecrement = 0;

				slideSpeed += (slideSpeedIncrement + 400) * DeltaTime;
				slideSpeedIncrement += inclination * 150 * DeltaTime;
			}else{      //inclination == 0
				slideSpeedDecrement = 0;
				slideSpeedIncrement = 0;

				//Decrement slideSpeed for finally stop if sliding in plain floor
				slideSpeed -= 300 * DeltaTime;
			}
		}else if(PlayerInput.aForward > 0 && slideSpeed < 100){     //Si estamso saltando y apretando hacia adelante y con muy poca velocidad
			//Damos un pequeño impulso
			slideSpeed = 150;
		}

		//Modificamos la velocidad maxima segun la entrada de teclado
		if(PlayerInput.aForward > 0){
			maxSlideSpeed = FInterpConstantTo(maxSlideSpeed, default.maxSlideSpeed + 300, DeltaTime, 300);
		}else if(PlayerInput.aForward < 0){	
			maxSlideSpeed = FInterpConstantTo(maxSlideSpeed, default.maxSlideSpeed - 300, DeltaTime, 300);			
		}else{
			maxSlideSpeed = FInterpConstantTo(maxSlideSpeed, default.maxSlideSpeed, DeltaTime, 300);
		}
		

		//Slide speed always between 0 and MaxSlideSpeeed
		slideSpeed = FClamp(slideSpeed, 0, maxSlideSpeed);
		
		//`log(slideSpeed @ "-" @ VSize(Pawn.Velocity));

		Pawn.GroundSpeed = slideSpeed;
	
		//if(slideSpeed==0){ //PENDIENTE: hacer que betty de media vuelta!
		//	NewRot.Yaw=32768; // 180º
		//	NewRot.Pitch=0;
		//	NewRot.Roll=0;
		
		//	//NINGUNA FUNCIONA
		//	//Pawn.SetDesiredRotation(RInterpTo(Pawn.Rotation,NewRot,Deltatime,1000,true),false,false,Deltatime,true);		
		//	//Pawn.FaceRotation(RInterpTo(Pawn.Rotation,NewRot,Deltatime,1,true),Deltatime);
		//	//SetRotation(RInterpTo(Pawn.Rotation,NewRot,Deltatime,1000,true));		
		//	//WorldInfo.Game.Broadcast(self,NewRot );
	
		//}
		
		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Pawn.Rotation,X,Y,Z);
			//Calculamos un ratio de velocidad sobre velocidad maxima para luego utilizarlo en la aceleracion y asi
			//limitar la capacidad de movimiento lateral segun la velocidad actual (mas velocidad menos capacidad de strafe)
			tempXAccel = Pawn.GroundSpeed / (default.maxSlideSpeed + 300);

			//Forced to go forward regardless of PlayerInput. 2200.0 its a mean value of PlayerInput.aForward
			//COn el tempXAccel determinamos la velocidad de Strafe segun la velocidad actual (mayor velocidad menor strafe)
			NewAccel = (0600.0 + 6000.0 * tempXAccel) * X + PlayerInput.aStrafe * Y;
			NewAccel.Z	= 0;

			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );
			
			OldRotation = Rotation;
			UpdateRotationCustom( DeltaTime , VSize(NewAccel) != 0);
			
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
				
				//ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			bPressedJump = bSaveJump;
		}	
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

	function UpdateRotationCustom( float DeltaTime, bool updatePawnRot){
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
		ViewShake( deltaTime );

		NewRotation = ViewRotation;
		NewRotation.Roll = Rotation.Roll;
		if ( Pawn != None && updatePawnRot)
			Pawn.FaceRotation(RInterpTo(Pawn.Rotation, NewRotation, DeltaTime, RotationSpeed, true), DeltaTime);

		SetRotation(ViewRotation);

	}
}



//exec function gotoFuria()
//{
//GotoState('Furia');
//}

exec function gotoWalk()
{
	GotoState('PlayerWalking');
}

state CombatStance
{
ignores SeePlayer, HearNoise, Bump;


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
		Global.PlayerTick(DeltaTime);
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

/**
 * Si no tenemos arma equipada simplemente la equipamos 
 */
state Equipping_Sword
{
Begin:
	BBBettyPawn(Pawn).GetSword();
	PopState();
}

state Sword_Attack{

	function startAttack(optional byte FireModeNum)
	{
		if(canCombo())	GotoState(,'Combo');
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
	if(getActiveAnimNode() != none) FinishAnim(getActiveAnimNode());
	comboAttack();
	FinishAnim(getActiveAnimNode());
	PopState();

}

state Air_Attack{
	event PushedState(){
		super.PushedState();
		Pawn.GotoState('AirAttack');
	}

}

state Grenade_Attack
{

	function prepararAttack()
	{
		//BBWeaponNone(Weapon).calcHitPosition();
		BBBettyPawn(Pawn).calcHitLocation();

   	}

	function lanzarAttack()
	{
		BBBettyPawn(Pawn).GrenadeAttack();
   	}	
	   	
	//exec function StopFire( optional byte FireModeNum )
	exec function EButtonUP( )
	{	
	
		if(BBBettyPawn(Pawn).itemsMiel-5>=0){
			GotoState('Grenade_Attack','Lanzar');
			if ( BBBettyPawn(Pawn) != None )
			{
			BBBettyPawn(Pawn).StartFire( 1 );
			BBBettyPawn(Pawn).StopFire( 1 );
			}
		}else PopState();

	}

Lanzar:
	if(reactivateTime[HN_Grenade] == 0){
		reactivateTime[HN_Grenade] = coldDowns[HN_Grenade];
		lanzarAttack();
		FinishAnim(getActiveAnimNode());
	}
	PopState();	
	
Begin:	
	prepararAttack();
}



DefaultProperties
{
	bDebug = false;

	CameraClass=class 'BBMainCamera' //Telling the player controller to use your custom camera script
	DefaultFOV=90.f //Telling the player controller what the default field of view (FOV) should be

	bBettyMovement=true;
	speed = 400;
	sideSpeed = 300;
	backSpeed = 250;
	slideSpeed = 800;
	maxSlideSpeed = 800;

	radioLockon=1000.0;

	broll=false;
	bSliding=false;
	bDoubleJump = true;
	//bPlay_humo_correr=true;

	RotationSpeed=150000;

	MinRespawnDelay = 3.0f
	AirAttackThreshold = 600.0f;       //Puesto a un valor grande para que limite poco

	costHeal = 20;
	amountHealed = 3;
	HealDamageType = class'DamageType';
	costFrenesi = 30;
	frenesiMaxDuration = 10.0;
	frenesiSpeedFactor = 1.5f;
	frenesiSlomoFactor = 1.0f;
	costGrenade = 5;
	
	//Heal, Frenesi, Roll, Grenade
	coldDowns[HN_Heal] = 1.0f;
	coldDowns[HN_Frenesi] = 1.0f;
	coldDowns[HN_Roll] = 3.0f;
	coldDowns[HN_Grenade] = 5.0f;
}