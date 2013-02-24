#import "Particle.h"

@interface WaveParticle : Particle {
    float theta,baseline;
    float vtheta;
    int ct;
}

+(WaveParticle*)cons_x:(float)x y:(float)y vx:(float)vx vtheta:(float)vtheta;

@end
