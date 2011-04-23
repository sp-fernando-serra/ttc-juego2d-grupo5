class BBEnemyPawnAnt extends BBEnemyPawn placeable;

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

 		AnimSets(0)=AnimSet'Betty_ant.SkModels.AntAnimSet'
		AnimTreeTemplate=AnimTree'Betty_ant.SkModels.AntAnimTree'
		SkeletalMesh=SkeletalMesh'Betty_ant.SkModels.Ant'
		HiddenGame=FALSE 
		HiddenEditor=FALSE
    End Object
    Mesh=InitialPawnSkeletalMesh
    Components.Add(InitialPawnSkeletalMesh)
  //  ControllerClass=class'BettyTheBee.BBAIController'
    
    bJumpCapable=false
    bCanJump=false
    GroundSpeed=200.0 //Making the bot slower than the player

	PerceptionDistance = 1500;
	AttackDistance = 60;
	AttackDamage = 5;

}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (MyController == none)
	{
		MyController = Spawn(class'BBControllerAIAnt', self);
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
				BBBettyPawn(HitActor).Health -= AttackDamage;
				//Worldinfo.Game.Broadcast(self,BBBettyPawn(HitActor).name $ " Actual Life: "$BBBettyPawn(HitActor).Health);
			}
		}
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
	goto 'Begin';
}

