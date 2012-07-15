#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Common.h"

@class Island;
@interface Island : CCSprite {
	float startX, startY, endX, endY, ndir;
    BOOL can_land;
    Island* next;
    
    float fill_hei;
    Vec3D* normal_vec;
}


@property(readwrite,assign) float startX, startY, endX, endY, fill_hei, ndir;
@property(readwrite,assign) Island* next;
@property(readwrite,assign) Vec3D* normal_vec;
@property(readwrite,assign) BOOL can_land;

+(float) NO_VALUE;
+(int)link_islands:(NSMutableArray*)islands;

-(void)link_finish;

-(float)get_height:(float)pos;
-(line_seg)get_line_seg_a:(float)pre_x b:(float)post_x;
-(float)get_t_given_position:(CGPoint)position;
-(CGPoint)get_position_given_t:(float)t;
-(Vec3D*)get_tangent_vec;





@end
