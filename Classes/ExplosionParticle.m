#import "ExplosionParticle.h"
#import "GameEngineLayer.h"

@implementation ExplosionParticle

static const float TIME = 30.0;
static const float MINSCALE = 0.5;
static const float MAXSCALE = 0.5;

-(CCAction*)init_anim:(NSArray*)a speed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_EXPLOSION];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_EXPLOSION idname:k]]];
    return  [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:NO];
}

+(ExplosionParticle*)init_x:(float)x y:(float)y {
    return [[ExplosionParticle node] cons_x:x y:y];
}


-(id)cons_x:(float)x y:(float)y {
    CCAction* anim = [self init_anim:[NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7", nil] speed:0.075];
    [self runAction:anim];
    
    [self setPosition:ccp(x,y)];
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
    return [[RelativePositionExplosionParticle node] cons_x:x y:y player:player];
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
