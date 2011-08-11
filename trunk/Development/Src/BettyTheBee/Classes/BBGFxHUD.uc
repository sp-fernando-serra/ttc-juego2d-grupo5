class BBGFxHUD extends GFxMoviePlayer;

//Create a Health Cache variable
var float LastHealthpc;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject mc_mask_vida,mc_mask_granada,mc_mask_furia;
var GFxObject mc_transp_furia,mc_transp_vida,mc_transp_granada;

var GFxObject txt_mum_items;
var GFxObject txt1,txt2,txt3;
var GFxAction_GetVariable pausa;

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
	//Start and load the SWF Movie
	Start();
	Advance(0.f);

	//Set the cahce value so that it will get updated on the first Tick
	LastHealthpc = -1;

	//txt_vida =  GetVariableObject("_root.txt_vida");
	mc_mask_vida =  GetVariableObject("_root.mc_hud_derecha.mc_mask_vida");
	mc_mask_granada =  GetVariableObject("_root.mc_hud_derecha.mc_mask_granada");
	mc_mask_furia =  GetVariableObject("_root.mc_hud_derecha.mc_mask_furia");

	mc_transp_furia =  GetVariableObject("_root.mc_hud_derecha.mc_transp_furia");
	mc_transp_vida =  GetVariableObject("_root.mc_hud_derecha.mc_transp_vida");
	mc_transp_granada =  GetVariableObject("_root.mc_hud_derecha.mc_transp_granada");
	txt_mum_items =  GetVariableObject("_root.mc_hud_derecha.txt_mum_items");
	txt1 =  GetVariableObject("_root.mc_hud_derecha.txt1");

	//txt_2 =  GetVariableObject("_root.txt_2");
	//txt_3 =  GetVariableObject("_root.txt_3");
	

}



//Called every update Tick
function TickHUD()
{


	local PlayerController PC;
	local BBBettyPawn UTP;

	PC = GetPC();
	
	UTP = BBBettyPawn(PC.Pawn);
	
	if (UTP == None)
	{
		return;
	}

	if(BBPlayerController(PC).reactivateTime[HN_Heal]!=0){
		mc_mask_vida.SetFloat("_yscale", (100*(1-BBPlayerController(PC).reactivateTime[HN_Heal]/BBPlayerController(PC).coldDowns[HN_Heal])));		
		mc_transp_vida.SetBool("_visible",true);
	}
	else mc_transp_vida.SetBool("_visible",false);

	if(BBPlayerController(PC).reactivateTime[HN_Grenade]!=0) {
		mc_mask_granada.SetFloat("_yscale", (100*(1-BBPlayerController(PC).reactivateTime[HN_Grenade]/BBPlayerController(PC).coldDowns[HN_Grenade])));
		mc_transp_granada.SetBool("_visible",true);
	}
	else mc_transp_granada.SetBool("_visible",false);

	if(BBPlayerController(PC).reactivateTime[HN_Frenesi]!=0) {
		mc_mask_furia.SetFloat("_yscale", (100*(1-BBPlayerController(PC).reactivateTime[HN_Frenesi]/BBPlayerController(PC).coldDowns[HN_Frenesi])));
		mc_transp_furia.SetBool("_visible",true);
	}
	else mc_transp_furia.SetBool("_visible",false);


	txt_mum_items.SetString("text", string(UTP.itemsMiel));

	//ASvariables(UTP.InvManager.PendingWeapon.getNom(),string(UTP.InvManager.InventoryChain),"cc");

	if(LastHealthpc!=UTP.Health){
			ASvida( String(UTP.Health));
	}

	LastHealthpc=UTP.Health;
	
	//`log(String(UTP.Health));
	/*//If the cached value for Health percentage isn't equal to the current...
	if (LastHealthpc != getpc2(UTP.Health, UTP.HealthMax))
	{
		//...Make it so...
		LastHealthpc = getpc2(UTP.Health, UTP.HealthMax);
		//...Update the bar's xscale (but don't let it go over 100)...
		HealthBarMC.SetFloat("_xscale", (LastHealthpc > 100) ? 100.0f : LastHealthpc);
		//...and update the text field
		HealthTF.SetString("text", round(LastHealthpc)$"%");
	}
*/
}

function ASvida(String texto1)
//function ASvariables(String texto1)
{
     //`log("sendind information to flash with the slots availables");
     ActionScriptVoid("vida");
}


function PlayGame()
{
   GetPC().SetPause(false);
}

function ExitGame(String mapa)
{
	ConsoleCommand(mapa);
   //GetPC().SetPause(false);
}

function animacioItem(){	

	ActionScriptVoid("item");

}

DefaultProperties
{
	//this is the HUD. If the HUD is off, then this should be off
	bDisplayWithHudOff=false
	//The path to the swf asset we will create later
	MovieInfo=SwfMovie'BettyInterface.interface_hud.hud'
	//Just put it in...
	//bGammaCorrection = false
}
