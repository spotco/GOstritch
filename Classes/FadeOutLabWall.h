#import "CaveWall.h"
#import "GEventDispatcher.h"

@interface FadeOutLabWall : GameObject <GEventListener> {
    int tar_opacity;
}

+(FadeOutLabWall*)init_x:(float)x y:(float)y width:(float)width height:(float)height;

@end
