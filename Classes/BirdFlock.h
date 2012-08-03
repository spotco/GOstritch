#import "GameObject.h"

@interface BirdFlock : GameObject {
    NSMutableArray *birds;
}

+(BirdFlock*)init_x:(float)x y:(float)y;

@end
