#import "Player.h"
#import "CCDrawingPrimitives.h"
#import "Resource.h"


@implementation Player
@synthesize vx,vy,touch_count,airjump_count;
@synthesize player_img;

+(Player*)init {
	Player *new_player = [Player node];
	CCSprite *player_img = [CCSprite node];
	player_img.anchorPoint = ccp(0,0);
	player_img.position = ccp(-(72/2)+5,-3);
	new_player.player_img = player_img;
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
        player position positive (-1 is used as a error value)
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
    float pos_x = player.position.x;
    float pos_y = player.position.y;
	float post_y = pos_y+player.vy;
    
    //Attempt to find if the player is in contact with an island (will be null if player is in freefall)
	Island *contact_island = [Player find_contact_island:islands pre_y:pos_y post_y:post_y pos_x:pos_x];
    
    //Both movement methods will return a CGPoint, this should be the player's position after the 'tick'
    CGPoint dp;
	if (contact_island != NULL) {
        dp = [self player_move_along_island:player contact_island:contact_island islands:islands pos_x:pos_x pos_y:pos_y post_y:post_y];
	} else {
        dp = [self player_free_fall:player islands:islands pos_x:pos_x pos_y:pos_y];
    }
    
    player.position = dp;
    //Return if the player is in contact with ground for gameengine/controls use
    return contact_island != NULL;
}

/**
    Finds the highest (in terms of order) island that the player is in contact with, given player pre/post position.
    @params
        (NSMutableArray*)islands - the islands of the player's world
        (Player*)player - the target player
        (float)pre_y - player y position before +vy
        (float)post_y - player y position after +vy
        (float)pos_x - player x position
    @returns
        An Island if the player is in contact with any,
        else NULL
         
 **/
+(Island*)find_contact_island:(NSMutableArray*)islands pre_y:(float)pre_y post_y:(float)post_y pos_x:(float)pos_x{
    Island *contact_island = NULL;
    for (Island* i in islands) {//if island height at pos_x overlaps ypre->ypost, CONTACT and select island
		float h = [i get_height:pos_x];
		if (h != -1 && h <= pre_y && h >= post_y) {
			post_y = h;
			contact_island = i;
			break;
		}
	}
    return contact_island;
}

/**
    Player movement calculation when in freefall (not in contact with any islands)
    Also applies a gravitation acceleration effect.
    @params
        (Player*)player - the target player
        (NSMutableArray*)islands - the islands of the player's world
        (float)pos_x - player x position
        (float)pos_y - player y position
    @modifies
        player.rotation
        player.vy (gravitational acceleration effect)
    @returns
        A CGPoint of the player's calculated position after this update 'tick'
 **/
+(CGPoint)player_free_fall:(Player*)player islands:(NSMutableArray*)islands pos_x:(float)pos_x pos_y:(float)pos_y {
    pos_y+=player.vy; //move before incrementing velocity (or else it will break)
    
    player.vy-=0.5; //gravitational acceleration effect

    player.rotation = player.rotation*0.9; //when freefall, center rotation
    
    float pre_x = pos_x;//move xdir by vx, check pre and post
    float post_x = pos_x+player.vx;
    BOOL has_hit_x = NO;
    for (Island* i in islands) { //use 2-line segment intersection to see if any x-dir conflicts
        float line_pre_y = [i get_height:pre_x];
        float line_post_y = [i get_height:post_x];
        
        CGPoint intersection = [Common line_seg_intersection_a1:ccp(pre_x,pos_y) a2:ccp(post_x,pos_y) b1:ccp(pre_x,line_pre_y) b2:ccp(post_x,line_post_y)];
        
        //if conflict, set position at conflict_x,contact_island_height(x)
        if (intersection.x != -1 && intersection.y != -1 && line_pre_y != -1 && line_post_y != -1) {
            pos_x = post_x; 
            pos_y = [i get_height:pos_x];
            has_hit_x = YES;
            break;
        }
    }
    
    if (!has_hit_x) {//else if no conflict, move vx unhindered
        pos_x = post_x;
    }
    return ccp(pos_x,pos_y);
}

/**
    Player movement calculation when in contact with an island (any ground).
    If moving past an island edge, calculates if the player should fall/climb onto any intersecting islands
     @params
         (Player*)player - the target player
         (Island*)contact_island - the island the player is in contact with
         (NSMutableArray*)islands - the islands of the player's world
         (float)pos_x - player x position
         (float)pos_y - player y position
         (float)post_y - player y position after +vy
     @modifies
         player.rotation - rotates player in the direction of contact_island
         player.vy - reduced to zero
     @returns
         A CGPoint of the player's calculated position after this update 'tick'
 **/
+(CGPoint)player_move_along_island:(Player*)player contact_island:(Island*)contact_island islands:(NSMutableArray*)islands pos_x:(float)pos_x pos_y:(float)pos_y post_y:(float)post_y {
    float rise_one = [contact_island get_height:(pos_x+1)] - [contact_island get_height:pos_x];
    float dx = player.vx*cos(atan(rise_one));
    float mov_h = [contact_island get_height:(pos_x+dx)]; //calculate slide movement on slope
    
    if (mov_h != -1 && [contact_island get_height:(pos_x+player.vx)] != -1) { //if on slope and enough forward room, apply movement up slope
        pos_x = pos_x + dx;
        pos_y = mov_h;
    } else { //else at an edge
        
        //test to see if the player should "fall" onto any other islands using two line-segment test
        //the first line segment is player position (pre_x,pre_y)->(post_x,post_y)
        //the second is island position (player's pre_x, extrapolated island height @ point) -> (player's post_x, calculated island height @ point)
        //the line segments are extended (length doubled left and right) because of inconsistencies in calculated values (float math, etc)
        float pre_x = pos_x;
        float post_x = pre_x + player.vx;
        float est_post_y = pos_y + (post_x-pre_x)*[contact_island get_slope:pre_x];
        line_seg player_lseg = [Common cons_line_seg_a:ccp(pos_x,pos_y) b:ccp(post_x,est_post_y)];
        player_lseg = [Common double_extend_line_seg:player_lseg];
        
        BOOL has_hit_x = NO;
        
        //loop through every island (ignoring contact_island and -1 (nonexistant@point) valued segments) and check if line segment intersection
        for (Island* i in islands) {
            if (i == contact_island) {
                continue;
            }
            line_seg island_lseg = [Common cons_line_seg_a:ccp(i.startX,[i get_height:i.startX]) b:ccp(post_x,[i get_height:post_x])];
            line_seg island_lseg_extend = [Common double_extend_line_seg:island_lseg];
            
            CGPoint intersection = [Common line_seg_intersection_a:player_lseg b:island_lseg_extend];
            if (!([Common line_seg_valid:island_lseg] && [Common line_seg_valid:island_lseg_extend])) {
                continue;
            }
            
            //if intersection is found the player is moved onto that island
            //*TODO -- seems to break on same-slope (relatively steep) line island joins when jumping repeatedly
            if ((intersection.x != -1 && intersection.y != -1) || ([Common point_fuzzy_on_line_seg:island_lseg pt:player_lseg.b])) {
                pos_x = post_x; 
                pos_y = [i get_height:post_x];
                has_hit_x = YES;
                break;
            }
        }
        
        if (!has_hit_x) {
            //if entering here, no linked islands found, extrapolate move based on current slope
            pos_x = pos_x + player.vx;
            pos_y= post_y + [contact_island get_slope:pre_x]*player.vx;
        }
        
    }
    float ang = [contact_island get_angle:pos_x]; //rotate player in rotation of contacting island
    player.rotation = -ang; 
    player.vy = 0;
    return ccp(pos_x,pos_y);
}




@end
