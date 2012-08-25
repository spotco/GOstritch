#import "GameObject.h"
#import "JumpPadParticle.h"

@interface JumpPad : GameObject {
    id anim;
    Vec3D* normal_vec;
    int recharge_ct;
}

+(JumpPad*)init_x:(float)x y:(float)y dirvec:(Vec3D*)vec;

@end
