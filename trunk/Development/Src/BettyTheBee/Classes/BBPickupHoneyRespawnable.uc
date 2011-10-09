class BBPickupHoneyRespawnable extends BBMielPickupItem placeable;

var () float respawnTime;
/** If the player has less than honeyThresholdToRespawn respawn item */
var () int honeyThresholdToRespawn;

function SetRespawn(){
	//Vamos a sleeping para despues respawnear
	GotoState('Sleeping');
}

function float GetRespawnTime(){
	return respawnTime;
}

State Sleeping
{
	ignores Touch;

	simulated function bool playerHasLessHoneyThan(int honeyAmount){
		local BBBettyPawn tempPawn;
		foreach DynamicActors(class'BBBettyPawn', tempPawn){
			if(tempPawn.itemsMiel < honeyAmount){
				return true;
			}
		}
		return false;
	}

Begin:
	bRespawnPaused = true;
	while (DelayRespawn())
	{
		Sleep(1.0);
	}
	bRespawnPaused = false;
	while(true){
		Sleep( GetReSpawnTime() - RespawnEffectTime );
		if(playerHasLessHoneyThan(honeyThresholdToRespawn)){
			break;
		}
	}
Respawn:
	RespawnEffect();
	Sleep(RespawnEffectTime);
	GotoState('Pickup');
}

DefaultProperties
{
	respawnTime = 10.0f;
	honeyThresholdToRespawn = 3;
	honey = 3;
}
