// init

enemyMax = 2;

// weapon type enumerator

enum weapon {
	shotgun,
	grenade,
	vacuum,
	flash
}

weaponSpawnCount = instance_number(obj_weapon_spawn);
weaponSpawnMin = 250;
weaponSpawnMax = 500;
weaponSpawnTimeout = irandom_range(weaponSpawnMin, weaponSpawnMax);
weaponExpireMin = 250;
weaponExpireMax = 500;
weaponExpireTimeout = 0;

coin = irandom(1);
with instance_find(obj_player_01, 0) currentWeaponType = other.coin ? weapon.shotgun : weapon.vacuum;
with instance_find(obj_player_02, 0) currentWeaponType = !other.coin ? weapon.shotgun : weapon.vacuum;