/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */
class SeqEvent_MobileSwipe extends SeqEvent_MobileRawInput
	native;

cpptext
{
	/**
	 * Handle a touch event coming from the device. 
	 *
	 * @param Originator		is a reference to the PC that caused the input
	 * @param Handle			the id of the touch
	 * @param Type				What type of event is this
	 * @param TouchLocation		Where the touch occurred
	 * @param DeviceTimestamp	Input event timestamp from the device
	 */
	void InputTouch(APlayerController* Originator, UINT Handle, BYTE Type, FVector2D TouchLocation, DOUBLE DeviceTimestamp);
}


/** How much tolerance should we give the weak axis in order to consider it a swipe */
var (swipe) float Tolerance;

/** How far does the touch need to travel in order to be consider a swipe */
var (swipe) float MinDistance;

var vector2D InitialTouch;

defaultproperties
{

	ObjName="Mobile Simple Swipes"
	ObjCategory="Input"
	MaxTriggerCount=0
	OutputLinks.Empty
	OutputLinks(0)=(LinkDesc="Swipe Left")
	OutputLinks(1)=(LinkDesc="Swipe Right")
	OutputLinks(2)=(LinkDesc="Swipe Up")
	OutputLinks(3)=(LinkDesc="Swipe Down")
}