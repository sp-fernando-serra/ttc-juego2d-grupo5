class BBCheckPoint extends PlayerStart placeable
	classGroup(BBActor);

var () editconst const CylinderComponent myCylinderComponent<DisplayName = Cylinder Component>;

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal){
	//local BBCheckPoint tempCheckPoint;
	//if(BBBettyPawn(Other) != none){
	//	foreach AllActors(class'BBCheckPoint', tempCheckPoint){
	//		tempCheckPoint.bEnabled = false;
	//		tempCheckPoint.bPrimaryStart = false;
	//	}

	//	bEnabled = true;
	//	bPrimaryStart = true;
	//}

	BBGameInfo(WorldInfo.Game).currentCheckPoint = self;
	BBGameInfo(WorldInfo.Game).SaveGameCheckpoint();
}


DefaultProperties
{

	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00040.000000
		CollisionHeight=+00080.000000
		CollideActors=true
		BlockActors=false

		// Don't want the cylinder to block bullets
		BlockZeroExtent=false
		BlockNonZeroExtent=true

		bAlwaysRenderIfSelected=true
	End Object

	CollisionComponent=CollisionCylinder
	myCylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bCollideActors=true
	CollisionType=COLLIDE_TouchAllButWeapons
	bNoDelete = true
	bStatic = false


	bPrimaryStart = false
	bEnabled = false
}
