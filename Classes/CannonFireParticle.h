#import "Particle.h"

@interface CannonFireParticle : Particle {
    int ct;
}

+(CannonFireParticle*)cons_x:(float)x y:(float)y;

@end
