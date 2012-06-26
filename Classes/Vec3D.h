#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Vec3D : NSObject {
    float x,y,z;
}

@property(readwrite, assign) float x,y,z;

+(Vec3D*) init_x:(float)x y:(float)y z:(float)z;
-(Vec3D*) add:(Vec3D*)v;
-(Vec3D*) sub:(Vec3D*)v;
-(Vec3D*) scale:(float)sf;
-(BOOL) eq:(Vec3D*)v;
-(void) negate;
-(double) length;
-(void) normalize;
-(Vec3D*) crossWith:(Vec3D*)a;
-(float) dotWith:(Vec3D*)a;
-(void) print;

@end
