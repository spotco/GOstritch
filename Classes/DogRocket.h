#import "GameObject.h"
#import "DogRocketEffect.h"

@interface DogRocket : GameObject {
    BOOL anim_toggle;
}

+(DogRocket*)cons_x:(float)x y:(float)y;

@end
