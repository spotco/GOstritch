#import "LineIsland.h"

@interface CaveLineIsland : LineIsland

+(CaveLineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land;

@end
