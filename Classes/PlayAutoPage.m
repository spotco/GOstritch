#import "PlayAutoPage.h"

@implementation PlayAutoPage

-(void)cons_starting_at:(CGPoint)tstart {
    [super cons_starting_at:tstart];
    
    CCSprite *logo = [CCSprite spriteWithTexture:[Resource get_tex:TEX_MENU_LOGO]];
    [logo setPosition:ccp([Common SCREEN].width/2,[Common SCREEN].height*0.85)];
    [self addChild:logo];
}

@end
