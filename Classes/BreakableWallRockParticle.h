#import "Particle.h"

@interface BreakableWallRockParticle : Particle {
    int ct;
}

+(BreakableWallRockParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;

@end
