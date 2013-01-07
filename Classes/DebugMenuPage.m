#import "DebugMenuPage.h"
#import "FileCache.h"

@implementation DebugMenuPage

-(void)cons_starting_at:(CGPoint)tstart {
    [super cons_starting_at:tstart];
    
    [self addChild:[Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.85] 
                                    color:ccc3(0, 0, 0) 
                                 fontsize:50 
                                      str:@"Debug Menu"]];
    
    
    [self add_interactive_item:[MainMenuPageZoomButton cons_spr:[CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"body"]]
                                                            at:[Common screen_pctwid:0.2 pcthei:0.5] 
                                                             fn:[Common cons_callback:self sel:@selector(play_boss_level)]]];
    
    [self add_interactive_item:[MainMenuPageZoomButton cons_spr:[CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROBOT] rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"]]
                                                             at:[Common screen_pctwid:0.7 pcthei:0.5] 
                                                             fn:[Common cons_callback:self sel:@selector(play_test_level)]]];
    
    [self add_interactive_item:[MainMenuPageZoomButton cons_spr:[CCSprite spriteWithTexture:[Resource get_tex:TEX_SWINGVINE_BASE]]
                                                             at:[Common screen_pctwid:0.5 pcthei:0.2] 
                                                             fn:[Common cons_callback:self sel:@selector(play_swingtest_level)]]];
}

-(void)play_boss_level {
    [GEventDispatcher push_event:[[GEvent init_type:GEventType_MENU_PLAY_TESTLEVEL_MODE] add_i1:0 i2:0]];
}

-(void)play_test_level {
    [GEventDispatcher push_event:[[GEvent init_type:GEventType_MENU_PLAY_TESTLEVEL_MODE] add_i1:1 i2:1]];
}

-(void)play_swingtest_level {
    [GEventDispatcher push_event:[[GEvent init_type:GEventType_MENU_PLAY_TESTLEVEL_MODE] add_i1:2 i2:2]];
}

@end
