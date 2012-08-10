#import "GameMain.h"

@implementation GameMain

#define USE_BG NO

+(void)main {
    [[CCDirector sharedDirector] setDisplayFPS:NO];
    //[[CCDirector sharedDirector] runWithScene:[CoverPage scene]];
    [[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with:@"test2"]];
}

+(BOOL)GET_USE_BG {
    return USE_BG;
}

@end
