#import "Island.h"
#import "Common.h"
#import "Vec3D.h"
#import "Resource.h"



@interface LineIsland : Island {
	float min_range, max_range,slope;
	gl_render_obj main_fill;
	gl_render_obj top_fill;
	float rot;
    
    float t_min,t_max;
}

@property(readwrite,assign)  float min_range, max_range, slope, t_min, t_max;
@property(readwrite,assign) gl_render_obj main_fill;
+(LineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end;
-(void)init_tex;
-(void)init_top;
-(void)set_pt1:(CGPoint)start pt2:(CGPoint)end;
-(void)calc_init;



@end
