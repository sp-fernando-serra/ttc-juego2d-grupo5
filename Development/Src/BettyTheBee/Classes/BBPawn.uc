class BBPawn extends UDKPawn; //Again, naming conventions apply here. Your script is extending the UDK script
//This lets the pawn tell the PlayerController what Camera Style to set the camera in initially (more on this later).

var DynamicLightEnvironmentComponent LightEnvironment;



DefaultProperties
{
	//Setting up the light environment
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		//AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		//AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment = MyLightEnvironment

}