class BBEnemyPawnRhino extends BBEnemyPawn placeable;

/** Blend node used for blending attack animations*/
//var AnimNodeBlendList nodeListAttack;
var AnimNodeBlendList nodeListCharge;

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
		CollisionHeight=+70.000000
		CollisionRadius=+65.000000
	End object

	Begin Object class=SkeletalMeshComponent Name=InitialPawnSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
			bAllowAmbientOcclusion=false
		BlockRigidBody=true;
		CollideActors=true;
		BlockZeroExtent=true;
			BlockNonZeroExtent = True
			BlockActors = True

        AnimSets(0)=AnimSet'Betty_rhino.SkModels.rhinoAnimSet'
		AnimTreeTemplate=AnimTree'Betty_rhino.SkModels.rhinoAnimTree'
		SkeletalMesh=SkeletalMesh'Betty_rhino.SkModels.rhino'
		HiddenGame=FALSE 
		HiddenEditor=FALSE
    End Object

	Mesh=InitialPawnSkeletalMesh
    Components.Add(InitialPawnSkeletalMesh)

	bJumpCapable=false
    bCanJump=false
    GroundSpeed=80.0 //Making the bot slower than the player

	PerceptionDistance = 1000;
	AttackDistance = 75;
	//AttackDistanceNear = 70;
	AttackDamage = 10;
	ChargeDamage = 30;

}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (MyController == none)
	{
		MyController = Spawn(class'BettyTheBee.BBControllerAIRhino');
		MyController.SetPawn(self);		
	}
    
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		nodeListAttack = AnimNodeBlendList(Mesh.FindAnimNode('listAttack'));
		attackAnim = AnimNodeSequence(Mesh.FindAnimNode('ATTACK'));
		nodeListCharge = AnimNodeBlendList(Mesh.FindAnimNode('listCharge'));
	}
}


state Attacking{

	simulated event doDamage(){
		local Vector CuernoDown, CuernoUp;
		local Vector HitLocation, HitNormal;
		local Actor HitActor;

		//Worldinfo.Game.Broadcast(self, Name $ ": Calculating Attack Collision");

		
		Mesh.GetSocketWorldLocationAndRotation('CuernoDown' , CuernoDown);
		Mesh.GetSocketWorldLocationAndRotation('CuernoUp', CuernoUp);
		HitActor = Trace(HitLocation, HitNormal, CuernoUp, CuernoDown, true);
		
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
		nodeListAttack.SetActiveChild(2,0.2f);
	}

	simulated event EndState(name NextStateName){
		super.EndState(NextStateName);
		nodeListAttack.SetActiveChild(1,0.2f);
	}
Begin:	
	FinishAnim(attackAnim);
	goto 'Begin';
}