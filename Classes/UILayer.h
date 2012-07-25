#import "CCLayer.h"
#import "Resource.h"
@class GameEngineLayer;

@interface UILayer : CCLayer {
    GameEngineLayer* game_engine_layer;
    
    CCSprite *coincount;
    CCSprite *menu;
    CCSprite *pausebutton;
    
}

+(UILayer*)init_with_gamelayer:(GameEngineLayer*)g;

@end
