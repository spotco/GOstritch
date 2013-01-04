#import "GameObject.h"

@interface BirdFlock : GameObject {
    NSMutableArray *birds;
    BOOL activated;
}

+(BirdFlock*)init_x:(float)x y:(float)y;

@end
