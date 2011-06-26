class BBHUD extends UDKHUD;

//Reference the actual SWF container (STGFxHUD created later)
var BBGFxHUD HudMovie;
//var BBPlayerController PlayerOwner;

//Called when this is destroyed
singular event Destroyed()
{
	if (HudMovie != none)
	{
		//Get rid of the memory usage of HudMovie
		HudMovie.Close(true);
		HudMovie = none;
	}
	//super.Destroy();
}

//Called after game loaded - initialise things
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	//Create a STGFxHUD for HudMovie
	HudMovie = new class'BBGFxHUD';
	//Set the timing mode to TM_Real - otherwide things get paused in menus
	HudMovie.SetTimingMode(TM_Real);
	//Call HudMovie's Initialise function
	HudMovie.Init2();
}

//Called every tick the HUD should be updated
event PostRender()
{
	HudMovie.TickHUD();
}

exec function Pause(){
PlayerOwner.SetPause(true);
}

DefaultProperties
{
}