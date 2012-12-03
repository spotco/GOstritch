#import "GameObject.h"
#import "cocos2d.h"
#import "Resource.h"

@interface DogBone : GameObject {
    BOOL anim_toggle;
    int bid;
    
    BOOL refresh_cached_hitbox;
    HitRect cached_hitbox;
    
    float vx,vy;
    BOOL follow;
    CGPoint initial_pos;
    
}

typedef enum {
    Bone_Status_TOGET, //to get
    Bone_Status_HASGET, //gotten, no checkpoint yet
    Bone_Status_SAVEDGET, //gotten, then checkpoint
    Bone_Status_ALREADYGET //already gotten
} Bone_Status;

+(DogBone*)init_x:(float)x y:(float)y bid:(int)bid;

@property(readwrite,assign) int bid;

@end
