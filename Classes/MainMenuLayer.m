#import "MainMenuLayer.h"

@implementation MainMenuBGLayer

+(MainMenuBGLayer*)initialize {
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


@implementation MainMenuLayer

#define TOUCHSCROLL_SCALE 2
#define BGWID 960.0
#define BGHEI 480.0

+(CCScene*)scene {
    CCScene* sc = [CCScene node];
    [sc addChild:[MainMenuBGLayer initialize]];
    [sc addChild:[MainMenuLayer node]];
    return sc;
}

-(void)add_pages {
    [menu_pages addObject:[PlayAutoPage node]];
    [menu_pages addObject:[PlayAutoPage node]];
    [menu_pages addObject:[PlayAutoPage node]];
    [menu_pages addObject:[PlayAutoPage node]];
}

-(id)init {
    self = [super init];
    
    menu_pages = [[NSMutableArray alloc] init];
    [self add_pages];
    for(int i = 0; i < [menu_pages count]; i++) {
        MainMenuPage* c = [menu_pages objectAtIndex:i];
        [c initialize_starting_at:ccp([Common SCREEN].width * i,c.position.y)];
        [self addChild:c];
    }
    last = ccp(-1,-1);
    cpos.z = 1;
    [self update_camera];
    self.isTouchEnabled = YES;
    
    [self schedule:@selector(update) interval:1.0/60];
    return self;
}

-(void)update {
    cpos.x += dp.x;
    cpos.x=cpos.x<0?0:cpos.x;
    cpos.x=cpos.x>([menu_pages count]-1)*[Common SCREEN].width?([menu_pages count]-1)*[Common SCREEN].width:cpos.x;
    
    dp = CGPointZero;
    [self update_camera];
    [self calculate_bg_scroll];
    [GEventDispatcher dispatch_events];
}

-(void)calculate_bg_scroll {
    float x = -cpos.x;
    float y = -cpos.y;
    float widscale = [menu_pages count]>1?1.0/([menu_pages count]-1):1;
    x*=widscale;
    
    x = x>0?0:x;
    x = x < -BGWID+[Common SCREEN].width?-BGWID+[Common SCREEN].width:x;
    
    y = y>0?0:y;
    y = y < -BGHEI+[Common SCREEN].height?-BGHEI+[Common SCREEN].height:y;
    [GEventDispatcher push_event:[[GEvent init_type:GEventType_MENU_TICK] add_pt:ccp(x,y)]];
}

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {    
    CGPoint touch;for (UITouch *t in pTouches) {touch = [t locationInView:[t view]];}
    last = touch;
}

-(void)ccTouchesMoved:(NSSet *)pTouches withEvent:(UIEvent *)event {
    CGPoint touch;for (UITouch *t in pTouches) {touch = [t locationInView:[t view]];}
    dp = ccp((last.x-touch.x)*TOUCHSCROLL_SCALE,-(last.y-touch.y)*TOUCHSCROLL_SCALE);
    last = touch;
}

-(void) ccTouchesEnded:(NSSet*)pTouches withEvent:(UIEvent*)event {
    CGPoint touch; for (UITouch *t in pTouches) {touch = [t locationInView:[t view]];}
    last = ccp(-1,-1);
    dp = CGPointZero;
}

-(BOOL)is_touch_down {
    return !CGPointEqualToPoint(last, ccp(-1,-1));
}

-(void)update_camera {
    [self.camera setEyeX:cpos.x eyeY:cpos.y eyeZ:cpos.z];
    [self.camera setCenterX:cpos.x centerY:cpos.y centerZ:0];
}

-(void)exit {
    [GEventDispatcher remove_all_listeners];
    NSLog(@"menu exit, should dealloc");
}

-(void)dealloc {
    NSLog(@"menu dealloc");
    [self removeAllChildrenWithCleanup:NO];
    [menu_pages removeAllObjects];
    [menu_pages release];
    [super dealloc];
}

@end
