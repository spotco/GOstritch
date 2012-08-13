#import "GameMain.h"

@implementation GameMain

#define USE_BG YES

+(void)main {
    [[CCDirector sharedDirector] setDisplayFPS:YES];
    //[[CCDirector sharedDirector] runWithScene:[CoverPage scene]];
    [[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with:@"item_test"]];
}

+(BOOL)GET_USE_BG {
    return USE_BG;
}

@end
