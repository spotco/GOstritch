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
    
    if (false) { //enable to show player-gameobject hitbox
        CGRect pathBox = [self get_hit_rect];
        CGPoint verts[4] = {
            ccp(pathBox.origin.x, pathBox.origin.y),
            ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y),
            ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y + pathBox.size.height),
            ccp(pathBox.origin.x, pathBox.origin.y + pathBox.size.height)
        };
        
        ccDrawPoly(verts, 4, YES);
    }
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
    
    //NSLog(@"{x:%f,y:%f,rotation:%f}",player.position.x,player.position.y,player.rotation);
    //NSLog(@"VX:%f VY:%f",player.vx,player.vy);
    //NSLog(@"UPX:%f UPY:%f",player.up_vec.x,player.up_vec.y);
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
    Island *i = player.current_island;
    Vec3D *tangent_vec = [i get_tangent_vec];
    
    float ABS_MAX_SPEED = 20;
    float LIMIT_SPEED = 5;
    float SLOPE_ACCEL = 0.2;
    
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
    //NSLog(@"LIM:%f",LIMIT_SPEED);
    
    float mov_speed = sqrtf(powf(player.vx, 2) + powf(player.vy, 2)); //TODO -- fall angle speed calc
    if (mov_speed > ABS_MAX_SPEED) {
        mov_speed = ABS_MAX_SPEED;
    }
    if (mov_speed > LIMIT_SPEED) {
        player.vx *= 0.98;
        player.vy *= 0.98;
    }
    //NSLog(@"speed:%f",mov_speed);
    
    
    float t = [i get_t_given_position:player.position];
    float t_final = t+mov_speed;
    CGPoint position_final = [i get_position_given_t:t_final];
    
    Vec3D *tmp = player.up_vec;
    player.up_vec = [[Vec3D Z_VEC] crossWith:tangent_vec];
    [player.up_vec normalize];
    [tmp release];
    
    float tar_rad = -[tangent_vec get_angle_in_rad];
    float tar_deg = [Common rad_to_deg:tar_rad];
    float dir = [Common shortest_dist_from_cur:player.rotation to:tar_deg];
    player.rotation += dir*0.3;
    
    
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
            player.vy = 0;
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
    float cur_deg = ((int)player.rotation)%360;
    float tar_deg = 0;
    float dir = [Common shortest_dist_from_cur:cur_deg to:tar_deg];
    player.rotation += dir*0.3;
    
    
    float cur_ang = [Common rad_to_deg:[player.up_vec get_angle_in_rad]];
    float tar_ang = 90;
    float rot_by = [Common shortest_dist_from_cur:cur_ang to:tar_ang]*0.1;
    rot_by = [Common deg_to_rad:rot_by];
    Vec3D *tmp = player.up_vec;
    
    Vec3D *rot_vec = [tmp rotate_vec_by_rad:rot_by];
    player.up_vec = rot_vec;
    [tmp dealloc];
    
    CGPoint player_pre = player.position;
    CGPoint player_post = ccp(player.position.x+player.vx,player.position.y+player.vy);
    line_seg player_mov = [Common cons_line_seg_a:player_pre b:player_post];
    
    Island* contact_island = NULL;
    CGPoint contact_intersection;
    line_seg contact_segment;
    
    for (Island *i in islands) {     
        line_seg island_seg = [i get_line_seg_a:player_pre.x b:player_post.x];
        CGPoint intersection = [Common line_seg_intersection_a:player_mov b:island_seg];
        if (intersection.x != [Island NO_VALUE] && intersection.y != [Island NO_VALUE]) {
            contact_island = i;
            contact_intersection = intersection;
            contact_segment = island_seg;
        }
    }
    
    if (contact_island != NULL) {
        player.current_island = contact_island;
        player.position = contact_intersection;
        
        float MAX_LOSS = 0.3;
        
        Vec3D *a = [Vec3D init_x:player_mov.b.x - player_mov.a.x y:player_mov.b.y - player_mov.a.y z:0];
        Vec3D *b = [Vec3D init_x:contact_segment.b.x - contact_segment.a.x y:contact_segment.b.y - contact_segment.a.y z:0];
        float theta = acosf( [a dotWith:b] / ([a length]*[b length]) );
        if (theta < M_PI) {
            player.vx *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
            player.vy *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
            NSLog(@"Landing:%f",(M_PI - theta)/(M_PI));
        } else {
            player.vx *= MAX_LOSS;
            player.vy *= MAX_LOSS;
        }
        [a release];
        [b release];
        
    } else {
        float grav_const = -0.5;
        player.vx += grav_const * player.up_vec.x;
        player.vy += grav_const * player.up_vec.y;
    }
    
    return player_post;
}



@end
