#import "BreakableWall.h"
#import "GameEngineLayer.h"

@implementation BreakableWall

#define BASE_IMG_WID 76.0
#define BASE_IMG_HEI 17.0

#define CENTER_IMG_WID 47.0
#define CENTER_IMG_HEI 128.0

+(BreakableWall*)init_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    BreakableWall *n = [BreakableWall node];
    [n initialize_x:x y:y x2:x2 y2:y2];
    return n;
}

-(void)initialize_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    [super initialize_x:x y:y x2:x2 y2:y2];
    broken = NO;
}

-(void)hit:(Player *)player g:(GameEngineLayer *)g {
    if (player.dashing) {
        [self setActive:NO];
        broken = YES;
        
        float len = [dir_vec length];
        for(float i = 0; i < len; i+=float_random(8, 30)) {
            [g add_particle:[BreakableWallRockParticle init_x:position_.x + (i/len)*dir_vec.x
                                                            y:position_.y + (i/len)*dir_vec.y
                                                           vx:float_random(-5, 5) 
                                                           vy:float_random(-5, 5)]];
        }
        
    } else {
        [super hit:player g:g];
    }
}

-(void)reset {
    [super reset];
    broken = NO;
}

-(void)draw_o {
    [Common draw_renderobj:top n_vtx:4];
    [Common draw_renderobj:bottom n_vtx:4];
    if (broken == NO) {
        [Common draw_renderobj:center n_vtx:4];
    }
}

-(CCTexture2D*)get_base_tex {
    return [Resource get_tex:TEX_CAVE_ROCKWALL_BASE];
}

-(CCTexture2D*)get_section_tex {
    return [Resource get_tex:TEX_CAVE_ROCKWALL_SECTION];
}

-(CGSize)get_base_size {
    return CGSizeMake(BASE_IMG_WID, BASE_IMG_HEI);
}

-(CGSize)get_section_size {
    return CGSizeMake(CENTER_IMG_WID, CENTER_IMG_HEI);
}

@end