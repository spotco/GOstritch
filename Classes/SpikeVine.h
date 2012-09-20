#import "GameObject.h"
#import "PolyLib.h"
#import "HitEffect.h"

@interface SpikeVine  : GameObject {
    Vec3D *dir_vec;
    gl_render_obj top,bottom,center;
    SATPoly r_hitbox;
}

+(SpikeVine*)init_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2;

-(CCTexture2D*)get_base_tex;
-(CCTexture2D*)get_section_tex;
-(CGSize)get_base_size;
-(CGSize)get_section_size;

-(void)hit:(Player *)player g:(GameEngineLayer *)g;
-(void)draw_o;

-(void)initialize_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2;
-(void)initialize_img;

@end
