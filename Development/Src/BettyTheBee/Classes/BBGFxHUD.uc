class BBGFxHUD extends GFxMoviePlayer;

//Create a Health Cache variable
var float LastHealthpc;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject mc_vida_mask;
var GFxObject txt_vida,txt_mum_items;
var GFxObject txt_1,txt_2,txt_3;

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
	mc_vida_mask =  GetVariableObject("_root.mc_hud_izquierda.mc_vida_mask");
	txt_mum_items =  GetVariableObject("_root.mc_hud_derecha.txt_mum_items");
	txt_1 =  GetVariableObject("_root.txt_1");
	txt_2 =  GetVariableObject("_root.txt_2");
	//txt_3 =  GetVariableObject("_root.txt_3");
	

}



//Called every update Tick
function TickHUD()
{



	local PlayerController PC;
	//local BettyGamePawn UTP;
	local BBBettyPawn UTP;
	

	PC = GetPC();
	
	UTP = BBBettyPawn(PC.Pawn);
	
	if (UTP == None)
	{
		return;
	}

	//txt_vida.SetString("text", string(UTP.Health));
	txt_mum_items.SetString("text", string(UTP.itemsMiel));
	//mc_vida_mask.SetFloat("_xscale", 20.0f);
	mc_vida_mask.SetFloat("_xscale", UTP.Health);

	
	//txt_1.SetString("text", string(UTP.Weapon.Class));
	
	//txt_2.SetString("text",  string(UTP.InvManager.PendingWeapon));
	//txt_2.SetString("text",  string(UTP.Weapon));
	
	//ASvariables(UTP.InvManager.PendingWeapon.getNom(),string(UTP.InvManager.InventoryChain),"cc");
	ASvariables( string(UTP.Weapon.Class),"","");
	
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

function ASvariables(String texto1, String texto2, String texto3)
//function ASvariables(String texto1)
{
     //`log("sendind information to flash with the slots availables");
     ActionScriptVoid("variables");
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
