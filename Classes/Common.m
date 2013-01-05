
#import "Common.h"
#import "Island.h"


@implementation Common

NSString* strf (char* format, ... ) {
    char outp[255];
    va_list a_list;
    va_start( a_list, format );
    vsprintf(outp, format, a_list);
    va_end(a_list);
    return [NSString stringWithUTF8String:outp];
}

int SIG(float n) {
    if (n > 0) {
        return 1;
    } else if (n < 0) {
        return -1;
    } else {
        return 0;
    }
}

+(CGSize)SCREEN {
    return CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
}

+(CGPoint)screen_pctwid:(float)pctwid pcthei:(float)pcthei {
    return ccp([Common SCREEN].width*pctwid,[Common SCREEN].height*pcthei);
}

+(void)run_callback:(callback)c {
    if (c.target != NULL) {
        [c.target performSelector:c.selector];
    } else {
        NSLog(@"callback target is null");
    }
}

+(callback)cons_callback:(NSObject*)tar sel:(SEL)sel {
    struct callback cb;
    cb.target = tar;
    cb.selector = sel;
    return cb;
}

+(HitRect)hitrect_cons_x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 {
    struct HitRect n;
    n.x1 = x1;
    n.y1 = y1;
    n.x2 = x2;
    n.y2 = y2;
    return n;
}

+(HitRect)hitrect_cons_x1:(float)x1 y1:(float)y1 wid:(float)wid hei:(float)hei {
    return [Common hitrect_cons_x1:x1 y1:y1 x2:x1+wid y2:y1+hei];
}

+(CGRect)hitrect_to_cgrect:(HitRect)rect {
    return CGRectMake(rect.x1, rect.y1, rect.x2-rect.x1, rect.y2-rect.y1);
}

+(CGPoint*)hitrect_get_pts:(HitRect)rect {
    CGPoint *pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
//    pts[0] = ccp(rect.x1,rect.y1);
//    pts[1] = ccp(rect.x1+(rect.x2-rect.x1),rect.y1);
//    pts[2] = ccp(rect.x2,rect.y2);
//    pts[3] = ccp(rect.x1,rect.y1+(rect.y2-rect.y1));
    
    pts[0] = ccp(rect.x1,rect.y1);
    pts[1] = ccp(rect.x2,rect.y1);
    pts[2] = ccp(rect.x2,rect.y2);
    pts[3] = ccp(rect.x1,rect.y2);

    return pts;
    
}

+(BOOL)hitrect_touch:(HitRect)r1 b:(HitRect)r2 {
    return !(r1.x1 > r2.x2 ||
             r2.x1 > r1.x2 ||
             r1.y1 > r2.y2 ||
             r2.y1 > r1.y2);
}

+(CGPoint)line_seg_intersection_a1:(CGPoint)a1 a2:(CGPoint)a2 b1:(CGPoint)b1 b2:(CGPoint)b2 {//2 line segment intersection (seg a1,a2) (seg b1,b2)
    CGPoint null_point = CGPointMake([Island NO_VALUE], [Island NO_VALUE]);
    double Ax = a1.x; double Ay = a1.y;
	double Bx = a2.x; double By = a2.y;
	double Cx = b1.x; double Cy = b1.y;
	double Dx = b2.x; double Dy = b2.y;
	double X; double Y;
	double  distAB, theCos, theSin, newX, ABpos ;
	
	if ((Ax==Bx && Ay==By) || (Cx==Dx && Cy==Dy)) return null_point; //  Fail if either line segment is zero-length.
    
	Bx-=Ax; By-=Ay;//Translate the system so that point A is on the origin.
	Cx-=Ax; Cy-=Ay;
	Dx-=Ax; Dy-=Ay;
	
	distAB=sqrt(Bx*Bx+By*By);//Discover the length of segment A-B.
	
	theCos=Bx/distAB;//Rotate the system so that point B is on the positive X axis.
	theSin=By/distAB;
    
	newX=Cx*theCos+Cy*theSin;
	Cy  =Cy*theCos-Cx*theSin; Cx=newX;
	newX=Dx*theCos+Dy*theSin;
	Dy  =Dy*theCos-Dx*theSin; Dx=newX;
	
	if ((Cy<0. && Dy<0.) || (Cy>=0. && Dy>=0.)) return null_point;//C-D must be origin crossing line
	
	ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy);//Discover the position of the intersection point along line A-B.
	
    
	if (ABpos<0. || /*ABpos>distAB*/ fm_a_gt_b(ABpos, distAB, 0.001)) {
        return null_point;//  Fail if segment C-D crosses line A-B outside of segment A-B.
	}
        
	X=Ax+ABpos*theCos;//Apply the discovered position to line A-B in the original coordinate system.
	Y=Ay+ABpos*theSin;
	
	return ccp(X,Y);
}
/*
 line_seg player_mov = [Common cons_line_seg_a:ccp(0,0) b:ccp(0,1)];
 line_seg a1 = [Common cons_line_seg_a:ccp(-1,0) b:ccp(0,0)];
 line_seg a2 = [Common cons_line_seg_a:ccp(1,0) b:ccp(0,0)];
 CGPoint i1 = [Common line_seg_intersection_a:player_mov b:a1];
 CGPoint i2 = [Common line_seg_intersection_a:player_mov b:a2];
 NSLog(@"a1:(%f,%f) a2:(%f,%f)",i1.x,i1.y,i2.x,i2.y);
 */

bool fm_a_gt_b(double a,double b,double delta) {
    return a-b > delta;
}

+(CGPoint)line_seg_intersection_a:(line_seg)a b:(line_seg)b {
    return [Common line_seg_intersection_a1:a.a a2:a.b b1:b.a b2:b.b];
}

+(line_seg)cons_line_seg_a:(CGPoint)a b:(CGPoint)b {
    struct line_seg new;
    new.a = a;
    new.b = b;
    return new;
}

+(BOOL)point_fuzzy_on_line_seg:(line_seg)seg pt:(CGPoint)pt {
    Vec3D *b_m_a = [Vec3D init_x:seg.b.x-seg.a.x y:seg.b.y-seg.a.y z:0];
    Vec3D *c_m_a = [Vec3D init_x:pt.x-seg.a.x y:pt.y-seg.a.y z:0];
    Vec3D *ab_c_ac = [b_m_a crossWith:c_m_a];
    
    float val = [ab_c_ac length] / [b_m_a length];
    [b_m_a dealloc];
    [c_m_a dealloc];
    [ab_c_ac dealloc];
    if (val <= 0.1) {
        return YES;
    } else {
        return NO;
    }
}

+(void)print_hitrect:(HitRect)l msg:(NSString*)msg {
    NSLog(@"%@ line segment (%f,%f) to (%f,%f)",msg,l.x1,l.y1,l.x2,l.y2);
}
+(NSString*)hitrect_to_string:(HitRect)r {
    return NSStringFromCGRect([Common hitrect_to_cgrect:r]);
}

+(void)print_line_seg:(line_seg)l msg:(NSString*)msg {
    NSLog(@"%@ line segment (%f,%f) to (%f,%f)",msg,l.a.x,l.a.y,l.b.x,l.b.y);
}

+(BOOL)pt_fuzzy_eq:(CGPoint)a b:(CGPoint)b {
    return [Common fuzzyeq_a:a.x b:b.x delta:0.1] && [Common fuzzyeq_a:a.y b:b.y delta:0.1]; //return ABS(a.x-b.x) <= 0.1 && ABS(a.y-b.y) <= 0.1;
}

+(BOOL)fuzzyeq_a:(float)a b:(float)b delta:(float)delta {
    return ABS(a-b) <= delta;
}

+(float)deg_to_rad:(float)degrees {
    return degrees * M_PI / 180.0;
}

+(float)rad_to_deg:(float)rad {
    return rad * 180.0 / M_PI;
}

+(float)shortest_dist_from_cur:(float)a1 to:(float)a2 {
    a1 = [Common deg_to_rad:a1];
    a2 = [Common deg_to_rad:a2];
    float res = atan2f(cosf(a1)*sinf(a2)-sinf(a1)*cosf(a2),
                       sinf(a1)*sinf(a2)+cosf(a1)*cosf(a2));
    
    res = [Common rad_to_deg:res];
    return res;
}

+(float)sig:(float)n {
    if (n > 0) {
        return 1;
    } else if (n < 0) {
        return -1;
    } else {
        return 0;
    }
}

+(gl_render_obj)init_render_obj:(CCTexture2D*)tex npts:(int)npts {
    struct gl_render_obj n;
    n.texture = tex;
    n.isalloc = 1;
    n.pts = npts;
    return n;
}

+(void)draw_renderobj:(gl_render_obj)obj n_vtx:(int)n_vtx {
    glBindTexture(GL_TEXTURE_2D, obj.texture.name);
	glVertexPointer(2, GL_FLOAT, 0, obj.tri_pts); 
	glTexCoordPointer(2, GL_FLOAT, 0, obj.tex_pts);
    
    if (n_vtx == 4) {
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    } else {
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
}

+(void)tex_map_to_tri_loc:(gl_render_obj*)o len:(int)len {
    for (int i = 0; i < len; i++) {
        o->tex_pts[i] = ccp(o->tri_pts[i].x/o->texture.pixelsWide, o->tri_pts[i].y/o->texture.pixelsHigh);
    }
}

+(CGRect)ssrect_from_dict:(NSDictionary*)dict tar:(NSString*)tar {    
    NSDictionary *frames_dict = [dict objectForKey:@"frames"];
    NSDictionary *obj_info = [frames_dict objectForKey:tar];
    NSString *txt = [obj_info objectForKey:@"textureRect"];
    CGRect r = CGRectFromString(txt);
    return r;
}

+(CCAction*)make_anim_frames:(NSMutableArray*)animFrames speed:(float)speed {
	id animate = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:YES];
    id m = [CCRepeatForever actionWithAction:animate];
	return m;
}

+(CGFloat) distanceBetween: (CGPoint)point1 and: (CGPoint)point2 {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
}

+(CCMenuItem*)make_button_tex:(CCTexture2D*)tex seltex:(CCTexture2D*)seltex zscale:(float)zscale callback:(callback)cb pos:(CGPoint)pos {
    CCSprite *img = [CCSprite spriteWithTexture:tex];
    CCSprite *img_zoom = [CCSprite spriteWithTexture:seltex];
    [Common set_zoom_pos_align:img zoomed:img_zoom scale:zscale];
    CCMenuItem* i = [CCMenuItemImage itemFromNormalSprite:img selectedSprite:img_zoom target:cb.target selector:cb.selector];
    [i setPosition:pos];
    return i;
}

+(void)set_zoom_pos_align:(CCSprite*)normal zoomed:(CCSprite*)zoomed scale:(float)scale {
    zoomed.scale = scale;
    zoomed.position = ccp((-[zoomed contentSize].width * zoomed.scale + [zoomed contentSize].width)/2
                          ,(-[zoomed contentSize].height * zoomed.scale + [zoomed contentSize].height)/2);
}

+(CCLabelTTF*)cons_label_pos:(CGPoint)pos color:(ccColor3B)color fontsize:(int)fontsize str:(NSString*)str {
    CCLabelTTF *l = [CCLabelTTF labelWithString:str fontName:@"Carton Six" fontSize:fontsize];
    [l setColor:color];
    [l setPosition:pos];
    return l;
}

CGPoint CGPointAdd(CGPoint p1, CGPoint p2){
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

+(gl_render_obj)transform_obj:(gl_render_obj)o by:(CGPoint)position {
    o.tri_pts[0] = CGPointAdd(position, o.tri_pts[0]);
    o.tri_pts[1] = CGPointAdd(position, o.tri_pts[1]);
    o.tri_pts[2] = CGPointAdd(position, o.tri_pts[2]);
    o.tri_pts[3] = CGPointAdd(position, o.tri_pts[3]);
    return o;
}

+(CameraZoom)cons_normalcoord_camera_zoom_x:(float)x y:(float)y z:(float)z {
    struct CameraZoom c = {x,y,z};
    [Common normal_to_gl_coord:&c];
    return c;
}

+(void)normal_to_gl_coord:(CameraZoom*)glzd {
    //data:(280,230,50),(360,270,130),(600,410,400)
    float gwid = 0.907*(glzd->z)+237.819;
    float ghei = 0.515*(glzd->z)+203.696;
    gwid*=2;
    ghei*=2;
    
    float escrwid = 480.0;
    float escrhei = 320.0;
    
    float outx = (escrwid/2 - glzd->x)*(ghei/escrhei);
    float outy = (escrhei/2 - glzd->y)*(ghei/escrhei);
    
    glzd->x = outx;
    glzd->y = outy;
}




@end
