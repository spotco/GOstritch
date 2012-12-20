#import "MainMenuBGLayer.h"

@implementation MainMenuBGLayer
+(MainMenuBGLayer*)cons {
    CCSprite *bg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_MENU_BG]];
    [bg setAnchorPoint:ccp(0,0)];
    MainMenuBGLayer* l = [MainMenuBGLayer node];
    [GEventDispatcher add_listener:l];
    [l addChild:bg];
    return l;
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_MENU_TICK) {
        [self setPosition:e.pt];
    }
}
@end

