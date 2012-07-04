#import "Island.h"
#import "Common.h"
#import "Vec3D.h"
#import "Resource.h"



@interface LineIsland : Island {
	float min_range, max_range,t_min,t_max,slope;
	gl_render_obj main_fill,top_fill,corner_fill,corner_top_fill;
    
    CGPoint toppts[3];
}

@property(readwrite,assign)  float min_range, max_range, t_min, t_max,slope;
@property(readwrite,assign) gl_render_obj main_fill,top_fill,corner_fill;

+(LineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height;

-(void)init_tex;
-(void)init_top;
-(void)set_pt1:(CGPoint)start pt2:(CGPoint)end;
-(void)calc_init;



@end
