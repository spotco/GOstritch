#import "Particle.h"

@interface DazedParticle : Particle {
    int ct;
    float cx,cy,theta;
    id<PhysicsObject> tar;
}

+(DazedParticle*)cons_x:(float)x y:(float)y theta:(float)theta time:(int)time tracking:(id<PhysicsObject>)t;
+(void)cons_effect:(GameEngineLayer*)g tar:(id<PhysicsObject>)tar time:(int)time;
//+(void)init_effect:(GameEngineLayer*)g x:(float)x y:(float)y time:(int)time;

@end
