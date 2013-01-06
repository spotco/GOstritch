#import "Particle.h"

@interface ExplosionParticle : Particle {
    int ct;
}
+(ExplosionParticle*)init_x:(float)x y:(float)y;
-(id)cons_x:(float)x y:(float)y;
@end


@interface RelativePositionExplosionParticle : ExplosionParticle {
    CGPoint rel_pos;
}
+(RelativePositionExplosionParticle*)init_x:(float)x y:(float)y player:(CGPoint)player;
@end