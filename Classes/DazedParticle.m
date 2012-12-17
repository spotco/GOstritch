#import "DazedParticle.h"
#import "GameEngineLayer.h"

@implementation DazedParticle

+(DazedParticle*)init_x:(float)x y:(float)y theta:(float)theta time:(int)time {
    return [[DazedParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]] initialize_x:x y:y t:theta time:time];
}

+(void)init_effect:(GameEngineLayer*)g x:(float)x y:(float)y time:(int)time {
    [g add_particle:[DazedParticle init_x:x y:y theta:0 time:time]];
    [g add_particle:[DazedParticle init_x:x y:y theta:M_PI/2 time:time]];
    [g add_particle:[DazedParticle init_x:x y:y theta:M_PI time:time]];
    [g add_particle:[DazedParticle init_x:x y:y theta:M_PI*(1.5) time:time]];
}

-(DazedParticle*)initialize_x:(float)x y:(float)y t:(float)t time:(int)time{
    [self setPosition:ccp(x,y)];
    [self setScale:0.6];
    [self setColor:ccc3(255, 255, 0)];
    cx = x;
    cy = y;
    ct = time;
    theta = t;
    return self;
}

#define scalex 40
#define scaley 10
#define speed 0.2

-(void)update:(GameEngineLayer *)g {
    ct--;
    theta+=speed;
    [self setPosition:ccp(cos(theta)*scalex+cx,sin(theta)*scaley+cy)];
    
    
}

-(BOOL)should_remove {
    return ct<=0;
}

-(int)get_render_ord { 
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD]+1; 
}

@end
