#import "CCLayer.h"
#import "Resource.h"
#import "GameEngineLayer.h"
#import "GameStartAnim.h"

@interface UILayer : CCLayer {
    GameEngineLayer* game_engine_layer;
    
    CCLabelTTF *count_disp;
    CCMenu *ingame_ui;
    
    CCLayer *pauselayer;
    CCLayer *game_end_menu_layer;
    
    
    GameEngineLayerMode prevmode;
    
    UIAnim *curanim;
}

+(UILayer*)init_with_gamelayer:(GameEngineLayer*)g;

-(void)start_initial_anim;

@end
