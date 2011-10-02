class BBAntHill extends Actor placeable
	classGroup(BBActor);
/** Determine the remaining number of grenades needed to destroy this Hill */
var int health;
/** Determine the max number of grenades needed to destroy this Hill */
var int maxHealth;

var () editconst const CylinderComponent myCylinderComponent;

var () KeyPoint SpawnPoint1;
var () KeyPoint SpawnPoint2;

var class<BBEnemyPawnAnt2> AntClass;
///** NOT USED. Ant2 Actor to use as a template when Spawning Ants */
//var () BBEnemyPawnAnt2 AntTemplate;

var BBEnemyPawnAnt2 SpawnedAnt1;
var BBEnemyPawnAnt2 SpawnedAnt2;

event PostBeginPlay(){
	super.PostBeginPlay();
	health = maxHealth;
}

simulated function AntHillSpawn(BBSeqAct_AntHillSpawn actionSpawn){
	SpawnedAnt1 = Spawn(AntClass,,,SpawnPoint1.Location, SpawnPoint1.Rotation,/*AntTemplate*/);
	SpawnedAnt2 = Spawn(AntClass,,,SpawnPoint2.Location, SpawnPoint2.Rotation,/*AntTemplate*/);

	SpawnedAnt1.antHill = self;
	SpawnedAnt2.antHill = self;
	
	//Controller spawned automatically only for level placed Enemies
	//Spawning custom controller for this pawns.
	SpawnedAnt1.SpawnDefaultController();
	SpawnedAnt2.SpawnDefaultController();
}

simulated event DestroyedAnt(BBEnemyPawn ant){
	if(ant == SpawnedAnt1){
		SpawnedAnt1 = none;
	}
	else if(ant == SpawnedAnt1){
		SpawnedAnt2 = none;
	}
}

simulated function AntHillDamaged(){
	health--;
	if(health > 0){
		TriggerGlobalEventClass(class'BBSeqEvent_AntHillDamaged', self);
	}else{
		TriggerGlobalEventClass(class'BBSeqEvent_AntHillDestroyed', self);
	}
}

simulated function bool StopsProjectile(Projectile P){
	return bBlockActors;
}

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal){
	if(BBProjectileGrenade(Other) != none){
		AntHillDamaged();
	}
}

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Trigger'
		HiddenGame=False
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollideActors=true
		CollisionRadius=+0040.000000
		CollisionHeight=+0040.000000
		bAlwaysRenderIfSelected=true
	End Object
	CollisionComponent=CollisionCylinder
	myCylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	//CollisionType = COLLIDE_TouchWeapons

	bHidden=true
	bCollideActors=true
	bProjTarget=true
	bStatic=false
	bNoDelete=true	

	AntClass = class'BBEnemyPawnAnt2';
	
	maxHealth = 3;
}
