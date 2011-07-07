class BBPlayerController extends PlayerController;

var bool bBettyMovement;
var float speed, sideSpeed, backSpeed;
var BBEnemyPawn targetedPawn;
var bool bCombatStance;

var rotator myRotation,myDesiredRotation;
var bool bLastStrafe, bLastForward,bLastBackward;
var bool bUpdateRot;

var bool broll;

//var bool bPlay_humo_correr;

//array de enemigos para la funcion lock-on(encarar enemigo)
var array<BBEnemyPawn> array_enemigos;

//radio de seleccion de enemigos
var float radioLockon;

//velocidad de rotacion de betty para giros mas suaves(en modo normal...no mario64)
var float RotationSpeed;

var bool block;

var int costHeal;
var float amountHealed;
var class<DamageType> HealDamageType;
var int costGrenade;


var		SoundCue			HealSound;
enum EHabilityNames
{
	HN_Heal,
	HN_Frenesi,
	HN_Roll,
	HN_Grenade
};
var float coldDowns[EHabilityNames];
var float reactivateTime[EHabilityNames];

simulated event PostBeginPlay() //This event is triggered when play begins
{
	super.PostBeginPlay();
}

//-----------------------------------------------------------------------------------------------
//--------------------------------FUNCIONES EXEC-------------------------------------------------


//RUEDA RATON
exec function NextWeapon() /*The "exec" command tells UDK that this function can be called by the console or keybind.
We'll go over how to change the function of keys later (if, for instance, you didn't want you use the scroll wheel, but page up and down for zooming instead.)*/
{
	if (PlayerCamera.FreeCamDistance < 512) //Checks that the the value FreeCamDistance, which tells the camera how far to offset from the view target, isn't further than we want the camera to go. Change this to your liking.
	{
		//`Log("MouseScrollDown"); //Another log message to tell us what's happening in the code
		PlayerCamera.FreeCamDistance += 64*(PlayerCamera.FreeCamDistance/256); 
		if(PlayerCamera.FreeCamDistance>370) PlayerCamera.FreeCamDistance=370;
		/*This portion increases the camera distance.
By taking a base zoom increment (64) and multiplying it by the current distance (d) over 256, we decrease the zoom increment for when the camera is close,
(d < 256), and increase it for when it's far away (d > 256).
Just a little feature to make the zoom feel better. You can tweak the values or take out the scaling altogether and just use the base zoom increment if you like */
	}
}

//RUEDA RATON
exec function PrevWeapon()
{
	if (PlayerCamera.FreeCamDistance > 64) //Checking if the distance is at our minimum distance
	{
		//`Log("MouseScrollUp");
		PlayerCamera.FreeCamDistance -= 64*(PlayerCamera.FreeCamDistance/256); //Once again scaling the zoom for distance
		if(PlayerCamera.FreeCamDistance<180) PlayerCamera.FreeCamDistance=180;
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

	// local Actor HitActor;
  //local Vector HitLocation, HitNormal, EyeLocation;
  //local Rotator EyeRotation;


	local BBEnemyPawn A;//,B;
	local int i;

	
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


//BOTON DERECHO RATON (UP)
exec function LockOff()
{
	if(TargetedPawn != none){
		array_enemigos.Remove(0,array_enemigos.length);
		TargetedPawn.stopPariclesFijado();
		TargetedPawn=none;
	}
	gotostate('PlayerWalking');
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
			PlaySound( HealSound );
			
			
		}
	}
}

//--------------------------------FUNCIONES EXEC-------------------------------------------------
//-----------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------
//--------------------------------FUNCIONES ROTACION CAMARA Y PLAYER-----------------------------


function UpdateRotationCustom( float DeltaTime, bool updatePawnRot)
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
		ViewShake( deltaTime );
//`log(TargetedPawn);
		switch(GetStateName())
			{
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
		if(FireModeNum==1 && canThrowGrenade())PushState('Grenade_Attack');
	}
	else{
		//Pasamos al estado de equipar la espada si no tenemos arma equipada
		
		if(FireModeNum==0 && canAttack())PushState('Equipping_Sword');
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

	if(Pawn.Physics != PHYS_Falling && !IsInState('Grenade_Attack')) return true;	
	return false;
}

function bool canCombo()
{
	local BBBettyPawn tempPawn;
	
	tempPawn = BBBettyPawn(Pawn);
	if(tempPawn!=None)
	{
		if(tempPawn.canStartCombo() && IsInState('Sword_Attack') && Pawn.Physics != PHYS_Falling) return true;
	}
	return false;
}

simulated function bool canThrowGrenade(){
	
	if(reactivateTime[HN_Grenade] == 0 && (IsInState('PlayerWalking') || IsInState('CombatStance')) && Pawn.Physics != PHYS_Falling && BBBettyPawn(Pawn).itemsMiel >= costGrenade) return true;
	else return false;
}

simulated function bool canUseHeal(){
	if(reactivateTime[HN_Heal] == 0 && (IsInState('PlayerWalking') || IsInState('CombatStance')) && Pawn.Physics != PHYS_Falling && BBBettyPawn(Pawn).itemsMiel >= costHeal) return true;
	else return false;
}

simulated function bool canUseRoll(){
	if(broll && reactivateTime[HN_Roll] == 0 && (IsInState('PlayerWalking') || IsInState('CombatStance')) && Pawn.Physics != PHYS_Falling) return true;
	else return false;
}

function CheckJumpOrDuck()
{
	if ( bPressedJump && (Pawn != None) )
	{
		BBBettyPawn(Pawn).prepareJump();
	}
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

	//NANDO: Aqui estaba la funcion PlayerMove() que ahora esta fuera de cualquier estado ya que este era el estado por defecto
	//       Si se quiere modificar el comportameinto de PlayerMove en algun estado basta con sobreescribir esta funcion.
	function PlayerMove(float DeltaTime){
		global.PlayerMove(DeltaTime);
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

//state Furia
//{


//event BeginState(Name PreviousStateName)
//{
//speed = 650;
//sideSpeed = 550;
//backSpeed = 500;
//}

//event EndState(Name NextStateName)
//{
//speed = 400;
//sideSpeed = 300;
//backSpeed = 250;
//}
//Begin:
//}


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

state Sword_Attack
{


	
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
	CameraClass=class 'BBMainCamera' //Telling the player controller to use your custom camera script
	DefaultFOV=90.f //Telling the player controller what the default field of view (FOV) should be

	bBettyMovement=true;
	speed = 400;
	sideSpeed = 300;
	backSpeed = 250;

	radioLockon=1000.0;

	broll=false;
	//bPlay_humo_correr=true;

	RotationSpeed=150000;

	costHeal = 20;
	amountHealed = 50;
	HealDamageType = class'DamageType';
	costGrenade = 5;
	
	//Heal, Frenesi, Roll, Grenade
	coldDowns[HN_Heal] = 10.0f;
	coldDowns[HN_Frenesi] = 20.0f;
	coldDowns[HN_Roll] = 3.0f;
	coldDowns[HN_Grenade] = 5.0f;


	HealSound=SoundCue'Betty_Sounds.vida_cue'

}