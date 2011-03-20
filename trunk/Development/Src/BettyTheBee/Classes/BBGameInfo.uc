
class BBGameInfo extends GameInfo; //This line tells UDK that you want to inherit all of the functionality of GameInfo.uc, and< add your own. The name after "class" must match the file name.
DefaultProperties //Self explanatory
{
	bDelayedStart = false
	PlayerControllerClass = class 'BettyTheBee.BBPlayerController' //Setting the Player Controller to your custom script
	DefaultPawnClass = class 'BettyTheBee.BBBettyPawn' //Setting the Pawn to your custom script
}