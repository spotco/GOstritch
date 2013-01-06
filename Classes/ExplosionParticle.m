#import "ExplosionParticle.h"
#import "GameEngineLayer.h"

@implementation ExplosionParticle

static const float TIME = 30.0;
static const float MINSCALE = 1;
static const float MAXSCALE = 10;

+(ExplosionParticle*)init_x:(float)x y:(float)y {
    return [[ExplosionParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]] cons_x:x y:y];
}


-(id)cons_x:(float)x y:(float)y {
    [self setPosition:ccp(x,y)];
    [self setColor:ccc3(255, 165, 0)];
    ct = TIME;
    [self setScale:MINSCALE];
    
    return self;
}

-(void)update:(GameEngineLayer*)g{
    ct--;
    [self setScale:(1-ct/TIME)*(MAXSCALE-MINSCALE)+MINSCALE];
    [self setOpacity:(int)(55*(ct/TIME))+200];
}

-(BOOL)should_remove {
    return ct <= 0;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

@end


@implementation RelativePositionExplosionParticle

+(RelativePositionExplosionParticle*) init_x:(float)x y:(float)y player:(CGPoint)player{
    return [[RelativePositionExplosionParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]] cons_x:x y:y player:player];
}

-(id)cons_x:(float)x y:(float)y player:(CGPoint)player {
    rel_pos = ccp(x-player.x,y-player.y);
    [super cons_x:x y:y];
    return self;
}

-(void)update:(GameEngineLayer*)g{
    [self setPosition:ccp(rel_pos.x+g.player.position.x,position_.y)];
    [super update:g];
}

@end
