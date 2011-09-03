class BBEnemyPawnCaterpillar2 extends BBEnemyPawn placeable;

/** Constant time between shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var () float timeBetweenShots;
/** Random time betweeen shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var () float randomTimeBetweenShots;
/** Vector  for randomness in prejectile shooting, each component indicates the randomness in each direction*/
var () Vector randomness;
/** This pawn enters in fear state if player is nearer than this distance  */
var () float fearDistance;

var name attackBeginAnime;
var name attackEndAnime;
var name fearAnimName;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (MyController == none)
	{
		MyController = Spawn(class'BettyTheBee.BBControllerAICaterpillar2');
		MyController.SetPawn(self);		
	}
    
}

state Attacking{
	
	simulated event doDamage(){
		local Vector Boca;
		local BBBettyPawn HitTarget,TempPawn;
		local BBProjectileCaterpillar SpawnedProjectile;

		Mesh.GetSocketWorldLocationAndRotation('Boca' , Boca);
		
		foreach AllActors(class'BBBettyPawn', TempPawn){
			HitTarget = TempPawn;
		}
		
		SpawnedProjectile = Spawn(class'BBProjectileCaterpillar',Self,,Boca);
		SpawnedProjectile.Damage = AttackDamage;
		SpawnedProjectile.Instigator = self;

		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.CalcAngle(Boca, HitTarget.Location,Randomness);
		}

		//`Log("Boca: "@Boca);
		//`Log("Objetivo: "@HitTarget.Location);
	}
	
	simulated event BeginState(name PreviousStateName){
		super.BeginState(PreviousStateName);
		customAnimSlot.PlayCustomAnim(attackBeginAnime,1.0f,0.25f,0.0f,false);
	}

	simulated event EndState(name NextStateName){
		super.EndState(NextStateName);
		if(NextStateName != 'Fearing')
			customAnimSlot.PlayCustomAnim(attackEndAnime,1.0f,0.0f,0.25f,false,true);
	}
Begin:
	FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
Attack:
	customAnimSlot.PlayCustomAnim(attackAnimName,1.0f,0.0f,0.0f,false,true);
	Sleep(customAnimSlot.GetCustomAnimNodeSeq().GetTimeLeft() - 0.05f);
	customAnimSlot.StopAnim();	
	Sleep(timeBetweenShots + randomTimeBetweenShots * FRand());
	goto 'Attack';
FinishAttack:
	//Playing stop attack anim and going to fear.
	customAnimSlot.PlayCustomAnim(attackEndAnime,1.0f,0.0f,0.25f,false,true);
	FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
	GotoState('Fearing');
}

state Fearing{
Begin:
	customAnimSlot.PlayCustomAnim(fearAnimName, 1.0f, 0.25, 0.25, true, true);
}


DefaultProperties
{
	
	//Not used, used Physics Asset for collision
	Begin Object Name=CollisionCylinder
			
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		BlockRigidBody=false
		CollideActors=false

		CollisionHeight=+100.0
		CollisionRadius=+20.0
		//Translation=(X=0.0,Y=0.0,Z=0.0)
    end object

	Begin Object class=SkeletalMeshComponent Name=SkMesh
		CastShadow=true
		bCastDynamicShadow=true
		
		LightEnvironment=MyLightEnvironment;
		bAllowAmbientOcclusion=false

		BlockNonZeroExtent = True
        BlockZeroExtent = True
        BlockActors = True
        CollideActors =True

		AnimSets(0)=AnimSet'Betty_caterpillar.SkModels.Caterpillar2_AnimSet'
		AnimTreeTemplate=AnimTree'Betty_caterpillar.SkModels.Caterpillar_AnimTree'
		PhysicsAsset=PhysicsAsset'Betty_caterpillar.SkModels.Caterpillar2_Physics'
		SkeletalMesh=SkeletalMesh'Betty_caterpillar.SkModels.Caterpillar2'
    End Object
	CollisionComponent=SkMesh
	Mesh=SkMesh
    Components.Add(SkMesh)
    
    bJumpCapable=false
    bCanJump=false
    GroundSpeed=200.0 //Making the bot slower than the player

	PerceptionDistance = 1200;
	AttackDistance = 1200;
	AttackDamage = 2;

	timeBetweenShots = 2;
	randomTimeBetweenShots = 1;
	randomness=(X=0.1,Y=0.1,Z=0.05);

	fearDistance = 400;

	//Name of diferent animations for playing in custom node (esta aqui porque en defaultProperties no funciona)
	attackAnimName = "Oruga_Attack_seq";
	attackBeginAnime = "Oruga_Alert_up_seq";
    attackEndAnime = "Oruga_Down_seq";
	//dyingAnimName = "Die";
	fearAnimName = "Oruga_Afraid_seq";

	DeadPS = ParticleSystem'Betty_caterpillar.Particles.Dead_PS';
}
