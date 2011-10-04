class HUDKismetSeqAct_RegisterRender extends SeqAct_Latent;

var Object PlayerController;
var Vector CameraPosition;
var Vector CameraDirection;

var HUDKismetRenderProxy RenderProxy;

var float activeTime;
var() float maxActiveTime;

event bool Update(float DeltaTime){
	//Miramos el active time ya que si vale 0 no desactivmos nunca el texto
	if(bActive && activeTime > 0){
		activeTime -= DeltaTime;
		if(activeTime <= 0){
			bActive = false;
			if(RenderProxy != none){
				RenderProxy.RemoveRenderHUDSequenceEvent(self);
				return false;
			}
		}
	}
	if(InputLinks[1].bHasImpulse && bActive){
		AbortFor(none);
		return false;
	}
	return true;
}


event Activated()
{
	local WorldInfo WorldInfo;
	local HUDKismetRenderProxy FoundRenderProxy;
	
	//Activate this item
	bActive = true;
	activeTime = maxActiveTime;

	// Get the world info
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();

	// Abort if the world info isn't found
	if (WorldInfo == None)
	{
		return;
	}

	// Find a render proxy to associate with this render HUD event
	ForEach WorldInfo.DynamicActors(class'HUDKismetRenderProxy', FoundRenderProxy)
	{
		RenderProxy = FoundRenderProxy;
		break;
	}

	// If a render proxy hasn't been found, then create a render proxy
	if (RenderProxy == None)
	{
		RenderProxy = WorldInfo.Spawn(class'HUDKismetRenderProxy');
	}

	// Add this HUD render sequence to the rendering proxy
	if (RenderProxy != None)
	{
		RenderProxy.AddRenderHUDSequenceEvent(Self);
	}
}

function Render(Canvas Canvas)
{
	local int i, j;
	local HUDKismetSeqAct_RenderObject RenderObject;

	if(bActive){
		// Render output links
		if (OutputLinks.Length > 0)
		{
			for (i = 0; i < OutputLinks.Length; ++i)
			{
				if (OutputLinks[i].Links.Length > 0)
				{
					for (j = 0; j < OutputLinks[i].Links.Length; ++j)
					{
						RenderObject = HUDKismetSeqAct_RenderObject(OutputLinks[i].Links[j].LinkedOp);

						if (RenderObject != None)
						{
							RenderObject.Render(Canvas);
						}
					}
				}
			}
		}
	}
}

defaultproperties
{
	ObjName="Register Render HUD"
	ObjCategory="ExtHUD"

	OutputLinks(0)=(LinkDesc="Out")
	InputLinks(1)=(LinkDesc="Abort")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',bHidden=true,LinkDesc="PlayerController",bWriteable=true,PropertyName=PlayerController)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',bHidden=true,LinkDesc="Camera Position",bWriteable=true,PropertyName=CameraPosition)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Vector',bHidden=true,LinkDesc="Camera Direction",bWriteable=true,PropertyName=CameraDirection)
}
