// extend UIEvent if this event should be UI Kismet Event instead of a Level Kismet Event
class BBSeqEvent_PawnStunned extends SequenceEvent;

defaultproperties
{
	ObjName="PawnStunned"
	ObjCategory="BB Events"

	MaxTriggerCount = 0;
	bPlayerOnly=false
}
