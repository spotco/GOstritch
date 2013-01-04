#import "GameObject.h"
#import "FireworksParticleA.h"

@interface CheckPoint : GameObject {
    CCSprite *inactive_img,*active_img;
    BOOL activated;
}

+(CheckPoint*)init_x:(float)x y:(float)y;
-(void)init_img;

@end
