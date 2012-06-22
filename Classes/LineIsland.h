#import "Island.h"
#import "Common.h"


@interface LineIsland : Island {
	float min_range, max_range,slope;
	gl_render_obj main_fill;
	gl_render_obj top_fill;
	float rot;
}

@property(readwrite,assign)  float min_range, max_range, slope;
@property(readwrite,assign) gl_render_obj main_fill;
+(LineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end;


@end
