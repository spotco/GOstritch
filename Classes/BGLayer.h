#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import "BackgroundObject.h"
#import "CloudGenerator.h"
@class GameEngineLayer;


@interface BGLayer : CCLayer {
	NSMutableArray *bg_elements;
    GameEngineLayer* game_engine_layer;
}

+(BGLayer*)init_with_gamelayer:(GameEngineLayer*)g;
+(NSMutableArray*) loadBg;
@end
