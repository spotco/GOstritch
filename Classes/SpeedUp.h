#import "GameObject.h"
#import "JumpPadParticle.h"

@interface SpeedUp : GameObject {
    id anim;
    Vec3D* normal_vec;
}

+(SpeedUp*)init_x:(float)x y:(float)y dirvec:(Vec3D *)vec;

@end
