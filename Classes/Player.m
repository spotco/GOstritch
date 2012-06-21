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

	
	CCTexture2D *texture = [Resource get_tex:@"char1_run1_ss"];
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

-(void) draw {
    [super draw];
    
	glColor4ub(255,0,0,100);
    glLineWidth(7.0f);
    ccDrawLine(ccp(-30,60),ccp(MIN(-30+(touch_count/15)*(50),20),60));
    
	/*glColor4f(0.0,1.0f,0,1.0f);
	ccDrawCircle(ccp(0,10), 10, 0, 10, NO);
	
	CGPoint points[] = { ccp(0,0) };
	glPointSize(3);
	glColor4ub(0,255,255,255);
	ccDrawPoints( points, 1);	*/
}



@end
