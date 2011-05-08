class BBEnemyPawnCaterpillar extends BBEnemyPawn placeable;

/** Constant time between shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var () float timeBetweenShots;
/** Random time betweeen shots in seconds.
 *  Time = timeBetweenShots + randomTimeBetweenShots*FRand()
 */
var () float randomTimeBetweenShots;

/** Blend node used for blending attack animations*/
var AnimNodeBlendList nodeListAttack;

/** Array containing all the attack animation AnimNodeSlots*/
var AnimNodeSequence attackAnim;

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
		CollisionHeight=+20.000000
    end object
	Begin Object class=SkeletalMeshComponent Name=InitialPawnSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
		BlockRigidBody=true;
		CollideActors=true;
		BlockZeroExtent=true;

 		AnimSets(0)=AnimSet'Betty_caterpillar.SkModels.CaterpillarAnimSet'
		AnimTreeTemplate=AnimTree'Betty_caterpillar.SkModels.CaterpillarAnimTree'
		SkeletalMesh=SkeletalMesh'Betty_caterpillar.SkModels.Caterpillar'
		HiddenGame=FALSE 
		HiddenEditor=FALSE
    End Object
    Mesh=InitialPawnSkeletalMesh
    Components.Add(InitialPawnSkeletalMesh)
    
    bJumpCapable=false
    bCanJump=false
    GroundSpeed=200.0 //Making the bot slower than the player

	PerceptionDistance = 4500;
	AttackDistance = 400;
	AttackDamage = 10;

	timeBetweenShots = 2;
	randomTimeBetweenShots = 1;
}

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
		nodeListAttack = AnimNodeBlendList(Mesh.FindAnimNode('listAttack'));
		attackAnim = AnimNodeSequence(Mesh.FindAnimNode('ATTACK_1'));
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
		SpawnedProjectile.Instigator = self;

		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.CalcAngle(Boca, HitTarget.Location);
		}

		//`Log("Boca: "@Boca);
		//`Log("Objetivo: "@HitTarget.Location);
	}
	
	simulated event BeginState(name NextStateName){
		super.BeginState(NextStateName);
		nodeListAttack.SetActiveChild(1,0.2f);
	}

	simulated event EndState(name NextStateName){
		super.EndState(NextStateName);
		nodeListAttack.SetActiveChild(0,0.2f);
	}
Begin:
	
	FinishAnim(attackAnim);
	Sleep(timeBetweenShots + randomTimeBetweenShots * FRand());
	goto 'Begin';
}