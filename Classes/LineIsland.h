#import "Island.h"
#import "Common.h"
#import "Vec3D.h"
#import "Resource.h"



@interface LineIsland : Island {
	float min_range, max_range,t_min,t_max,slope;
	gl_render_obj main_fill,top_fill,corner_fill,corner_top_fill;
    
    
    gl_render_obj tl_top_corner,tr_top_corner;
    
    CGPoint toppts[3];
}

@property(readwrite,assign)  float min_range, max_range, t_min, t_max,slope;
@property(readwrite,assign) gl_render_obj main_fill,top_fill,corner_fill;

+(LineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land;

-(void)init_tex;
-(void)init_top;
-(void)calculate_normal;
-(void)set_pt1:(CGPoint)start pt2:(CGPoint)end;
-(void)calc_init;



@end
