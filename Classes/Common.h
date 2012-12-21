#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Vec3D.h"

#define float_random(smallNumber, bigNumber) ((((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (bigNumber - smallNumber)) + smallNumber)

@interface Common : NSObject 

typedef struct HitRect {
    float x1,y1,x2,y2;
} HitRect;

typedef struct gl_render_obj {
	CCTexture2D *texture;
	CGPoint tri_pts[4];
	CGPoint tex_pts[4];
    int isalloc;
    
} gl_render_obj;

typedef struct line_seg {
    CGPoint a;
    CGPoint b;
} line_seg;

typedef struct callback {
    NSObject* target;
    SEL selector;
} callback;

typedef struct CameraZoom {
    float x;
    float y;
    float z;
} CameraZoom;

+(CGSize)SCREEN;
+(CGPoint)screen_pctwid:(float)pctwid pcthei:(float)pcthei;

+(void)run_callback:(callback)c;
+(callback)cons_callback:(NSObject*)tar sel:(SEL)sel;

+(CGPoint)line_seg_intersection_a1:(CGPoint)a1 a2:(CGPoint)a2 b1:(CGPoint)b1 b2:(CGPoint)b2;
+(CGPoint)line_seg_intersection_a:(line_seg)a b:(line_seg)b;
+(line_seg)cons_line_seg_a:(CGPoint)a b:(CGPoint)b;
+(void)print_line_seg:(line_seg)l msg:(NSString*)msg;
+(BOOL)point_fuzzy_on_line_seg:(line_seg)seg pt:(CGPoint)pt;
+(BOOL)pt_fuzzy_eq:(CGPoint)a b:(CGPoint)b;
+(BOOL)fuzzyeq_a:(float)a b:(float)b delta:(float)delta;
+(BOOL)hitrect_touch:(HitRect)r1 b:(HitRect)r2;

+(HitRect)hitrect_cons_x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2;
+(HitRect)hitrect_cons_x1:(float)x1 y1:(float)y1 wid:(float)wid hei:(float)hei;
+(CGPoint*)hitrect_get_pts:(HitRect)rect;
+(CGRect)hitrect_to_cgrect:(HitRect)rect;

+(float)shortest_dist_from_cur:(float)a1 to:(float)a2;

+(float)deg_to_rad:(float)degrees;
+(float)rad_to_deg:(float)rad;
+(float)sig:(float)n;

+(void)draw_renderobj:(gl_render_obj)obj n_vtx:(int)n_vtx;
+(void)tex_map_to_tri_loc:(gl_render_obj*)o len:(int)len;
+(gl_render_obj)init_render_obj:(CCTexture2D*)tex npts:(int)npts;

+(CGRect)ssrect_from_dict:(NSDictionary*)dict tar:(NSString*)tar;
+(id)make_anim_frames:(NSMutableArray*)animFrames speed:(float)speed;
+(CGFloat) distanceBetween: (CGPoint)point1 and: (CGPoint)point2;

+(CCMenuItem*)make_button_tex:(CCTexture2D*)tex seltex:(CCTexture2D*)seltex zscale:(float)zscale callback:(callback)cb pos:(CGPoint)pos;
+(CCLabelTTF*)cons_label_pos:(CGPoint)pos color:(ccColor3B)color fontsize:(int)fontsize str:(NSString*)str;

@end
