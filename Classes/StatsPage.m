#import "StatsPage.h"

@implementation StatsPage

-(void)cons_starting_at:(CGPoint)tstart {
    [super cons_starting_at:tstart];
    CCSprite *logo = [CCSprite spriteWithTexture:[Resource get_tex:TEX_MENU_STATS_TITLE]];
    [logo setPosition:ccp([Common SCREEN].width/2,[Common SCREEN].height*0.85)];
    [self addChild:logo];
}

@end
