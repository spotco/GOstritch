#import "GameObject.h"
#import "cocos2d.h"
#import "Resource.h"

@interface Coin : GameObject {
    BOOL anim_toggle;
    int bid;
}

typedef enum {
    Coin_Status_TOGET, //to get
    Coin_Status_HASGET, //gotten, no checkpoint yet
    Coin_Status_SAVEDGET, //gotten, then checkpoint
    Coin_Status_ALREADYGET //already gotten
} Coin_Status;

+(Coin*)init_x:(float)x y:(float)y bid:(int)bid;

@property(readwrite,assign) int bid;

@end
