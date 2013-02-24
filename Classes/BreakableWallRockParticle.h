#import "Particle.h"

@interface BreakableWallRockParticle : Particle {
    int ct;
}

+(BreakableWallRockParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
-(void)cons_vx:(float)tvx vy:(float)tvy ;

@end
