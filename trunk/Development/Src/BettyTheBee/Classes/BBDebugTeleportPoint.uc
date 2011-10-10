class BBDebugTeleportPoint extends Actor 
	placeable
	classGroup(BBActor);

/** Sort teleportPoints in array using this order. 0 is first element in the array */
var() int order;

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Teleport'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=150,G=200,B=255)
		ArrowSize=0.5
		bTreatAsASprite=True
		HiddenGame=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Arrow)

	Begin Object Class=CylinderComponent Name=CollisionCylinder LegacyClassName=NavigationPoint_NavigationPointCylinderComponent_Class
		CollisionRadius=+0025.000000
		CollisionHeight=+0045.000000
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
}
