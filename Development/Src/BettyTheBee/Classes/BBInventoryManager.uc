class BBInventoryManager extends InventoryManager;

simulated function SwitchWeapon(byte NewGroup)
{

//SetCurrentWeapon(0);
/*local array<Weapon> WeaponList;
GetWeaponList(WeaponList,true,NewGroup);
SetPendingWeapon(WeaponList[NewGroup]);
*/
}
/*
simulated function GetWeaponList(out array<Weapon> WeaponList, optional bool bFilter, optional int GroupFilter, optional bool bNoEmpty)
{
	local Weapon Weap;
	local int i;

	ForEach InventoryActors( class'Weapon', Weap )
	{
		if ( (!bFilter || Weap.InventoryGroup == GroupFilter) && ( !bNoEmpty || Weap.HasAnyAmmo()) )
		{
			if ( WeaponList.Length>0 )
			{
				// Find it's place and put it there.

				for (i=0;i<WeaponList.Length;i++)
				{
					if (WeaponList[i].InventoryWeight > Weap.InventoryWeight)
					{
						WeaponList.Insert(i,1);
						WeaponList[i] = Weap;
						break;
					}
				}
				if (i==WeaponList.Length)
				{
					WeaponList.Length = WeaponList.Length+1;
					WeaponList[i] = Weap;
				}
			}
			else
			{
				WeaponList.Length = 1;
				WeaponList[0] = Weap;
			}
		}
	}
}
*/
DefaultProperties
{
	PendingFire(0)=0
	//PendingFire(1)=0//si tinguesim dos tipus de dispars amb la mateixa arma...By default, Fire mode 0 is triggered by Left mouse button, and Fire mode 1 by Right Mouse Button.
}