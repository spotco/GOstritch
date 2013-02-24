#import "MainMenuLayer.h"

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
    [menu_pages addObject:[DogModePage node]];
    [menu_pages addObject:[PlayAutoPage node]];
    [menu_pages addObject:[DebugMenuPage node]];
    [menu_pages addObject:[StatsPage node]];
    [menu_pages addObject:[SettingsPage node]];
}

-(id)init {
    self = [super init];
    
    [AudioManager play:BGMUSIC_MENU1];
    
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
    [self set_cur:MENU_STARTING_PAGE_ID];
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
        
    } else if (e.type == GEventType_MENU_PLAY_TESTLEVEL_MODE) {
        [self exit];
        if (e.i1 == 1) {
            [GameMain start_testlevel];
        } else if (e.i1 == 0) {
            [GameMain start_game_bosstestlevel];
        } else if (e.i2 == 2) {
            [GameMain start_swingtestlevel];
        }
        
    
    } else if (e.type == GEventType_MENU_GOTO_PAGE) {
        cur_page = e.i1;
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
    [GEventDispatcher push_event:[[[GEvent cons_type:GEventType_MENU_TICK] add_pt:ccp(x,y)] add_i1:cur_page i2:[menu_pages count]]];
}

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {    
    CGPoint touch;for (UITouch *t in pTouches) {touch = [t locationInView:[t view]];}
    last = touch;
    [GEventDispatcher push_event:
     [
      [[GEvent cons_type:GEventType_MENU_TOUCHDOWN] 
        add_pt:ccp(touch.x+cpos.x, [Common SCREEN].height - touch.y+cpos.y)]
        add_f1:cpos.x f2:cpos.y]
    ];
    killdrag = false;
}

-(void)ccTouchesMoved:(NSSet *)pTouches withEvent:(UIEvent *)event {
    CGPoint touch;for (UITouch *t in pTouches) {touch = [t locationInView:[t view]];}
    dp = ccp((last.x-touch.x)*TOUCHSCROLL_SCALE,-(last.y-touch.y)*TOUCHSCROLL_SCALE);
    last = touch;
    [GEventDispatcher push_event:
     [
      [[GEvent cons_type:GEventType_MENU_TOUCHMOVE] 
       add_pt:ccp(touch.x+cpos.x, [Common SCREEN].height - touch.y+cpos.y)]
       add_f1:cpos.x f2:cpos.y]
     ];
}

-(void) ccTouchesEnded:(NSSet*)pTouches withEvent:(UIEvent*)event {
    CGPoint touch; for (UITouch *t in pTouches) {touch = [t locationInView:[t view]];}
    last = ccp(-1,-1);
    dp = CGPointZero;
    [self calc_new_cur_page];
    [GEventDispatcher push_event:
     [
      [[GEvent cons_type:GEventType_MENU_TOUCHUP] 
       add_pt:ccp(touch.x+cpos.x, [Common SCREEN].height - touch.y+cpos.y)]
       add_f1:cpos.x f2:cpos.y]
     ];
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
    [self unscheduleAllSelectors];
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:NO];
    [menu_pages removeAllObjects];
    [menu_pages release];
    [super dealloc];
}

@end
