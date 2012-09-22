#import "GameObject.h"
#import "BlockerEffect.h"

@interface Blocker : GameObject {
    float width,height;
}

+(Blocker*)init_x:(float)x y:(float)y width:(float)width height:(float)height;

-(void)init_x:(float)x y:(float)y width:(float)pwidth height:(float)pheight;

@end
