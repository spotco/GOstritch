#import "StreamParticle.h"

@interface JumpPadParticle : StreamParticle

+(JumpPadParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
-(void)cons_vx:(float)lvx vy:(float)lvy;
-(void)set_color;
@end

@interface RocketLaunchParticle : JumpPadParticle

+(RocketLaunchParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
+(RocketLaunchParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy scale:(float)scale;

@end

@interface RocketExplodeParticle : JumpPadParticle

+(RocketExplodeParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
+(RocketExplodeParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy scale:(float)scale;

@end
