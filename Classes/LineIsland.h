#import "Island.h"
#import "Common.h"
#import "Vec3D.h"
#import "Resource.h"



@interface LineIsland : Island {
    BOOL do_draw;
	gl_render_obj main_fill,top_fill,corner_fill,corner_top_fill;
    gl_render_obj tl_top_corner,tr_top_corner;
    gl_render_obj bottom_line_fill,corner_line_fill,left_line_fill,right_line_fill;
    CGPoint toppts[3];
    
    CGPoint tl,bl,tr,br;
    CGPoint bl1,bl2,br1,br2;
}

@property(readwrite,assign) CGPoint tl,bl,tr,br,bl1,bl2,br1,br2;

+(LineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land;


-(void)set_pt1:(CGPoint)start pt2:(CGPoint)end;
-(void)calc_init;
-(void)init_tex;
-(void)init_top;

-(CCTexture2D*)get_tex_fill;
-(CCTexture2D*)get_tex_corner;
-(CCTexture2D*)get_tex_border;
-(CCTexture2D*)get_tex_top;
-(ccColor4F)get_corner_fill_color;





@end
