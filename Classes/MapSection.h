#import "MapLoader.h"

@interface MapSection : NSObject {
    GameMap map;
}
@property(readwrite,assign) GameMap map;
+(MapSection*)init_from_name:(NSString*)name;
@end