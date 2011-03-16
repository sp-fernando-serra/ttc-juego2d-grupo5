
class BettyGameInfo extends GameInfo; //This line tells UDK that you want to inherit all of the functionality of GameInfo.uc, and< add your own. The name after "class" must match the file name.
DefaultProperties //Self explanatory
{
	bDelayedStart = false
	PlayerControllerClass = class 'BettyTheBee.BettyGamePlayerController' //Setting the Player Controller to your custom script
	DefaultPawnClass = class 'BettyTheBee.BettyGamePawn' //Setting the Pawn to your custom script
}