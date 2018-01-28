//------------------------------------------------------//
//						MOVEMENT						//
//------------------------------------------------------//

// count how many particles of slime the player is touching
touching = 0;
dhs = 0;
dvs = 0;

count = physics_particle_count();
if count > 0 {
	buffer = buffer_create(count * 4 * 4, buffer_grow, 4);
	physics_particle_get_data(buffer, phy_particle_data_flag_position | phy_particle_data_flag_velocity);
  
	for (n = 0; n < count; n++) {
		xx = buffer_read(buffer, buffer_f32);
		yy = buffer_read(buffer, buffer_f32);
		xv = buffer_read(buffer, buffer_f32);
		yv = buffer_read(buffer, buffer_f32);
		if collision_point(xx, yy, self, false, false) {
			touching++;
			dhs += xv;
			dvs += yv;
		}
	}
	
	buffer_delete(buffer);
}

if touching > 0 {
	//show_debug_message("Touching particles " + string(touching) + " Average velocity " + string(dhs) + "," + string(dvs));
	dhs /= (touching * slimeSpeedRatio);
	dvs /= (touching * slimeSpeedRatio);
	
	//show_debug_message("Moving by " + string(dhs) + "," + string(dvs));
}


if (canMove) {
	sc_player_movement(gp_padl, gp_padr, gp_padu, gp_padd, gp_face1, playerNumber, 
		dhs, dvs, touching * slimeSlowAmount);
}

// wrap to other side of screen when leaving bounds
//move_wrap(true, true, 0);

//------------------------------------------------------//
//						ANIMATION						//
//------------------------------------------------------//
#region
//if (!onGround) {
//	if (vspd <= 0) {
//		sprite_index = jumpSprite;
//	}
//	if (vspd > 0 && !place_meeting(x, y-sprite_height, obj_impasse)) {
//		sprite_index = idleSprite;
//	}
//}

if (onGround) {
	if (keyLeft || keyRight) {
		sprite_index = walkSprite;
	}
	if (!keyLeft && !keyRight) {
	    sprite_index = idleSprite;
	}	
	if (keyLeft && keyRight) {
	    sprite_index = idleSprite;
	}
}

#endregion

// -- WEAPONS -- //

// pick up and drop weapons
if (gamepad_button_check_pressed(playerNumber, gp_face2)) {
	if place_meeting(x, y, obj_weapon_drop) {
		var wd = instance_place(x, y, obj_weapon_drop);
		currentWeaponType = wd.weaponType;
		instance_destroy(wd);
		// change sprite to match weapon type
	//}else{
	//	var wd = instance_create_layer(x, y-(sprite_height/2), "spriteLayer", obj_weapon_drop);
	//	wd.weaponType = currentWeaponType;
	//	currentWeaponType = noone;
	//	// change sprite to match weapon loss
	}
}

// origin point for weapons
xorigin = x + sprite_width / 2;
yorigin = y - sprite_height / 2;

firing = gamepad_button_check(playerNumber, gp_shoulderrb);

// fire shotgun
if (gunCooldown > 0) {
	gunCooldown--;
}

if (currentWeaponType == weapon.shotgun and firing and gunCooldown <= 0) {
	gunCooldown += gunCooldownRate;
	
	for (b = 0; b < bulletCount; b++) {
		with instance_create_layer(xorigin, yorigin, layer, obj_bullet) {
			direction = other.aimDirection + (other.b - (other.bulletCount - 1) / 2) * other.spreadAngle;
			speed = other.bulletSpeed;
			xv = lengthdir_x(speed, direction);
			yv = lengthdir_y(speed, direction);
		}
	}
}

// throw a grenade
if (grenadeCooldown > 0) {
	grenadeCooldown--;
}
if (currentWeaponType == weapon.grenade and firing and grenadeCooldown <= 0) {
	grenadeCooldown += grenadeCooldownRate;
	
	grenadeDirection = aimActive ? aimDirection : 
		(image_xscale > 0 ? grenadeDefaultAngle : 180 - grenadeDefaultAngle);
	
	with instance_create_layer(xorigin, yorigin, layer, obj_grenade) {
		direction = other.grenadeDirection;
		speed = other.grenadeSpeed;
		xv = lengthdir_x(speed, direction);
		yv = lengthdir_y(speed, direction);
	}
}

// spawn a vacuum cleaner instance
if (currentWeaponType == weapon.vacuum and firing and (vacuum == noone || !instance_exists(vacuum))) {
	vacuum = instance_create_layer(xorigin, yorigin, layer, obj_vacuum);
	vacuum.direction = aimDirection;
}

// spawn a flash cleaner
if (currentWeaponType == weapon.flash and firing and (flash == noone || !instance_exists(flash))) {
	flash = instance_create_layer(xorigin, yorigin, layer, obj_flash);
}

// -- DEATH WHEN COLLIDING WITH ENEMY -- //

if (place_meeting(x, y, obj_enemy_01)) {
	instance_destroy();
}