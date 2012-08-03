#import "BirdFlock.h"

@interface Bird: CCSprite {
    float vx,vy;
    CGPoint initial_pos;
    BOOL flying;
    id _STANDANIM, _FLYANIM;
    id current_anim;
    int fly_ct;
}
@property(readwrite,assign) int fly_ct;
@property(readwrite,assign) float vx,vy;
@property(readwrite,assign) BOOL flying;
-(void)update;
-(void)set_stand:(id)standanim set_fly:(id)flyanim;
-(void)reset;
@end

@implementation Bird
@synthesize vx,vy;
@synthesize flying;
@synthesize fly_ct;
-(void)set_stand:(id)standanim set_fly:(id)flyanim {
    _STANDANIM = standanim;
    _FLYANIM = flyanim;
    current_anim = _STANDANIM;
    [self runAction:_STANDANIM];
    initial_pos = position_;
}
-(void)update {
    [self anim_update];
    if (flying) {
        [self setPosition:ccp(position_.x + vx, position_.y + vy)];
        fly_ct--;
        if (fly_ct <= 0) {
            [self reset];
        }
    }
}
-(void)anim_update {
    if (flying && current_anim != _FLYANIM) {
        [self stopAllActions];
        current_anim = _FLYANIM;
        [self runAction:_FLYANIM];
        
    } else if (!flying && current_anim != _STANDANIM) {
        [self stopAllActions];
        current_anim = _STANDANIM;
        [self runAction:_STANDANIM];
    }
}

-(void)reset {
    [self setPosition:initial_pos];
    flying = NO;
    [self stopAllActions];
    [self runAction:_STANDANIM];
}
-(void)dealloc {
    [self stopAllActions];
    [_STANDANIM dealloc];
    [_FLYANIM dealloc];
    [super dealloc];
}
@end

@implementation BirdFlock

+(BirdFlock*)init_x:(float)x y:(float)y {
    BirdFlock* b = [BirdFlock node];
    b.position = ccp(x,y);
    [b init_birds];
    b.active = YES;
    return b;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ISLAND_ORD];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-200 y1:[self position].y-30 wid:400 hei:200];
}

-(GameObjectReturnCode)update:(Player*)player g:(GameEngineLayer *)g {
    for (Bird *i in birds) {
        [i update];
    }
    
    if (!active) {
        return GameObjectReturnCode_NONE;
    }
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [self activate_birds];
        [self set_active:NO];
    }
    return GameObjectReturnCode_NONE;
}

-(void)activate_birds {
    for (Bird *i in birds) {
        i.flying = YES;
        i.fly_ct = 400;
    }
}

-(void)init_birds {
    birds = [NSMutableArray array];
    [birds retain];
    
    for(int i = 0; i < 5; i++) {
        Bird* b = [Bird node];
        b.position = ccp(float_random(-150,150),float_random(-5,5));
        b.vx = float_random(-9, 9);
        b.vy = float_random(5, 15);
        
        id _STAND_ANIM = [self init_stand_anim:float_random(0.1, 0.3)];
        id _FLY_ANIM = [self init_fly_anim:float_random(0.1, 0.3)];
        
        [b set_stand:_STAND_ANIM set_fly:_FLY_ANIM];
        if (b.vx > 0) {
            b.scaleX = -1;
        }
        [birds addObject:b];
        [self addChild:b];
    }
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(void)reset {
    [super reset];
    for (Bird *i in birds) {
        [i reset];
    }
}

-(id)init_stand_anim:(float)speed {
    CCTexture2D *tex = [Resource get_tex:TEX_BIRD_SS];
    NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"sit1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"sit2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"sit3"]]];
    return [[Common make_anim_frames:animFrames speed:speed] retain];
}

-(id)init_fly_anim:(float)speed {
    CCTexture2D *tex = [Resource get_tex:TEX_BIRD_SS];
    NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"fly1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"fly2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"fly3"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[BirdFlock bird_ss_rect_tar:@"fly4"]]];
    return [[Common make_anim_frames:animFrames speed:speed] retain];
}


#define BIRD_SS_FILENAME @"bird_ss"
NSDictionary *bird_ss_plist_dict = NULL;
+(CGRect)bird_ss_rect_tar:(NSString*)tar {
    if (bird_ss_plist_dict == NULL) {
        bird_ss_plist_dict =[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:BIRD_SS_FILENAME ofType:@"plist"]];
    }
    return [Common ssrect_from_dict:bird_ss_plist_dict tar:tar];
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end
