#import "GameMain.h"

@implementation GameMain

+(void)main {
    [[CCDirector sharedDirector] setDisplayFPS:NO];
    [[CCDirector sharedDirector] runWithScene:[CoverPage scene]];
}

@end
