class BBGFxHUDmenu extends GFxMoviePlayer;

//Create a Health Cache variable
var float LastHealthpc;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject mc_mask_vida,mc_mask_granada,mc_mask_furia;
var GFxObject mc_transp_furia,mc_transp_vida,mc_transp_granada;

var GFxObject txt_mum_items;
var GFxObject txt1,txt2,txt3;
var GFxAction_GetVariable pausa;

var SoundCue selec0;
var SoundCue selec1;
var SoundCue selec2;

var SoundCue over1;
var SoundCue over2;
var SoundCue over3;
var SoundCue over4;

//var BettyGamePlayerController PlayerOwner;



//  Function to round a float value to an int
function int roundNum(float NumIn)
{
	local int iNum;
	local float fNum;

	fNum = NumIn;
	iNum = int(fNum);
	fNum -= iNum;
	if (fNum >= 0.5f)
	{
		return (iNum + 1);
	}
	else
	{
		return iNum;
	}
}

//  Function to return a percentage from a value and a maximum
function int getpc2(int val, int max)
{
	return roundNum((float(val) / float(max)) * 100.0f);
}

//Called from STHUD'd PostBeginPlay()
//function Init2(PlayerController PC)
function Init2()
{

		Start();
	Advance(0.f);


}



//Called every update Tick
function TickHUD()
{


	
}



function sonido(String sonido)
{

	//local name Sound;
	//Sound=name(sonido);
//GetPC().PlaySound(SoundCue(sonido));	
	switch(sonido){
		case "selec" : 
			GetPC().PlaySound (selec0);	
			break;
		case "over" : 
			GetPC().PlaySound (over1);	
			break;

		default: 			
			break;
		}	

	
}

DefaultProperties
{

	TimingMode=TM_Real
	
	//this is the HUD. If the HUD is off, then this should be off
	bDisplayWithHudOff=true
	//bShowHud=true
	
	//The path to the swf asset we will create later
	MovieInfo=SwfMovie'BettyInterface.interface_menu.menu'
	//Just put it in...
	//bGammaCorrection = false


	SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'BettyInterface.sonidos.menu_sounds')

	


	selec0=SoundCue'BettyInterface.sonidos.selec0'
	selec1=SoundCue'BettyInterface.sonidos.selec1'
	selec2=SoundCue'BettyInterface.sonidos.selec2'

	over1=SoundCue'BettyInterface.sonidos.over1'
	over2=SoundCue'BettyInterface.sonidos.over2'
	over3=SoundCue'BettyInterface.sonidos.over3'
	over4=SoundCue'BettyInterface.sonidos.over4'


	
}
