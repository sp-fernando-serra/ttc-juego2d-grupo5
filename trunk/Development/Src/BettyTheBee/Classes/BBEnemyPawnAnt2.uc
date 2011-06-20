class BBEnemyPawnAnt2 extends BBEnemyPawn placeable;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (MyController == none)
	{
		MyController = Spawn(class'BettyTheBee.BBControllerAIAnt2');
		MyController.SetPawn(self);
	}
    
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		//Name of diferent animations for playing in custom node (esta aqui porque en defaultProperties no funciona)
		attackAnimName = 'Ant_attack_seq';
		dyingAnimName = 'Ant_iddle_seq';
	}
}

state Attacking{

	simulated event doDamage(){
		local Vector PinzasStart, PinzasEnd;
		local Vector HitLocation, HitNormal;
		local Actor HitActor;

		//Worldinfo.Game.Broadcast(self, Name $ ": Calculating Attack Collision");
		
		Mesh.GetSocketWorldLocationAndRotation('PinzasInicio' , PinzasStart);
		Mesh.GetSocketWorldLocationAndRotation('PinzasFinal', PinzasEnd);
		HitActor = Trace(HitLocation, HitNormal, PinzasEnd, PinzasStart, true);
		
		if(HitActor != none){
			//Worldinfo.Game.Broadcast(self, Name $ ": Hit actor "$HitActor.Name);
			if(HitActor.Class == class'BBBettyPawn'){
				BBBettyPawn(HitActor).TakeDamage(AttackDamage,Controller,HitLocation,vect(0,0,0),MyDamageType);
				Worldinfo.Game.Broadcast(self,BBBettyPawn(HitActor).name $ " Actual Life: "$BBBettyPawn(HitActor).Health);
			}
		}
	}
	
	simulated event BeginState(name NextStateName){
		super.BeginState(NextStateName);
		customAnimSlot.PlayCustomAnim(attackAnimName,1.0f,0.25f,0.25f,true);
	}

	simulated event EndState(name NextStateName){
		super.EndState(NextStateName);
		customAnimSlot.StopCustomAnim(0.25f);
	}
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
		CollisionHeight=+34.000000
	End object
	
	Begin Object class=SkeletalMeshComponent Name=InitialPawnSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
		BlockRigidBody=true;
		CollideActors=true;
		BlockZeroExtent=true;

 		AnimSets(0)=AnimSet'Betty_ant.SkModels.Ant2AnimSet'
		AnimTreeTemplate=AnimTree'Betty_ant.SkModels.Ant2AnimTree'
		SkeletalMesh=SkeletalMesh'Betty_ant.SkModels.Ant2'
		HiddenGame=FALSE 
		HiddenEditor=FALSE

		Scale = 1.5f;
    End Object
    Mesh=InitialPawnSkeletalMesh
    Components.Add(InitialPawnSkeletalMesh)
    
    bJumpCapable=false
    bCanJump=false
    GroundSpeed=200.0 //Making the bot slower than the player

	PerceptionDistance = 1500;
	AttackDistance = 40;
	AttackDamage = 10;
}