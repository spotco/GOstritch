#import "FireworksParticleA.h"
#import "GameEngineLayer.h"

@interface SubFireworksParticleA : Particle {
    int ct;
}
+(SubFireworksParticleA*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
@end

@implementation SubFireworksParticleA
+(SubFireworksParticleA*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    SubFireworksParticleA* p = [SubFireworksParticleA spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    return p;
}
-(void)cons_vx:(float)tvx vy:(float)tvy {
    vx = tvx;
    vy = tvy;
    ct = 15;
    [self setColor:ccc3(251, 232, 52)];
    [self setScale:float_random(0.25, 0.75)];
}
-(void)update:(GameEngineLayer *)g {
    [self setPosition:ccp(position_.x+vx,position_.y+vy)];
    ct--;
    [self setOpacity:((int)(ct/15.0*255))];
}
-(BOOL)should_remove {
    return ct <= 0;
}
@end


@implementation FireworksParticleA

+(FireworksParticleA*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy ct:(int)ct {
    FireworksParticleA* p = [FireworksParticleA spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    p.position = ccp(x,y);
    [p cons_vx:vx vy:vy ct:ct];
    return p;
}

-(void)cons_vx:(float)tvx vy:(float)tvy ct:(int)tct{
    vx = tvx;
    vy = tvy;
    ct = tct;
    [self setColor:ccc3(251, 232, 52)];
}

-(void)update:(GameEngineLayer*)g {
    [self setPosition:ccp(position_.x+vx,position_.y+vy)];
    ct--;
    if (ct == 0) {
        for (float i = 0; i < M_PI * 2; i+= (M_PI*2)/14) {
            [g add_particle:[SubFireworksParticleA cons_x:position_.x y:position_.y vx:cosf(i)*8+float_random(0, 1) vy:sinf(i)*8+float_random(0, 1)]];
        }
    }
}

-(BOOL)should_remove {
    return ct <= 0;
}

@end

