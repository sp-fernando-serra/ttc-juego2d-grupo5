class BBCheckPoint extends Trigger placeable
	classGroup(BBActor);

//var () editconst const CylinderComponent myCylinderComponent<DisplayName = Cylinder Component>;

var () PlayerStart spawnPoint;

var SoundCue ActivationCue;

var float activationTime;
var bool bActivable;

event PostBeginPlay(){
	super.PostBeginPlay();

	if(spawnPoint == none){
		`warn(GetHumanReadableName() @ "has no spawn Point designed");
	}
}

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal){
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	if(bActivable){
		PlaySound(ActivationCue);
		BBGameInfo(WorldInfo.Game).currentCheckPoint = self;
		BBGameInfo(WorldInfo.Game).SaveGameCheckpoint();
		bActivable = false;
		setTimer(activationTime, false);
	}
}

event Timer(){
	bActivable = true;
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
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bCollideActors=true
	CollisionType=COLLIDE_TouchAllButWeapons
	bNoDelete = true
	bStatic = false

	ActivationCue = SoundCue'Betty_item.Sounds.FxCheckpoint0_Cue';
	activationTime = 3;
	bActivable = true;

}
