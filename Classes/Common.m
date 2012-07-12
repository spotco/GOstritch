
#import "Common.h"
#import "Island.h"


@implementation Common

+(CGPoint)line_seg_intersection_a1:(CGPoint)a1 a2:(CGPoint)a2 b1:(CGPoint)b1 b2:(CGPoint)b2 {//2 line segment intersection (seg a1,a2) (seg b1,b2)
    CGPoint null_point = CGPointMake([Island NO_VALUE], [Island NO_VALUE]);
    double Ax = a1.x; double Ay = a1.y;
	double Bx = a2.x; double By = a2.y;
	double Cx = b1.x; double Cy = b1.y;
	double Dx = b2.x; double Dy = b2.y;
	double X; double Y;
	double  distAB, theCos, theSin, newX, ABpos ;
	
	if ((Ax==Bx && Ay==By) || (Cx==Dx && Cy==Dy)) return null_point; //  Fail if either line segment is zero-length.
	if ((Ax==Cx && Ay==Cy) || (Bx==Cx && By==Cy) ||  (Ax==Dx && Ay==Dy) || (Bx==Dx && By==Dy)) return null_point; //  Fail if the segments share an end-point.
	
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
	
	if ((Cy<0. && Dy<0.) || (Cy>=0. && Dy>=0.)) return null_point;//  Fail if segment C-D doesn't cross line A-B.
	
	ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy);//Discover the position of the intersection point along line A-B.
	
	if (ABpos<0. || ABpos>distAB) return null_point;//  Fail if segment C-D crosses line A-B outside of segment A-B.
	
	X=Ax+ABpos*theCos;//Apply the discovered position to line A-B in the original coordinate system.
	Y=Ay+ABpos*theSin;
	
	return ccp(X,Y);//  Success.
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

+(line_seg)double_extend_line_seg:(line_seg)seg {
    Vec3D *dir_vec = [Vec3D init_x:seg.b.x-seg.a.x y:seg.b.y-seg.a.y z:0];
    line_seg new = [Common cons_line_seg_a:seg.a b:seg.b];
    new.b.x += dir_vec.x;
    new.b.y += dir_vec.y;
    
    [dir_vec negate];
    
    new.a.x += dir_vec.x;
    new.a.y += dir_vec.y;
    [dir_vec dealloc];
    
    return new;
}

+(line_seg)left_extend_line_seg:(line_seg)seg {
    Vec3D *dir_vec = [Vec3D init_x:seg.b.x-seg.a.x y:seg.b.y-seg.a.y z:0];
    line_seg new = [Common cons_line_seg_a:seg.a b:seg.b];
    
    [dir_vec negate];
    
    new.a.x += dir_vec.x;
    new.a.y += dir_vec.y;
    [dir_vec dealloc];
    
    return new;
}

+(BOOL)point_fuzzy_on_line_seg:(line_seg)seg pt:(CGPoint)pt {
    Vec3D *b_m_a = [Vec3D init_x:seg.b.x-seg.a.x y:seg.b.y-seg.a.y z:0];
    Vec3D *c_m_a = [Vec3D init_x:pt.x-seg.a.x y:pt.y-seg.a.y z:0];
    Vec3D *ab_c_ac = [b_m_a crossWith:c_m_a];
    
    float val = [ab_c_ac length] / [b_m_a length];
    if (val <= 0.1) {
        return YES;
    } else {
        return NO;
    }
}

+(void)print_line_seg:(line_seg)l msg:(NSString*)msg {
    NSLog(@"%@ line segment (%f,%f) to (%f,%f)",msg,l.a.x,l.a.y,l.b.x,l.b.y);
}

+(BOOL)pt_fuzzy_eq:(CGPoint)a b:(CGPoint)b {
    return ABS(a.x-b.x) <= 0.1 && ABS(a.y-b.y) <= 0.1;
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




@end
