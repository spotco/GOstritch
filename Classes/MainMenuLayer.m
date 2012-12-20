#import "MainMenuLayer.h"

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

@implementation MainMenuPageStaticLayer

#define IND_HEI 15.0
#define IND_PAD 20.0
#define IND_SEL_SCALE 2.0

+(MainMenuPageStaticLayer*)cons {
    MainMenuPageStaticLayer* l = [MainMenuPageStaticLayer node];
    [GEventDispatcher add_listener:l];

    return l;
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_MENU_TICK) {
        
        if (indicator_pts == NULL) {
            [self lazy_cons_totalpages:e.i2];
        }
        [self set_ind:e.i1];
    }
}

-(void)set_ind:(int)tar {
    for(int i = 0; i < [indicator_pts count]; i++) {
        CCSprite *ei = [indicator_pts objectAtIndex:i];
        ei.scale = tar == i ? IND_SEL_SCALE : 1.0;
    }
}

-(void)lazy_cons_totalpages:(int)t {
    indicator_pts = [[NSMutableArray alloc] init];
    int below,above;
    float belowx,abovex;
    if (t%2==0) {
        below = t/2;
        above = t/2+1;
        belowx = [Common SCREEN].width/2+IND_PAD/2;
        abovex = [Common SCREEN].width/2-IND_PAD/2;
        
    } else {
        [indicator_pts addObject:[self cons_dot:ccp([Common SCREEN].width/2,IND_HEI)]];
        below = t/2-1;
        above = t/2+1;
        belowx = [Common SCREEN].width/2;
        abovex = [Common SCREEN].width/2;
    }
    
    while(below >= 0) {
        belowx-=IND_PAD;
        [indicator_pts insertObject:[self cons_dot:ccp(belowx,IND_HEI)] atIndex:0];
        below--;
    }
    
    while(above < t) {
        abovex+=IND_PAD;
        [indicator_pts insertObject:[self cons_dot:ccp(abovex,IND_HEI)] atIndex:[indicator_pts count]];
        above++;
    }
    
}

-(CCSprite*)cons_dot:(CGPoint)pt {
    CCSprite *dot = [CCSprite spriteWithTexture:[Resource get_tex:TEX_MENU_TEX_SELECTDOT_SMALL]];
    [dot setPosition:pt];
    [self addChild:dot];
    return dot;
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:NO];
    [indicator_pts removeAllObjects];
    [indicator_pts release];
    [super dealloc];
}
@end


@implementation MainMenuLayer

#define BGWID 960.0
#define BGHEI 480.0
#define TOUCHSCROLL_SCALE 1
#define SNAPTO_STAY_PCT 0.15
#define SNAPTO_SPD 5

+(CCScene*)scene {
    CCScene* sc = [CCScene node];
    [sc addChild:[MainMenuBGLayer cons]];
    [sc addChild:[MainMenuLayer node]];
    [sc addChild:[MainMenuPageStaticLayer cons]];
    return sc;
}

-(void)add_pages {
    [menu_pages addObject:[PlayAutoPage node]];
    [menu_pages addObject:[PlayAutoPage node]];
    [menu_pages addObject:[PlayAutoPage node]];
}

-(id)init {
    self = [super init];
    [GEventDispatcher add_listener:self];
    menu_pages = [[NSMutableArray alloc] init];
    [self add_pages];
    for(int i = 0; i < [menu_pages count]; i++) {
        MainMenuPage* c = [menu_pages objectAtIndex:i];
        [c cons_starting_at:ccp([Common SCREEN].width * i,c.position.y)];
        [self addChild:c];
    }
    last = ccp(-1,-1);
    cpos.z = 1;
    [self set_cur:1];
    [self update_camera];
    self.isTouchEnabled = YES;
    
    [self schedule:@selector(update) interval:1.0/60];
    return self;
}

-(void)set_cur:(int)tar {
    cur_page = tar;
    cpos.x = tar*[Common SCREEN].width;
}

-(void)update {
    [self update_state];
    
    if (cstate == MainMenuState_TouchDown) {
        cpos.x += dp.x;
        dp = CGPointZero;
        
    } else if (cstate == MainMenuState_Snapping) {
        float dist = ABS([self get_snapto]-cpos.x);
        float dx = [Common sig:[self get_snapto]-cpos.x]*(dist/SNAPTO_SPD);
        cpos.x += dx;
        
    } else if (cstate == MainMenuState_None) {
        cpos.x = [self get_snapto];
        
    }

    
    [self update_camera];
    [self calculate_bg_scroll];
    [GEventDispatcher dispatch_events];
}

-(void)update_state {
    if ([self is_touch_down] && !killdrag) {
        cstate = MainMenuState_TouchDown;
    } else if (ABS([self get_snapto]-cpos.x)>10) {
        cstate = MainMenuState_Snapping;
    } else {
        cstate = MainMenuState_None;
    }
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_MENU_TOUCHUP) {
        MainMenuPage *tar = [menu_pages objectAtIndex:cur_page];
        [tar touch_up_at:ccp(e.pt.x-[self get_snapto], e.pt.y)];
        
    } else if (e.type == GEventType_MENU_TOUCHDOWN) {
        MainMenuPage *tar = [menu_pages objectAtIndex:cur_page];
        [tar touch_down_at:ccp(e.pt.x-[self get_snapto], e.pt.y)];
        
    } else if (e.type == GEventType_MENU_TOUCHMOVE) {
        MainMenuPage *tar = [menu_pages objectAtIndex:cur_page];
        [tar touch_move_at:ccp(e.pt.x-[self get_snapto], e.pt.y)];
        
    } else if (e.type == GEventType_MENU_CANCELDRAG) {
        killdrag = true;
        
    } else if (e.type == GEventType_MENU_PLAY_AUTOLEVEL_MODE) {
        [self exit];
        [GameMain start_game_autolevel];
    }
}


-(float)get_snapto {
    return cur_page*[Common SCREEN].width;
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
    [GEventDispatcher push_event:[[[GEvent init_type:GEventType_MENU_TICK] add_pt:ccp(x,y)] add_i1:cur_page i2:[menu_pages count]]];
}

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {    
    CGPoint touch;for (UITouch *t in pTouches) {touch = [t locationInView:[t view]];}
    last = touch;
    [GEventDispatcher push_event:[[GEvent init_type:GEventType_MENU_TOUCHDOWN] add_pt:ccp(touch.x+cpos.x, [Common SCREEN].height - touch.y+cpos.y)]];
    killdrag = false;
}

-(void)ccTouchesMoved:(NSSet *)pTouches withEvent:(UIEvent *)event {
    CGPoint touch;for (UITouch *t in pTouches) {touch = [t locationInView:[t view]];}
    dp = ccp((last.x-touch.x)*TOUCHSCROLL_SCALE,-(last.y-touch.y)*TOUCHSCROLL_SCALE);
    last = touch;
    [GEventDispatcher push_event:[[GEvent init_type:GEventType_MENU_TOUCHMOVE] add_pt:ccp(touch.x+cpos.x, [Common SCREEN].height - touch.y+cpos.y)]];
}

-(void) ccTouchesEnded:(NSSet*)pTouches withEvent:(UIEvent*)event {
    CGPoint touch; for (UITouch *t in pTouches) {touch = [t locationInView:[t view]];}
    last = ccp(-1,-1);
    dp = CGPointZero;
    [self calc_new_cur_page];
    [GEventDispatcher push_event:[[GEvent init_type:GEventType_MENU_TOUCHUP] add_pt:ccp(touch.x+cpos.x, [Common SCREEN].height - touch.y+cpos.y)]];
}

-(void)calc_new_cur_page {
    float curmin = cur_page*[Common SCREEN].width - [Common SCREEN].width*(SNAPTO_STAY_PCT);
    float curmax = cur_page*[Common SCREEN].width + [Common SCREEN].width*(SNAPTO_STAY_PCT);
    if (cpos.x > 0 && cpos.x < curmin) {
        cur_page--;
    } else if (cpos.x < ([menu_pages count]-1)*[Common SCREEN].width && cpos.x > curmax) {
        cur_page++;
    }
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
}

-(void)dealloc {
    NSLog(@"menu dealloc");
    [self removeAllChildrenWithCleanup:NO];
    [menu_pages removeAllObjects];
    [menu_pages release];
    [super dealloc];
}

@end
