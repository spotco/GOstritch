#import "GameObject.h"
#import "BlockerEffect.h"

@interface Blocker : GameObject {
    float width,height;
}

+(Blocker*)init_x:(float)x y:(float)y width:(float)width height:(float)height;

@end
