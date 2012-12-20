#import "PlayAutoPage.h"

@implementation PlayAutoPage

-(void)cons_starting_at:(CGPoint)tstart {
    [super cons_starting_at:tstart];
    
    CCSprite *logo = [CCSprite spriteWithTexture:[Resource get_tex:TEX_MENU_LOGO]];
    [logo setPosition:ccp([Common SCREEN].width/2,[Common SCREEN].height*0.85)];
    [self addChild:logo];
    
    MainMenuPageZoomButton* playbtn = [MainMenuPageZoomButton cons_texture:[Resource get_tex:TEX_MENU_PLAYBUTTON] 
                                                                        at:ccp([Common SCREEN].width/2,[Common SCREEN].height*0.3) 
                                                                        fn:[Common cons_callback:self sel:@selector(play)]];
    [self add_interactive_item:playbtn];
    
    MainMenuPageZoomButton* statsbtn = [MainMenuPageZoomButton cons_texture:[Resource get_tex:TEX_MENU_STATS_BUTTON] 
                                                                        at:ccp([Common SCREEN].width*0.87,[Common SCREEN].height*0.9) 
                                                                        fn:[Common cons_callback:self sel:@selector(stats)]];
    [self add_interactive_item:statsbtn];
    
    MainMenuPageZoomButton* settingsbtn = [MainMenuPageZoomButton cons_texture:[Resource get_tex:TEX_MENU_SETTINGS_BUTTON] 
                                                                         at:ccp([Common SCREEN].width*0.1,[Common SCREEN].height*0.9) 
                                                                         fn:[Common cons_callback:self sel:@selector(settings)]];
    [self add_interactive_item:settingsbtn];
    
}

-(void)play {
    [GEventDispatcher push_event:[GEvent init_type:GEventType_MENU_PLAY_AUTOLEVEL_MODE]];
}

-(void)stats {
    NSLog(@"stats");
}

-(void)settings {
    NSLog(@"settings");
}

-(void)touch_down_at:(CGPoint)pt {
    [super touch_down_at:pt];
}

-(void)touch_move_at:(CGPoint)pt {
    [super touch_move_at:pt];
}

-(void)touch_up_at:(CGPoint)pt {
    [super touch_up_at:pt];
}

@end
