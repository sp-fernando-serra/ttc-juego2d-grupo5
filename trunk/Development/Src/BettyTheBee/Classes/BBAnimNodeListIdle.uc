class BBAnimNodeListIdle extends UDKAnimBlendBase;

/** Constant time to Special Idle. timeToNextSpecialIdle = specialIdleTime + FRand()*specailIdleRandomTime */
var () float specialIdleTime;
/** Random time to Special Idle. timeToNextSpecialIdle = specialIdleTime + FRand()*specailIdleRandomTime */
var () float specialIdleRandomTime;

/** Time since this node was relevant */
var float timeActive;
/** Time to next special idle. This changes betwee specialIdleTime and specialIdleTime + specialIdleRandomTime */
var float timeToNextSpecialIdle;

/** Special idle playing? */
var bool isSpecialIdlePlaying;
/** Time left to finish special idle anim */
var float specialIdleTimeLeft;

event TickAnim(float DeltaSeconds){
	if(bRelevant){
		if(isSpecialIdlePlaying){
			specialIdleTimeLeft -= DeltaSeconds;
			if(specialIdleTimeLeft < 0){
				SetActiveChild(0,BlendTime);
				timeActive = 0.0;
				isSpecialIdlePlaying = false;
			}
		}else{
			timeActive += DeltaSeconds;
			if(timeActive > timeToNextSpecialIdle){
				SetActiveChild(1,BlendTime);
				isSpecialIdlePlaying = true;
				specialIdleTimeLeft = AnimNodeSequence(Children[1].Anim).GetTimeLeft();
			}
		}
	}
}

event OnBecomeRelevant(){
	timeToNextSpecialIdle = specialIdleTime + FRand()*specialIdleRandomTime;
}

event OnCeaseRelevant(){
	timeActive = 0.0f;
	if(specialIdleTimeLeft > 0){
		SetActiveChild(0,0.0);
		isSpecialIdlePlaying = false;
	}
}

DefaultProperties
{
	specialIdleTime = 10;
	specialIdleRandomTime = 5;

	bTickAnimInScript = true

	Children(0)=(Name="Idle",Weight=1.0)
	Children(1)=(Name="SpecialIdle")
	bFixNumChildren = true
	bPlayActiveChild = true

	bCallScriptEventOnInit = true
	bCallScriptEventOnBecomeRelevant = true
	bCallScriptEventOnCeaseRelevant = true

	CategoryDesc = "BB"
}
