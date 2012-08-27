#import "GameMain.h"

@implementation GameMain

#define USE_BG NO
#define ENABLE_BG_PARTICLES YES


/**
 TODO --
 -Level editor:
 add new items to level editor
 
 -Game fixes:
 floating particle effect
 
 -breakable walls
 -spike vine
 -cave spike
 -bridge island
 
 hot tomale item pickup
 implement manual zoom
 start/end area new graphics
 sun in background
 **/

+(void)main {
    [[CCDirector sharedDirector] setDisplayFPS:NO];
    //[[CCDirector sharedDirector] runWithScene:[CoverPage scene]];
    [[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with:@"cave_test"]];
    
}

+(BOOL)GET_USE_BG {
    return USE_BG;
}

+(BOOL)GET_ENABLE_BG_PARTICLES {
    return ENABLE_BG_PARTICLES;
}

@end
