#import "cocos2d.h"
#import "Resource.h"
#import "BackgroundObject.h"
#import "CloudGenerator.h"
#import "GameEngineLayer.h"
#import "GameMain.h"
#import "GEventDispatcher.h"


@interface BGLayer : CCLayer <GEventListener> {
	NSMutableArray *bg_elements;
    GameEngineLayer* game_engine_layer;
    CCSprite *bgsky,*bghills,*bgclouds,*bgtrees,*bgclosehills;
    
    float lastx,lasty, curx,cury;
}

+(BGLayer*)init_with_gamelayer:(GameEngineLayer*)g;
-(void)set_gameengine:(GameEngineLayer*)ref;

@end
