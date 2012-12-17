#import "Particle.h"

@interface DazedParticle : Particle {
    int ct;
    float cx,cy,theta;
}

+(DazedParticle*)init_x:(float)x y:(float)y theta:(float)theta time:(int)time;
+(void)init_effect:(GameEngineLayer*)g x:(float)x y:(float)y time:(int)time;

@end
