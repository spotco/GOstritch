#import "Particle.h"

@interface CannonFireParticle : Particle {
    int ct;
}

+(CannonFireParticle*)init_x:(float)x y:(float)y;

@end
