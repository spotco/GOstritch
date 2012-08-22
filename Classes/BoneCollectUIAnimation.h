#import "UIIngameAnimation.h"
#import "Resource.h"

@interface BoneCollectUIAnimation : UIIngameAnimation {
    CGPoint start,end;
}

+(BoneCollectUIAnimation*)init_start:(CGPoint)start end:(CGPoint)end;

@end
