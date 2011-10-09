//class BBHUD extends UTHUDBase;
class BBHUD extends HUD;

//Reference the actual SWF container (STGFxHUD created later)
var BBGFxHUD HudMovie;
var BBGFxHUDmenu HudMovieMenu;
var GFxMoviePlayer myHud;
//var BBPlayerController PlayerOwner;

var Font defaultFont;

var MaterialInterface collectableHUDMat;

var Texture2D controlsTexture;

/** True for painting collectable items on HUD */
var bool bDrawCollectable;

var bool bShowControls;

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

	HudMovie = new class'BBGFxHUD';
	//Set the timing mode to TM_Real - otherwide things get paused in menus
	HudMovie.SetTimingMode(TM_Real);
	//Call HudMovie's Initialise function
	HudMovie.Init2();
	
	bDrawCollectable = true;
	SetTimer(4.0, false, 'stopDrawCollectables');

}
function startAnimacioItem(){
//	Canvas.Project(PlayerOwner.Pawn.Location)
	
	HudMovie.animacioItem();
}

function startAnimacioColeccionable(){
	
	HudMovie.animacioColeccionable();
}

function showControls(bool show){
	bShowControls = show;
}

function startCollectableCaughtAnimation(BBPickupCollectable collectableItem){
	bDrawCollectable = true;
	SetTimer(4.0, false, 'stopDrawCollectables');
}

function stopDrawCollectables(){
	bDrawCollectable = false;
}

//Called every tick the HUD should be updated
event PostRender()
{
	if(bDrawCollectable && bShowHUD){
		drawCollectables();
	}
	if(bShowControls && bShowHUD){
		drawControls();
	}
	if(bShowHUD){
		super.PostRender();
		HudMovie.TickHUD();
	}else{      //Aunque no pintemos el HUD llamamos a PostRender() con bSHowHUD = true para pintar el canvas
		bShowHUD = true;
		super.PostRender();
		bShowHUD = false;
	}	
}


function ASvida(String texto1){
	HudMovie.ASvida(texto1);
}

function texto_ayuda(String texto1, String texto2, int tamany, int pox_x, int pos_y)
{
    HudMovie.texto_ayuda(texto1,texto2,tamany,pox_x,pos_y);
}

function texto_ayudaOFF()
{
    HudMovie.texto_ayudaOFF();
}

simulated function drawCollectables(){
	local int numCollectables,maxCollectables;
	local float lenX, lenY;

	numCollectables = BBBettypawn(PlayerOwner.Pawn).collectableItems;
	maxCollectables = BBBettypawn(PlayerOwner.Pawn).maxCollectableItems;

	Canvas.SetPos(Canvas.ClipX * 0.55, Canvas.ClipY * 0.837);
	Canvas.DrawMaterialTile(collectableHUDMat, 100, 100);


	Canvas.Font = defaultFont;
	Canvas.TextSize(numCollectables @ "/" @ maxCollectables, lenX, lenY);
	Canvas.SetPos(0.55 * Canvas.ClipX - lenX, Canvas.ClipY * 0.837);	
	Canvas.SetDrawColor(255, 241, 85);
	Canvas.DrawText(numCollectables @ "/" @ maxCollectables);
}

simulated function drawControls(){
	//local LinearColor tempColor;
	local float tempScale;

	//tempColor.R = 0.5;
	//tempColor.G = 0.5;
	//tempColor.B = 0.5;
	Canvas.SetDrawColor(255, 255, 255, 255);
	tempScale = 0.75;
	Canvas.SetPos(Canvas.ClipX *0.5 - controlsTexture.SizeX * 0.5 * tempScale, Canvas.ClipY * 0.5 - controlsTexture.SizeY * 0.5 * tempScale);
	Canvas.DrawTextureBlended(controlsTexture, tempScale, BLEND_Masked);
	//Canvas.DrawTile(controlsTexture, controlsTexture.GetSurfaceWidth() * tempScale, controlsTexture.GetSurfaceHeight() * tempScale, 0, 0, controlsTexture.GetSurfaceWidth(), controlsTexture.GetSurfaceHeight(), tempColor,,BLEND_Masked);
}

function playFromCheckpoint(){
	BBGameInfo(WorldInfo.Game).LoadGameCheckpoint();
}

DefaultProperties
{
	collectableHUDMat = Material'BettyInterface.interface_hud.CollectableHUD_Mat'
	defaultFont = Font'BettyInterface.Fonts.HoboLarge_Font';

	controlsTexture = Texture2D'BettyInterface.interface_menu.controles'
}
