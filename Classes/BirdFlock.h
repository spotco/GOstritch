#import "GameObject.h"

@interface BirdFlock : GameObject {
    id _STAND_ANIM,_FLY_ANIM;
}

+(BirdFlock*)init_x:(float)x y:(float)y;

@end
