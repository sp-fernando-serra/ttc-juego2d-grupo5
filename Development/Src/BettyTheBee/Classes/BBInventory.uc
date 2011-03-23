class BBInventory extends Inventory;

var int contItemsMel;

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	return false;
}

DefaultProperties
{
}