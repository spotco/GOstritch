#import "DazedParticle.h"
#import "GameEngineLayer.h"

@implementation DazedParticle

+(DazedParticle*)cons_x:(float)x y:(float)y theta:(float)theta time:(int)time tracking:(id<PhysicsObject>)t {
    return [[DazedParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]] cons_x:x y:y t:theta time:time tracking:t];
}

+(void)cons_effect:(GameEngineLayer *)g tar:(id<PhysicsObject>)tar time:(int)time {
    float x = tar.position.x;
    float y = tar.position.y+60*(tar.current_island != NULL?tar.last_ndir:1);
    
    [g add_particle:[DazedParticle cons_x:x y:y theta:0 time:time tracking:tar]];
    [g add_particle:[DazedParticle cons_x:x y:y theta:M_PI/2 time:time tracking:tar]];
    [g add_particle:[DazedParticle cons_x:x y:y theta:M_PI time:time tracking:tar]];
    [g add_particle:[DazedParticle cons_x:x y:y theta:M_PI*1.5 time:time tracking:tar]];
    
}

-(DazedParticle*)cons_x:(float)x y:(float)y t:(float)t time:(int)time tracking:(id<PhysicsObject>)tracking {
    [self setPosition:ccp(x,y)];
    [self setScale:0.6];
    [self setColor:ccc3(255, 255, 0)];
    cx = x;
    cy = y;
    ct = time;
    theta = t;
    tar = tracking;
    return self;
}

#define scalex 40
#define scaley 10
#define speed 0.2

-(void)update:(GameEngineLayer *)g {
    ct--;
    theta+=speed;
    [self setPosition:ccp(cos(theta)*scalex+cx,sin(theta)*scaley+cy)];
    
    if (tar) {
        cx = tar.position.x;
        cy = tar.position.y+60*(tar.current_island != NULL?tar.last_ndir:1);
    }
    
}

-(BOOL)should_remove {
    return ct<=0;
}

-(int)get_render_ord { 
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD]+1; 
}

@end
