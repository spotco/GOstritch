#import "PlayerEffectParams.h"

@interface FireworksParticleA : Particle {
    int ct;
}

+(FireworksParticleA*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy ct:(int)ct;

@end
