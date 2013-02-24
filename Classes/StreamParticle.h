#import "Particle.h"

@interface StreamParticle : Particle {
    int ct;
}

#define STREAMPARTICLE_CT_DEFAULT 40.0

@property(readwrite,assign) int ct;

+(StreamParticle*)cons_x:(float)x y:(float)y;
+(StreamParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
-(void)cons;

@end
