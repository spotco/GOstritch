#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Common.h"

@interface Island : CCSprite {
	float startX, startY, endX, endY;
    Island* next;
    
    float fill_hei;
}


@property(readwrite,assign) float startX, startY, endX, endY, fill_hei;
@property(readwrite,assign) Island* next;

+(float) NO_VALUE;
+(int)link_islands:(NSMutableArray*)islands;

-(void)link_finish;

-(float)get_height:(float)pos;
-(line_seg)get_line_seg_a:(float)pre_x b:(float)post_x;
-(float)get_t_given_position:(CGPoint)position;
-(CGPoint)get_position_given_t:(float)t;
-(Vec3D*)get_tangent_vec;





@end
