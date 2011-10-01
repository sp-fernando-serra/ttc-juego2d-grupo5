class BBGameInfo extends GameInfo;
/** Self explanatory. Used for load player information when player Spawn (PostLogin()) */
var BBSaveGame lastLoadedGame;
/** Self explanatory. Last checkpoint touched; where player respawns once dead */
var BBCheckPoint currentCheckPoint;
/** When Spawning decals, use this for never spawn two decals with the same Depthbias */
var float depthBiasLastDecal;

`define saveExtension   ".bsg"

`define saveFolder   "..//..//"

/**Initialize the game.
 * The GameInfo's InitGame() function is called before any other scripts (including
 * PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn
 * its helper classes.
 * Warning: this is called before actors' PreBeginPlay.
 */
event InitGame(string Options, out string ErrorMessage){
	local string loadGameFileName;

	super.InitGame(Options, ErrorMessage);
	if(HasOption(Options, "LoadPreviousGame")){
		loadGameFileName = ParseOption(Options, "LoadPreviousGame");	
		InitMapFromFile(loadGameFileName);
	}
}

event PostLogin( PlayerController NewPlayer ){
	super.PostLogin(NewPlayer);

	if(lastLoadedGame != none){
		lastLoadedGame.LoadBettyInfo(WorldInfo);
	}
}

/** FindPlayerStart()
* Return the 'best' player start for this player to start from.
* @param Player is the controller for whom we are choosing a playerstart
* @param InTeam specifies the Player's team (if the player hasn't joined a team yet)
* @param IncomingName specifies the tag of a teleporter to use as the Playerstart
* @return NavigationPoint chosen as player start (usually a PlayerStart)
 */
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string IncomingName )
{
	local NavigationPoint N, BestStart;
	local Teleporter Tel;
	local PlayerStart P;

	// if incoming start is specified, then just use it
	if( incomingName!="" ){
		ForEach WorldInfo.AllNavigationPoints( class 'Teleporter', Tel ){
			if( string(Tel.Tag)~=incomingName ){
				return Tel;
			}
		}
	}
	// always pick StartSpot at start of match
	if ( ShouldSpawnAtStartSpot(Player) &&
		(PlayerStart(Player.StartSpot) == None || RatePlayerStart(PlayerStart(Player.StartSpot), InTeam, Player) >= 0.0) )
	{
		return Player.StartSpot;
	}


	if(currentCheckPoint != none)
		BestStart = currentCheckPoint.spawnPoint;
	else{
		// Find best playerstart
		foreach WorldInfo.AllNavigationPoints(class'PlayerStart', P){
			if ( P.bEnabled ){
				BestStart = P;
				break;
			}
		}
	}

	if (BestStart == None){
		// no playerstart found, so pick any NavigationPoint to keep player from failing to enter game
		`log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
		ForEach AllActors( class 'NavigationPoint', N ){
			BestStart = N;
			break;
		}
	}
	return BestStart;
}

//function RestartPlayer(Controller NewPlayer){
//	RestartGame();
//}

/**Saves map state to a temp file called CheckPointSave
 * 
 */
exec function bool SaveGameCheckpoint(){
	//@FIXME: Hack. Only save checkpoint if local player is fully loaded. To prevent Checkpoint save at player Spawning
	if(WorldInfo.GetALocalPlayerController().Pawn != none)
		return SaveGame("CheckPointSave");
	else
		return false;
}

/**Saves map state to a file.
 * @param fileName Filename Without extension 
 */
exec function bool SaveGame(string fileName){
	local BBSaveGame tempSave;
	local bool tempResult;
	tempSave = new class'BBSaveGame';
	tempSave.SaveInfo(WorldInfo);
	tempResult = class'Engine'.static.BasicSaveObject(tempSave, `saveFolder $ fileName $ `saveExtension, true, 0);
	return tempResult;
}

exec function bool LoadGameCheckpoint(){
	return LoadGameFromFile("CheckPointSave");	
}

/**Changes current level and schedule a InitMapFromFile() when the level has been loaded
 * @param fileName Filename without extension to obtain the name of new map.
 */
exec function bool LoadGameFromFile(string fileName){
	local BBSaveGame tempSave;
	local bool tempResult;
	local string tempMapName;
	//if(fileName ~= "CheckPointSave")
	//	return false;
	tempSave = new class'BBSaveGame';
	tempResult = class'Engine'.static.BasicLoadObject(tempSave, `saveFolder $ fileName $ `saveExtension, true, 0);
	if(tempResult == false)
		`warn("Error");
	tempMapName = tempSave.GetMapName();
	WorldInfo.GetALocalPlayerController().ClientTravel( tempMapName $ "?LoadPreviousGame=" $ fileName, TRAVEL_Partial );
	return tempResult;
}

/**Changes current level
 * @param mapName Name of next map to load
 */
exec function LoadGame(string mapName){
	WorldInfo.GetALocalPlayerController().ClientTravel( mapName, TRAVEL_Absolute );
}

/**Charge information of a File in this current map.
 * @param fileName Filename without extension
 */
function bool InitMapFromFile(string fileName){
	local BBSaveGame tempSave;
	local bool tempResult;
	tempSave = new class'BBSaveGame';
	tempResult = class'Engine'.static.BasicLoadObject(tempSave, `saveFolder $ fileName $ `saveExtension, true, 0);
	tempSave.LoadInfo(WorldInfo);
	lastLoadedGame = tempSave;
	return tempResult;
}


DefaultProperties 
{
	bDelayedStart = false
	bRestartLevel = false
	PlayerControllerClass = class 'BettyTheBee.BBPlayerController' //Setting the Player Controller to your custom script
	HUDType=class'BettyTheBee.BBHUD'
	DefaultPawnClass = class 'BettyTheBee.BBBettyPawn' //Setting the Pawn to your custom script

	depthBiasLastDecal = - 0.000060f;

}