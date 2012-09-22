#import "GameMain.h"
#import "PolyLib.h"

@implementation GameMain

#define USE_BG NO
#define ENABLE_BG_PARTICLES YES
#define DRAW_HITBOX NO


/**
 TODO --
 -swinging vine
 -bridge island
 -implement island filler in level editor
 -minion robot with beserk
 -dog redesign upload
 **/

+(void)main {
    [[CCDirector sharedDirector] setDisplayFPS:NO];
    //[[CCDirector sharedDirector] runWithScene:[CoverPage scene]];
    [[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with:@"camera_test"]];
}

+(BOOL)GET_USE_BG {
    return USE_BG;
}

+(BOOL)GET_ENABLE_BG_PARTICLES {
    return ENABLE_BG_PARTICLES;
}

+(BOOL)GET_DRAW_HITBOX {
    return DRAW_HITBOX;
}
@end
