#import "BirdFlock.h"

@implementation BirdFlock

+(BirdFlock*)init_x:(float)x y:(float)y {
    BirdFlock* b = [BirdFlock node];
    b.position = ccp(x,y);
    [b init_anim];
    return b;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ISLAND_ORD];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
}

-(GameObjectReturnCode)update:(Player*)player g:(GameEngineLayer *)g {        
    /*if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        NSLog(@"hit!!");
    }*/
    return GameObjectReturnCode_NONE;
}

-(void)init_anim {
    _STAND_ANIM = [self init_stand_anim:0.4];
    _FLY_ANIM = [self init_fly_anim:0.1];
    [self runAction:_FLY_ANIM];
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
    [_STAND_ANIM release];
    [_FLY_ANIM release];
    [super dealloc];
}

@end
