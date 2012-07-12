#import "Player.h"

#define IMGWID 60
#define IMGHEI 55

#define IMG_OFFSET_X -31
#define IMG_OFFSET_Y -3


@implementation Player
@synthesize vx,vy;
@synthesize player_img;
@synthesize current_island;
@synthesize up_vec;

+(Player*)init {
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
	
	new_player.anchorPoint = ccp(0,0);
	return new_player;
}

-(CGRect) get_hit_rect {
    return CGRectMake([self position].x-IMGHEI/2,  [self position].y, IMGWID, IMGHEI);
}

@end
