#import "GameObject.h"
#import "CaveWall.h"

@interface IslandFill : CaveWall {
    BOOL has_lazy_setrenderord;
}

+(IslandFill*)cons_x:(float)x y:(float)y width:(float)width height:(float)height;

@end
