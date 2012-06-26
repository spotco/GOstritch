#import "Vec3D.h"

@implementation Vec3D

@synthesize x,y,z;

+(Vec3D*) init_x:(float)x y:(float)y z:(float)z {
    Vec3D *v = [Vec3D alloc];
    v.x = x;
    v.y = y;
    v.z = z;
    return v;
}


-(Vec3D*) add:(Vec3D*)v {
    return [Vec3D init_x:(x + v.x) y:(y+v.y) z:(z+v.z)];
}

-(Vec3D*) sub:(Vec3D*)v {
    return [Vec3D init_x:(x - v.x) y:(y-v.y) z:(z-v.z)];
}

-(Vec3D*) scale:(float)sf {
    return [Vec3D init_x:(x * sf) y:(y*sf) z:(z*sf)];
}

-(BOOL) eq:(Vec3D*)v {
    return v.x == x && v.y == y && v.z == z;
}

-(void) negate {
    x = -x;
    y = -y;
    z = -z;
}

-(double) length {
    return sqrt((x * x) + (y * y) + (z * z));
}

-(void) normalize {
    float len = [self length];
    x /= len;
    y /= len;
    z /= len;
}

-(Vec3D*) crossWith:(Vec3D*)a{
	float x1, y1, z1;
    x1 = (y*a.z) - (a.y*z);
    y1 = -((x*a.z) - (z*a.x));
    z1 = (x*a.y) - (a.x*y);
    
    return [Vec3D init_x:(x1) y:(y1) z:(z1)];
}

-(float) dotWith:(Vec3D*)a {
	return ( x * a.x ) + ( y * a.y ) + ( z * a.z );
}

-(void) print {
    NSLog(@"<%f,%f,%f>",x,y,z);
}

@end
