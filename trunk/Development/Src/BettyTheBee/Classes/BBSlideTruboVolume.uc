class BBSlideTruboVolume extends PhysicsVolume;

/** Change pawn velocity in this volume */
var () bool bForceSpeed;
/** New velocity */
var () float speedToForce<bShowOnlyWhenTrue=bForceSpeed>;

DefaultProperties
{
	bColored=true
	BrushColor=(B=0,G=255,R=120,A=255)
}
