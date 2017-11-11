/// @description  Player Logic

// VELOCITY HANDLING ==================================================

// Clamp velocities.
xspeed = iff(abs(xspeed) > xmaxspeed, xmaxspeed * sign(xspeed), xspeed);
yspeed = iff(abs(yspeed) > ymaxspeed, ymaxspeed * sign(yspeed), yspeed);

// Vertical velocity:
if (!place_meeting(x, y + yspeed, o_block)) {
  y += yspeed;
}
else {
  // Landing.
  if (yspeed > 0) {
    isClimbing = false;
    isJumping = false;
    isDismounting = false;
    landing = landing_max;
    dismount = dismount_max;
    y = floor(y);
  }
  move_contact_solid(point_direction(x, y, x, y + yspeed), yspeed);
  yspeed = 0;
}

// Horizontal velocity:
if (!place_meeting(x + xspeed, y, o_block)) {
    x += xspeed;
} 
else {
  move_contact_solid(point_direction(x, y, x + xspeed, y), xspeed);
  xspeed = 0;
}

// Limit position within room.
if (x < 0) x = 0;
if (x > room_width) x = room_width;

// PLAYER MOVEMENT ==================================================

isWallsliding = false;

if (isClimbing == false) {
  
  // Handle directions.
  if (key_check(K_LEFT, E_PRESS) || (key_check(K_LEFT, E_DOWN) && key_check(K_RIGHT, E_RELEASE))) {
    dir = -1;
  }
  if (key_check(K_RIGHT, E_PRESS) || (key_check(K_RIGHT, E_DOWN) && key_check(K_LEFT, E_RELEASE))) {
    dir = 1; 
  }
  
  // Jumping from air:
  if (!place_meeting(x, y+1, o_block)) {
    yspeed += weight;
    if (!key_check(K_JUMP, E_DOWN)) {
      canDoubleJump = true;
    }
    // Wall jump.
    if (canWalljump && key_check(K_JUMP, E_PRESS)) {
      if (place_meeting(x+4, y, o_block)) {
        xspeed = -xmaxspeed;
        yspeed = -jumpHeight;
        isJumping = true;
      }
      if (place_meeting(x-4, y, o_block)) {
        xspeed = xmaxspeed;
        yspeed = -jumpHeight;
        isJumping = true;
      }
    }
    // Wall slide.
    if (place_meeting(x+4, y, o_block) && key_check(K_RIGHT, E_DOWN) ||
        place_meeting(x-4, y, o_block) && key_check(K_LEFT, E_DOWN)) {
      if (yspeed > ymaxspeed / 6) {
        isWallsliding = true;
        aiming = 0;
        firing = 0;
        yspeed = ymaxspeed / 6;
      }
    }
    // Double jump.
    else if (availableJumps > 0 && key_check(K_JUMP, E_PRESS) && canDoubleJump == true) {
      availableJumps -= 1;
      yspeed = -jumpHeight;
      xspeed = xmaxspeed * (0 - key_check(K_LEFT, E_DOWN) + key_check(K_RIGHT, E_DOWN));
      isJumping = true;
    }
    // Jump cancel.
    if (!key_check(K_JUMP, E_DOWN) && isJumping && (yspeed < -jumpHeight / 2)) {
      yspeed = -jumpHeight / 2;
    }
  }
  // Jumping from ground.
  else {
    availableJumps = maxDoubleJumps;
    canDoubleJump = false;
    if (key_check(K_JUMP, E_PRESS)) {
      yspeed = -jumpHeight;
      xspeed = xmaxspeed * (0 - key_check(K_LEFT, E_DOWN) + key_check(K_RIGHT, E_DOWN));
      isJumping = true;
    }
  }

  // Horizontal acceleration.
  if (key_check(K_LEFT, E_DOWN) && xspeed > -xmaxspeed && dir == -1) {
    xspeed -= accel;
  }
  if (key_check(K_RIGHT, E_DOWN) && xspeed < xmaxspeed && dir == 1) {
    xspeed += accel;
  }
  
  // Horizontal friction.
  if (!key_check(K_LEFT, E_DOWN) && !key_check(K_RIGHT, E_DOWN)) {
    if (abs(xspeed) > xfriction) {
      xspeed -= sign(xspeed) * xfriction;
    } else {
      xspeed = 0;
    }
  }
  
  // Climbing on to ladder.
  if (place_meeting(x, y, o_ladder) && !isDismounting) {
    if (key_check(K_UP, E_DOWN) && place_meeting(x, y-8, o_ladder)) {
      isClimbing = true;
    }
    if (key_check(K_DOWN, E_DOWN) && place_meeting(x, y+8, o_ladder) && !place_meeting(x, y+1, o_block)) {
      isClimbing = true;
    }
  }
}
// Movement on ladder:
else {
  // Stop climbing.
  if (!place_meeting(x, y, o_ladder)) {
    isClimbing = false;
  }
  
  // Handle direction.
  if (key_check(K_LEFT, E_PRESS)) {
    dir = -1;
  } 
  if (key_check(K_RIGHT, E_PRESS)) {
    dir = 1;
  }
  
  // Dismounting counter.
  if ((key_check(K_LEFT, E_DOWN) || key_check(K_RIGHT, E_DOWN)) && yspeed == 0) {
    dismount -= 1;
  } else {
    dismount = dismount_max;
  }
  
  xspeed = 0;
  yspeed = 0;
  
  if (firing == 0) {
    // Go down the ladder.
    if (place_meeting(x, y+8, o_ladder) && key_check(K_DOWN, E_DOWN)) {
      yspeed = 2.0;
      if (place_meeting(x, y+1, o_block)) {
        is_climbing = false;
      }
    }
    // Go up the ladder.
    if (place_meeting(x, y-8, o_ladder) && key_check(K_UP, E_DOWN)) {
      yspeed = -2.0;
    }
    
  }
  
  // Cancel firing.
  if (key_check(K_UP, E_PRESS) || key_check(K_DOWN, E_PRESS)) {
    firing = 0;
  }
  
  // Dismounting.
  if (key_check(K_JUMP, E_PRESS) || dismount <= 0) {
    isClimbing = false;
    isDismounting = true;
    if (dismount <= 0) {
      xspeed = (xmaxspeed / 2) * dir;
    }
    if (!key_check(K_DOWN, E_DOWN)) {
      yspeed = -6;
    }
  }
}
    
// SHOOTING ==================================================

// Decrement counters.
if (firing > 0) {
  firing -= 0.5; 
}

if (aiming > 0) {
  aiming -= 1;
}

// Shooting.
if (key_check(K_FIRE, E_PRESS) && !isWallsliding && firing < 6) {
  sprite_index = s_dude_gun_fire;
  firing = image_number;
  aiming = aiming_max;
  
  bullet = instance_create(x + dir*12, y-10, o_bullet);
  bullet.hspeed = 18.0 * dir;
  bullet.image_xscale = dir;
}

///Image Handling

// Draw the appropriate sprites:
if (place_meeting(x, y+1, o_block)) {
  if (xspeed == 0) {
    // Idle.
    sprite_index = iff(aiming, s_dude_gun, s_dude_idle);
    if (aiming && firing > 0) {
      // Shooting.
      sprite_index = s_dude_gun_fire;
      image_index = image_number - firing;
    }
  }
  else {
    // Running.
    if (sign(xspeed) == sign(dir)) {
      sprite_index = iff(aiming, s_dude_gun_run, s_dude_run);
    }
    // Skidding.
    else {
      sprite_index = iff(aiming, s_dude_gun_skid, s_dude_skid);
    }
  }
}
else {
  // Jumping.
  sprite_index = iff(aiming, s_dude_gun_jump, s_dude_jump);
  image_index = 1 + sign(yspeed);
  if (abs(yspeed) < 2) {
    image_index = 1;
  }
}
// Landing.
if (landing > 0) {
  landing -= 1;
  sprite_index = iff(aiming, s_dude_gun_land, s_dude_land);
}
// Climbing.
if (isClimbing) {
  if (firing == 0) {
    sprite_index = s_dude_climb;
    if (dismount < dismount_max && yspeed == 0) {
      sprite_index = s_dude_climb_off;
    }
    if (!place_meeting(x, y-8, o_ladder)) {
      sprite_index = s_dude_climb_top;
    }
  } else {
    sprite_index = s_dude_climb_fire;
    if (!place_meeting(x, y-8, o_ladder)) {
      sprite_index = s_dude_climb_top_fire;
    }
  }
  image_index = floor(y/16); 
}

// Configure image speeds.
image_speed = 1.0;

if (sprite_index == s_dude_run || s_dude_gun_run) {
  image_speed = 0.2;
}

// Handle image direction.
image_xscale = dir;


