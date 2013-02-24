#import "GroundDetail.h"
#import "GameEngineLayer.h"

@implementation GroundDetail
@synthesize imgtype;

+(GroundDetail*)cons_x:(float)posx y:(float)posy type:(int)type islands:(NSMutableArray *)islands{
    GroundDetail *d = [GroundDetail node];
    d.position = ccp(posx,posy);
    CCTexture2D *texture; 
    d.imgtype = type;
    if (type == 1) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_1];
    } else if (type == 2) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_2];
    } else if (type == 3) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_3];
    } else if (type == 4) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_4];
    } else if (type == 5) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_5];
    } else if (type == 6) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_6];
    } else if (type == 7) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_7];
    } else if (type == 8) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_8];
    } else if (type == 9) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_9];
    } else {
        NSLog(@"GroundDetail init type error");
    }
    d.img = [CCSprite spriteWithTexture:texture];
    d.img.position = ccp(0,[d.img boundingBoxInPixels].size.height / 2.0);
    [d addChild:d.img];
    [d attach_toisland:islands];
    return d;
}

-(int)get_render_ord {
    if (imgtype == 9) {
        return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
    } else {
        return [super get_render_ord];
    }
}

-(void)check_should_render:(GameEngineLayer *)g {
    if ([Common hitrect_touch:[g get_viewbox] b:[self get_hit_rect]]) {
        do_render = YES;
    } else {
        do_render = NO;
    }
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:position_.x y1:position_.y wid:1 hei:1];
}

-(void)attach_toisland:(NSMutableArray*)islands {
    Island* i = [self get_connecting_island:islands];
    if (i != NULL) {
        Vec3D *tangent_vec = [i get_tangent_vec];
        [tangent_vec scale:[i ndir]];
        float tar_rad = -[tangent_vec get_angle_in_rad];
        float tar_deg = [Common rad_to_deg:tar_rad];
        img.rotation = tar_deg;
        
        [tangent_vec normalize];
        Vec3D *normal_vec = [[Vec3D Z_VEC] crossWith:tangent_vec];
        
        if (imgtype == 9) {
            [normal_vec scale:-8];
            [self setPosition:[normal_vec transform_pt:position_]];
        }
        
        [tangent_vec dealloc];
        [normal_vec dealloc];
    }
}


@end
