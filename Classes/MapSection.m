#import "MapSection.h"
#import "AutoLevel.h"

#define DOTMAP @"map"

@implementation MapSection
@synthesize map;
+(MapSection*)init_from_name:(NSString*)name {
    MapSection* m = [[MapSection alloc] init];
    [m initialize:name];
    return m;
}
-(void)initialize:(NSString*)name {
    map = [MapLoader load_map:name oftype:DOTMAP];
    [AutoLevel transform_map:map by_x:-map.connect_pts_x1 by_y:-map.connect_pts_y1];
}
@end