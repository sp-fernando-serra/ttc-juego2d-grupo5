class BBEnemyPawnCaterpillar extends BBEnemyPawn placeable;

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

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (MyController == none)
	{
		MyController = Spawn(class'BettyTheBee.BBControllerAICaterpillar');
		MyController.SetPawn(self);		
	}
    
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		//Name of diferent animations for playing in custom node (esta aqui porque en defaultProperties no funciona)
		attackAnimName = 'Attack_1';
		dyingAnimName = '';
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
	
	simulated event BeginState(name NextStateName){
		super.BeginState(NextStateName);
		customAnimSlot.PlayCustomAnim(attackAnimName,1.0f,0.25f,0.25f,true);
	}

	simulated event EndState(name NextStateName){
		super.EndState(NextStateName);
		customAnimSlot.StopCustomAnim(0.25f);
	}
Begin:
	FinishAnim(customAnimSlot.GetCustomAnimNodeSeq());
	Sleep(timeBetweenShots + randomTimeBetweenShots * FRand());
	goto 'Begin';
}


DefaultProperties
{
	//Setting up the light environment
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Name=CollisionCylinder
			
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		BlockRigidBody=false
		CollideActors=false

		CollisionHeight=+45.0
		CollisionRadius=+20.0
		//Translation=(X=0.0,Y=0.0,Z=40.0)
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

		AnimSets(0)=AnimSet'Betty_caterpillar.SkModels.Caterpillar_anims'
		AnimTreeTemplate=AnimTree'Betty_caterpillar.SkModels.Caterpillar_AnimTree'
		PhysicsAsset=PhysicsAsset'Betty_caterpillar.SkModels.Caterpillar_Physics'
		SkeletalMesh=SkeletalMesh'Betty_caterpillar.SkModels.Caterpillar'
    End Object
	//CollisionComponent=SkMesh
	Mesh=SkMesh
    Components.Add(SkMesh)
    
    bJumpCapable=false
    bCanJump=false
    GroundSpeed=200.0 //Making the bot slower than the player

	PerceptionDistance = 4500;
	AttackDistance = 400;
	AttackDamage = 10;

	timeBetweenShots = 2;
	randomTimeBetweenShots = 1;
	randomness=(X=0.1,Y=0.1,Z=0.05);
}