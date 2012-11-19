#import "MapLoader.h"

@interface MapSection : NSObject {
    GameMap map;
    float offset_x,offset_y;
    
    int debugid;
}

typedef enum {
    MapSection_Position_PAST,
    MapSection_Position_CURRENT,
    MapSection_Position_AHEAD
} MapSection_Position;

@property(readwrite,assign) GameMap map;
+(MapSection*)init_from_name:(NSString*)name;
-(MapSection_Position)get_position_status:(CGPoint)p;
-(void)offset_x:(float)x y:(float)y;
-(int)get_debugid;
@end