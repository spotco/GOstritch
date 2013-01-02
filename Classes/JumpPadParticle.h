#import "StreamParticle.h"

@interface JumpPadParticle : StreamParticle

+(JumpPadParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
-(void)cons_vx:(float)lvx vy:(float)lvy;
@end

@interface RocketLaunchParticle : JumpPadParticle

+(RocketLaunchParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;

@end
