/// @description  Player Variables

PLAYER_NUMBER = 1;     // The number of the player. 

dir = 1;               // Player direction. 1 = right, -1 = left.
xspeed = 0.0;          // Horizontal speed.
yspeed = 0.0;          // Vertical speed.
xmaxspeed = 4.0;       // Horizontal speed limit.
ymaxspeed = 10.0;      // Vertical speed limit.

weight = 0.4;          // How fast the player falls.
accel = 0.5;           // How fast the player accelerates horizontally.
xfriction = 0.5;       // How fast the player decelerates horizontally.
jumpHeight = 6.5;      // How high the player jumps.

maxDoubleJumps = 0;    // Number of possible additional jumps. 
availableJumps = 0;    // Number of available additional jumps.
canDoubleJump = false; // Whether or not player can do an additional jump.
canWalljump = true;    // Whether or not player can walljump.

isClimbing = false;    // Whether or not player is climbing.
isJumping = false;     // Whether or not player is jumping.
isDismounting = false; // Whether or not player is dismounting a ladder.
isWallsliding = false; // Whether or not player is sliding down a wall.

aiming_max = 60;       // Max number of aiming frames.
dismount_max = 20;     // Max number of ladder dismounting frames.
landing_max = 10;      // Max number of landing frames.

aiming = 0;            // Remaining number of aiming frames.
dismount = 0;          // Remaining number of ladder dismounting frames.
landing = 0;           // Remaining number of landing frames.
firing = 0;            // Remaining number of firing frames.

