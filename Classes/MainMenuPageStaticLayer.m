#import "MainMenuPageStaticLayer.h"
#import "MainMenuLayer.h"

@interface MenuDogIcon : CCSprite
@end
@implementation MenuDogIcon
-(void)setScale:(float)scale {
    [self setScaleX:-scale*0.5];
    [self setScaleY:scale*0.5];
}
@end

@implementation MainMenuPageStaticLayer

#define IND_HEI 15.0
#define IND_PAD 20.0
#define IND_SEL_SCALE 2.0
#define CHANGE_CUR_CHAR_ANIM_SIZE 1.2
#define CHANGE_CUR_CHAR_ANIM_INCR 0.05

+(MainMenuPageStaticLayer*)cons {
    MainMenuPageStaticLayer* l = [MainMenuPageStaticLayer node];
    [GEventDispatcher add_listener:l];
    
    return l;
}

-(id)init {
    interactive_items = [[NSMutableArray alloc] init];
    return [super init];
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_MENU_TICK) {
        if (indicator_pts == NULL) {
            [self lazy_cons_totalpages:e.i2];
        }
        [self set_ind:e.i1];
        
        if (!ccbtn.pressed && ccbtn.scale > 1.0) {
            ccbtn.scale -= CHANGE_CUR_CHAR_ANIM_INCR;
        }
        
    } else if (e.type == GEventType_MENU_TOUCHDOWN) {
        for (MainMenuPageInteractiveItem *i in interactive_items) {
            [i touch_down_at:ccp(e.pt.x-e.f1,e.pt.y-e.f2)];
        }
        
    } else if (e.type == GEventType_MENU_TOUCHMOVE) {
        for (MainMenuPageInteractiveItem *i in interactive_items) {
            [i touch_move_at:ccp(e.pt.x-e.f1,e.pt.y-e.f2)];
        }
        
    } else if (e.type == GEventType_MENU_TOUCHUP) {
        for (MainMenuPageInteractiveItem *i in interactive_items) {
            [i touch_up_at:ccp(e.pt.x-e.f1,e.pt.y-e.f2)];
        }
        
    } else if (e.type == GEventType_CHANGE_CURRENT_DOG) {
        [self update_animp];
        
    }
}

-(void)set_ind:(int)tar {
    for(int i = 0; i < [indicator_pts count]; i++) {
        CCSprite *ei = [indicator_pts objectAtIndex:i];
        ei.scale = tar == i ? IND_SEL_SCALE : 1.0;
    }
}

-(void)update_animp {
    if (![cur_disp_char isEqualToString:[Player get_character]]) {
        [cur_disp_char release];
        cur_disp_char = [[Player get_character] retain];
        [animp stopAction:cur_char_anim];
        [cur_char_anim dealloc];
        cur_char_anim = [self cons_run_anim:[Player get_character]];
        [animp runAction:cur_char_anim];
        
        [ccbtn setScale:CHANGE_CUR_CHAR_ANIM_SIZE];
    }
}

-(void)cons_cur_char_sel {
    ccbtn = [MainMenuPageZoomButton 
     cons_texture:[Resource get_tex:TEX_MENU_CURRENT_CHARACTER] 
     at:ccp([Common SCREEN].width*0.95,[Common SCREEN].height*0.075) 
     fn:[Common cons_callback:self sel:@selector(goto_dog_mode)]];
    [self addChild:ccbtn];
    
    
    cur_disp_char = [[Player get_character] retain];
    animp = [MenuDogIcon node];
    [animp setScale:1.0];
    
    [animp stopAction:cur_char_anim];
    [cur_char_anim release];
    
    cur_char_anim = [self cons_run_anim:[Player get_character]];
    [animp runAction:cur_char_anim];
    [ccbtn addChild:animp];
    
    [interactive_items addObject:ccbtn];
}

-(CCAction*)cons_run_anim:(NSString*)tar {
	CCTexture2D *texture = [Resource get_tex:tar];
	NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"run_0"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"run_1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"run_2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"run_3"]]];
	return [[Common make_anim_frames:animFrames speed:0.1] retain];
}

-(void)goto_dog_mode {
    [GEventDispatcher push_event:[[GEvent cons_type:GEventType_MENU_GOTO_PAGE] add_i1:MENU_DOG_MODE_PAGE_ID i2:0]];
}

-(void)lazy_cons_totalpages:(int)t {
    [self cons_cur_char_sel];
    
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
    [animp stopAction:cur_char_anim];
    [cur_char_anim release];
    [indicator_pts removeAllObjects];
    [indicator_pts release];
    [interactive_items removeAllObjects];
    [interactive_items release];
    [super dealloc];
}
@end