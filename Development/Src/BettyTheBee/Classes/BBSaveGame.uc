class BBSaveGame extends Object;

struct export BettyInfo
{
	var int Health;
	var int Honey;
};

struct export EnemyInfo
{
	var name enemyInstanceName;
	
	//var bool bIsAlive;
	
	//var class<BBEnemyPawn> enemyClass;

	//var Vector enemyLocation;
	//var Rotator enemyRotation;

	////EnemyPawn Variables
	//var float PerceptionDistance;
	//var float alertRadius;
	//var float AttackDistance;
	//var float AttackDistanceFactor;
	//var int AttackDamage;
	//var bool bAggressive;
	//var Route MyRoutePoints;
	//var float timeStunned;

	////Caterpillar Variables
	//var float timeBetweenShots;
	//var float randomTimeBetweenShots;
	//var Vector randomness;
	//var float fearDistance;

	////RhinoMiniBoss Variables
	//var int ChargeDamage;
	//var float chargeSpeed;
	//var float attackChargeDistance;
	//var float attackChargeSpeedModifier;
	//var float attackChargeLengthModifier;
	//var float attackDistanceNear;
	//var float attackDistanceFar;
	//var Vector attackChargeMomentum;
	//var array<PathTargetPoint> chargePoints;
};

struct export PickupInfo
{
	var name itemName;
	var bool bIsActive;
};


/** Level Name at which the SaveGame belongs */
var string levelName;

var name playerStartPoint;

var BettyInfo bettyData;

var array<EnemyInfo> enemiesInfo;

var array<PickupInfo> pickupsInfo;



function string GetMapName(){
	return levelName;
}



function bool SaveInfo(WorldInfo WorldInformation){
	levelName = WorldInformation.GetURLMap();
	
	SaveBettyInfo(WorldInformation);
	SavePickups(WorldInformation);
	SaveCheckPoint(WorldInformation);
	SaveEnemies(WorldInformation);

	return true;
}

function bool LoadInfo(WorldInfo WorldInformation){
	//LoadBettyInfo(WorldInformation);          //This will be loaded when player Spawn (PostLogin())
	LoadPickups(WorldInformation);
	LoadCheckPoint(WorldInformation);
	LoadEnemies(WorldInformation);
	return true;
}

function protected SaveBettyInfo(WorldInfo WorldInformation){
	local BBBettyPawn tempPawn;

	tempPawn = BBBettyPawn(WorldInformation.GetALocalPlayerController().Pawn);
	if(tempPawn != none){
		bettyData.Health = tempPawn.Health;
		bettyData.Honey = tempPawn.itemsMiel;
	}
}

function protected SavePickups(WorldInfo WorldInformation){
	local BBMielPickupItem tempItem;
	local PickupInfo tempInfo;

	foreach WorldInformation.DynamicActors(class'BBMielPickupItem', tempItem){
		tempInfo.itemName = tempItem.Name;
		tempInfo.bIsActive = tempItem.IsInState('Pickup');
		pickupsInfo.AddItem(tempInfo);
	}
}

function protected SaveCheckPoint(WorldInfo WorldInformation){
	playerStartPoint = BBGameInfo(WorldInformation.Game).currentCheckPoint.Name;
}

function protected SaveEnemies(WorldInfo WorldInformation){
	local BBEnemyPawn tempEnemy;
	local EnemyInfo tempInfo;

	foreach WorldInformation.DynamicActors(class'BBEnemyPawn', tempEnemy){
		tempInfo.enemyInstanceName = tempEnemy.Name;
		//tempInfo.bIsAlive = true;                 //If enemy is in the list he is Alive
		enemiesInfo.AddItem(tempInfo);
	}
}

//Is public because we have to load enemies when player has spawned.
function LoadBettyInfo(WorldInfo WorldInformation){
	WorldInformation.GetALocalPlayerController().Pawn.Health = bettyData.Health;
	BBBettyPawn(WorldInformation.GetALocalPlayerController().Pawn).itemsMiel = bettyData.Honey;
}

function protected LoadPickups(WorldInfo WorldInformation){
	local BBMielPickupItem tempItem;
	
	local int tempIndex;

	foreach WorldInformation.DynamicActors(class'BBMielPickupItem', tempItem){
		tempIndex = pickupsInfo.Find('itemName', tempItem.Name);
		if(tempIndex != -1 && !pickupsInfo[tempIndex].bIsActive)
			tempItem.ShutDown();
		else if(tempIndex != -1)
			tempItem.Reset();
	}
}

function protected LoadCheckPoint(WorldInfo WorldInformation){
	local BBCheckPoint tempPoint;
	
	foreach WorldInformation.DynamicActors(class'BBCheckPoint', tempPoint){
		if(tempPoint.Name == playerStartPoint){
			BBGameInfo(WorldInformation.Game).currentCheckPoint = tempPoint;
		}
	}
}

function protected LoadEnemies(WorldInfo WorldInformation){
	local BBEnemyPawn tempEnemy;
	
	local int tempIndex;

	foreach WorldInformation.DynamicActors(class'BBEnemyPawn', tempEnemy){
		tempIndex = enemiesInfo.Find('enemyInstanceName', tempEnemy.Name);
		if(tempIndex == -1){
			if(tempEnemy.Controller != none)
				tempEnemy.Controller.Destroy();
			tempEnemy.Destroy();
		}
	}
}

DefaultProperties
{
}
