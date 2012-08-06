#import "Particle.h"

@interface StreamParticle : Particle {
    int ct;
}

#define STREAMPARTICLE_CT_DEFAULT 40.0

@property(readwrite,assign) int ct;

+(StreamParticle*)init_x:(float)x y:(float)y;
-(void)initialize;

@end
