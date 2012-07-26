#import "CCLayer.h"
#import "Resource.h"
@class GameEngineLayer;

@interface UILayer : CCLayer {
    GameEngineLayer* game_engine_layer;
    
    CCLabelTTF *count_disp;
    CCMenu *ingame_ui;
    
    CCLayer *pauselayer;
}

+(UILayer*)init_with_gamelayer:(GameEngineLayer*)g;

@end
