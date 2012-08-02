#import "CCSprite.h"
#import "cocos2d.h"
#import "Resource.h"
#import "Common.h"

@interface FishGenerator : CCSprite {
    float bwidth;
    NSMutableArray *fishes;
}

+(FishGenerator*)init_ofwidth:(float)wid;
-(void)update;

@end
