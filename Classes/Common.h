#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Vec3D.h"

@interface Common : NSObject {

}

typedef struct gl_render_obj {
	CCTexture2D *texture;
	CGPoint *tri_pts;
	CGPoint *tex_pts;
} gl_render_obj;

typedef struct line_seg {
    CGPoint a;
    CGPoint b;
} line_seg;

+(CGPoint)line_seg_intersection_a1:(CGPoint)a1 a2:(CGPoint)a2 b1:(CGPoint)b1 b2:(CGPoint)b2;
+(CGPoint)line_seg_intersection_a:(line_seg)a b:(line_seg)b;
+(line_seg)cons_line_seg_a:(CGPoint)a b:(CGPoint)b;
+(line_seg)double_extend_line_seg:(line_seg)seg;
+(line_seg)left_extend_line_seg:(line_seg)seg;
+(void)print_line_seg:(line_seg)l msg:(NSString*)msg;
+(BOOL)line_seg_valid:(line_seg)l;
+(BOOL)point_fuzzy_on_line_seg:(line_seg)seg pt:(CGPoint)pt;
+(BOOL)pt_fuzzy_eq:(CGPoint)a b:(CGPoint)b;
+(float)shortest_rot_dir_from_cur:(float)cur to_tar:(float)tar;

+(float)deg_to_rad:(float)degrees;
+(float)rad_to_deg:(float)rad;




@end
