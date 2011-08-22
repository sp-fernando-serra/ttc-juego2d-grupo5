class BBDamageType extends DamageType;

/************** DEATH ANIM *********/

/** Name of animation to play upon death. */
var(DeathAnim)	name	DeathAnim;
/** How fast to play the death animation */
var(DeathAnim)	float	DeathAnimRate;
/** If non-zero, stop death anim after this time (in seconds) after stopping taking damage of this type. */
var(DeathAnim)	float	StopAnimAfterDamageInterval;

/***********************************/

/************** HIT *********/

/** Name of animation to play upon death. */
var(Hit)	name	HitAnim;
/** How fast to play the death animation */
var(Hit)	float	HitAnimRate;
/** When get hitted the pawn stops his movement "hitStopTime" seconds */
var(Hit)    float HitStopTime;

/***********************************/

/** NO IMPLEMENTADO!!!  camera anim played instead of the default damage shake when taking this type of damage */
var CameraAnim DamageCameraAnim;

DefaultProperties
{
	DeathAnimRate = 1.0f
	StopAnimAfterDamageInterval = 0.0f
}
