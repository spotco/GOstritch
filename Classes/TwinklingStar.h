#import "CCSprite.h"

@interface TwinklingStar : CCSprite{
    int maxOpacity;
    int minOpacity;
    int opacitySpeed;
    
    BOOL opacityIncreasing;
}

@property(readwrite, assign) int maxOpacity;
@property(readwrite, assign) int opacitySpeed;
@property(readwrite, assign) int minOpacity;
@property(readwrite, assign) BOOL opacityIncreasing;
    
@end
