#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Island : CCSprite {
	float startX, startY, endX, endY;
}

@property(readwrite,assign)  float startX, startY, endX, endY;

-(float)get_height:(float)pos;
-(float)get_angle:(float)pos;


@end
