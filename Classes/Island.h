#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Common.h"

@interface Island : CCSprite {
	float startX, startY, endX, endY;
    Island* next;
}


@property(readwrite,assign) float startX, startY, endX, endY;
@property(readwrite,assign) Island* next;

+(float) NO_VALUE;

-(float)get_height:(float)pos;
-(float)get_angle:(float)pos;
-(float)get_slope:(float)pos;

-(line_seg)get_line_seg_a:(float)pre_x b:(float)post_x;
-(float)get_t_given_position:(CGPoint)position;
-(CGPoint)get_position_given_t:(float)t;

+(int)link_islands:(NSMutableArray*)islands;
+(Vec3D*)get_tangent_vec_given_slope:(float)slope;

@end
