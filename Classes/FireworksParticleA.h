#import "PlayerEffectParams.h"

@interface FireworksParticleA : Particle {
    int ct;
}

+(FireworksParticleA*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy ct:(int)ct;

@end
