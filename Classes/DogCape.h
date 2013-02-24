#import "GameObject.h"
#import "DogCapeEffect.h"

@interface DogCape : GameObject {
    BOOL anim_toggle;
}

+(DogCape*)cons_x:(float)x y:(float)y;

@end
