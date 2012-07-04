#import "Player.h"
#import "CCDrawingPrimitives.h"
#import "Resource.h"


@implementation Player
@synthesize vx,vy,touch_count,airjump_count;
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
    float mov_speed = player.vx;
    player.vy = 0;
    
    Island *i = player.current_island;
    float t = [i get_t_given_position:player.position];
    float t_final = t+mov_speed;
    CGPoint position_final = [i get_position_given_t:t_final];
    
    Vec3D *tmp = player.up_vec;
    Vec3D *tangent_vec = [Island get_tangent_vec_given_slope:[i get_slope:player.position.x]];
    player.up_vec = [[Vec3D Z_VEC] crossWith:tangent_vec];
    [player.up_vec normalize];
    
    [tmp dealloc];
    [tangent_vec dealloc];
    
    
    float tar_ang = -[i get_angle:player.position.x];
    float ang_dist = [Common test:player.rotation to:tar_ang];
    float d_ang = 0;
    if (ang_dist != 0) {
        d_ang = ang_dist / ABS(ang_dist);
    }
    //FIX ME! logarithmic
    player.rotation += ang_dist;
    
    if (position_final.x == [Island NO_VALUE] || position_final.y == [Island NO_VALUE]) {
        if (i.next != NULL) {
            player.current_island = i.next;
            position_final = ccp(i.next.startX,i.next.startY);
        } else {
            float slope = [i get_slope:player.position.x];
            if (slope == INFINITY) {
                slope = 0;
            }
            position_final = ccp(i.endX + slope*mov_speed,i.endY);
            player.current_island = NULL;
        }
    }
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
    player.rotation = player.rotation*0.9;
    
    float cur_ang = [player.up_vec get_angle_in_rad];
    float tar_ang = -M_PI_2;
    float rot_by = [Common shortest_rot_dir_from_cur:cur_ang to_tar:tar_ang]*0.05;
    Vec3D *tmp = player.up_vec;
    Vec3D *rot_vec = [tmp rotate_vec_by_rad:rot_by];
    player.up_vec = rot_vec;
    [tmp dealloc];
    
    CGPoint player_pre = player.position;
    CGPoint player_post = ccp(player.position.x+player.vx,player.position.y+player.vy);
    line_seg player_mov = [Common cons_line_seg_a:player_pre b:player_post];
    
    Island* contact_island = NULL;
    CGPoint contact_intersection;
    
    for (Island *i in islands) {     
        line_seg island_seg = [i get_line_seg_a:player_pre.x b:player_post.x];
        CGPoint intersection = [Common line_seg_intersection_a:player_mov b:island_seg];
        if (intersection.x != [Island NO_VALUE] && intersection.y != [Island NO_VALUE]) {
            contact_island = i;
            contact_intersection = intersection;
        }
    }
    
    if (contact_island != NULL) {
        player.current_island = contact_island;
        player.position = contact_intersection;
    } else {
        float grav_const = -0.5;
        player.vx += grav_const * player.up_vec.x;
        player.vy += grav_const * player.up_vec.y;
    }
    
    return player_post;
}



@end
