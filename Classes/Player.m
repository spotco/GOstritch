#import "Player.h"
#import "CCDrawingPrimitives.h"
#import "Resource.h"


@implementation Player
@synthesize vx,vy,touch_count,airjump_count,rotate_to;
@synthesize player_img;
@synthesize current_island;
@synthesize up_vec;

+(Player*)init {
	Player *new_player = [Player node];
	CCSprite *player_img = [CCSprite node];
    
    new_player.current_island = NULL;
	player_img.anchorPoint = ccp(0,0);
	player_img.position = ccp(-(72/2)+5,-3);
	new_player.player_img = player_img;
    new_player.up_vec = [Vec3D init_x:0 y:1 z:0];
	[new_player addChild:player_img];

	
	CCTexture2D *texture = [Resource get_tex:TEX_DOG_RUN_1];
	NSMutableArray *animFrames = [NSMutableArray array];
	
	for (int i = 1; i<=3; i++) {
		CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(60*(i-1), 0, 60, 55)];
		[animFrames addObject:frame];
	}
	
	CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:0.1f];
	
	id animate = [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO];
	id repeat= [CCRepeatForever actionWithAction:animate];
	[player_img runAction:repeat];
	
	new_player.anchorPoint = ccp(0,0);
    new_player.touch_count = 0;
    
	return new_player;
}

-(CGRect) get_hit_rect {
    return CGRectMake([self position].x-55/2,  [self position].y, 60, 55);
}

-(void) draw {
    [super draw];
    
	glColor4ub(255,0,0,100);
    glLineWidth(7.0f);
    ccDrawLine(ccp(-30,60),ccp(MIN(-30+(touch_count/15)*(50),20),60));
}

/**
 Calculates player position and moves the player one 'tick' based on current state and islands.
 @requires
     islands is sorted
 @params
     (Player*)player - the target player to move
     (NSMutableArray*)islands - the islands of the player's world
 @modifies
     player.position
     player.rotation
     player.vx/player.vy
 @returns
     YES if player is in contact with the ground
     else NO
 **/
+(BOOL)player_move:(Player*)player with_islands:(NSMutableArray*)islands {
    if (player.current_island == NULL) {
        player.position = [Player player_free_fall:player islands:islands];
    } else {
        player.position = [Player player_move_along_island:player islands:islands];
    }
    return player.current_island != NULL;
}

/**
 Player movement calculation when in contact with an island (any ground).
 If moving past an island edge, calculates if the player should fall/climb onto any intersecting islands
 @params
     (Player*)player - the target player
     (NSMutableArray*)islands - the islands of the player's world
 @modifies
     player.rotation - rotates player in the direction of contact_island
     player.vy - reduced to zero
 @returns
    A CGPoint of the player's calculated position after this update 'tick'
 **/
+(CGPoint)player_move_along_island:(Player*)player islands:(NSMutableArray*)islands {
    float ABS_MAX_SPEED = 20;
    float LIMIT_SPEED = 10;
    float MIN_SPEED = 8;
    float SLOPE_ACCEL = 0.3;
    float FRICTION = 0.99;
    float TO_GROUND_ROTATION_SPEED = 0.3;
    
    Island *i = player.current_island;
    Vec3D *tangent_vec = [i get_tangent_vec];
    
    if (i.ndir < 0) {
        player.scaleY = -1;
    } else {
        player.scaleY = 1;
    }
        
    if (tangent_vec.y < 0) {
        float ang = [tangent_vec get_angle_in_rad];
        if (ang < -M_PI_2) {
            ang = ang + M_PI;
        }
        player.vx += SLOPE_ACCEL;
        player.vy += SLOPE_ACCEL;
        float pct = ABS(ang/M_PI_2);
        LIMIT_SPEED += (ABS_MAX_SPEED - LIMIT_SPEED)*(pct);
    }
    
    float mov_speed = sqrtf(powf(player.vx, 2) + powf(player.vy, 2));
    
    if (mov_speed > ABS_MAX_SPEED) {
        mov_speed = ABS_MAX_SPEED;
    }
    if (mov_speed > LIMIT_SPEED) {
        player.vx *= FRICTION;
        player.vy *= FRICTION;
    }
    if (mov_speed < MIN_SPEED) {
        float acc = (MIN_SPEED - mov_speed)/5;
        player.vx += acc;
        player.vy += acc;
    }
    
    float t = [i get_t_given_position:player.position];
    float t_final = t+mov_speed;
    CGPoint position_final = [i get_position_given_t:t_final];
    
    Vec3D *tmp = player.up_vec;
    player.up_vec = [[Vec3D Z_VEC] crossWith:tangent_vec];
    [player.up_vec normalize];
    [player.up_vec scale:i.ndir];
    [tmp release];
    
    float tar_rad = -[tangent_vec get_angle_in_rad];
    float tar_deg = [Common rad_to_deg:tar_rad];
    float dir = [Common shortest_dist_from_cur:player.rotation to:tar_deg];
    player.rotation += dir*TO_GROUND_ROTATION_SPEED;
    
    
    if (position_final.x == [Island NO_VALUE] || position_final.y == [Island NO_VALUE]) {
        if (i.next != NULL) {
            float t_sum = mov_speed;
            t_sum -= [i get_t_given_position:ccp(i.endX,i.endY)] - t;
            player.current_island = i.next;
            if ([player.current_island get_position_given_t:t_sum].x != [Island NO_VALUE] && [player.current_island get_position_given_t:t_sum].y != [Island NO_VALUE]) {
                position_final = [player.current_island get_position_given_t:t_sum];
            } else {
                position_final = ccp(player.current_island.endX,player.current_island.endY);
                NSLog(@"GOTTA GO FAST");
            }
        } else {
            position_final = ccp(i.endX + tangent_vec.x*mov_speed, i.endY + tangent_vec.y*mov_speed);
            player.current_island = NULL;
            player.vx = tangent_vec.x * mov_speed;
            player.vy = tangent_vec.y * mov_speed;
        }
    }
    
    [tangent_vec release];
    return position_final;
}


/**
 Player movement calculation when in freefall (not in contact with any islands)
 Also applies a gravitation acceleration effect.
 @params
     (Player*)player - the target player
     (NSMutableArray*)islands - the islands of the player's world
 @modifies
     player.rotation
     player.vy (gravitational acceleration effect)
 @returns
    A CGPoint of the player's calculated position after this update 'tick'
 **/
+(CGPoint)player_free_fall:(Player*)player islands:(NSMutableArray*)islands {
    float CENTERING_ROTATION_SPD = 0.1;
    float CENTERING_UP_VEC_SPD = 0.07;
    float MAX_LOSS = 0.3;
    float GRAVITY = -0.5;
    
    
    player.scaleX = 1;
    player.scaleY = 1;
    
    float cur_deg = ((int)player.rotation)%360;
    float tar_deg = 0;
    float dir = [Common shortest_dist_from_cur:cur_deg to:tar_deg];
    player.rotation += dir*CENTERING_ROTATION_SPD;
    
    
    float cur_ang = [Common rad_to_deg:[player.up_vec get_angle_in_rad]];
    float tar_ang = 90;
    float rot_by = [Common shortest_dist_from_cur:cur_ang to:tar_ang]*CENTERING_UP_VEC_SPD;
    rot_by = [Common deg_to_rad:rot_by];
    Vec3D *tmp = player.up_vec;
    
    Vec3D *rot_vec = [tmp rotate_vec_by_rad:rot_by];
    player.up_vec = rot_vec;
    [tmp dealloc];
    
    CGPoint player_pre = player.position;
    CGPoint player_post = ccp(player.position.x+player.vx,player.position.y+player.vy);
    line_seg player_mov = [Common cons_line_seg_a:player_pre b:player_post];
    Vec3D *player_mov_vec = [Vec3D init_x:player_mov.b.x - player_mov.a.x y:player_mov.b.y - player_mov.a.y z:0];
    
    Island* contact_island = NULL;
    CGPoint contact_intersection;
    line_seg contact_segment;
    
    for (Island *i in islands) {     
        line_seg island_seg = [i get_line_seg_a:player_pre.x b:player_post.x];
        CGPoint intersection = [Common line_seg_intersection_a:player_mov b:island_seg];
        if (i.can_land && intersection.x != [Island NO_VALUE] && intersection.y != [Island NO_VALUE] && ABS([Vec3D rad_angle_between_a:player_mov_vec and_b:i.normal_vec]) >= M_PI / 2) {
            contact_island = i;
            contact_intersection = intersection;
            contact_segment = island_seg;
        }
    }
    [player_mov_vec dealloc];
    
    if (contact_island != NULL) {
        player.current_island = contact_island;
        player.position = contact_intersection;
        
        if (contact_island.ndir == -1) {
            MAX_LOSS = 1;
        }
        
        Vec3D *a = [Vec3D init_x:player_mov.b.x - player_mov.a.x y:player_mov.b.y - player_mov.a.y z:0];
        Vec3D *b = [Vec3D init_x:contact_segment.b.x - contact_segment.a.x y:contact_segment.b.y - contact_segment.a.y z:0];
        float theta = [Vec3D rad_angle_between_a:a and_b:b];
        if (theta < M_PI) {
            player.vx *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
            player.vy *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
        } else {
            player.vx *= MAX_LOSS;
            player.vy *= MAX_LOSS;
        }
        [a dealloc];
        [b dealloc];
        
    } else {
        float grav_const = GRAVITY;
        player.vx += grav_const * player.up_vec.x;
        player.vy += grav_const * player.up_vec.y;
    }
    
    return player_post;
}



@end
