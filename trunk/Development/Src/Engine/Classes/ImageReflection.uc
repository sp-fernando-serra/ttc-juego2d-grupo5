/**
 * An actor which specifies a reflection primitive used by materials that use image based reflections.
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */
class ImageReflection extends Actor
	showcategories(Movement)
	AutoExpandCategories(ImageReflection)
	AutoExpandCategories(ImageBasedReflectionComponent)
	native(Mesh)
	placeable;

/** Image reflection component */
var deprecated ImageReflectionComponent ReflectionComponent;

/** Image reflection component */
var() ImageBasedReflectionComponent ImageReflectionComponent;

cpptext
{
protected:
	virtual void PostLoad();
}

defaultproperties
{
	bStatic=FALSE
	bNoDelete=true

	// Network settings taken from AInfo
	RemoteRole=ROLE_None
	NetUpdateFrequency=10
	bOnlyDirtyReplication=TRUE
	bSkipActorPropertyReplication=TRUE

	Begin Object Class=ImageBasedReflectionComponent Name=ReflectionComponent0
	End Object
	ImageReflectionComponent=ReflectionComponent0
	Components.Add(ReflectionComponent0)
}
