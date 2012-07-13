#import "Player.h"

#define IMGWID 60
#define IMGHEI 55
#define IMG_OFFSET_X -31
#define IMG_OFFSET_Y -3

#define DEFAULT_GRAVITY -0.5
#define DEFAULT_MIN_SPEED 6

#define MIN_SPEED_MAX 14
#define LIMITSPD_INCR 2
#define ACCEL_INCR 0.01


@implementation Player
@synthesize vx,vy;
@synthesize player_img;
@synthesize current_island;
@synthesize up_vec;
@synthesize airjump_count;
@synthesize start_pt;

- (id)init
{
    self = [super init];
    if (self) {
        [self reset_params];
    }
    return self;
}

+(Player*)init_at:(CGPoint)pt {
	Player *new_player = [Player node];
	CCSprite *player_img = [CCSprite node];
    
    new_player.current_island = NULL;
	player_img.anchorPoint = ccp(0,0);
	player_img.position = ccp(IMG_OFFSET_X,IMG_OFFSET_Y);
	new_player.player_img = player_img;
    new_player.up_vec = [Vec3D init_x:0 y:1 z:0];
	[new_player addChild:player_img];
	
	CCTexture2D *texture = [Resource get_tex:TEX_DOG_RUN_1];
	NSMutableArray *animFrames = [NSMutableArray array];
	
	for (int i = 1; i<=3; i++) {
		CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(IMGWID*(i-1), 0, IMGWID, IMGHEI)];
		[animFrames addObject:frame];
	}
	CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay:0.1f];
	id animate = [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO];
	id repeat= [CCRepeatForever actionWithAction:animate];
	[player_img runAction:repeat];
	
    new_player.start_pt = pt;
	new_player.anchorPoint = ccp(0,0);
    new_player.position = new_player.start_pt;
	return new_player;
}

-(PlayerEffectParams*) get_current_params {
    if (temp_params != NULL) {
        return temp_params;
    } else {
        return current_params;
    }
}

-(void) reset {
    position_ = start_pt;
    vx = 0;
    vy = 0;
    rotation_ = 0;
    [self reset_params];
}

-(void) reset_params {
    if (current_params != NULL) {
        [current_params dealloc];
    }
    current_params = [PlayerEffectParams init_with_gravity:DEFAULT_GRAVITY 
                                                  limitvel:DEFAULT_MIN_SPEED + LIMITSPD_INCR
                                                    minvel:DEFAULT_MIN_SPEED 
                                                      time:-1];
}

-(void) update {
    float vel = sqrtf(powf(vx, 2) + powf(vy, 2));
    float tar = current_params.cur_min_speed;
    
    if (current_params.cur_min_speed < MIN_SPEED_MAX && temp_params == NULL && (vel >= tar || ABS(tar-vel) < 0.5)  ) {
        
        current_params.cur_min_speed += ACCEL_INCR;
        current_params.cur_limit_speed = current_params.cur_min_speed + LIMITSPD_INCR;
        
        NSLog(@"accel:%f",current_params.cur_min_speed);
    }
}

-(CGRect) get_hit_rect {
    return CGRectMake([self position].x-IMGHEI/2,  [self position].y, IMGWID, IMGHEI);
    //return [self boundingBox];
}

@end
