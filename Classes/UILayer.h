#import "CCLayer.h"
#import "Resource.h"
#import "GameEngineLayer.h"
#import "GameStartAnim.h"
#import "UIIngameAnimation.h"
#import "BoneCollectUIAnimation.h"
#import "GEventDispatcher.h"

@interface UILayer : CCLayer <GEventListener> {
    GameEngineLayer* game_engine_layer;
    
    CCLabelTTF *count_disp;
    CCMenu *ingame_ui;
    
    CCLayer *pauselayer;
    CCLayer *game_end_menu_layer;
    
    UIAnim *curanim;
    NSMutableArray* ingame_ui_anims;
}

+(UILayer*)init_with_gamelayer:(GameEngineLayer*)g;

-(void)start_initial_anim;

@end
