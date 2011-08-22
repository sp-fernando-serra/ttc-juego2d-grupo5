class BBPropSlidingRock extends InterpActor placeable
	classGroup(BBActor);

/** Damage of rock */
var() int damage;

var class<BBDamageType> MyDamageType;

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal){
	
	if(BBBettyPawn(Other) != none){
		Other.TakeDamage(damage, none, HitLocation, vect(0,0,0), MyDamageType, , self);
	}
}


DefaultProperties
{


	//NOT WORKING don't know why....
	Begin Object Name=StaticMeshComponent0
	    StaticMesh=StaticMesh'Betty_Traps1.Models.SlidingRock1'
		CollideActors = true;
		BlockActors = false;
	End Object
	CollisionComponent=StaticMeshComponent0
	StaticMeshComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	bCollideActors = true;


	DrawScale = 0.3

	damage = 2;
	MyDamageType = class'BBDamageType_SlidingRock'

	Tag = "SlidingRock";
	Group = "Traps";
		
}
