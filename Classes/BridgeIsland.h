#import "Island.h"
#import "Resource.h"
#import "Common.h"

@interface BridgeIsland : Island {
    gl_render_obj left,right,center;
}

+(BridgeIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land;

@end
